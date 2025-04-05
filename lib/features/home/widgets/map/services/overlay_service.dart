import 'dart:developer' as dev;
import 'dart:math';

import 'package:client/core/constants/constants.dart';
import 'package:client/data/models/route_model.dart';
import 'package:client/data/models/station_model.dart';
import 'package:client/features/home/widgets/bottom_drawer/view_models/bottom_drawer_view_model.dart';
import 'package:client/core/theme/theme.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

abstract class MapInteractionCallback {
  void onRouteSelected(String routeId);
  void onStationSelected(
    String stationId,
    double lat,
    double lng,
    String? routeId,
  );
}

class OverlayService {
  final NOverlayImage routePatternImage;
  final NOverlayImage stationMarkerImage;
  MapInteractionCallback? _mapCallback;

  OverlayService({
    required this.routePatternImage,
    required this.stationMarkerImage,
  });

  Map<NLatLng, int> overlapCount = {};
  Map<String, int> pathCount = {};

  List<NLatLng> adjustRoute(List<NLatLng> originalPath, int routeIndex) {
    List<NLatLng> curvedPath = [];

    // 노선별로 다른 곡률 적용
    double baseCurveFactor = 0.0001;
    double curveFactor = baseCurveFactor * (1 + (routeIndex % 3) * 0.2);

    // 홀수/짝수 노선에 따라 곡률 방향 반대로 설정
    int direction = routeIndex % 2 == 0 ? 1 : -1;
    curveFactor *= direction;

    for (int i = 0; i < originalPath.length - 1; i++) {
      NLatLng start = originalPath[i];
      NLatLng end = originalPath[i + 1];

      List<NLatLng> curveSegment = createBezierCurve(start, end, curveFactor);

      // 중복 포인트 제거
      if (i > 0) {
        curveSegment = curveSegment.sublist(1);
      }

      curvedPath.addAll(curveSegment);
    }

    return curvedPath;
  }

  List<NLatLng> createBezierCurve(
      NLatLng start, NLatLng end, double curveFactor) {
    List<NLatLng> curvePoints = [];

    // 제어점 계산 (곡선의 높이 조절)
    double midLat = (start.latitude + end.latitude) / 2;
    double midLng = (start.longitude + end.longitude) / 2;

    // 수직 방향 오프셋 계산
    double dx = end.longitude - start.longitude;
    double dy = end.latitude - start.latitude;
    double normalX = -dy;
    double normalY = dx;
    double distance = sqrt(dx * dx + dy * dy);

    // 제어점 (곡선의 정점)
    NLatLng controlPoint = NLatLng(midLat + normalY / distance * curveFactor,
        midLng + normalX / distance * curveFactor);

    // 곡선에 포인트 추가
    final steps = 20;
    for (int i = 0; i <= steps; i++) {
      double t = i / steps;
      double lat =
          _bezierPoint(start.latitude, controlPoint.latitude, end.latitude, t);
      double lng = _bezierPoint(
          start.longitude, controlPoint.longitude, end.longitude, t);
      curvePoints.add(NLatLng(lat, lng));
    }

    return curvePoints;
  }

  double _bezierPoint(double p0, double p1, double p2, double t) {
    return (1 - t) * (1 - t) * p0 + 2 * (1 - t) * t * p1 + t * t * p2;
  }

  void setMapInteractionCallback(MapInteractionCallback callback) {
    _mapCallback = callback;
  }

// 오버레이 생성 관련 메서드들
  Map<String, dynamic> createMapOverlays(
    List<RouteModel> routes,
    List<StationModel> stations,
    BottomDrawerViewModel drawerNotifier,
  ) {
    if (_mapCallback == null) {
      throw Exception('MapInteractionCallback이 설정되지 않았습니다.');
    }

    final routeData = _prepareRouteData(routes);
    final routeOverlays = _createRouteOverlays(routeData, drawerNotifier);
    final stationOverlays = _createStationMarkers(stations, drawerNotifier);

    return {
      'routeOverlays': _processRouteOverlays(routeOverlays),
      'baseStations': stationOverlays['base'],
      'extendedStations': stationOverlays['extended'],
    };
  }

  // 경로 데이터 준비
  List<Map<String, dynamic>> _prepareRouteData(List<RouteModel> routes) {
    return routes.asMap().entries.map((entry) {
      int index = entry.key + 1;
      var route = entry.value;

      return {
        'index': index,
        'id': entry.value.id,
        'departureCoords': _prepareCoordinates(route.departureStations),
        'arrivalCoords': _prepareCoordinates(route.arrivalStations),
      };
    }).toList();
  }

  // 좌표 데이터 준비
  List<Map<String, dynamic>> _prepareCoordinates(List<StationModel> stations) {
    return stations
        .map((station) => {
              'coord': NLatLng(station.latitude!, station.longitude!),
              'id': station.id
            })
        .toList();
  }

  // 경로 오버레이 생성
  Map<String, Set<NAddableOverlay<NOverlay<void>>>> _createRouteOverlays(
    List<Map<String, dynamic>> routeData,
    BottomDrawerViewModel drawerNotifier,
  ) {
    final overlays = {
      'baseRoutes': <NAddableOverlay<NOverlay<void>>>{},
      'extendedRoutes': <NAddableOverlay<NOverlay<void>>>{},
    };

    for (var route in routeData) {
      _processRoute(route, overlays, drawerNotifier);
    }

    _setRouteZoomLevels(overlays);
    return overlays;
  }

