import 'package:client/data/graphql/queries/route/index.dart';
import 'package:client/data/graphql/queries/station/__generated__/get_stations.data.gql.dart';
import 'package:client/data/models/station_model.dart';

class RouteModel {
  final String id;
  final String name;
  final List<StationModel> departureStations;
  final List<StationModel> arrivalStations;

  RouteModel({
    required this.id,
    required this.name,
    required this.departureStations,
    required this.arrivalStations,
  });

  factory RouteModel.fromGraphQL(GGetRoutesData_routes routeData) {
    return RouteModel(
      id: routeData.id,
      name: routeData.name,
      departureStations: (routeData.departureStations as List<dynamic>? ?? [])
          .map((station) =>
              StationModel.fromGraphQL(station as GGetStationsData_stations))
          .toList(),
      arrivalStations: (routeData.arrivalStations as List<dynamic>? ?? [])
          .map((station) =>
              StationModel.fromGraphQL(station as GGetStationsData_stations))
          .toList(),
    );
  }
}
