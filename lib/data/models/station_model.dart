import 'package:client/data/graphql/queries/station/index.dart';

class StationModel {
  final String id;
  final String? name;
  final String? description;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? stopTime;
  final bool? isDeparture;
  final List<String>? routes;

  StationModel({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.stopTime,
    required this.isDeparture,
    this.routes,
  });
  // station_model.dart에 추가
  factory StationModel.fromGraphQL(GGetStationsData_stations stationData) {
    return StationModel(
      id: stationData.id,
      name: stationData.name,
      description: stationData.description,
      address: stationData.address,
      latitude: stationData.latitude,
      longitude: stationData.longitude,
      stopTime: stationData.stopTime,
      isDeparture: stationData.isDeparture,
      routes: stationData.routes?.map((e) => e ?? '').toList(),
    );
  }
}
