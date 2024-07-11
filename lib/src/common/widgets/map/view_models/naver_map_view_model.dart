import 'dart:developer';

import 'package:client/src/common/widgets/bottom_sheet/providers/bottom_drawer_provider.dart';
import 'package:client/src/common/widgets/map/models/route_model.dart';
import 'package:client/src/config/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<Map<String, Set<NAddableOverlay<NOverlay<void>>>>> loadShuttleData(
    BuildContext context, WidgetRef ref, NaverMapController? controller) async {
  final List<Map<String, dynamic>> getRoutes =
      routesData.asMap().entries.map((entry) {
    int index = entry.key;
    var route = entry.value;

    final departureCoords = route.departureStations
        .map((station) => {
              'coord': NLatLng(station.latitude, station.longitude),
              'id': station.id
            })
        .toList();
    final arrivalCoords = route.arrivalStations
        .map((station) => {
              'coord': NLatLng(station.latitude, station.longitude),
              'id': station.id
            })
        .toList();

    return {
      'index': index,
      'departureCoords': departureCoords,
      'arrivalCoords': arrivalCoords,
    };
  }).toList();

  final Map<String, dynamic> overlays =
      createOverlays(getRoutes, context, ref, controller);

  return {
    'stations': {
      ...overlays['overviewStations'],
      ...overlays['detailStations'],
    },
    'routes': {
      ...overlays['overviewRoutes'],
      ...overlays['detailRoutes'],
    }
  };
}

Map<String, dynamic> createOverlays(List<Map<String, dynamic>> routesData,
    BuildContext context, WidgetRef ref, NaverMapController? controller) {
  const patternImage =
      NOverlayImage.fromAssetImage('assets/icons/chevron_up.png');
  const iconImage =
      NOverlayImage.fromAssetImage('assets/icons/bus_station_icon.png');

  Set<NMultipartPathOverlay> overviewRoutes = {};
  Set<NMultipartPathOverlay> detailRoutes = {};
  Set<NMarker> overviewStations = {};
  Set<NMarker> detailStations = {};

  final bottomDrawerNotifier = ref.watch(bottomDrawerProvider.notifier);

  void addMarkers(Set<NMarker> markerSet,
      List<Map<String, dynamic>> stationList, int index, String type) {
    for (var station in stationList) {
      final marker = NMarker(
        id: station['id'],
        position: station['coord'],
        icon: iconImage,
        size: const NSize(32, 40),
      );
      marker.setOnTapListener((NMarker marker) async {
        log("마커가 터치되었습니다. id: ${marker.info.id} $marker");

        // bottomSheetNotifier.openBottomSheet(context, marker.info.id);
        bottomDrawerNotifier.updateStationId(marker.info.id);

        if (!bottomDrawerNotifier.isDrawerOpen) {
          bottomDrawerNotifier.openDrawer();
        }
        if (controller != null) {
          final cameraUpdate = NCameraUpdate.scrollAndZoomTo(
            target: station['coord'],
            zoom: 17,
          )
            ..setAnimation(
              animation: NCameraAnimation.easing,
              duration: const Duration(milliseconds: 300),
            )
            ..setPivot(const NPoint(1 / 2, 1 / 2));

          await controller.updateCamera(cameraUpdate);
        }
      });
      markerSet.add(marker);
    }
  }

  NMultipartPathOverlay createMultipartPathOverlay(
      String id, int index, List<NMultipartPath> paths,
      {bool isDetail = false}) {
    return NMultipartPathOverlay(
      id: id,
      width: 8,
      patternImage: isDetail ? patternImage : null,
      paths: paths,
    );
  }

  for (var route in routesData) {
    int index = route['index'];
    List<Map<String, dynamic>> departureCoords = route['departureCoords'];
    List<Map<String, dynamic>> arrivalCoords =
        route.containsKey('arrivalCoords') ? route['arrivalCoords'] : [];

    // overviewRoutes와 overviewStations에 departureCoords 추가
    addMarkers(overviewStations, departureCoords, index, 'departure');
    overviewRoutes.add(
      createMultipartPathOverlay(
        '$index-overview',
        index,
        [
          NMultipartPath(
            color: AppTheme.lineColors[index],
            outlineColor: AppTheme.lineColors[index],
            coords: departureCoords
                .map((item) => item['coord'] as NLatLng)
                .toList(),
          )
        ],
      ),
    );

    // detailRoutes에 departureCoords와 arrivalCoords 추가
    List<NMultipartPath> detailPaths = [
      NMultipartPath(
        color: AppTheme.lineColors[index],
        outlineColor: AppTheme.lineColors[index],
        coords:
            departureCoords.map((item) => item['coord'] as NLatLng).toList(),
      )
    ];

    if (arrivalCoords.isNotEmpty) {
      detailPaths.add(
        NMultipartPath(
          color: AppTheme.lineColors[index],
          outlineColor: AppTheme.lineColors[index],
          coords:
              arrivalCoords.map((item) => item['coord'] as NLatLng).toList(),
        ),
      );
      // detailStations에 arrivalCoords 추가
      addMarkers(
        detailStations,
        arrivalCoords,
        index,
        'arrival',
      );
    }

    detailRoutes.add(
      createMultipartPathOverlay(
        '$index-detail',
        index,
        detailPaths,
        isDetail: true,
      ),
    );
  }

  // 줌 레벨에 따라 노선과 정류장 표시
  setZoomSettings(overviewRoutes, 0, 14);
  setZoomSettings(overviewStations, 12, 21);
  setZoomSettings(detailStations, 14, 21);
  setZoomSettings(detailRoutes, 14, 21);

  return {
    'overviewRoutes': overviewRoutes,
    'detailRoutes': detailRoutes,
    'overviewStations': overviewStations,
    'detailStations': detailStations,
  };
}

void setZoomSettings(Set<NAddableOverlay<NOverlay<void>>> items, double minZoom,
    double maxZoom) {
  for (var item in items) {
    item.setMinZoom(minZoom);
    item.setMaxZoom(maxZoom);
    item.setIsMinZoomInclusive(true);
    item.setIsMaxZoomInclusive(maxZoom == 21);
  }
}
