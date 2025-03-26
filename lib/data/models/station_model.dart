import 'dart:developer';

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

  const StationModel({
    required this.id,
    this.name,
    this.description,
    this.address,
    this.latitude,
    this.longitude,
    this.stopTime,
    this.isDeparture,
    this.routes,
  });

  factory StationModel.fromStationList(
      GGetStationsData_getStations stationData) {
    return StationModel(
      id: stationData.id,
      name: stationData.name,
      description: stationData.description,
      address: stationData.address,
      latitude: stationData.latitude,
      longitude: stationData.longitude,
      stopTime: stationData.stopTime,
      isDeparture: stationData.isDeparture,
      routes: stationData.routes?.map((e) => e.toString()).toList(),
    );
  }
  factory StationModel.fromStation(dynamic stationData) {
    List<String>? routes;
    if (stationData is GGetStationByIdData_getStationById) {
      routes = stationData.routes?.map((e) => e.toString()).toList();
    } else {
      routes =
          stationData.routes != null ? List.from(stationData.routes) : null;
    }

    return StationModel(
      id: stationData.id,
      name: stationData.name,
      description: stationData.description,
      address: stationData.address,
      latitude: stationData.latitude,
      longitude: stationData.longitude,
      stopTime: stationData.stopTime,
      isDeparture: stationData.isDeparture,
      routes: routes,
    );
  }
}
