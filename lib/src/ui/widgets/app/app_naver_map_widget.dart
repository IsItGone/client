import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:client/src/data/services/naver_map_service.dart';
// import 'package:geolocator/geolocator.dart';

final naverMapServiceProvider = Provider((ref) => NaverMapService());

final naverMapInitializationProvider = FutureProvider<void>((ref) async {
  final naverMapService = ref.read(naverMapServiceProvider);
  await naverMapService.initialize();
});

// final currentLocationProvider = FutureProvider<Position>((ref) async {
//   final naverMapService = ref.read(naverMapServiceProvider);
//   return await naverMapService.getCurrentLocation();
// });

class NaverMapWidget extends ConsumerWidget {
  const NaverMapWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initialization = ref.watch(naverMapInitializationProvider);
    // final currentLocation = ref.watch(currentLocationProvider);

    return initialization.when(
      data: (_) {
        // return currentLocation.when(
        //   data: (position) {
        return NaverMap(
            options: const NaverMapViewOptions(
              initialCameraPosition: NCameraPosition(
                  target: NLatLng(36.3553177, 127.2981911), // 대전 삼성화재 연수원
                  zoom: 10,
                  bearing: 0,
                  tilt: 0),
              indoorEnable: true,
              locationButtonEnable: false,
              consumeSymbolTapEvents: false,
              locale: Locale('ko', 'KR'),
            ),
            onMapReady: (controller) {
              // log('current location $currentLocation');
              log("onMapReady", name: "onMapReady");
            });
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Text('Error: $error'),
      ),
    );
    // },
    // loading: () => const Center(
    //   child: CircularProgressIndicator(),
    // ), // 초기화 중 로딩 표시
    // error: (error, stack) => Center(
    //   child: Text('Error: $error'),
    // ),
    // )
  }
}
