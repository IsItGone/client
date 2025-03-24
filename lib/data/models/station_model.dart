import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
part 'station_model.g.dart';

@JsonSerializable()
class StationModel {
  final String id;
  final String name;
  final String description;
  final String address;
  final double latitude;
  final double longitude;
  final String? stopTime;
  final bool isDeparture;
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

  factory StationModel.fromJson(Map<String, dynamic> json) =>
      _$StationModelFromJson(json);

  Map<String, dynamic> toJson() => _$StationModelToJson(this);

  static List<StationModel> fromJsonList(List<dynamic> jsonList) => jsonList
      .map((json) => StationModel.fromJson(json as Map<String, dynamic>))
      .toList();
}

class StationListModel {
  final List<StationModel>? stationList;
  StationListModel({this.stationList});

  factory StationListModel.fromJson(String jsonString) {
    List<dynamic> listFromJson = json.decode(jsonString);
    List<StationModel> stationList = <StationModel>[];

    stationList =
        listFromJson.map((route) => StationModel.fromJson(route)).toList();
    return StationListModel(stationList: stationList);
  }
}
