import 'dart:developer';

import 'package:client/data/graphql/queries/station/index.dart';
import 'package:client/data/repositories/graphql_repository.dart';

import 'package:ferry/ferry.dart';

class StationRepository extends GraphQLRepository {
  // getStations
  Future<OperationResponse<GGetStationsData, GGetStationsVars>>
      getStations() async {
    try {
      final request = GGetStationsReq();
      final response = await executeQuery(request);
      return response;
    } catch (e) {
      log('예상치 못한 오류: $e');
      throw Exception('서비스 연결에 문제가 발생했습니다.');
    }
  }

  // getStationById
  Future<OperationResponse<GGetStationByIdData, GGetStationByIdVars>>
      getStationById(String id) async {
    try {
      final request = GGetStationByIdReq((b) => b..vars.id = id);

      final response = await executeQuery(request);
      return response;
    } catch (e) {
      log('예상치 못한 오류: $e');
      throw Exception('서비스 연결에 문제가 발생했습니다.');
    }
  }
}
