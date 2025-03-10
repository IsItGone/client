import 'dart:developer';

import 'package:client/src/common/widgets/bottom_drawer/models/info_type.dart';
import 'package:client/src/common/widgets/bottom_drawer/view_models/bottom_drawer_view_model.dart';
import 'package:client/src/common/widgets/map/data/models/station_model.dart';
import 'package:client/src/common/widgets/map/services/overlay_service.dart';
import 'package:client/src/common/widgets/map/models/map_state.dart';
import 'package:client/src/config/constants.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/src/common/widgets/map/data/models/route_model.dart';

class NaverMapViewModel extends StateNotifier<MapState>
    implements MapInteractionCallback {
  final BottomDrawerViewModel _drawerNotifier;
  final OverlayService _overlayService;

  NaverMapViewModel(
    this._drawerNotifier,
    this._overlayService,
  ) : super(const MapState());

  @override
  void onRouteSelected(String routeId) {
    if (state.mapController != null &&
        state.currentZoom >= MapConstants.minZoomBase) {
      _drawerNotifier.updateInfoId(routeId);
      _drawerNotifier.openDrawer(InfoType.route);
      selectRoute(routeId);
      moveCamera(MapConstants.defaultCameraPosition, 10.5);
    }
  }

  @override
  void onStationSelected(String stationId, NLatLng position) {
    _drawerNotifier.updateInfoId(stationId);
    _drawerNotifier.openDrawer(InfoType.station);
    moveCamera(position, 17);
  }

  void initializeMap(
    NaverMapController controller,
    List<RouteModel> routes,
    List<StationModel> stations,
    BottomDrawerViewModel drawerNotifier,
  ) {
    // 컨트롤러 설정
    state = state.copyWith(mapController: controller);

    // 오버레이 생성 및 상태 업데이트
    final overlayData = _overlayService.createMapOverlays(
      routes,
      stations,
      drawerNotifier,
    );

    state = state.copyWith(
      routeOverlays: overlayData['routeOverlays'],
      baseStations: overlayData['baseStations'],
      extendedStations: overlayData['extendedStations'],
    );

    setZoomLevels(); // 줌 레벨 설정 추가
    _updateDefaultVisibility(); // 초기 가시성 설정
  }

  Set<NAddableOverlay<NOverlay<void>>> getAllOverlays() {
    return {
      ...state.routeOverlays.values.expand((map) => map.values),
      ...state.baseStations,
      ...state.extendedStations,
    };
  }

  void updateZoomLevel(double zoom) {
    state = state.copyWith(currentZoom: zoom);
    _updateVisibility();
  }

  Future<void> moveCamera(NLatLng target, double zoom) async {
    if (state.mapController == null) return;

    final cameraUpdate = NCameraUpdate.scrollAndZoomTo(
      target: target,
      zoom: zoom,
    )
      ..setAnimation(
          animation: NCameraAnimation.easing,
          duration: const Duration(milliseconds: 300))
      ..setPivot(const NPoint(1 / 2, 1 / 2));

    await state.mapController!.updateCamera(cameraUpdate);
  }

  void selectRoute(String routeId) {
    state = state.copyWith(selectedRouteId: routeId);
    _updateOverlayVisibility();
  }

  void resetSelection() {
    // 선택된 노선 ID를 null로 설정
    state = state.copyWith(selectedRouteId: "");

    _updateDefaultVisibility();
    setZoomLevels();
  }

  void _updateVisibility() {
    final selectedRouteId = state.selectedRouteId;
    final currentZoom = state.currentZoom;

    if (selectedRouteId != null && selectedRouteId.isNotEmpty) {
      if (currentZoom >= MapConstants.minZoomExtended) {
        // 줌 레벨이 14 이상일 때 상세 경로와 정류장 표시
        _updateSelectedRouteVisibility(true);
      } else if (currentZoom >= MapConstants.minZoomBase) {
        // 줌 레벨이 12 이상일 때 기본 경로와 정류장 표시
        _updateSelectedRouteVisibility(false);
      } else {
        // 줌 레벨이 12 미만일 때도 선택된 노선은 보이도록
        _updateSelectedRouteVisibility(false);
      }
    } else {
      _updateDefaultVisibility();
    }
  }

  void _updateOverlayVisibility() {
    final selectedRouteId = state.selectedRouteId;

    if (selectedRouteId != null) {
      // 선택된 노선이 있을 때
      for (var entry in state.routeOverlays.entries) {
        final isSelected = entry.key == selectedRouteId;
        entry.value.forEach((_, overlay) {
          overlay.setIsVisible(isSelected);
        });
      }

      // 선택된 노선과 관련된 정류장만 표시
      _updateStationVisibility((station) {
        return _isStationInSelectedRoute(station as NMarker);
      });
    } else {
      // 선택된 노선이 없을 때 (초기 상태)
      _showAllOverlays();
    }
  }

  bool _isStationInSelectedRoute(NMarker station) {
    if (state.selectedRouteId == null) return true;

    final selectedRouteOverlays =
        state.routeOverlays[state.selectedRouteId!]?.values ?? {};
    for (var overlay in selectedRouteOverlays) {
      for (var path in overlay.paths) {
        if (path.coords.contains(station.position)) {
          return true;
        }
      }
    }
    return false;
  }

  void _showAllOverlays() {
    // 모든 노선 표시
    for (var routeOverlays in state.routeOverlays.values) {
      routeOverlays.forEach((_, overlay) {
        overlay.setIsVisible(true);
      });
    }

    // 모든 정류장 표시
    _updateStationVisibility((_) => true);
  }

  void _updateStationVisibility(
      bool Function(NAddableOverlay<NOverlay<void>>) predicate) {
    for (var station in state.baseStations) {
      station.setIsVisible(predicate(station));
    }
    for (var station in state.extendedStations) {
      station.setIsVisible(predicate(station));
    }
  }

  void _updateSelectedRouteVisibility(bool isDetailView) {
    final routeId = state.selectedRouteId!;

    // 선택된 노선 관련 오버레이만 표시
    for (var entry in state.routeOverlays.entries) {
      final isSelected = entry.key == routeId;
      entry.value.forEach((type, overlay) {
        bool isExtendedRoute = overlay.info.id.contains('extended');
        overlay.setIsVisible(isSelected && isExtendedRoute == isDetailView);
      });
    }

    // 선택된 노선과 관련된 정류장만 표시
    final stations = isDetailView ? state.extendedStations : state.baseStations;
    for (var station in stations) {
      final isStationInRoute = _isStationInSelectedRoute(station as NMarker);
      station.setIsVisible(isStationInRoute);
    }

    // 다른 타입의 정류장은 숨김
    final otherStations =
        isDetailView ? state.baseStations : state.extendedStations;
    for (var station in otherStations) {
      station.setIsVisible(false);
    }
  }

  void _updateDefaultVisibility() {
    final currentZoom = state.currentZoom;

    // 줌 레벨에 따른 오버레이 가시성 설정
    for (var routeOverlays in state.routeOverlays.values) {
      routeOverlays.forEach((type, overlay) {
        bool isExtendedRoute = overlay.info.id.contains('extended');
        if (isExtendedRoute) {
          // 상세 경로는 줌 레벨에 따라 표시
          overlay.setIsVisible(currentZoom >= MapConstants.minZoomExtended);
        } else {
          // 기본 경로는 항상 표시 (줌 레벨 체크 제거)
          overlay.setIsVisible(true);
        }
      });
    }

    // 정류장 마커 가시성 설정
    for (var station in state.baseStations) {
      station.setIsVisible(currentZoom >= MapConstants.minZoomBase);
    }
    for (var station in state.extendedStations) {
      station.setIsVisible(currentZoom >= MapConstants.minZoomExtended);
    }
  }

  void setZoomLevels() {
    // 오버레이별 줌 레벨 제한 설정
    for (var routeOverlays in state.routeOverlays.values) {
      for (var overlay in routeOverlays.values) {
        bool isExtendedRoute = overlay.info.id.contains('extended');
        if (isExtendedRoute) {
          // 상세 경로는 14-21 줌 레벨
          overlay.setMinZoom(14);
          overlay.setMaxZoom(21);
        } else {
          // 기본 경로는 0-14 줌 레벨 (항상 보이도록)
          overlay.setMinZoom(0);
          overlay.setMaxZoom(14);
        }
      }
    }

    // 정류장 마커 줌 레벨 제한 설정
    for (var station in state.baseStations) {
      // 기본 정류장은 12-21 줌 레벨
      station.setMinZoom(12);
      station.setMaxZoom(21);
    }

    for (var station in state.extendedStations) {
      // 상세 정류장은 14-21 줌 레벨
      station.setMinZoom(14);
      station.setMaxZoom(21);
    }

    // 최소/최대 줌 포함 여부 설정
    for (var overlay in getAllOverlays()) {
      overlay.setIsMinZoomInclusive(true);
      overlay.setIsMaxZoomInclusive(true);
    }
  }
}

