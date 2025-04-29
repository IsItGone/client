import 'route_model.dart';
import 'station_model.dart';

class MapDataModel {
  final List<RouteModel> routes;
  final List<StationModel> stations;
  const MapDataModel({required this.routes, required this.stations});
}
