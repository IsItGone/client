import 'package:client/core/constants/route_colors.dart';
import 'package:client/data/graphql/queries/route/index.dart';
import 'package:client/data/models/location_model.dart';
import 'package:client/data/models/station_model.dart';
import 'package:flutter/material.dart';

class RouteModel {
  final String id;
  final String name;
  final List<StationModel> departureStations;
  final List<StationModel> arrivalStations;
  final List<LocationModel>? departurePath;
  final List<LocationModel>? arrivalPath;
  final Color color;

  const RouteModel({
    required this.id,
    required this.name,
    required this.departureStations,
    required this.arrivalStations,
    required this.departurePath,
    required this.arrivalPath,
    required this.color,
  });

  factory RouteModel.fromRouteList(GGetRoutesData_getRoutes routeData) {
    return RouteModel(
      id: routeData.id,
      name: routeData.name,
      departureStations: (routeData.departureStations?.toList() ?? [])
          .where((station) => station != null)
          .map((station) => StationModel.fromStation(station))
          .toList(),
      arrivalStations: (routeData.arrivalStations?.toList() ?? [])
          .where((station) => station != null)
          .map((station) => StationModel.fromStation(station))
          .toList(),
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
      color: RouteColors.getColor(routeData.id),
    );
  }

  factory RouteModel.fromRoute(GGetRouteByIdData_getRouteById routeData) {
    final routeId = routeData.id;

    return RouteModel(
      id: routeId,
      name: routeData.name,
      departureStations: (routeData.departureStations?.toList() ?? [])
          .where((station) => station != null)
          .map((station) {
        final compositeId = "${station?.id}_$routeId";
        final stationModel = StationModel.fromStation(
          station,
          routeId: routeId,
        );
        return stationModel.copyWith(compositeId: compositeId);
      }).toList(),
      arrivalStations: (routeData.arrivalStations?.toList() ?? [])
          .where((station) => station != null)
          .map((station) => StationModel.fromStation(station))
          .toList(),
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
