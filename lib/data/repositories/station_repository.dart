import 'package:client/data/graphql/index.dart';
import 'package:client/data/models/route_model.dart';
import 'package:client/data/models/station_model.dart';
import 'package:client/data/repositories/graphql_repository.dart';

import 'package:ferry/ferry.dart';

class StationRepository extends GraphQLRepository {
  Future<R> _fetch<R, TData, TVars>(
    OperationRequest<TData, TVars> req,
    R Function(TData) convert,
  ) =>
      run(req, convert: convert);

  /// Station Detail
  Future<StationModel> getStationDetail(String id) => _fetch(
        GGetStationByIdReq(
          (b) => b
            ..vars.id = id
            ..vars.withLocation = true
            ..vars.withDetail = true
            ..vars.withRoutes = true,
        ),
        (d) => StationModel.fromStation(d.getStationById as GStationFields),
      );

  /// Station Info
  Future<RouteModel> getStationInfo(String id) => _fetch(
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

  /// Search Stations
  Future<List<StationModel>> searchStations(String keyword) => _fetch(
        GSearchStationsByKeywordReq(
          (b) => b
            ..vars.keyword = keyword
            ..vars.withLocation = true
            ..vars.withDetail = true
            ..vars.withRoutes = false,
        ),
        (d) => d.searchStationsByKeyword!
            .whereType<GStationFields>()
            .map(StationModel.fromStation)
            .toList(),
      );
}