  // 경로 오버레이 가공
  Map<String, Map<String, NMultipartPathOverlay>> _processRouteOverlays(
    Map<String, Set<NAddableOverlay<NOverlay<void>>>> overlays,
  ) {
    return {
      for (var overlay in overlays['baseRoutes']!)
        overlay.info.id.split('-')[0]: {
          'base': overlay as NMultipartPathOverlay,
          'extended': overlays['extendedRoutes']!.firstWhere((o) =>
                  o.info.id.split('-')[0] == overlay.info.id.split('-')[0])
              as NMultipartPathOverlay,
        },
    };
  }

  // 개별 경로 처리
  void _processRoute(
    Map<String, dynamic> route,
    Map<String, Set<NAddableOverlay<NOverlay<void>>>> overlays,
    BottomDrawerViewModel drawerNotifier,
  ) {
    int index = route['index'];
    String id = route['id'];
    List<Map<String, dynamic>> departureCoords = route['departureCoords'];
    List<Map<String, dynamic>> arrivalCoords = route['arrivalCoords'] ?? [];

    // 기본 경로 추가
    _addRoutes(
      overlays['baseRoutes'],
      index,
      id,
      [departureCoords],
      false,
      drawerNotifier,
    );

    // 상세 경로 추가
    List<List<Map<String, dynamic>>> extendedCoords = [departureCoords];
    if (arrivalCoords.isNotEmpty) {
      extendedCoords.add(arrivalCoords);
    }

    _addRoutes(
      overlays['extendedRoutes'],
      index,
      id,
      extendedCoords,
      true,
      drawerNotifier,
    );
  }

  // 경로 추가 헬퍼 메서드
  void _addRoutes(
    Set<NAddableOverlay<NOverlay<void>>>? routeSet,
    int index,
    String id,
    List<List<Map<String, dynamic>>> coordsList,
    bool isExtended,
    BottomDrawerViewModel drawerNotifier,
  ) {
    List<NMultipartPath> paths = coordsList
        .map((coords) => NMultipartPath(
              color: AppTheme.lineColors[index],
              outlineColor: AppTheme.lineColors[index],
              coords: adjustRoute(
                coords.map((item) => item['coord'] as NLatLng).toList(),
                index, // 노선 인덱스 전달
              ),
            ))
        .toList();
    final overlay = NMultipartPathOverlay(
      id: '$id-${isExtended ? 'extended' : 'base'}',
      width: 3,
      patternImage: isExtended ? routePatternImage : null,
      paths: paths,
    );

    overlay.setOnTapListener((NMultipartPathOverlay tappedOverlay) {
      dev.log('tapped: $tappedOverlay');
      final routeId = tappedOverlay.info.id.split('-')[0];
      _mapCallback?.onRouteSelected(routeId);
    });

    routeSet?.add(overlay);
  }

  // 정류장 마커 생성
  Map<String, Set<NAddableOverlay<NOverlay<void>>>> _createStationMarkers(
    List<StationModel> stations,
    BottomDrawerViewModel drawerNotifier,
  ) {
    final baseStations = <NAddableOverlay<NOverlay<void>>>{};
    final extendedStations = <NAddableOverlay<NOverlay<void>>>{};

    Map<String, StationModel> coordMap = {};

    for (var station in stations) {
      if (station.latitude != null && station.longitude != null) {
        String coordKey = '${station.latitude},${station.longitude}';

        // 회차 정류장 처리: 동일한 좌표를 가진 경우 하나의 마커만 추가
        if (!coordMap.containsKey(coordKey)) {
          coordMap[coordKey] = station;

          final marker = _createStationMarker(
            station,
            drawerNotifier,
          );

          if (station.isDeparture != null && station.isDeparture == true) {
            baseStations.add(marker);
          } else {
            extendedStations.add(marker);
          }
        }
      }
    }

    _setStationZoomLevels(baseStations, extendedStations);

    return {
      'base': baseStations,
      'extended': extendedStations,
    };
  }

  // 정류장 마커 생성 헬퍼 메서드
  NMarker _createStationMarker(
    StationModel station,
    BottomDrawerViewModel drawerNotifier,
  ) {
    final marker = NMarker(
      id: station.id,
      position: NLatLng(station.latitude!, station.longitude!),
      icon: stationMarkerImage,
      size: const NSize(24, 32),
    );

    marker.setOnTapListener((NMarker marker) {
      _mapCallback?.onStationSelected(
        marker.info.id,
        marker.position.latitude,
        marker.position.longitude,
        null,
      );
    });

    return marker;
  }

  // 줌 레벨 설정
  void _setStationZoomLevels(
    Set<NAddableOverlay<NOverlay<void>>> baseStations,
    Set<NAddableOverlay<NOverlay<void>>> extendedStations,
  ) {
    _setZoomForOverlays(
      baseStations,
      MapConstants.baseZoomLevel,
      MapConstants.maxZoomLevel,
    );
    _setZoomForOverlays(
      extendedStations,
      MapConstants.normalZoomLevel,
      MapConstants.maxZoomLevel,
    );
  }

  void _setRouteZoomLevels(
    Map<String, Set<NAddableOverlay<NOverlay<void>>>> overlays,
  ) {
    _setZoomForOverlays(
      overlays['baseRoutes']!,
      MapConstants.minZoomLevel,
      MapConstants.maxZoomLevel,
    );
    _setZoomForOverlays(
      overlays['extendedRoutes']!,
      MapConstants.normalZoomLevel,
      MapConstants.maxZoomLevel,
    );
  }

  void _setZoomForOverlays(
    Set<NAddableOverlay<NOverlay<void>>> overlays,
    double minZoom,
    double maxZoom,
  ) {
    for (var overlay in overlays) {
      overlay.setMinZoom(minZoom);
      overlay.setMaxZoom(maxZoom);
      overlay.setIsMinZoomInclusive(true);
      overlay.setIsMaxZoomInclusive(maxZoom == MapConstants.maxZoomLevel);
    }
  }
}
