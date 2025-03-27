import 'dart:developer' as dev;
import 'dart:math';

import 'package:client/data/models/route_model.dart';
import 'package:client/data/models/station_model.dart';
import 'package:client/features/home/widgets/bottom_drawer/view_models/bottom_drawer_view_model.dart';
import 'package:client/core/theme/theme.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

abstract class MapInteractionCallback {
  void onRouteSelected(String routeId);
  void onStationSelected(String stationId, NLatLng position);
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

  List<NLatLng> adjustPath(List<NLatLng> originalPath) {
    // 2-1. Path를 문자열 또는 해시값으로 변환
    String pathKey =
        originalPath.map((e) => "${e.latitude},${e.longitude}").join(";");
    int count = pathCount[pathKey] ?? 0; // 등장 횟수 확인

    // 2-2. 겹치는 경우, 일정 거리만큼 밀어줌
    double offset = 0.000001 * count; // 겹칠수록 더 많이 밀림

    double dx = (originalPath.last.longitude - originalPath.first.longitude);
    double dy = (originalPath.last.latitude - originalPath.first.latitude);
    double magnitude = sqrt(dx * dx + dy * dy);

    double offsetX = -dy / magnitude * offset;
    double offsetY = dx / magnitude * offset;

    // 2-3. 새로운 경로 생성 (밀어줌)
    List<NLatLng> adjustedPath = originalPath
        .map((coord) =>
            NLatLng(coord.latitude + offsetY, coord.longitude + offsetX))
        .toList();

    // 2-4. 등장 횟수 증가
    pathCount[pathKey] = count + 1;

    return adjustedPath;
  }

  List<NLatLng> adjustRoute(List<NLatLng> originalPath) {
    List<NLatLng> adjustedPath = [];
    for (var coord in originalPath) {
      int count = overlapCount[coord] ?? 0;
      double offset = 0.000008 * count; // 겹치는 횟수에 따라 밀어줌
      // 기존 좌표에서 offset을 추가 (경로 방향에 따라 법선 벡터 적용)
      double dx = (originalPath.last.longitude - originalPath.first.longitude);
      double dy = (originalPath.last.latitude - originalPath.first.latitude);
      double magnitude = sqrt(dx * dx + dy * dy);
      double offsetX = -dy / magnitude * offset;
      double offsetY = dx / magnitude * offset;
      adjustedPath
          .add(NLatLng(coord.latitude + offsetY, coord.longitude + offsetX));
      // 겹친 횟수 업데이트
      overlapCount[coord] = count + 1;
    }

    dev.log('$overlapCount');
    return adjustedPath;
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
              ),
              // coords.map((item) => item['coord'] as NLatLng).toList(),
            ))
        .toList();

    final overlay = NMultipartPathOverlay(
      id: '$id-${isExtended ? 'extended' : 'base'}',
      width: 4,
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

    for (var station in stations) {
      if (station.latitude != null && station.longitude != null) {
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
        marker.position,
      );
    });

    return marker;
  }

  // 줌 레벨 설정
  void _setStationZoomLevels(
    Set<NAddableOverlay<NOverlay<void>>> baseStations,
    Set<NAddableOverlay<NOverlay<void>>> extendedStations,
  ) {
    _setZoomForOverlays(baseStations, 12, 21);
    _setZoomForOverlays(extendedStations, 14, 21);
  }

  void _setRouteZoomLevels(
    Map<String, Set<NAddableOverlay<NOverlay<void>>>> overlays,
  ) {
    _setZoomForOverlays(overlays['baseRoutes']!, 0, 21);
    _setZoomForOverlays(overlays['extendedRoutes']!, 14, 21);
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
      overlay.setIsMaxZoomInclusive(maxZoom == 21);
    }
  }
}
