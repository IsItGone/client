import 'package:client/src/common/widgets/map/data/models/route_model.dart';
import 'package:client/src/common/widgets/map/data/models/station_model.dart';
import 'package:flutter/services.dart';

Future<List<RouteModel>> loadAllRoutes() async {
  final String response =
      await rootBundle.loadString("assets/data/routesData.json");
  final data = RouteListModel.fromJson(response).routeList ?? <RouteModel>[];
  return data;
}

Future<List<StationModel>> loadAllStations() async {
  final String response =
      await rootBundle.loadString("assets/data/stationsData.json");
  final data =
      StationListModel.fromJson(response).stationList ?? <StationModel>[];
  return data;
}
