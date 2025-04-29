import 'package:client/data/models/route_model.dart';
import 'package:client/data/models/station_model.dart';
import 'package:client/data/repositories/station_repository.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

// TODO : 캐싱 및 자동 폐기 최적화?
mixin StationProviders {
  static final repo = Provider((_) => StationRepository());

  // 1) Station Detail
  static final stationDetailProvider = FutureProvider.autoDispose
      .family<StationModel, String>(
          (ref, id) => ref.watch(repo).getStationDetail(id));

  // 2) Station Info
  static final stationInfoProvider = FutureProvider.autoDispose
      .family<RouteModel, String>(
          (ref, id) => ref.watch(repo).getStationInfo(id));

  // 3) 검색
  static final searchProvider = FutureProvider.autoDispose
      .family<List<StationModel>, String>(
          (ref, keyword) => ref.watch(repo).searchStations(keyword));
}
