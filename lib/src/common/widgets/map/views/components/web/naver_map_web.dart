import 'dart:developer';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:ui_web' as ui;

import 'package:client/src/common/widgets/bottom_drawer/bottom_drawer.dart';
import 'package:client/src/common/widgets/bottom_drawer/components/station_detail.dart';
import 'package:client/src/common/widgets/bottom_drawer/providers/bottom_drawer_provider.dart';
import 'package:client/src/common/widgets/map/models/route_model.dart';
import 'package:client/src/common/widgets/map_search_bar.dart';
import 'package:client/src/config/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/src/common/widgets/map/providers/naver_map_providers.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

class NaverMapWidget extends ConsumerStatefulWidget {
  const NaverMapWidget({super.key});

  @override
  ConsumerState<NaverMapWidget> createState() => _NaverMapWidgetState();
}

class _NaverMapWidgetState extends ConsumerState<NaverMapWidget> {
  late String clientId;
  html.IFrameElement? _iframeElement;
  List<RouteModel> messageData = [];
  List<Color> colors = AppTheme.lineColors;

  @override
  void initState() {
    super.initState();
    clientId = ref.read(naverMapClientIdProvider);
    const origin = String.fromEnvironment('POST_MESSAGE_TARGET');
    const String env = String.fromEnvironment('ENV');
    html.window.localStorage['env'] = env;
    final String routesDataJson = jsonEncode({
      'data': {
        "routes": routesData,
        'colors': colors.map((color) => color.value.toRadixString(16)).toList(),
      },
      'origin': origin
    });

    ui.platformViewRegistry.registerViewFactory('naver-map', (int viewId) {
      _iframeElement = html.IFrameElement()
        ..style.width = '100%'
        ..style.height = '100%'
        ..src = 'map.html?clientId=$clientId'
        ..style.border = 'none'
        ..style.zIndex = '-1'
        ..onLoad.listen(
          (event) {
            _iframeElement?.contentWindow
                ?.postMessage(routesDataJson, origin); // map.html에 데이터 전달
          },
        );
      // HTML 메시지 수신 설정
      html.window.onMessage.listen((event) {
        final response = jsonDecode(event.data);
        if (event.origin != origin) {
          log('Untrusted origin: ${event.origin}');
          return;
        }
        final notifier = ref.read(bottomDrawerProvider.notifier);
        log('${notifier.isDrawerOpen}');

        if (response['action'] == 'openDrawer') {
          final stationId = response['data'];
          notifier.updateStationId(stationId);
          notifier.openDrawer();
        } else if (response['action'] == 'closeDrawer') {
          notifier.closeDrawer();
        }
      });
      return _iframeElement!;
    });

    // html.window.postMessage(routesDataJson, origin); // 현재 웹 페이지의 다른 부분에 데이터 전달
  }

  @override
  Widget build(BuildContext context) {
    final drawState = ref.watch(bottomDrawerProvider);

    return Stack(
      children: [
        const Positioned.fill(
          child: HtmlElementView(viewType: 'naver-map'),
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
          bottom: drawState.isDrawerOpen
              ? 0
              : -MediaQuery.of(context).size.height * 0.33,
          left: 0,
          right: 0,
          child: PointerInterceptor(
            child: SingleChildScrollView(
              child: BottomDrawer(
                isDrawerOpen: drawState.isDrawerOpen,
                child: StationDetail(drawState.stationId),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
