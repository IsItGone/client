import 'package:client/core/constants/route_colors.dart';
import 'package:client/data/graphql/index.dart';
import 'package:client/data/models/location_model.dart';
import 'package:client/data/models/station_model.dart';
import 'package:flutter/material.dart';

class RouteModel {
  final String id;
  final String name;
  List<StationModel> departureStations;
  final List<StationModel> arrivalStations;
  final List<LocationModel>? departurePath;
  final List<LocationModel>? arrivalPath;
  final Color color;

  RouteModel({
    required this.id,
    required this.name,
    required this.departureStations,
    required this.arrivalStations,
    required this.departurePath,
    required this.arrivalPath,
    required this.color,
  });

  static List<LocationModel> buildPath({
    List<LocationModel>? pathFromServer,
    List<StationModel>? stationList,
  }) {
    if (pathFromServer != null && pathFromServer.isNotEmpty) {
      return pathFromServer
          .map((l) =>
              LocationModel(latitude: l.latitude, longitude: l.longitude))
          .toList();
    }

    return stationList
            ?.map((s) => LocationModel(
                  latitude: s.latitude!,
                  longitude: s.longitude!,
                ))
            .whereType<LocationModel>()
            .toList() ??
        [];
  }

  factory RouteModel.fromRouteList(GRouteFields routeData) {
    final depStations = routeData.departureStations
            ?.whereType<GStationFields>()
            .map(StationModel.fromStation)
            .toList() ??
        [];
    final arrStations = routeData.arrivalStations
            ?.whereType<GStationFields>()
            .map(StationModel.fromStation)
            .toList() ??
        [];

    return RouteModel(
      id: routeData.id,
      name: routeData.name,
      departureStations: depStations,
      arrivalStations: arrStations,
      departurePath: buildPath(
        pathFromServer: routeData.departurePath
            ?.map((l) => LocationModel(
                  latitude: l!.latitude!,
                  longitude: l.longitude!,
                ))
            .toList(),
        stationList: depStations,
      ),
      arrivalPath: buildPath(
        pathFromServer: routeData.arrivalPath
            ?.map((l) => LocationModel(
                  latitude: l!.latitude!,
                  longitude: l.longitude!,
                ))
            .toList(),
        stationList: arrStations,
      ),
      color: RouteColors.getColor(routeData.id),
    );
  }

  factory RouteModel.fromRoute(GRouteFields routeData) {
    final routeId = routeData.id;

    return RouteModel(
      id: routeId,
      name: routeData.name,
      departureStations: routeData.departureStations?.map((s) {
            final compositeId = '${s?.id}_$routeId';
            return StationModel.fromStation(
              s as GStationFields,
              routeId: routeId,
            ).copyWith(compositeId: compositeId);
          }).toList() ??
          [],
      arrivalStations: routeData.arrivalStations
              ?.whereType<GStationFields>()
              .map(StationModel.fromStation)
              .toList() ??
          [],
      departurePath: (routeData.departurePath?.toList() ?? [])
          .map((location) => LocationModel(
                latitude: location!.latitude!,
                longitude: location.longitude!,
              ))
          .toList(),
      arrivalPath: (routeData.arrivalPath?.toList() ?? [])
          .map((location) => LocationModel(
                latitude: location!.latitude!,
                longitude: location.longitude!,
              ))
          .toList(),
      color: RouteColors.getColor(routeId),
    );
  }
}