// // // TODO : 인스턴스 전역적으로 사용하도록 수정

// class ShuttleDataLoader {
//   static const NOverlayImage patternImage =
//       NOverlayImage.fromAssetImage('assets/icons/chevron_up.png');
//   static const NOverlayImage iconImage =
//       NOverlayImage.fromAssetImage('assets/icons/bus_station_icon.png');

//   static Map<String, Map<String, NMultipartPathOverlay>> routesOverlay = {};
//   static Set<NAddableOverlay<NOverlay<void>>> overviewStations = {};
//   static Set<NAddableOverlay<NOverlay<void>>> detailStations = {};
//   static String? selectedRouteId;
//   static NaverMapController? mapController;

//   static Map<String, Set<NAddableOverlay<NOverlay<void>>>> loadShuttleData(
//     WidgetRef ref,
//     NaverMapController? controller,
//     List<RouteModel> routesData,
//     List<StationModel> stationsData,
//   ) {
//     mapController = controller;

//     final List<Map<String, dynamic>> getRoutes = _prepareRouteData(routesData);
//     final Map<String, Set<NAddableOverlay<NOverlay<void>>>> overlays =
//         _createOverlays(getRoutes, ref);

//     // 전체 노선 정보로 polyline 생성
//     routesOverlay = {
//       for (var overlay in overlays['overviewRoutes']!)
//         overlay.info.id.split('-')[0]: {
//           'overview': overlay as NMultipartPathOverlay,
//           'detail': overlays['detailRoutes']!.firstWhere((o) =>
//                   o.info.id.split('-')[0] == overlay.info.id.split('-')[0])
//               as NMultipartPathOverlay,
//         },
//     };

