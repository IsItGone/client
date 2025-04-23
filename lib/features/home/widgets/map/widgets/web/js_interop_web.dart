import 'dart:js_interop';

import 'package:client/data/models/location_model.dart';
import 'package:client/data/models/route_model.dart';
import 'package:client/data/models/station_model.dart';

@JS('initializeNaverMap')
external JSPromise initializeNaverMap(String elementId);

@JS('selectRoute')
external void selectRouteJS(String routeId);

@JS()
external set openDrawer(JSFunction callback);

@JS()
external set closeDrawer(JSFunction callback);

@JS('naverMap')
external NaverMapJS get naverMap;

@JS()
@staticInterop
class NaverMapJS {}

extension NaverMapJSExtension on NaverMapJS {
  external void drawData(JSArray routes, JSArray stations, JSArray colors);
  external void selectRouteById(String routeId);
}

// RouteModel 웹 확장
extension RouteModelWebExtension on RouteModel {
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        // 'departureStations': departureStations.map((s) => s.toJson()).toList(),
        // 'arrivalStations': arrivalStations.map((s) => s.toJson()).toList(),
        'departurePath': departurePath?.map((l) => l.toJson()).toList(),
        'arrivalPath': arrivalPath?.map((l) => l.toJson()).toList(),
      };

  JSObject toJSObject() => toJson().jsify() as JSObject;
}

// StationModel 웹 확장
extension StationModelWebExtension on StationModel {
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        // 'stopTime': stopTime,
        'isDeparture': isDeparture,
        'routes': routes,
      };

  JSObject toJSObject() => toJson().jsify() as JSObject;
}

// LocationModel 웹 확장
extension LocationModelWebExtension on LocationModel {
  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
      };

  JSObject toJSObject() => toJson().jsify() as JSObject;
}
