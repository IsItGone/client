import 'dart:developer';
import 'package:flutter_naver_map/flutter_naver_map.dart';

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
}
