import 'package:flutter_naver_map/flutter_naver_map.dart';

class MapConstants {
  static const NLatLng defaultLatLng =
      NLatLng(36.3553177, 127.2981911); // default : 대전 삼성화재 연수원
  static const double maxZoomLevel = 21.0;
  static const double normalZoomLevel = 14.0;
  static const double baseZoomLevel = 12.0;
  static const double minZoomLevel = 0.0;
  static const NLatLng defaultCameraPosition =
      NLatLng(36.35467885768207, 127.36340320598653);
}
