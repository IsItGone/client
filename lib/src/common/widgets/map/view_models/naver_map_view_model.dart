import 'dart:developer';
import 'package:client/src/common/widgets/bottom_drawer/view_models/bottom_drawer_view_model.dart';
import 'package:client/src/common/widgets/map/data/models/station_model.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/src/common/widgets/bottom_drawer/providers/bottom_drawer_provider.dart';
import 'package:client/src/common/widgets/map/data/models/route_model.dart';
import 'package:client/src/config/theme.dart';

class ShuttleDataLoader {
  static const NOverlayImage patternImage =
      NOverlayImage.fromAssetImage('assets/icons/chevron_up.png');
  static const NOverlayImage iconImage =
      NOverlayImage.fromAssetImage('assets/icons/bus_station_icon.png');

  static Map<String, Map<String, NMultipartPathOverlay>> allRoutesOverlay = {};
  static Set<NAddableOverlay<NOverlay<void>>> overviewStationsOverlay = {};
  static Set<NAddableOverlay<NOverlay<void>>> detailStationsOverlay = {};
  static String? clickedRouteId;
  static NaverMapController? _controller;

  static Map<String, Set<NAddableOverlay<NOverlay<void>>>> loadShuttleData(
    WidgetRef ref,
    NaverMapController? controller,
    List<RouteModel> routesData,
    List<StationModel> stationsData,
  ) {
    _controller = controller;

    final List<Map<String, dynamic>> getRoutes = _prepareRouteData(routesData);
    final Map<String, Set<NAddableOverlay<NOverlay<void>>>> overlays =
        _createOverlays(getRoutes, ref);

    // 전체 노선 정보로 polyline 생성
    allRoutesOverlay = {
      for (var overlay in overlays['overviewRoutes']!)
        overlay.info.id.split('-')[0]: {
          'overview': overlay as NMultipartPathOverlay,
          'detail': overlays['detailRoutes']!.firstWhere((o) =>
                  o.info.id.split('-')[0] == overlay.info.id.split('-')[0])
              as NMultipartPathOverlay,
        },
    };

    log('allRoutesOverlay: $allRoutesOverlay');
    // 전체 정류장 정보로 marker 생성
    final stationOverlays = _createStationMarkers(stationsData, ref);

    overviewStationsOverlay = stationOverlays['overviewStations']!;
    detailStationsOverlay = stationOverlays['detailStations']!;

    log('allRoutesOverlay: $overlays');
    return {
      'stations': {...overviewStationsOverlay, ...detailStationsOverlay},
      'routes': allRoutesOverlay.values.expand((map) => map.values).toSet(),
    };
  }

  static List<Map<String, dynamic>> _prepareRouteData(
      List<RouteModel> routesData) {
    return routesData.asMap().entries.map((entry) {
      int index = entry.key + 1;
      var route = entry.value;

      return {
        'index': index,
        'departureCoords': _prepareCoordinates(route.departureStations),
        'arrivalCoords': _prepareCoordinates(route.arrivalStations),
      };
    }).toList();
  }

  static List<Map<String, dynamic>> _prepareCoordinates(
      List<dynamic> stations) {
    return stations
        .map((station) => {
              'coord': NLatLng(station.latitude, station.longitude),
              'id': station.id
            })
        .toList();
  }

  static Map<String, Set<NAddableOverlay<NOverlay<void>>>> _createOverlays(
    List<Map<String, dynamic>> routesData,
    WidgetRef ref,
  ) {
    final overlays = _initializeOverlays();
    final bottomDrawerNotifier = ref.read(bottomDrawerProvider.notifier);

    for (var route in routesData) {
      _processRoute(route, overlays, bottomDrawerNotifier);
    }

    _setZoomSettings(overlays);

    return overlays;
  }

  static Map<String, Set<NAddableOverlay<NOverlay<void>>>>
      _initializeOverlays() {
    return {
      'overviewRoutes': <NAddableOverlay<NOverlay<void>>>{},
      'detailRoutes': <NAddableOverlay<NOverlay<void>>>{},
      'overviewStations': <NAddableOverlay<NOverlay<void>>>{},
      'detailStations': <NAddableOverlay<NOverlay<void>>>{},
    };
  }

  static void _processRoute(
    Map<String, dynamic> route,
    Map<String, Set<NAddableOverlay<NOverlay<void>>>> overlays,
    BottomDrawerViewModel drawerNotifier,
  ) {
    int index = route['index'];
    List<Map<String, dynamic>> departureCoords = route['departureCoords'];
    List<Map<String, dynamic>> arrivalCoords = route['arrivalCoords'] ?? [];

    _addRoutes(
      overlays['overviewRoutes'],
      index,
      [departureCoords],
      false,
      drawerNotifier,
    );

    List<List<Map<String, dynamic>>> detailCoords = [departureCoords];
    if (arrivalCoords.isNotEmpty) {
      detailCoords.add(arrivalCoords);
    }

    _addRoutes(
      overlays['detailRoutes'],
      index,
      detailCoords,
      true,
      drawerNotifier,
    );
  }

