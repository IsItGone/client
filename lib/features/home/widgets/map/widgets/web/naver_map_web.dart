import 'dart:developer';
import 'dart:js_interop';
import 'dart:ui_web' as ui_web;
import 'package:client/data/models/route_model.dart';
import 'package:client/data/models/station_model.dart';
import 'package:client/features/home/widgets/map/widgets/web/js_interop_web.dart';
import 'package:web/web.dart' as web;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/features/home/widgets/bottom_drawer/providers/bottom_drawer_provider.dart';
import 'package:client/features/home/widgets/map/providers/naver_map_providers.dart';
import 'package:client/core/theme/theme.dart';

class NaverMapWidget extends ConsumerStatefulWidget {
  final List<RouteModel> routes;
  final List<StationModel> stations;

  const NaverMapWidget({
    super.key,
    required this.routes,
    required this.stations,
  });

  @override
  ConsumerState<NaverMapWidget> createState() => _NaverMapWidgetState();
}

class _NaverMapWidgetState extends ConsumerState<NaverMapWidget> {
  late final String clientId;

  @override
  void initState() {
    super.initState();
    clientId = ref.read(naverMapClientIdProvider);
    _registerViewFactory();
  }

  void _injectAndInitialize(String containerId) {
    if (web.document.querySelector('script#naver-map-script') == null) {
      final script =
          web.document.createElement('script') as web.HTMLScriptElement;
      script.id = 'naver-map-script';
      script.type = 'text/javascript';
      script.src =
          'https://openapi.map.naver.com/openapi/v3/maps.js?ncpClientId=$clientId';
      script.defer = true;
      script.onload = ((web.Event event) {
        log('네이버 맵 스크립트 로드됨');
        _initializeMap(containerId);
      }).toJS;

      web.document.head!.append(script);
    } else {
      _initializeMap(containerId);
    }
  }

  void _initializeMap(String containerId) {
    initializeNaverMap(containerId).toDart.then((_) {
      log('지도 초기화 성공');
      _drawData();

      openDrawer = _handleOpenDrawer.toJS;
      closeDrawer = _handleCloseDrawer.toJS;
    }).catchError((e) {
      log('지도 초기화 실패: $e');
    });
  }

  void _registerViewFactory() {
    ui_web.platformViewRegistry.registerViewFactory('naver-map', (int viewId) {
      final String containerId = 'naver-map-$viewId';
      final element = web.document.createElement('div') as web.HTMLElement;
      element.id = containerId;
      element.style
        ..width = '100%'
        ..height = '100%'
        ..position = 'absolute'
        ..overflow = 'hidden'
        ..willChange = 'transform'
        ..contain = 'layout paint';
      return element;
    });
  }

  void _drawData() {
    final jsRoutes =
        widget.routes.map((r) => r.toJSObject()).toList().jsify() as JSArray;
    final jsStations =
        widget.stations.map((s) => s.toJSObject()).toList().jsify() as JSArray;
    final jsColors = AppTheme.lineColors
        .map((c) => c.toARGB32().toRadixString(16))
        .toList()
        .jsify() as JSArray;

    naverMap.drawData(jsRoutes, jsStations, jsColors);
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(
      viewType: 'naver-map',
      onPlatformViewCreated: (viewId) {
        final String containerId = 'naver-map-$viewId';
        log('HtmlElementView created with containerId: $containerId');
        // _injectAndInitialize(containerId);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _injectAndInitialize(containerId);
        });
      },
    );
  }

  void _handleOpenDrawer(String id, String type) {
    final vm = ref.read(naverMapViewModelProvider.notifier);
    if (type == 'station') {
      vm.onStationSelected(id, 0, 0, null);
    } else if (type == 'route') {
      vm.onRouteSelected(id);
    }
  }

  void _handleCloseDrawer() {
    ref.read(bottomDrawerProvider.notifier).closeDrawer();
  }
}
