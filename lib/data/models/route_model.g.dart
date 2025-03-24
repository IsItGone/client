// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RouteModel _$RouteModelFromJson(Map<String, dynamic> json) => RouteModel(
      id: json['id'] as String,
      name: json['name'] as String,
      departureStations: (json['departureStations'] as List<dynamic>)
          .map((e) => StationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      arrivalStations: (json['arrivalStations'] as List<dynamic>)
          .map((e) => StationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RouteModelToJson(RouteModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'departureStations':
          instance.departureStations.map((e) => e.toJson()).toList(),
      'arrivalStations':
          instance.arrivalStations.map((e) => e.toJson()).toList(),
    };