  static Map<String, Set<NAddableOverlay<NOverlay<void>>>>
      _createStationMarkers(
    List<StationModel> stationsData,
    WidgetRef ref,
  ) {
    final Set<NAddableOverlay<NOverlay<void>>> overviewStations = {};
    final Set<NAddableOverlay<NOverlay<void>>> detailStations = {};
    final bottomDrawerNotifier = ref.read(bottomDrawerProvider.notifier);

    for (var station in stationsData) {
      final marker = NMarker(
        id: station.id,
        position: NLatLng(station.latitude, station.longitude),
        icon: iconImage,
        size: const NSize(24, 32),
      );

      marker.setOnTapListener((NMarker marker) async {
        log("마커가 터치되었습니다. id: ${marker.info.id} $marker");
        bottomDrawerNotifier.updateInfoId(marker.info.id);
        bottomDrawerNotifier.openDrawer(InfoType.station);
        await _moveCamera(NLatLng(station.latitude, station.longitude), 17);
      });

      if (station.isDeparture) {
        overviewStations.add(marker);
      } else {
        detailStations.add(marker);
      }
    }

    return {
      'overviewStations': overviewStations,
      'detailStations': detailStations,
    };
  }

  static void _addRoutes(
    Set<NAddableOverlay<NOverlay<void>>>? routeSet,
    int index,
    List<List<Map<String, dynamic>>> coordsList,
    bool isDetail,
    BottomDrawerViewModel drawerNotifier,
  ) {
    List<NMultipartPath> paths = coordsList
        .map((coords) => NMultipartPath(
              color: AppTheme.lineColors[index],
              outlineColor: AppTheme.lineColors[index],
              coords: coords.map((item) => item['coord'] as NLatLng).toList(),
            ))
        .toList();

    final overlay = NMultipartPathOverlay(
      id: '$index-${isDetail ? 'detail' : 'overview'}',
      width: 8,
      patternImage: isDetail ? patternImage : null,
      paths: paths,
    );

    overlay.setOnTapListener((NMultipartPathOverlay tappedOverlay) async {
      if (_controller != null && _checkZoomLevel(_controller!, 10)) {
        log('zoom: ${_controller!.nowCameraPosition.zoom}');
        log('노선 클릭됨: ${tappedOverlay.info.id}');

        clickedRouteId = tappedOverlay.info.id.split('-')[0];
        _updateOverlayVisibility(clickedRouteId!);

        await _moveCamera(
          const NLatLng(36.35467885768207, 127.36340320598653), // center
          10.5,
        );

        drawerNotifier.updateInfoId(tappedOverlay.info.id.split('-')[0]);
        drawerNotifier.openDrawer(InfoType.route);
      }
    });

    routeSet?.add(overlay);
  }

  static bool _checkZoomLevel(
      NaverMapController controller, double requiredZoom) {
    return controller.nowCameraPosition.zoom >= requiredZoom;
  }

  static void _setZoomSettings(Map<String, Set<NOverlay>> overlays) {
    _setZoomForOverlay(overlays['overviewRoutes'], 0, 14);
    _setZoomForOverlay(overlays['overviewStations'], 12, 21);
    _setZoomForOverlay(overlays['detailStations'], 14, 21);
    _setZoomForOverlay(overlays['detailRoutes'], 14, 21);
  }

  static void _setZoomForOverlay(
    Set<NOverlay>? overlays,
    double minZoom,
    double maxZoom,
  ) {
    overlays?.forEach((overlay) {
      if (overlay is NAddableOverlay) {
        overlay.setMinZoom(minZoom);
        overlay.setMaxZoom(maxZoom);
        overlay.setIsMinZoomInclusive(true);
        overlay.setIsMaxZoomInclusive(maxZoom == 21);
      }
    });
  }

  static void _updateOverlayVisibility(String clickedRouteId) {
    // 클릭된 노선만 가시화하고 나머지 노선은 숨김
    for (var routeId in allRoutesOverlay.keys) {
      for (var route in allRoutesOverlay[routeId]?.values ?? []) {
        (route as NMultipartPathOverlay)
            .setIsVisible(routeId == clickedRouteId);
      }
    }

    for (var station in overviewStationsOverlay) {
      bool isStationInRoute = false;
      for (var route in allRoutesOverlay[clickedRouteId]?.values ?? []) {
        final paths = (route as NMultipartPathOverlay).paths;
        for (var path in paths) {
          if (path.coords.contains((station as NMarker).position)) {
            isStationInRoute = true;
            break;
          }
        }
      }
      station.setIsVisible(isStationInRoute);
    }

    for (var station in detailStationsOverlay) {
      bool isStationInRoute = false;
      for (var route in allRoutesOverlay[clickedRouteId]?.values ?? []) {
        final paths = (route as NMultipartPathOverlay).paths;
        for (var path in paths) {
          if (path.coords.contains((station as NMarker).position)) {
            isStationInRoute = true;
            break;
          }
        }
      }
      station.setIsVisible(isStationInRoute);
    }
  }