//     log('routesOverlay: $routesOverlay');
//     // 전체 정류장 정보로 marker 생성
//     final stationOverlays = _createStationMarkers(stationsData, ref);

//     overviewStations = stationOverlays['overviewStations']!;
//     detailStations = stationOverlays['detailStations']!;

//     log('allOverlay: $overlays');
//     return {
//       'stations': {...overviewStations, ...detailStations},
//       'routes': routesOverlay.values.expand((map) => map.values).toSet(),
//     };
//   }

//   static List<Map<String, dynamic>> _prepareRouteData(
//       List<RouteModel> routesData) {
//     return routesData.asMap().entries.map((entry) {
//       int index = entry.key + 1;
//       var route = entry.value;

//       return {
//         'index': index,
//         'departureCoords': _prepareCoordinates(route.departureStations),
//         'arrivalCoords': _prepareCoordinates(route.arrivalStations),
//       };
//     }).toList();
//   }

//   static List<Map<String, dynamic>> _prepareCoordinates(
//       List<dynamic> stations) {
//     return stations
//         .map((station) => {
//               'coord': NLatLng(station.latitude, station.longitude),
//               'id': station.id
//             })
//         .toList();
//   }

//   static Map<String, Set<NAddableOverlay<NOverlay<void>>>> _createOverlays(
//     List<Map<String, dynamic>> routesData,
//     WidgetRef ref,
//   ) {
//     final overlays = _initializeOverlays();
//     final bottomDrawerNotifier = ref.read(bottomDrawerProvider.notifier);

