import 'package:client/data/models/route_model.dart';
import 'package:client/data/models/station_model.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

// 앱(Android/iOS) 빌드: 동기 import
import 'widgets/app/naver_map_app.dart'
    if (dart.library.js_interop) 'widgets/web/naver_map_web.dart' as native;

// 웹 빌드: deferred import
import 'widgets/app/naver_map_app.dart'
    if (dart.library.js_interop) 'widgets/web/naver_map_web.dart'
    deferred as deffered_map show NaverMapWidget;

export 'widgets/app/naver_map_app.dart'
    if (dart.library.js_interop) 'widgets/web/naver_map_web.dart';

class NaverMapWidget extends StatelessWidget {
  final List<RouteModel> routes;
  final List<StationModel> stations;
  const NaverMapWidget({
    super.key,
    required this.routes,
    required this.stations,
  });

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      // 웹: deffered_map 라이브러리 로드 후 렌더
      return FutureBuilder(
        future: deffered_map.loadLibrary(),
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          return deffered_map.NaverMapWidget(
            routes: routes,
            stations: stations,
          );
        },
      );
    } else {
      // 모바일: 동기 import 된 구현체 바로 사용
      return native.NaverMapWidget(
        routes: routes,
        stations: stations,
      );
    }
  }
}
