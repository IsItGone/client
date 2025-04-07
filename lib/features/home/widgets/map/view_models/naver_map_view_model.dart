import 'dart:developer';

import 'package:client/core/constants/constants.dart';
import 'package:client/features/home/widgets/bottom_drawer/models/info_type.dart';
import 'package:client/features/home/widgets/bottom_drawer/view_models/bottom_drawer_view_model.dart';
import 'package:client/data/models/station_model.dart';
import 'package:client/features/home/widgets/map/services/overlay_service.dart';
import 'package:client/features/home/widgets/map/models/map_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/data/models/route_model.dart';

class NaverMapViewModel extends StateNotifier<MapState>
    implements MapInteractionCallback {
  final BottomDrawerViewModel _drawerNotifier;
  final OverlayService _overlayService;
  bool _isAnimating = false;
  double _lastProcessedZoom = 0.0;

  NaverMapViewModel(
    this._drawerNotifier,
    this._overlayService,
  ) : super(const MapState());

  // @override
  // void onRouteSelected(String routeId) {
  //   log('selected: $routeId');
  //   selectRoute(routeId);

  //   _drawerNotifier.updateInfoId(null, routeId);
  //   _drawerNotifier.openDrawer(InfoType.route);

  //   if (!kIsWeb) {
  //     if (state.mapController != null &&
  //         state.currentZoom >= MapConstants.baseZoomLevel) {
  //       moveCamera(MapConstants.defaultCameraPosition, 10.5);
  //     }
  //   }
  // }
  @override
  void onRouteSelected(String routeId) {
    log('selected: $routeId');

    // 애니메이션 시작 상태 설정
    _isAnimating = true;

    // 1. 먼저 선택 상태만 업데이트 (가벼운 작업)
    state = state.copyWith(selectedRouteId: routeId);

    // 2. 기본 경로만 우선 표시 (애니메이션 성능 향상)
    _simplifiedRouteUpdate(routeId);

    // 3. 드로어 열기 (UI 애니메이션)
    _drawerNotifier.updateInfoId(stationId: null, routeId: routeId);
    _drawerNotifier.openDrawer(InfoType.route);

    // 4. 애니메이션 후 카메라 이동
    if (!kIsWeb && state.mapController != null) {
      Future.delayed(const Duration(milliseconds: 50), () {
        // 카메라 이동
        moveCamera(MapConstants.defaultCameraPosition, 10.5);

        // 5. 모든 애니메이션 완료 후 상세 업데이트
        Future.delayed(const Duration(milliseconds: 300), () {
          _isAnimating = false;
          _updateVisibility(); // 전체 업데이트 수행
        });
      });
    }
  }

  // 추가 메소드: 간소화된 노선 업데이트
  void _simplifiedRouteUpdate(String routeId) {
    // 선택된 노선의 기본 정보만 표시 (가벼운 작업)
    for (var entry in state.routeOverlays.entries) {
      final isSelected = entry.key == routeId;
      entry.value.forEach((type, overlay) {
        bool isBaseRoute = !overlay.info.id.contains('extended');
        // 애니메이션 중에는 확장 경로 숨기기
        overlay.setIsVisible(isSelected && isBaseRoute);
      });
    }
  }

  // @override
  // void onStationSelected(
  //     String stationId, double lat, double lng, String? routeId) {
  //   if (!kIsWeb) {
  //     moveCamera(NLatLng(lat, lng), 17);
  //   }

  //   _drawerNotifier.updateInfoId(stationId, routeId);
  //   _drawerNotifier.openDrawer(InfoType.station);
  // }
  @override
  void onStationSelected(
      String stationId, double lat, double lng, String? routeId) {
    // 애니메이션 상태 설정
    _isAnimating = true;

    // 1. 드로어 열기 (UI 애니메이션 시작)
    _drawerNotifier.updateInfoId(stationId: stationId, routeId: routeId);
    _drawerNotifier.openDrawer(InfoType.station);

    // 2. 애니메이션 후 카메라 이동
    if (!kIsWeb && state.mapController != null) {
      Future.delayed(const Duration(milliseconds: 50), () {
        // 카메라 이동
        moveCamera(NLatLng(lat, lng), 17);

        // 3. 모든 애니메이션 완료 후 상태 업데이트
        Future.delayed(const Duration(milliseconds: 300), () {
          _isAnimating = false;
          // 필요한 경우 추가 업데이트 작업
        });
      });
    }
  }

  Set<NAddableOverlay<NOverlay<void>>> initializeMap(
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

    _updateDefaultVisibility(); // 초기 가시성 설정
    return getAllOverlays(); // 오버레이 반환
  }

  Set<NAddableOverlay<NOverlay<void>>> getAllOverlays() {
    return {
      ...state.routeOverlays.values.expand((map) => map.values),
      ...state.baseStations,
      ...state.extendedStations,
    };
  }

  // void updateZoomLevel(double zoom) {
  //   state = state.copyWith(currentZoom: zoom);
  //   _updateVisibility();
  // }

  void updateZoomLevel(double zoom) {
    // 최소 변화량 체크로 불필요한 업데이트 방지
    if ((zoom - state.currentZoom).abs() < 0.05) return;

    // 드로어가 열려 있는 동안 줌 레벨 변경 시 오버레이 업데이트 최소화
    if (_drawerNotifier.isDrawerOpen &&
        (zoom - _lastProcessedZoom).abs() < 0.5) {
      return;
    }

    _lastProcessedZoom = zoom;
    state = state.copyWith(currentZoom: zoom);
    _updateVisibilityLite(); // 가벼운 가시성 업데이트 메소드 호출
  }

  void _updateVisibilityLite() {
    if (_isAnimating) return; // 애니메이션 중이면 업데이트 건너뛰기

    final currentZoom = state.currentZoom;
    final selectedRouteId = state.selectedRouteId;

    // 선택된 노선만 업데이트
    if (selectedRouteId != null && selectedRouteId.isNotEmpty) {
      if (currentZoom >= MapConstants.normalZoomLevel) {
        // 줌 레벨이 높을 때는 상세 보기
        _updateSelectedRouteVisibility(true);
      } else {
        // 줌 레벨이 낮을 때는 간소화된 보기
        _updateSelectedRouteVisibility(false);
      }
    } else {
      // 줌 레벨에 따른 가시성만 업데이트
      _updateDefaultVisibility();
    }
  }

  void moveCamera(NLatLng target, double zoom) {
    if (state.mapController == null) return;

    final cameraUpdate = NCameraUpdate.scrollAndZoomTo(
      target: target,
      zoom: zoom,
    );

    state.mapController!.updateCamera(cameraUpdate);
  }

  void selectRoute(String routeId) {
    state = state.copyWith(selectedRouteId: routeId);
    _updateOverlayVisibility();
  }

  void resetSelection() {
    state = state.copyWith(selectedRouteId: "");

    _updateDefaultVisibility();
    setZoomLevels();
  }

// overlay_service.dart에 추가
  bool isOverlayInBounds(NAddableOverlay overlay, NLatLngBounds bounds) {
    if (overlay is NMarker) {
      return bounds.containsPoint(overlay.position);
    } else if (overlay is NMultipartPathOverlay) {
      // 각 경로의 시작점과 끝점만 체크하여 성능 최적화
      for (var path in overlay.paths) {
        if (path.coords.isEmpty) continue;

        // 경로의 첫 점과 마지막 점만 체크
        if (bounds.containsPoint(path.coords.first) ||
            bounds.containsPoint(path.coords.last)) {
          return true;
        }

        // 긴 경로인 경우 중간점도 체크
        if (path.coords.length > 10) {
          final midIndex = path.coords.length ~/ 2;
          if (bounds.containsPoint(path.coords.elementAt(midIndex))) {
            return true;
          }
        }
      }
      return false;
    }
    return true;
  }

  void _updateVisibility() {
    final selectedRouteId = state.selectedRouteId;
    final currentZoom = state.currentZoom;

    if (selectedRouteId != null && selectedRouteId.isNotEmpty) {
      if (currentZoom >= MapConstants.normalZoomLevel) {
        // 줌 레벨이 14 이상일 때 상세 경로와 정류장 표시
        _updateSelectedRouteVisibility(true);
      } else if (currentZoom >= MapConstants.baseZoomLevel) {
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
          overlay.setIsVisible(currentZoom >= MapConstants.normalZoomLevel);
        } else {
          // 기본 경로는 항상 표시 (줌 레벨 체크 제거)
          overlay.setIsVisible(true);
        }
      });
    }

    // 정류장 마커 가시성 설정
    for (var station in state.baseStations) {
      station.setIsVisible(currentZoom >= MapConstants.baseZoomLevel);
    }
    for (var station in state.extendedStations) {
      station.setIsVisible(currentZoom >= MapConstants.normalZoomLevel);
    }
  }

  void setZoomLevels() {
    // 오버레이별 줌 레벨 제한 설정
    for (var routeOverlays in state.routeOverlays.values) {
      for (var overlay in routeOverlays.values) {
        bool isExtendedRoute = overlay.info.id.contains('extended');
        if (isExtendedRoute) {
          // 상세 경로는 14-21 줌 레벨
          overlay.setMinZoom(MapConstants.normalZoomLevel);
          overlay.setMaxZoom(MapConstants.maxZoomLevel);
        } else {
          // 기본 경로는 0-14 줌 레벨 (항상 보이도록)
          overlay.setMinZoom(MapConstants.minZoomLevel);
          overlay.setMaxZoom(MapConstants.normalZoomLevel);
        }
      }
    }

    // 정류장 마커 줌 레벨 제한 설정
    for (var station in state.baseStations) {
      // 기본 정류장은 12-21 줌 레벨
      station.setMinZoom(MapConstants.baseZoomLevel);
      station.setMaxZoom(MapConstants.maxZoomLevel);
    }

    for (var station in state.extendedStations) {
      // 상세 정류장은 14-21 줌 레벨
      station.setMinZoom(MapConstants.normalZoomLevel);
      station.setMaxZoom(MapConstants.maxZoomLevel);
    }

    // 최소/최대 줌 포함 여부 설정
    for (var overlay in getAllOverlays()) {
      overlay.setIsMinZoomInclusive(true);
      overlay.setIsMaxZoomInclusive(true);
    }
  }
}
