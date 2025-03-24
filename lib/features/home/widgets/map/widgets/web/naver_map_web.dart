import 'dart:developer';
import 'dart:js_interop';
import 'dart:ui_web' as ui_web;
import 'package:client/features/home/widgets/bottom_drawer/models/info_type.dart';
import 'package:client/features/home/widgets/map/providers/data_provider.dart';
import 'package:web/web.dart' as web;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:client/features/home/widgets/bottom_drawer/providers/bottom_drawer_provider.dart';
import 'package:client/data/models/route_model.dart';
import 'package:client/features/home/widgets/map/providers/naver_map_providers.dart';
import 'package:client/core/theme/theme.dart';

@JS()
external set openDrawer(JSFunction value);

@JS()
external set closeDrawer(JSFunction value);

@JS()
external JSPromise initNaverMap(String elementId, String clientId);

@JS()
external void drawRoutesToMap(
    JSArray<JSObject> routesData, JSArray<JSString> colorsData);

class NaverMapWidget extends ConsumerStatefulWidget {
  const NaverMapWidget({super.key});

  @override
  ConsumerState<NaverMapWidget> createState() => _NaverMapWidgetState();
}

class _NaverMapWidgetState extends ConsumerState<NaverMapWidget> {
  late String clientId;
  late List<RouteModel> routesData;

  @override
  void initState() {
    super.initState();
    clientId = ref.read(naverMapClientIdProvider);
    _registerViewFactory();
  }

  void openDrawerFromJS(String markerId) {
    ref.read(bottomDrawerProvider.notifier).openDrawer(InfoType.station);
  }

  void closeDrawerFromJS() {
    ref.read(bottomDrawerProvider.notifier).closeDrawer();
  }

  Future<void> initializeMap() async {
    await initNaverMap('map', clientId).toDart;
    routesData = await ref.read(routeDataProvider.future);

    _drawRoutes();
    openDrawer = openDrawerFromJS.toJS;
    closeDrawer = closeDrawerFromJS.toJS;
  }

  void _drawRoutes() {
    final jsRoutesData = routesData
        .map((route) => route.toJson())
        .toList()
        .jsify() as JSArray<JSObject>;
    final jsColorsData = AppTheme.lineColors
        .map((color) => color.toARGB32().toRadixString(16))
        .toList()
        .jsify() as JSArray<JSString>;

    drawRoutesToMap(jsRoutesData, jsColorsData);
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