//     for (var route in routesData) {
//       _processRoute(route, overlays, bottomDrawerNotifier);
//     }

//     _setZoomSettings(overlays);

//     return overlays;
//   }

//   static Map<String, Set<NAddableOverlay<NOverlay<void>>>>
//       _initializeOverlays() {
//     return {
//       'overviewRoutes': <NAddableOverlay<NOverlay<void>>>{},
//       'detailRoutes': <NAddableOverlay<NOverlay<void>>>{},
//       'overviewStations': <NAddableOverlay<NOverlay<void>>>{},
//       'detailStations': <NAddableOverlay<NOverlay<void>>>{},
//     };
//   }

//   static void _processRoute(
//     Map<String, dynamic> route,
//     Map<String, Set<NAddableOverlay<NOverlay<void>>>> overlays,
//     BottomDrawerViewModel drawerNotifier,
//   ) {
//     int index = route['index'];
//     List<Map<String, dynamic>> departureCoords = route['departureCoords'];
//     List<Map<String, dynamic>> arrivalCoords = route['arrivalCoords'] ?? [];

//     _addRoutes(
//       overlays['overviewRoutes'],
//       index,
//       [departureCoords],
//       false,
//       drawerNotifier,
//     );

//     List<List<Map<String, dynamic>>> detailCoords = [departureCoords];
//     if (arrivalCoords.isNotEmpty) {
//       detailCoords.add(arrivalCoords);
//     }

//     _addRoutes(
//       overlays['detailRoutes'],
//       index,
//       detailCoords,
//       true,
//       drawerNotifier,
//     );
//   }

//   static Map<String, Set<NAddableOverlay<NOverlay<void>>>>
//       _createStationMarkers(
//     List<StationModel> stationsData,
//     WidgetRef ref,
//   ) {
//     final Set<NAddableOverlay<NOverlay<void>>> overviewStations = {};
//     final Set<NAddableOverlay<NOverlay<void>>> detailStations = {};
//     final bottomDrawerNotifier = ref.read(bottomDrawerProvider.notifier);

//     for (var station in stationsData) {
//       final marker = NMarker(
//         id: station.id,
//         position: NLatLng(station.latitude, station.longitude),
//         icon: iconImage,
//         size: const NSize(24, 32),
//       );

//       marker.setOnTapListener((NMarker marker) async {
//         log("마커가 터치되었습니다. id: ${marker.info.id} $marker");
//         bottomDrawerNotifier.updateInfoId(marker.info.id);
//         bottomDrawerNotifier.openDrawer(InfoType.station);
//         await _moveCamera(NLatLng(station.latitude, station.longitude), 17);
//       });

//       if (station.isDeparture) {
//         overviewStations.add(marker);
//       } else {
//         detailStations.add(marker);
//       }
//     }

//     return {
//       'overviewStations': overviewStations,
//       'detailStations': detailStations,
//     };
//   }

//   static void _addRoutes(
//     Set<NAddableOverlay<NOverlay<void>>>? routeSet,
//     int index,
//     List<List<Map<String, dynamic>>> coordsList,
//     bool isDetail,
//     BottomDrawerViewModel drawerNotifier,
//   ) {
//     List<NMultipartPath> paths = coordsList
//         .map((coords) => NMultipartPath(
//               color: AppTheme.lineColors[index],
//               outlineColor: AppTheme.lineColors[index],
//               coords: coords.map((item) => item['coord'] as NLatLng).toList(),
//             ))
//         .toList();