  static void handleZoomLevelChange() {
    if (_controller == null) return;

    final zoomLevel = _controller!.nowCameraPosition.zoom;

    if (clickedRouteId != null) {
      if (zoomLevel >= 14) {
        // 줌 레벨이 14 이상일 때 detailRoutes와 detailStations를 가시화
        for (var route in allRoutesOverlay[clickedRouteId]?.values ?? []) {
          (route as NMultipartPathOverlay).setIsVisible(true);
        }

        for (var station in detailStationsOverlay) {
          bool isStationInRoute = false;
          for (var route in allRoutesOverlay[clickedRouteId]?.values ?? []) {
            final paths = (route as NMultipartPathOverlay).paths;
            for (var path in paths) {
              if (path.coords.contains((station as NMarker).position)) {
                isStationInRoute = true;
                break;
              }
            }
          }
          station.setIsVisible(isStationInRoute);
        }
      } else if (zoomLevel >= 12) {
        // 줌 레벨이 12 이상일 때 overviewRoutes와 overviewStations를 가시화
        for (var route in allRoutesOverlay[clickedRouteId]?.values ?? []) {
          (route as NMultipartPathOverlay)
              .setIsVisible(!route.info.id.contains('detail'));
        }

        for (var station in overviewStationsOverlay) {
          bool isStationInRoute = false;
          for (var route in allRoutesOverlay[clickedRouteId]?.values ?? []) {
            final paths = (route as NMultipartPathOverlay).paths;
            for (var path in paths) {
              if (path.coords.contains((station as NMarker).position)) {
                isStationInRoute = true;
                break;
              }
            }
          }
          station.setIsVisible(isStationInRoute);
        }
      }
    } else {
      // 클릭된 노선이 없을 때 기본 줌 설정 적용
      _setZoomSettings({
        'overviewRoutes': allRoutesOverlay.values
            .expand((map) => map.values)
            .where((overlay) => overlay.info.id.contains('overview'))
            .toSet(),
        'detailRoutes': allRoutesOverlay.values
            .expand((map) => map.values)
            .where((overlay) => overlay.info.id.contains('detail'))
            .toSet(),
        'overviewStations': overviewStationsOverlay,
        'detailStations': detailStationsOverlay,
      });
    }
  }

  static void resetOverlayVisibility() {
    clickedRouteId = null; // 클릭된 노선 ID 초기화
    for (var route in allRoutesOverlay.values.expand((map) => map.values)) {
      route.setIsVisible(true);
    }

    for (var station in overviewStationsOverlay) {
      station.setIsVisible(true);
    }

    for (var station in detailStationsOverlay) {
      station.setIsVisible(true);
    }
  }

  static NMultipartPathOverlay? getRouteOverlayById(
      String routeId, String type) {
    return allRoutesOverlay[routeId]?[type];
  }

  static Future<void> _moveCamera(
    NLatLng target,
    double zoom,
  ) async {
    if (_controller != null) {
      final cameraUpdate = NCameraUpdate.scrollAndZoomTo(
        target: target,
        zoom: zoom,
      )
        ..setAnimation(
            animation: NCameraAnimation.easing,
            duration: const Duration(milliseconds: 300))
        ..setPivot(const NPoint(1 / 2, 1 / 2));

      await _controller!.updateCamera(cameraUpdate);
    }
  }

  static Future<void> triggerRouteClick(
      String routeId, BottomDrawerViewModel drawerNotifier) async {
    final routeOverlay = getRouteOverlayById(routeId, 'overview');
    if (routeOverlay != null &&
        _controller != null &&
        _checkZoomLevel(_controller!, 10)) {
      log('zoom: ${_controller!.nowCameraPosition.zoom}');
      log('노선 클릭됨: ${routeOverlay.info.id}');

      clickedRouteId = routeOverlay.info.id.split('-')[0];
      _updateOverlayVisibility(clickedRouteId!);

      await _moveCamera(
        const NLatLng(36.35467885768207, 127.36340320598653), // center
        10.5,
      );

      drawerNotifier.updateInfoId(routeOverlay.info.id.split('-')[0]);
      drawerNotifier.openDrawer(InfoType.route);
    }
  }
}
