import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:client/src/common/widgets/map/data/models/station_model.dart';
part 'route_model.g.dart';

@JsonSerializable(explicitToJson: true)
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

  factory RouteModel.fromJson(Map<String, dynamic> json) =>
      _$RouteModelFromJson(json);

  Map<String, dynamic> toJson() => _$RouteModelToJson(this);

  List<StationModel> get allStations => [
        ...departureStations,
        ...arrivalStations,
      ];
}

class RouteListModel {
  final List<RouteModel>? routeList;
  RouteListModel({this.routeList});

  factory RouteListModel.fromJson(String jsonString) {
    List<dynamic> listFromJson = json.decode(jsonString);
    List<RouteModel> routeList = <RouteModel>[];

    routeList =
        listFromJson.map((route) => RouteModel.fromJson(route)).toList();
    return RouteListModel(routeList: routeList);
  }
}
