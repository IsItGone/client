import 'package:client/features/home/widgets/bottom_drawer/models/info_type.dart';
import 'package:client/features/home/widgets/bottom_drawer/view_models/bottom_drawer_view_model.dart';
import 'package:client/data/models/station_model.dart';
import 'package:client/features/home/widgets/map/services/overlay_service.dart';
import 'package:client/features/home/widgets/map/models/map_state.dart';
import 'package:client/core/constants/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/data/models/route_model.dart';

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
    //TODO  routeId: 호차 번호 -> 노선 ID
    _drawerNotifier.updateInfoId(routeId);
    _drawerNotifier.openDrawer(InfoType.route);
    if (!kIsWeb) {
      if (state.mapController != null &&
          state.currentZoom >= MapConstants.minZoomBase) {
        selectRoute(routeId);
        moveCamera(MapConstants.defaultCameraPosition, 10.5);
      }
    }
  }

  @override
  void onStationSelected(String stationId, NLatLng? position) {
    _drawerNotifier.updateInfoId(stationId);
    _drawerNotifier.openDrawer(InfoType.station);
    if (!kIsWeb) {
      moveCamera(position!, 17);
    }
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
