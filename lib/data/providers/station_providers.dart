import 'package:client/data/models/station_model.dart';
import 'package:client/data/repositories/station_repository.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

// TODO : 캐싱 및 자동 폐기 최적화?
mixin StationProviders {
  static final stationRepositoryProvider =
      Provider((ref) => StationRepository());

  static final stationDataProvider =
      FutureProvider<List<StationModel>>((ref) async {
    final repository = ref.watch(stationRepositoryProvider);
    final response = await repository.getStations();

    if (response.hasErrors) {
      final errorMessage =
          response.graphqlErrors?.first.message ?? '알 수 없는 오류가 발생했습니다.';
      throw Exception('정류장 데이터를 불러오는데 실패했습니다: $errorMessage');
    } else if (response.data == null) {
      throw Exception('정류장 데이터가 없습니다.');
    }

    return response.data!.getStations!
        .map((stationData) => StationModel.fromStationList(stationData!))
        .toList();
  });

  static final stationByIdProvider = FutureProvider.family
      .autoDispose<StationModel, String>((ref, stationId) async {
    final repository = ref.watch(StationProviders.stationRepositoryProvider);
    final response = await repository.getStationById(stationId);

    if (response.hasErrors) {
      final errorMessage =
          response.graphqlErrors?.first.message ?? '알 수 없는 오류가 발생했습니다.';
      throw Exception('정류장 데이터를 불러오는데 실패했습니다: $errorMessage');
    } else if (response.data == null) {
      throw Exception('정류장 데이터가 없습니다.');
    }

    return StationModel.fromStation(response.data!.getStationById!);
  });

  static final searchStationByKeywordProvider =
      FutureProvider.family<List<StationModel>, String>((ref, keyword) async {
    final repository = ref.watch(StationProviders.stationRepositoryProvider);
    final response = await repository.searchStationsByKeyword(keyword);

    if (response.hasErrors) {
      final errorMessage =
          response.graphqlErrors?.first.message ?? '알 수 없는 오류가 발생했습니다.';
      throw Exception('검색 데이터를 불러오는데 실패했습니다: $errorMessage');
    } else if (response.data == null) {
      throw Exception('검색 데이터가 없습니다.');
    }

    return response.data!.searchStationsByKeyword!
        .map((stationData) => StationModel.fromStation(stationData!))
        .toList();
  });
}
