import 'dart:developer';

import 'package:client/src/common/widgets/bottom_drawer/providers/bottom_drawer_provider.dart';
import 'package:client/src/config/constants.dart';
import 'package:client/src/config/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

class NaverMapService {
  // 지도 초기화
  Future<void> initialize() async {
    log('init map');
    const clientId = String.fromEnvironment('NAVER_MAP_CLIENT_ID');
    log('client id : $clientId');
    await NaverMapSdk.instance.initialize(
        clientId: clientId, // 클라이언트 ID 설정
        onAuthFailed: (e) => log("네이버맵 인증오류 : $e", name: "onAuthFailed"));
  }

  // 현재 위치 가져오기
  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    log('get current location');

    // 위치 서비스 활성화 확인
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    log("serviceEnabled $serviceEnabled");
    if (!serviceEnabled) {
      // 위치 서비스가 비활성화 상태일 때
      return null;
      // return Future.error('위치 서비스가 비활성화되어 있습니다.');
    }

    // 위치 권한 요청 및 상태 확인
    permission = await Geolocator.checkPermission();
    log('permission $permission');

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      log('request permission $permission');
      if (permission == LocationPermission.denied) {
        // 위치 권한이 거부되었을 때
        return null;
        // return Future.error('위치 권한이 거부되었습니다.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // 위치 권한이 영구적으로 거부되었을 때
      return null;
      // return Future.error('위치 권한이 영구적으로 거부되었습니다. 권한을 요청할 수 없습니다.');
    }

    // 위치 정보 가져오기
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }
}

// station mock data
Future<Map<String, Set<NAddableOverlay<NOverlay<void>>>>> loadShuttleData(
    BuildContext context, WidgetRef ref) async {
  const iconImage =
      NOverlayImage.fromAssetImage('assets/icons/bus_station_icon.png');

  final stations = {
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

  final routes = {
    NMultipartPathOverlay(
      id: "test호차",
      width: 3,
      paths: [
        NMultipartPath(
          color: AppTheme.lineColor[2],
          outlineColor: AppTheme.lineColor[2],
          coords: [
            const NLatLng(36.3612482, 127.3848091), // 정부 대전청사
            const NLatLng(36.36210517519867, 127.35634803771973), // 유성구청
            const NLatLng(36.359810556432436, 127.34099453020005), // 유성 문화원
            const NLatLng(36.35438082628037, 127.3404049873352), // 유성온천역 맥도날드
            const NLatLng(36.35954771869189, 127.32119718761012), // 현충원역
            MapConstants.defaultLatLng,
          ],
        ),
        NMultipartPath(
          color: AppTheme.lineColor[4],
          outlineColor: AppTheme.lineColor[4],
          coords: [
            const NLatLng(36.332326, 127.434211), // 대전역
            const NLatLng(36.357554, 127.3727623), // 갈마역
            const NLatLng(36.35438082628037, 127.3404049873352), // 유성온천역 맥도날드
            const NLatLng(36.3604371, 127.3055545), // 덕명네거리
            MapConstants.defaultLatLng,
          ],
        ),
      ],
    ),
  };

  for (var station in stations) {
    final drawerNotifier = ref.read(bottomDrawerProvider.notifier);

    station.setOnTapListener((NMarker station) {
      log("마커가 터치되었습니다. id: ${station.info.id}");
      if (!drawerNotifier.isDrawerOpen) {
        drawerNotifier.openDrawer();
      }
    });
    station.setMinZoom(12);
    station.setMaxZoom(18);
    station.setIsMinZoomInclusive(true);
    station.setIsMaxZoomInclusive(false);
  }

  return {'stations': stations, 'routes': routes};
}
