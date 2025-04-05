import 'dart:developer';

import 'package:flutter_naver_map/flutter_naver_map.dart';
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
    log("location service enabled $serviceEnabled");
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
        locationSettings: LocationSettings(accuracy: LocationAccuracy.high));
  }
}
