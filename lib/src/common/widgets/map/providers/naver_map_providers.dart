import 'dart:developer';

import 'package:client/src/common/widgets/map/services/naver_map_service.dart';

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
