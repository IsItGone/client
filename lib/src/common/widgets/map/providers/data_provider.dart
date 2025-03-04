import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/src/common/widgets/map/data/models/station_model.dart';
import 'package:client/src/common/widgets/map/data/models/route_model.dart';
import 'package:client/src/common/widgets/map/data/repositories/map_repository.dart';

final mapRepositoryProvider = Provider<MapRepository>((ref) {
  return MapRepository(baseUrl: '');
});

final stationDataProvider = FutureProvider<List<StationModel>>((ref) async {
  final repository = ref.read(mapRepositoryProvider);
  return await repository.loadAllStations();
});

final routeDataProvider = FutureProvider<List<RouteModel>>((ref) async {
  final repository = ref.read(mapRepositoryProvider);
  return await repository.loadAllRoutes();
});
