import 'dart:developer';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:ui_web' as ui;

import 'package:client/src/common/widgets/bottom_drawer/bottom_drawer.dart';
import 'package:client/src/common/widgets/bottom_drawer/providers/bottom_drawer_provider.dart';
import 'package:client/src/common/widgets/map/models/route_model.dart';
import 'package:client/src/common/widgets/map/views/components/app/naver_map_app.dart';
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
    final String routesDataJson = jsonEncode({
      'data': {
        "routes": routesData,
        'colors': colors.map((color) => color.value.toRadixString(16)).toList()
      }
    });

    log('post target origin : $origin');
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
      return _iframeElement!;
    });

    html.window.onMessage.listen((event) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            messageData = RouteModel.fromJsonList(jsonDecode(event.data));
          });
        }
      });
    });

    // html.window.postMessage(routesDataJson, origin); // 현재 웹 페이지의 다른 부분에 데이터 전달
  }

  @override
  Widget build(BuildContext context) {
    final drawerState = ref.watch(bottomDrawerProvider);
    final drawerNotifier = ref.read(bottomDrawerProvider.notifier);

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
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: PointerInterceptor(
            child: BottomDrawer(
              drawerState: drawerState,
              drawerNotifier: drawerNotifier,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: messageData
                      .map((route) => buildRouteItem(route))
                      .toList(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

Widget buildRouteItem(RouteModel route) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Route Name: ${route.name}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text('ID: ${route.id}'),
        Column(
          children: route.departureStations.map((station) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  const Icon(Icons.train, color: Colors.green),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Station: ${station.name}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('Latitude: ${station.latitude}'),
                      Text('Longitude: ${station.longitude}'),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        const Divider(),
      ],
    ),
  );
}
