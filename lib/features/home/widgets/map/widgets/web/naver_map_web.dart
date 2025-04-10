import 'dart:developer';
import 'dart:js_interop';
import 'dart:ui_web' as ui_web;
import 'package:client/data/models/route_model.dart';
import 'package:client/data/models/station_model.dart';
import 'package:client/data/providers/route_providers.dart';
import 'package:client/features/home/widgets/map/widgets/web/js_interop_web.dart';
import 'package:web/web.dart' as web;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/data/providers/station_providers.dart';
import 'package:client/features/home/widgets/bottom_drawer/providers/bottom_drawer_provider.dart';
import 'package:client/features/home/widgets/map/providers/naver_map_providers.dart';
import 'package:client/core/theme/theme.dart';

class NaverMapWidget extends ConsumerStatefulWidget {
  const NaverMapWidget({super.key});

  @override
  ConsumerState<NaverMapWidget> createState() => _NaverMapWidgetState();
}

class _NaverMapWidgetState extends ConsumerState<NaverMapWidget> {
  late final String clientId;
  late List<RouteModel> _routeModels;
  late List<StationModel> _stationModels;

  bool _isMapInitialized = false;
  bool _isDataLoaded = false;

  @override
  void initState() {
    super.initState();
    clientId = ref.read(naverMapClientIdProvider);
    _injectNaverMapScript();
    _registerViewFactory();
    _loadData();
  }

  void _injectNaverMapScript() {
    if (web.document.querySelector('script#naver-map-script') != null) return;

    final script =
        web.document.createElement('script') as web.HTMLScriptElement;
    script.id = 'naver-map-script';
    script.type = 'text/javascript';
    script.src =
        'https://openapi.map.naver.com/openapi/v3/maps.js?ncpClientId=$clientId';
    script.defer = true;
    script.onload = ((web.Event event) {
      initializeNaverMap('map').toDart.then((_) {
        if (_isDataLoaded) {
          _drawData();
        }

        openDrawer = _handleOpenDrawer.toJS;
        closeDrawer = _handleCloseDrawer.toJS;

        setState(() {
          _isMapInitialized = true;
        });
      }).catchError((e) {
        log('지도 초기화 실패: $e');
      });
    }).toJS;

    web.document.head!.append(script);
  }

  void _registerViewFactory() {
    ui_web.platformViewRegistry.registerViewFactory('naver-map', (int viewId) {
      final element = web.document.createElement('div') as web.HTMLElement;
      element.id = 'map';
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

  Future<void> _loadData() {
    return Future.wait([
      ref.read(RouteProviders.routesDataProvider.future),
      ref.read(StationProviders.stationDataProvider.future),
    ]).then((results) {
      _routeModels = results[0] as List<RouteModel>;
      _stationModels = results[1] as List<StationModel>;

      _isDataLoaded = true;
      if (_isMapInitialized) {
        _drawData();
      }
    }).catchError((e) {
      log('데이터 로딩 오류: $e');
    });
  }

  void _drawData() {
    final jsRoutes =
        _routeModels.map((r) => r.toJSObject()).toList().jsify() as JSArray;
    final jsStations =
        _stationModels.map((s) => s.toJSObject()).toList().jsify() as JSArray;
    final jsColors = AppTheme.lineColors
        .map((c) => c.toARGB32().toRadixString(16))
        .toList()
        .jsify() as JSArray;

    naverMap.drawData(jsRoutes, jsStations, jsColors);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        HtmlElementView(
          viewType: 'naver-map',
        ),
        if (!_isMapInitialized)
          const Positioned.fill(
            child: ColoredBox(
              color: Colors.white,
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
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
