import 'dart:developer';

import 'package:client/src/common/widgets/bottom_drawer/providers/bottom_drawer_provider.dart';
import 'package:client/src/common/widgets/map/services/naver_map_service.dart';
import 'package:client/src/common/widgets/map/services/overlay_service.dart';
import 'package:client/src/common/widgets/map/view_models/naver_map_view_model.dart';
import 'package:client/src/common/widgets/map/models/map_state.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

final naverMapClientIdProvider = Provider<String>((ref) {
  const naverMapClientId = String.fromEnvironment('NAVER_MAP_CLIENT_ID');
  log('naver map client id : $naverMapClientId');
  return naverMapClientId;
});

final naverMapServiceProvider = Provider((ref) => NaverMapService());

final naverMapInitializationProvider = FutureProvider<void>((ref) async {
  final naverMapService = ref.read(naverMapServiceProvider);
  await naverMapService.initialize();
});

final currentLocationProvider = FutureProvider<Position?>((ref) async {
  final naverMapService = ref.read(naverMapServiceProvider);
  return await naverMapService.getCurrentLocation();
});

final overlayServiceProvider = Provider((ref) {
  final overlayService = OverlayService(
    routePatternImage:
        NOverlayImage.fromAssetImage('assets/icons/chevron_up.png'),
    stationMarkerImage:
        NOverlayImage.fromAssetImage('assets/icons/bus_station_icon.png'),
  );
  return overlayService;
});

final naverMapViewModelProvider =
    StateNotifierProvider<NaverMapViewModel, MapState>((ref) {
  final drawerNotifier = ref.watch(bottomDrawerProvider.notifier);
  final overlayService = ref.watch(overlayServiceProvider);

  // ViewModel 생성
  final viewModel = NaverMapViewModel(
    drawerNotifier,
    overlayService,
  );

  // ViewModel을 콜백으로 설정
  overlayService.setMapInteractionCallback(viewModel);

  return viewModel;
});
