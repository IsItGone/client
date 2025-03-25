import 'dart:developer';
import 'dart:js_interop';
import 'dart:ui_web' as ui_web;
import 'package:client/data/models/route_model.dart';
import 'package:client/data/models/station_model.dart';
import 'package:web/web.dart' as web;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/features/home/widgets/map/providers/data_provider.dart';
import 'package:client/features/home/widgets/bottom_drawer/providers/bottom_drawer_provider.dart';
import 'package:client/features/home/widgets/map/providers/naver_map_providers.dart';
import 'package:client/core/theme/theme.dart';

// RouteModel 웹 확장
extension RouteModelWebExtension on RouteModel {
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'departureStations': departureStations.map((s) => s.toJson()).toList(),
        'arrivalStations': arrivalStations.map((s) => s.toJson()).toList(),
      };

  JSObject toJSObject() => toJson().jsify() as JSObject;
}

// StationModel 웹 확장
extension StationModelWebExtension on StationModel {
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'stopTime': stopTime,
        'isDeparture': isDeparture,
        'routes': routes,
      };

  JSObject toJSObject() => toJson().jsify() as JSObject;
}

@JS()
external set openDrawer(JSFunction value);

@JS()
external set closeDrawer(JSFunction value);

@JS()
external JSPromise initNaverMap(String elementId, String clientId);

@JS()
external void drawDataToMap(
  JSArray routesData,
  JSArray stationsData,
  JSArray colorsData,
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
    try {
      await initNaverMap('map', clientId).toDart;
      await _drawData();

      openDrawer = openDrawerFromJS.toJS;
      closeDrawer = closeDrawerFromJS.toJS;
    } catch (e) {
      // 에러 처리
      log('데이터 로딩 오류: $e');
      // TODO :사용자에게 오류 알림
    }
  }

  Future<void> _drawData() async {
    try {
      final routesData = await ref.read(routeDataProvider.future);
      final stationsData = await ref.read(stationDataProvider.future);

      // 모델 객체를 JavaScript 객체로 변환
      final jsRoutesData = routesData
          .map((route) => route.toJSObject())
          .toList()
          .jsify() as JSArray;

      final jsStationsData = stationsData
          .map((station) => station.toJSObject())
          .toList()
          .jsify() as JSArray;

      final jsColorsData = AppTheme.lineColors
          .map((color) => color.toARGB32().toRadixString(16))
          .toList()
          .jsify() as JSArray;

      drawDataToMap(jsRoutesData, jsStationsData, jsColorsData);
    } catch (e) {
      // 오류 처리
      log('데이터 로딩 오류: $e');
      // TODO : 사용자에게 오류 메시지 표시
    }
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
