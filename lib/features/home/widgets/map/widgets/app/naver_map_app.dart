import 'dart:developer';
import 'dart:io';

import 'package:client/core/constants/constants.dart';
import 'package:client/data/models/route_model.dart';
import 'package:client/data/models/station_model.dart';
import 'package:client/features/home/widgets/bottom_drawer/providers/bottom_drawer_provider.dart';
import 'package:client/features/home/widgets/bottom_drawer/view_models/bottom_drawer_view_model.dart';
import 'package:client/features/home/widgets/map/providers/naver_map_providers.dart';

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

class NaverMapWidget extends ConsumerStatefulWidget {
  final List<RouteModel> routes;
  final List<StationModel> stations;

  const NaverMapWidget({
    super.key,
    required this.routes,
    required this.stations,
  });

  @override
  ConsumerState<NaverMapWidget> createState() => _NaverMapWidgetState();
}

class _NaverMapWidgetState extends ConsumerState<NaverMapWidget> {
  NaverMapController? _controller;
  bool _isMapInitialized = false;

  @override
  Widget build(BuildContext context) {
    final initialization = ref.watch(naverMapInitializationProvider);
    final currentLocation = ref.watch(currentLocationProvider);
    final drawerNotifier = ref.read(bottomDrawerProvider.notifier);

    return initialization.when(
      data: (_) => _buildCurrentLocationMap(currentLocation, drawerNotifier),
      loading: () => const LoadingIndicator(),
      error: (error, stack) => ErrorIndicator(error: error),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Widget _buildCurrentLocationMap(
    AsyncValue<Position?> currentLocation,
    BottomDrawerViewModel drawerNotifier,
  ) {
    return currentLocation.when(
      data: (position) => _buildMap(position, drawerNotifier),
      loading: () => const LoadingIndicator(),
      error: (error, stack) => ErrorIndicator(error: error),
    );
  }

  Widget _buildMap(Position? position, BottomDrawerViewModel drawerNotifier) {
    final initialPosition = position != null
        ? NLatLng(position.latitude, position.longitude)
        : MapConstants.defaultLatLng;

    return NaverMap(
      forceHybridComposition: Platform.isAndroid,
      forceGesture: true,
      options: _buildMapOptions(initialPosition),
      onMapReady: (controller) async {
        _controller = controller;

        if (_isMapInitialized) return;
        _isMapInitialized = true;

        // 혹시 초기화가 아직이면 여기서 보장
        await ref.read(naverMapInitializationProvider.future);

        try {
          final mapViewModel = ref.read(naverMapViewModelProvider.notifier);
          final overlays = mapViewModel.initializeMap(
            controller,
            widget.routes,
            widget.stations,
            drawerNotifier,
          );
          controller.addOverlayAll(overlays);
        } catch (e) {
          log('데이터 로딩 오류: $e');

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('지도 데이터 로딩 중 오류가 발생했습니다: $e')),
            );
          }
        }
      },
      onMapTapped: (point, latLng) {
        _handleMapTap(drawerNotifier);
      },
      onCameraIdle: () => {
        ref
            .read(naverMapViewModelProvider.notifier)
            .updateZoomLevel(_controller?.nowCameraPosition.zoom ?? 0)
      },
    );
  }

  NaverMapViewOptions _buildMapOptions(NLatLng initialPosition) {
    return NaverMapViewOptions(
      initialCameraPosition: NCameraPosition(
        target: initialPosition,
        zoom: 17,
        bearing: 0,
        tilt: 0,
      ),
      extent: NLatLngBounds(
        southWest: NLatLng(36.18, 127.25),
        northEast: NLatLng(36.50, 127.56),
      ),
      logoAlign: NLogoAlign.leftBottom,
      logoMargin: const EdgeInsets.only(bottom: 10, left: 10),
      scaleBarEnable: false,
      indoorLevelPickerEnable: false,
      locationButtonEnable: true,
      consumeSymbolTapEvents: false,
      locale: const Locale('ko'),
      minZoom: 10,
      maxZoom: 19,
    );
  }

  void _handleMapTap(BottomDrawerViewModel drawerNotifier) {
    log("map tapped");

    if (drawerNotifier.isDrawerOpen) {
      drawerNotifier.closeDrawer();
    }
    ref.read(naverMapViewModelProvider.notifier).resetSelection();
  }
}

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

class ErrorIndicator extends StatelessWidget {
  final Object error;

  const ErrorIndicator({required this.error, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Error: $error'),
    );
  }
}
