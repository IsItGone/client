import 'dart:developer';
import 'dart:js_interop';
import 'dart:ui_web' as ui_web;
import 'package:client/data/graphql/queries/route/__generated__/get_routes.data.gql.dart';
import 'package:client/data/graphql/queries/station/__generated__/get_stations.data.gql.dart';
import 'package:client/features/home/widgets/map/providers/data_provider.dart';
import 'package:web/web.dart' as web;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:client/features/home/widgets/bottom_drawer/providers/bottom_drawer_provider.dart';
import 'package:client/features/home/widgets/map/providers/naver_map_providers.dart';
import 'package:client/core/theme/theme.dart';

@JS()
external set openDrawer(JSFunction value);

@JS()
external set closeDrawer(JSFunction value);

@JS()
external JSPromise initNaverMap(String elementId, String clientId);

@JS()
external void drawDataToMap(
  JSArray<JSAny?> routesData,
  JSArray<JSAny?> stationsData,
  JSArray<JSAny?> colorsData,
);

class NaverMapWidget extends ConsumerStatefulWidget {
  const NaverMapWidget({super.key});

  @override
  ConsumerState<NaverMapWidget> createState() => _NaverMapWidgetState();
}

class _NaverMapWidgetState extends ConsumerState<NaverMapWidget> {
  late String clientId;

  @override
  void initState() {
    super.initState();
    clientId = ref.read(naverMapClientIdProvider);
    _registerViewFactory();
  }

  void openDrawerFromJS(String id, String type) {
    final mapViewModel = ref.read(naverMapViewModelProvider.notifier);
    switch (type) {
      case 'station':
        mapViewModel.onStationSelected(id, null);
        break;
      case 'route':
        mapViewModel.onRouteSelected(id);
        break;
      case 'place':
        // TODO: Implement place drawer
        break;
    }
  }

  void closeDrawerFromJS() {
    ref.read(bottomDrawerProvider.notifier).closeDrawer();
  }

  Future<void> initializeMap() async {
    await initNaverMap('map', clientId).toDart;

    try {
      _drawData();

      openDrawer = openDrawerFromJS.toJS;
      closeDrawer = closeDrawerFromJS.toJS;
    } catch (e) {
      // 에러 처리
      log('데이터 로딩 오류: $e');
      // TODO :사용자에게 오류 알림
    }
  }

  void _drawData() async {
    try {
      final routesData = await ref.read(routeDataProvider.future);
      final stationsData = await ref.read(stationDataProvider.future);

      // GraphQL 데이터를 JavaScript 객체로 직접 변환
      final jsRoutesData = routesData
          .whereType<GGetRoutesData_routes>()
          .map(_convertRouteToJs)
          .toList()
          .jsify() as JSArray<JSAny?>;

      final jsStationsData = stationsData
          .whereType<GGetStationsData_stations>()
          .map(_convertStationToJs)
          .toList()
          .jsify() as JSArray<JSAny?>;

      final jsColorsData = AppTheme.lineColors
          .map((color) => color.toARGB32().toRadixString(16))
          .toList()
          .jsify() as JSArray<JSAny?>;

      drawDataToMap(jsRoutesData, jsStationsData, jsColorsData);
    } catch (e) {
      // 오류 처리
      log('데이터 로딩 오류: $e');
      // TODO : 사용자에게 오류 메시지 표시
    }
  }

  Map<String, dynamic> _convertRouteToJs(GGetRoutesData_routes route) {
    return {
      'id': route.id,
      'name': route.name,
      'departureStations':
          _convertStationsList(route.departureStations as List?),
      'arrivalStations': _convertStationsList(route.arrivalStations as List?),
    };
  }

// 범용 스테이션 변환 함수로 수정
  List<Map<String, dynamic>> _convertStationsList(List? stationsList) {
    if (stationsList == null) return [];
    return stationsList
        .where((station) => station != null)
        .map((station) => {
              'id': station.id,
              'name': station.name,
              'description': station.description,
              'address': station.address,
              'latitude': station.latitude,
              'longitude': station.longitude,
              'stopTime': station.stopTime,
              'isDeparture': station.isDeparture,
              'routes':
                  (station.routes as List? ?? []).map((e) => e ?? '').toList(),
            })
        .toList();
  }

// 일반 스테이션 변환 함수 (직접 사용)
  Map<String, dynamic> _convertStationToJs(GGetStationsData_stations station) {
    return {
      'id': station.id,
      'name': station.name,
      'description': station.description,
      'address': station.address,
      'latitude': station.latitude,
      'longitude': station.longitude,
      'stopTime': station.stopTime,
      'isDeparture': station.isDeparture,
      'routes': (station.routes as List? ?? []).map((e) => e ?? '').toList(),
    };
  }

  void _registerViewFactory() {
    ui_web.platformViewRegistry.registerViewFactory('naver-map', (int viewId) {
      final element = web.document.createElement('div') as web.HTMLElement;
      element.id = 'map';
      element.style.width = '100%';
      element.style.height = '100vh';
      return element;
    });
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(
      viewType: 'naver-map',
      onPlatformViewCreated: (_) {
        log('platform created');
        initializeMap();
      },
    );
  }
}
