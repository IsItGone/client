import 'dart:developer';
import 'package:client/src/common/widgets/bottom_drawer/view_models/bottom_drawer_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/src/common/widgets/bottom_drawer/providers/bottom_drawer_provider.dart';
import 'package:client/src/common/widgets/map/models/route_model.dart';
import 'package:client/src/config/theme.dart';

class ShuttleDataLoader {
  static const NOverlayImage patternImage =
      NOverlayImage.fromAssetImage('assets/icons/chevron_up.png');
  static const NOverlayImage iconImage =
      NOverlayImage.fromAssetImage('assets/icons/bus_station_icon.png');

  static Set<NAddableOverlay<NOverlay<void>>> allRoutes = {};
  static Set<NAddableOverlay<NOverlay<void>>> allStations = {};

  static Future<Map<String, Set<NAddableOverlay<NOverlay<void>>>>>
      loadShuttleData(
    BuildContext context,
    WidgetRef ref,
    NaverMapController? controller,
  ) async {
    final List<Map<String, dynamic>> getRoutes = _prepareRouteData();
    final Map<String, Set<NAddableOverlay<NOverlay<void>>>> overlays =
        _createOverlays(getRoutes, context, ref, controller);

// TODO : 받아온 데이터처럼 각 노선 정보 안에 지나는 정류장 정보 포함하도록 관리 필요함
    allRoutes = {
      ...overlays['overviewRoutes']!,
      ...overlays['detailRoutes']!,
    };

    allStations = {
      ...overlays['overviewStations']!,
      ...overlays['detailStations']!
    };

    return {
      'stations': allStations,
      'routes': allRoutes,
    };
  }

  static List<Map<String, dynamic>> _prepareRouteData() {
    return routesData.asMap().entries.map((entry) {
      int index = entry.key;
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
    BuildContext context,
    WidgetRef ref,
    NaverMapController? controller,
  ) {
    final overlays = _initializeOverlays();
    final bottomDrawerNotifier = ref.read(bottomDrawerProvider.notifier);

    for (var route in routesData) {
      _processRoute(route, overlays, bottomDrawerNotifier, controller);
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
    NaverMapController? controller,
  ) {
    int index = route['index'];
    List<Map<String, dynamic>> departureCoords = route['departureCoords'];
    List<Map<String, dynamic>> arrivalCoords = route['arrivalCoords'] ?? [];

    _addMarkers(
      overlays['overviewStations'],
      departureCoords,
      index,
      'departure',
      drawerNotifier,
      controller,
    );
    _addRoutes(
      overlays['overviewRoutes'],
      index,
      [departureCoords],
      false,
      drawerNotifier,
      controller,
    );

    List<List<Map<String, dynamic>>> detailCoords = [departureCoords];
    if (arrivalCoords.isNotEmpty) {
      detailCoords.add(arrivalCoords);
      _addMarkers(
        overlays['detailStations'],
        arrivalCoords,
        index,
        'arrival',
        drawerNotifier,
        controller,
      );
    }

    _addRoutes(
      overlays['detailRoutes'],
      index,
      detailCoords,
      true,
      drawerNotifier,
      controller,
    );
  }

  static void _addMarkers(
    Set<NAddableOverlay<NOverlay<void>>>? markerSet,
    List<Map<String, dynamic>> stationList,
    int index,
    String type,
    BottomDrawerViewModel drawerNotifier,
    NaverMapController? controller,
  ) {
    for (var station in stationList) {
      final marker = NMarker(
        id: station['id'],
        position: station['coord'],
        icon: iconImage,
        size: const NSize(32, 40),
      );

      marker.setOnTapListener((NMarker marker) async {
        log("마커가 터치되었습니다. id: ${marker.info.id} $marker");
        drawerNotifier.updateInfoId(marker.info.id);
        drawerNotifier.openDrawer(InfoType.station);
        await _moveCamera(controller, station['coord'], 17);
      });

      markerSet?.add(marker);
    }
  }

  static void _addRoutes(
    Set<NAddableOverlay<NOverlay<void>>>? routeSet,
    int index,
    List<List<Map<String, dynamic>>> coordsList,
    bool isDetail,
    BottomDrawerViewModel drawerNotifier,
    NaverMapController? controller,
  ) {
    List<NMultipartPath> paths = coordsList
        .map((coords) => NMultipartPath(
              color: AppTheme.lineColors[index],
              outlineColor: AppTheme.lineColors[index],
              coords: coords.map((item) => item['coord'] as NLatLng).toList(),
            ))
        .toList();

    final overlay = NMultipartPathOverlay(
      id: '${index + 1}-${isDetail ? 'detail' : 'overview'}',
      width: 8,
      patternImage: isDetail ? patternImage : null,
      paths: paths,
    );

    overlay.setOnTapListener((NMultipartPathOverlay tappedOverlay) async {
      if (controller != null && _checkZoomLevel(controller, 10)) {
        log('zoom: ${controller.nowCameraPosition.zoom}');
        log('노선 클릭됨: ${tappedOverlay.info.id}');

        _updateOverlayVisibility(tappedOverlay.info.id.split('-')[0]);

        await _moveCamera(
          controller,
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
    for (var route in allRoutes) {
      bool isClicked = route.info.id.split('-')[0] == clickedRouteId;
      route.setIsVisible(isClicked);
    }

    // for (var station in allStations) {
    //   // route.
    // }
  }

  static Future<void> _moveCamera(
    NaverMapController? controller,
    NLatLng target,
    double zoom,
  ) async {
    if (controller != null) {
      final cameraUpdate = NCameraUpdate.scrollAndZoomTo(
        target: target,
        zoom: zoom,
      )
        ..setAnimation(
            animation: NCameraAnimation.easing,
            duration: const Duration(milliseconds: 300))
        ..setPivot(const NPoint(1 / 2, 1 / 2));

      await controller.updateCamera(cameraUpdate);
    }
  }
}
