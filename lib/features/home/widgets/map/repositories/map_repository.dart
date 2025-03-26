import 'package:client/data/models/route_model.dart';
import 'package:client/data/models/station_model.dart';
import 'package:client/data/repositories/route_repository.dart';
import 'package:client/data/repositories/station_repository.dart';

class MapRepository {
  final RouteRepository _routeRepository;
  final StationRepository _stationRepository;

  MapRepository({
    required RouteRepository routeRepository,
    required StationRepository stationRepository,
  })  : _routeRepository = routeRepository,
        _stationRepository = stationRepository;

  Future<List<RouteModel>> loadAllRoutes() async {
    final response = await _routeRepository.getRoutes();

// TODO : 예외처리 통합관리
    if (response.hasErrors || response.data == null) {
      throw Exception('노선 데이터를 불러오는데 실패했습니다.');
    }

    return response.data!.getRoutes!
        .map((routeData) => RouteModel.fromRouteList(routeData!))
        .toList();
  }

  Future<List<StationModel>> loadAllStations() async {
    final response = await _stationRepository.getStations();

    if (response.hasErrors || response.data == null) {
      throw Exception('정류장 데이터를 불러오는데 실패했습니다.');
    }

    return response.data!.getStations!
        .map((stationData) => StationModel.fromStationList(stationData!))
        .toList();
  }
}
