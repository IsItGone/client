import 'dart:developer';

import 'package:client/src/common/widgets/bottom_drawer/providers/bottom_drawer_provider.dart';
import 'package:client/src/common/widgets/bottom_drawer/view_models/bottom_drawer_view_model.dart';
import 'package:client/src/common/widgets/map/data/models/route_model.dart';
import 'package:client/src/common/widgets/map/data/models/station_model.dart';
import 'package:client/src/common/widgets/map/data/repositories/map_repository.dart';
import 'package:client/src/common/widgets/map/providers/naver_map_providers.dart';
import 'package:client/src/common/widgets/map/view_models/naver_map_view_model.dart';
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
        List<RouteModel> routesData = await loadAllRoutes();
        // TODO:
        List<StationModel> stationsData = await loadAllStations();

        if (routesData.isEmpty) {
          throw Exception("No route data available");
        }

        final data = ShuttleDataLoader.loadShuttleData(
          ref,
          _controller,
          routesData,
          stationsData,
        );
        controller.addOverlayAll(data['stations'] ?? <NAddableOverlay>{});
        controller.addOverlayAll(data['routes'] ?? <NAddableOverlay>{});
      },
      onMapTapped: (point, latLng) {
        _handleMapTap(drawerNotifier);
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

    log('all routes : ${ShuttleDataLoader.allRoutesOverlay}');
    log('all stations : ${ShuttleDataLoader.allStationsOverlay}');
    if (drawerNotifier.isDrawerOpen) {
      drawerNotifier.closeDrawer();

      for (var overlay in ShuttleDataLoader.allRoutesOverlay) {
        overlay.setIsVisible(true);
      }
    }
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
