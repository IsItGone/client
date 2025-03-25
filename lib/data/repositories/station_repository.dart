import 'dart:developer';

import 'package:client/data/graphql/queries/station/index.dart';
import 'package:client/data/repositories/graphql_repository.dart';

import 'package:ferry/ferry.dart';

class StationRepository extends GraphQLRepository {
  // 정류장 데이터 가져오기
  Stream<OperationResponse<GGetStationsData, GGetStationsVars>> getStations() {
    try {
      final request = GGetStationsReq();
      return executeQuery(request).handleError((error) {
        log('정류장 정보 조회 중 오류 발생: $error');
        throw Exception('정류장 데이터를 불러오는데 실패했습니다.');
      });
    } catch (e) {
      log('예상치 못한 오류: $e');
      throw Exception('서비스 연결에 문제가 발생했습니다.');
    }
  }
}
