import 'dart:developer';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:ui_web' as ui_web;
import 'package:client/src/common/widgets/bottom_drawer/view_models/bottom_drawer_view_model.dart';
import 'package:web/web.dart' as web;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:client/src/common/widgets/bottom_drawer/bottom_drawer.dart';
import 'package:client/src/common/widgets/bottom_drawer/components/station_detail.dart';
import 'package:client/src/common/widgets/bottom_drawer/providers/bottom_drawer_provider.dart';
import 'package:client/src/common/widgets/map/models/route_model.dart';
import 'package:client/src/common/widgets/map/providers/naver_map_providers.dart';
import 'package:client/src/common/widgets/map_search_bar.dart';
import 'package:client/src/config/theme.dart';

import 'package:pointer_interceptor/pointer_interceptor.dart';

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
  late BottomDrawerViewModel drawerViewModel;

  @override
  void initState() {
    super.initState();
    clientId = ref.read(naverMapClientIdProvider);
    _registerViewFactory();
  }

  @JSExport()
  void openDrawerFromJS(String markerId) {
    ref.read(bottomDrawerProvider.notifier).openDrawer();
  }

  @JSExport()
  void closeDrawerFromJS() {
    ref.read(bottomDrawerProvider.notifier).closeDrawer();
  }

  Future<void> initializeMap() async {
    await initNaverMap('map', clientId).toDart;
    _drawRoutes();
    _setupJSInterop();
  }

  void _setupJSInterop() {
    globalContext.setProperty(
        'openDrawerFromJS' as JSAny, openDrawerFromJS.toJS);
    globalContext.setProperty(
        'closeDrawerFromJS' as JSAny, closeDrawerFromJS.toJS);
  }

  void _drawRoutes() {
    final jsRoutesData = routesData
        .map((route) => route.toJson())
        .toList()
        .jsify() as JSArray<JSObject>;
    final jsColorsData = AppTheme.lineColors
        .map((color) => color.value.toRadixString(16))
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

  // TODO : app구조 web 재사용&추상화 가능한지 해보기
// TODO : Init할때 위치 확인하기, 현위치 버튼 클릭시 지도 panning

  @override
  Widget build(BuildContext context) {
    final drawerState = ref.watch(bottomDrawerProvider);

    return Stack(
      children: [
        Positioned.fill(
          child: HtmlElementView(
            viewType: 'naver-map',
            onPlatformViewCreated: (_) {
              log('platform created');
              initializeMap();
            },
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: PointerInterceptor(child: const MapSearchBar()),
            ),
          ),
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          bottom: drawerState.isDrawerOpen
              ? 0
              : -MediaQuery.of(context).size.height * 0.33,
          left: 0,
          right: 0,
          child: PointerInterceptor(
            child: SingleChildScrollView(
              child: BottomDrawer(
                isDrawerOpen: drawerState.isDrawerOpen,
                child: StationDetail(drawerState.stationId),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
