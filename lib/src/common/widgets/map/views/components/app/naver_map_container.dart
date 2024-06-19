import 'dart:developer';

import 'package:client/src/common/widgets/bottom_drawer/providers/bottom_drawer_provider.dart';
import 'package:client/src/common/widgets/map/providers/naver_map_providers.dart';
import 'package:client/src/common/widgets/map/services/naver_map_service.dart';
import 'package:client/src/config/constants.dart';

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NaverMapContainer extends ConsumerStatefulWidget {
  const NaverMapContainer({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NaverMapContainerState();
}

class _NaverMapContainerState extends ConsumerState<NaverMapContainer> {
  @override
  Widget build(BuildContext context) {
    final initialization = ref.watch(naverMapInitializationProvider);
    final currentLocation = ref.watch(currentLocationProvider);
    final drawerNotifier = ref.read(bottomDrawerProvider.notifier);

    return initialization.when(
      data: (_) {
        return currentLocation.when(
          data: (position) {
            final initialPosition = position != null
                ? NLatLng(position.latitude, position.longitude)
                : MapConstants.defaultLatLng;
            return FutureBuilder<
                Map<String, Set<NAddableOverlay<NOverlay<void>>>>>(
              future: loadShuttleData(context, ref),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else {
                  final stations = snapshot.data!['stations'];
                  final routes = snapshot.data!['routes'];

                  return NaverMap(
                    forceGesture: true,
                    options: NaverMapViewOptions(
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
                      logoAlign: NLogoAlign.rightBottom,
                      logoMargin: NEdgeInsets.fromEdgeInsets(
                        const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 30),
                      ),
                      locale: const Locale('ko'),
                    ),
                    onMapReady: (controller) {
                      log('current location $currentLocation');
                      log("onMapReady", name: "onMapReady");
                      controller.addOverlayAll(stations!);
                      controller.addOverlayAll(routes!);
                    },
                    onMapTapped: (point, latLng) {
                      log("map tapped");
                      if (drawerNotifier.isDrawerOpen) {
                        drawerNotifier.closeDrawer();
                      }
                    },
                  );
                }
              },
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stack) => Center(
            child: Text('Error: $error'),
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ), // 초기화 중 로딩 표시
      error: (error, stack) => Center(
        child: Text('Error: $error'),
      ),
    );
  }
}
