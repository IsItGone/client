import 'package:client/data/graphql/index.dart';
import 'package:client/data/models/map_data_model.dart';
import 'package:client/data/models/route_model.dart';
import 'package:client/data/models/station_model.dart';
import 'package:client/data/repositories/graphql_repository.dart';

import 'package:ferry/ferry.dart';

class RouteRepository extends GraphQLRepository {
  Future<R> _fetch<R, TData, TVars>(
    OperationRequest<TData, TVars> req,
    R Function(TData) convert,
  ) =>
      run(req, convert: convert);

  /// 지도: 노선 + 정류장
  Future<MapDataModel> getMapData() => _fetch(
        GGetMapDataReq(
          (b) => b
            ..vars.withPath = true
            ..vars.withStations = true
            ..vars.withLocation = true
            ..vars.withDetail = false
            ..vars.withRoutes = false,
        ),
        (d) => MapDataModel(
          routes: d.getRoutes!
              .whereType<GRouteFields>()
              .map(RouteModel.fromRouteList)
              .toList(),
          stations: d.getStations!
              .whereType<GStationFields>()
              .map(StationModel.fromStationList)
              .toList(),
        ),
      );

  /// Route Detail
  Future<RouteModel> getRouteDetail(String id) => _fetch(
        GGetRouteByIdReq(
          (b) => b
            ..vars.id = id
            ..vars.withPath = false
            ..vars.withStations = true
            ..vars.withLocation = true
            ..vars.withDetail = true
            ..vars.withRoutes = false,
        ),
        (d) => RouteModel.fromRoute(d.getRouteById as GRouteFields),
      );

  /// Linear Routes
  Future<RouteModel> getLinearRoutes(String id) => _fetch(
        GGetRouteByIdReq(
          (b) => b
            ..vars.id = id
            ..vars.withPath = false
            ..vars.withStations = true
            ..vars.withLocation = true
            ..vars.withDetail = true
            ..vars.withRoutes = false,
        ),
        (d) => RouteModel.fromRoute(d.getRouteById as GRouteFields),
      );

  /// getRouteByName
  Future<RouteModel> getRouteByname(String name) => _fetch(
        GGetRouteByNameReq(
          (b) => b
            ..vars.name = name
            ..vars.withPath = false
            ..vars.withStations = false
            ..vars.withLocation = false
            ..vars.withDetail = false
            ..vars.withRoutes = false,
        ),
        (d) => RouteModel.fromRoute(d.getRouteByName as GRouteFields),
      );
}
