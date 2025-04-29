import 'package:client/core/constants/route_colors.dart';
import 'package:client/data/models/map_data_model.dart';
import 'package:client/data/models/route_model.dart';
import 'package:client/data/repositories/route_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

mixin RouteProviders {
  static final repo = Provider((_) => RouteRepository());

  // 1) 홈맵
  static final mapDataProvider =
      FutureProvider.autoDispose<MapDataModel>((ref) async {
    final mapData = await ref.watch(repo).getMapData();
    RouteColors.initializeColors(mapData.routes.map((r) => r.id).toList());

    return mapData;
  });

  // 2) Route Detail
  static final routeDetailProvider = FutureProvider.autoDispose
      .family<RouteModel, String>(
          (ref, id) => ref.watch(repo).getRouteDetail(id));

  // 3) Linear Routes
  static final linearRoutesProvider = FutureProvider.autoDispose
      .family<RouteModel, String>(
          (ref, id) => ref.watch(repo).getLinearRoutes(id));

  // 4) 이름으로 단일 노선
  static final routeByNameProvider = FutureProvider.autoDispose
      .family<RouteModel, String>(
          (ref, name) => ref.watch(repo).getRouteByname(name));
}
