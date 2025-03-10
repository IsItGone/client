import 'dart:developer';

import 'package:client/src/common/widgets/bottom_drawer/providers/bottom_drawer_provider.dart';
import 'package:client/src/common/widgets/bottom_drawer/view_models/bottom_drawer_view_model.dart';
import 'package:client/src/common/widgets/map/providers/data_provider.dart';
import 'package:client/src/common/widgets/map/providers/naver_map_providers.dart';
import 'package:client/src/config/constants.dart';

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

class NaverMapWidget extends ConsumerStatefulWidget {
  const NaverMapWidget({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NaverMapWidgetState();
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

        final routesData = await ref.read(routeDataProvider.future);
        final stationsData = await ref.read(stationDataProvider.future);

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

        // final data = ShuttleDataLoader.loadShuttleData(
        //   ref,
        //   _controller,
        //   routesData,
        //   stationsData,
        // );
        // controller.addOverlayAll(data['stations'] ?? <NAddableOverlay>{});
        // controller.addOverlayAll(data['routes'] ?? <NAddableOverlay>{});
      },
      onMapTapped: (point, latLng) {
        _handleMapTap(drawerNotifier);
      },
      onCameraChange: (reason, isAnimated) {
        // 줌 레벨 변경 처리를 ViewModel로 위임
        final mapViewModel = ref.read(naverMapViewModelProvider.notifier);
        mapViewModel.updateZoomLevel(_controller?.nowCameraPosition.zoom ?? 0);
        // ShuttleDataLoader.handleZoomLevelChange();
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
