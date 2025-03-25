import 'dart:developer';

import 'package:client/data/models/route_model.dart';
import 'package:client/data/models/station_model.dart';
import 'package:client/data/repositories/route_repository.dart';
import 'package:client/data/repositories/station_repository.dart';
import 'package:ferry/ferry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/data/graphql/queries/station/index.dart';
import 'package:client/data/graphql/queries/route/index.dart';

final routeRepositoryProvider = Provider<RouteRepository>((ref) {
  return RouteRepository();
});

final stationRepositoryProvider = Provider<StationRepository>((ref) {
  return StationRepository();
});

// 노선 정보 제공
final routesProvider =
    StreamProvider<OperationResponse<GGetRoutesData, GGetRoutesVars>>((ref) {
  final repository = ref.watch(routeRepositoryProvider);
  return repository.getRoutes();
});

// 역 정보 제공
final stationsProvider =
    StreamProvider<OperationResponse<GGetStationsData, GGetStationsVars>>(
        (ref) {
  final repository = ref.watch(stationRepositoryProvider);
  return repository.getStations();
});

// 가공된 노선 데이터 제공 (UI에서 사용하기 쉬운 형태로)
final routeDataProvider = FutureProvider<List<RouteModel>>((ref) async {
  final response = await ref.watch(routesProvider.future);

  if (response.hasErrors) {
    final errorMessage =
        response.graphqlErrors?.first.message ?? '알 수 없는 오류가 발생했습니다.';
    throw Exception('노선 데이터를 불러오는데 실패했습니다: $errorMessage');
  } else if (response.data == null) {
    throw Exception('노선 데이터가 없습니다.');
  }

  return response.data!.getRoutes!
      .map((routeData) => RouteModel.fromGraphQL(routeData!))
      .toList();
});

// 가공된 정류장 데이터 제공
final stationDataProvider = FutureProvider<List<StationModel>>((ref) async {
  final response = await ref.watch(stationsProvider.future);

  if (response.hasErrors) {
    final errorMessage =
        response.graphqlErrors?.first.message ?? '알 수 없는 오류가 발생했습니다.';
    throw Exception('정류장 데이터를 불러오는데 실패했습니다: $errorMessage');
  } else if (response.data == null) {
    throw Exception('정류장 데이터가 없습니다.');
  }

  return response.data!.getStations!
      .map((stationData) => StationModel.fromGraphQL(stationData!))
      .toList();
});