//     final overlay = NMultipartPathOverlay(
//       id: '$index-${isDetail ? 'detail' : 'overview'}',
//       width: 8,
//       patternImage: isDetail ? patternImage : null,
//       paths: paths,
//     );

//     overlay.setOnTapListener((NMultipartPathOverlay tappedOverlay) async {
//       if (mapController != null &&
//           _checkZoomLevel(mapController!, MapConstants.minZoomOverview)) {
//         log('zoom: ${mapController!.nowCameraPosition.zoom}');
//         log('노선 클릭됨: ${tappedOverlay.info.id}');

//         selectedRouteId = tappedOverlay.info.id.split('-')[0];
//         _updateOverlayVisibility(selectedRouteId!);

//         await _moveCamera(
//           MapConstants.defaultCameraPosition,
//           10.5,
//         );

//         drawerNotifier.updateInfoId(tappedOverlay.info.id.split('-')[0]);
//         drawerNotifier.openDrawer(InfoType.route);
//       }
//     });

//     routeSet?.add(overlay);
//   }

//   static bool _checkZoomLevel(
//       NaverMapController controller, double requiredZoom) {
//     return controller.nowCameraPosition.zoom >= requiredZoom;
//   }

//   static void _setZoomSettings(Map<String, Set<NOverlay>> overlays) {
//     _setZoomForOverlay(overlays['overviewRoutes'], 0, 14);
//     _setZoomForOverlay(overlays['overviewStations'], 12, 21);
//     _setZoomForOverlay(overlays['detailStations'], 14, 21);
//     _setZoomForOverlay(overlays['detailRoutes'], 14, 21);
//   }

//   static void _setZoomForOverlay(
//     Set<NOverlay>? overlays,
//     double minZoom,
//     double maxZoom,
//   ) {
//     overlays?.forEach((overlay) {
//       if (overlay is NAddableOverlay) {
//         overlay.setMinZoom(minZoom);
//         overlay.setMaxZoom(maxZoom);
//         overlay.setIsMinZoomInclusive(true);
//         overlay.setIsMaxZoomInclusive(maxZoom == 21);
//       }
//     });
//   }

//   static void _updateOverlayVisibility(String selectedRouteId) {
//     // 클릭된 노선만 가시화하고 나머지 노선은 숨김
//     for (var routeId in routesOverlay.keys) {
//       for (var route in routesOverlay[routeId]?.values ?? []) {
//         (route as NMultipartPathOverlay)
//             .setIsVisible(routeId == selectedRouteId);
//       }
//     }

//     for (var station in overviewStations) {
//       bool isStationInRoute = false;
//       for (var route in routesOverlay[selectedRouteId]?.values ?? []) {
//         final paths = (route as NMultipartPathOverlay).paths;
//         for (var path in paths) {
//           if (path.coords.contains((station as NMarker).position)) {
//             isStationInRoute = true;
//             break;
//           }
//         }
//       }
//       station.setIsVisible(isStationInRoute);
//     }

//     for (var station in detailStations) {
//       bool isStationInRoute = false;
//       for (var route in routesOverlay[selectedRouteId]?.values ?? []) {
//         final paths = (route as NMultipartPathOverlay).paths;
//         for (var path in paths) {
//           if (path.coords.contains((station as NMarker).position)) {
//             isStationInRoute = true;
//             break;
//           }
//         }
//       }
//       station.setIsVisible(isStationInRoute);
//     }
//   }

//   static void handleZoomLevelChange() {
//     if (mapController == null) return;

//     final zoomLevel = mapController!.nowCameraPosition.zoom;

//     if (selectedRouteId != null) {
//       if (zoomLevel >= MapConstants.minZoomDetail) {
//         // 줌 레벨이 14 이상일 때 detailRoutes와 detailStations를 가시화
//         for (var route in routesOverlay[selectedRouteId]?.values ?? []) {
//           (route as NMultipartPathOverlay).setIsVisible(true);
//         }

