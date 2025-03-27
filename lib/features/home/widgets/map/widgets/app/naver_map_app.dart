import 'dart:developer';

import 'package:client/core/constants/constants.dart';
import 'package:client/features/home/widgets/bottom_drawer/providers/bottom_drawer_provider.dart';
import 'package:client/features/home/widgets/bottom_drawer/view_models/bottom_drawer_view_model.dart';
import 'package:client/data/providers/route_providers.dart';
import 'package:client/data/providers/station_providers.dart';
import 'package:client/features/home/widgets/map/providers/naver_map_providers.dart';

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

class NaverMapWidget extends ConsumerStatefulWidget {
  const NaverMapWidget({super.key});

  @override
  ConsumerState<NaverMapWidget> createState() => _NaverMapWidgetState();
}

class _NaverMapWidgetState extends ConsumerState<NaverMapWidget> {
  NaverMapController? _controller;

  @override
  Widget build(BuildContext context) {
    final initialization = ref.watch(naverMapInitializationProvider);
    final currentLocation = ref.watch(currentLocationProvider);
    final drawerNotifier = ref.watch(bottomDrawerProvider.notifier);

    return initialization.when(
      data: (_) => _buildCurrentLocationMap(currentLocation, drawerNotifier),
      loading: () => const LoadingIndicator(),
      error: (error, stack) => ErrorIndicator(error: error),
    );
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
      forceGesture: true,
      options: _buildMapOptions(initialPosition),
      onMapReady: (controller) async {
        log('current location $position');
        log("onMapReady", name: "onMapReady");
        _controller = controller;

        try {
          final routesData =
              await ref.read(RouteProviders.routesDataProvider.future);
          final stationsData =
              await ref.read(StationProviders.stationDataProvider.future);

          if (routesData.isEmpty) {
            throw Exception("No route data available");
          }

          final mapViewModel = ref.read(naverMapViewModelProvider.notifier);
          // 지도 초기화 및 오버레이 생성
          mapViewModel.initializeMap(
            controller,
            routesData,
            stationsData,
            drawerNotifier,
          );
          // 생성된 오버레이 추가
          final overlays = mapViewModel.getAllOverlays();
          controller.addOverlayAll(overlays);
        } catch (e) {
          // 에러 처리
          log('데이터 로딩 오류: $e');
          // TODO : 사용자에게 오류 알림
        }
      },
      onMapTapped: (point, latLng) {
        _handleMapTap(drawerNotifier);
      },
      onCameraChange: (reason, isAnimated) {
        final mapViewModel = ref.read(naverMapViewModelProvider.notifier);
        mapViewModel.updateZoomLevel(_controller?.nowCameraPosition.zoom ?? 0);
      },
      // onSymbolTapped: (symbol) => log('symbol tapped ${symbol.caption}'),
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
      indoorEnable: true,
      scaleBarEnable: false,
      locationButtonEnable: true,
      consumeSymbolTapEvents: false,
      locale: const Locale('ko'),
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
