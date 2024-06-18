import 'dart:developer';

import 'package:client/src/providers/naver_map_providers.dart';
import 'package:client/src/ui/features/map/widgets/app/naver_map_app.dart';
import 'package:client/src/utils/constants/constants.dart';

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

    return initialization.when(
      data: (_) {
        return currentLocation.when(
          data: (position) {
            final initialPosition = position != null
                ? NLatLng(position.latitude, position.longitude)
                : MapConstants.defaultLatLng;
            return FutureBuilder<Set<NAddableOverlay<NOverlay<void>>>>(
              future: loadMarkers(context, ref),
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
                  final markers = snapshot.data!;

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
                      controller.addOverlayAll(markers);
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

// station mock data
Future<Set<NAddableOverlay<NOverlay<void>>>> loadMarkers(
    BuildContext context, WidgetRef ref) async {
  const iconImage =
      NOverlayImage.fromAssetImage('assets/icons/bus_station_icon.png');
  final markers = {
    NMarker(
      // 유성온천역 맥도날드
      id: '1',
      position: const NLatLng(36.35438082628037, 127.3404049873352),
      icon: iconImage,
    ),
    NMarker(
      // 유성 문화원
      id: '2',
      position: const NLatLng(36.359810556432436, 127.34099453020005),
      icon: iconImage,
    ),
    NMarker(
      // 현충원역
      id: '3',
      position: const NLatLng(36.35954771869189, 127.32119718761012),
      icon: iconImage,
    ),
  };

  for (var marker in markers) {
    marker.setOnTapListener((NMarker marker) {
      log("마커가 터치되었습니다. id: ${marker.info.id}");
      // ref.read(drawerProvider).toggleDrawer();
      ref.read(drawerStateProvider).toggleDrawer();
    });
  }

  return markers;
}
