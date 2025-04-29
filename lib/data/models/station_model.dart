import 'package:client/data/graphql/index.dart';

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
  final String? compositeId;

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
    this.compositeId,
  });

  StationModel copyWith({
    String? id,
    String? name,
    String? description,
    String? address,
    double? latitude,
    double? longitude,
    String? stopTime,
    bool? isDeparture,
    List<String>? routes,
    String? compositeId,
  }) {
    return StationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      stopTime: stopTime ?? this.stopTime,
      isDeparture: isDeparture ?? this.isDeparture,
      routes: routes ?? this.routes,
      compositeId: compositeId ?? this.compositeId,
    );
  }

  factory StationModel.fromStationList(GStationFields stationData) {
    return StationModel(
      id: stationData.id,
      latitude: stationData.latitude,
      longitude: stationData.longitude,
      isDeparture: stationData.isDeparture,
    );
  }

  factory StationModel.fromStation(GStationFields stationData,
      {String? routeId}) {
    // List<String>? routes;
    String? compositeId = routeId != null ? "${stationData.id}_$routeId" : null;

    // if (stationData is GGetStationByIdData_getStationById) {
    //   routes = stationData.routes?.map((e) => e.toString()).toList();
    // } else {
    //   routes =
    //       stationData.routes != null ? List.from(stationData.routes) : null;
    // }

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
      compositeId: compositeId,
    );
  }
}