//         for (var station in detailStations) {
//           bool isStationInRoute = false;
//           for (var route in routesOverlay[selectedRouteId]?.values ?? []) {
//             final paths = (route as NMultipartPathOverlay).paths;
//             for (var path in paths) {
//               if (path.coords.contains((station as NMarker).position)) {
//                 isStationInRoute = true;
//                 break;
//               }
//             }
//           }
//           station.setIsVisible(isStationInRoute);
//         }
//       } else if (zoomLevel >= 12) {
//         // 줌 레벨이 12 이상일 때 overviewRoutes와 overviewStations를 가시화
//         for (var route in routesOverlay[selectedRouteId]?.values ?? []) {
//           (route as NMultipartPathOverlay)
//               .setIsVisible(!route.info.id.contains('detail'));
//         }

//         for (var station in overviewStations) {
//           bool isStationInRoute = false;
//           for (var route in routesOverlay[selectedRouteId]?.values ?? []) {
//             final paths = (route as NMultipartPathOverlay).paths;
//             for (var path in paths) {
//               if (path.coords.contains((station as NMarker).position)) {
//                 isStationInRoute = true;
//                 break;
//               }
//             }
//           }
//           station.setIsVisible(isStationInRoute);
//         }
//       }
//     } else {
//       // 클릭된 노선이 없을 때 기본 줌 설정 적용
//       _setZoomSettings({
//         'overviewRoutes': routesOverlay.values
//             .expand((map) => map.values)
//             .where((overlay) => overlay.info.id.contains('overview'))
//             .toSet(),
//         'detailRoutes': routesOverlay.values
//             .expand((map) => map.values)
//             .where((overlay) => overlay.info.id.contains('detail'))
//             .toSet(),
//         'overviewStations': overviewStations,
//         'detailStations': detailStations,
//       });
//     }
//   }

//   static void resetOverlayVisibility() {
//     selectedRouteId = null;
//     for (var route in routesOverlay.values.expand((map) => map.values)) {
//       route.setIsVisible(true);
//     }

//     for (var station in overviewStations) {
//       station.setIsVisible(true);
//     }

//     for (var station in detailStations) {
//       station.setIsVisible(true);
//     }
//   }

//   static NMultipartPathOverlay? getRouteOverlayById(
//       String routeId, String type) {
//     return routesOverlay[routeId]?[type];
//   }

//   static Future<void> _moveCamera(
//     NLatLng target,
//     double zoom,
//   ) async {
//     if (mapController != null) {
//       final cameraUpdate = NCameraUpdate.scrollAndZoomTo(
//         target: target,
//         zoom: zoom,
//       )
//         ..setAnimation(
//             animation: NCameraAnimation.easing,
//             duration: const Duration(milliseconds: 300))
//         ..setPivot(const NPoint(1 / 2, 1 / 2));

//       await mapController!.updateCamera(cameraUpdate);
//     }
//   }

//   static Future<void> triggerRouteClick(
//       String routeId, BottomDrawerViewModel drawerNotifier) async {
//     final routeOverlay = getRouteOverlayById(routeId, 'overview');
//     if (routeOverlay != null &&
//         mapController != null &&
//         _checkZoomLevel(mapController!, MapConstants.minZoomOverview)) {
//       log('zoom: ${mapController!.nowCameraPosition.zoom}');
//       log('노선 클릭됨: ${routeOverlay.info.id}');

//       selectedRouteId = routeOverlay.info.id.split('-')[0];
//       _updateOverlayVisibility(selectedRouteId!);

//       await _moveCamera(MapConstants.defaultCameraPosition, 10.5);

//       drawerNotifier.updateInfoId(routeOverlay.info.id.split('-')[0]);
//       drawerNotifier.openDrawer(InfoType.route);
//     }
//   }
// }
