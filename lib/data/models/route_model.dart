import 'package:client/data/graphql/queries/route/index.dart';
import 'package:client/data/models/station_model.dart';

class RouteModel {
  final String id;
  final String name;
  final List<StationModel> departureStations;
  final List<StationModel> arrivalStations;

  const RouteModel({
    required this.id,
    required this.name,
    required this.departureStations,
    required this.arrivalStations,
  });

  factory RouteModel.fromGraphQL(GGetRoutesData_getRoutes routeData) {
    return RouteModel(
      id: routeData.id,
      name: routeData.name,
      departureStations: (routeData.departureStations?.toList() ?? [])
          .where((station) => station != null)
          .map((station) => StationModel.fromRouteStation(station))
          .toList(),
      arrivalStations: (routeData.arrivalStations?.toList() ?? [])
          .where((station) => station != null)
          .map((station) => StationModel.fromRouteStation(station))
          .toList(),
    );
  }
}
