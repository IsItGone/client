import 'dart:js_interop';

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

  factory StationModel.fromGraphQL(GGetStationsData_getStations stationData) {
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

  factory StationModel.fromRouteStation(dynamic stationData) {
    return StationModel(
      id: stationData.id,
      name: stationData.name,
      description: stationData.description,
      address: stationData.address,
      latitude: stationData.latitude,
      longitude: stationData.longitude,
      stopTime: stationData.stopTime,
      isDeparture: stationData.isDeparture,
      routes: stationData.routes != null
          ? List<String>.from(stationData.routes)
          : null,
    );
  }

  // JavaScript 변환을 위한 메서드 추가
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'stopTime': stopTime,
        'isDeparture': isDeparture,
        'routes': routes,
      };

  // JS 객체로 직접 변환하는 메서드
  JSObject toJSObject() => toJson().jsify() as JSObject;
}
