import 'dart:developer';

import 'package:client/data/graphql/queries/route/index.dart';
import 'package:client/data/repositories/graphql_repository.dart';

import 'package:ferry/ferry.dart';

class RouteRepository extends GraphQLRepository {
  // getRoutes
  Future<OperationResponse<GGetRoutesData, GGetRoutesVars>> getRoutes() async {
    try {
      final request = GGetRoutesReq();

      final response = await executeQuery(request);
      // log('getRoutes: ${response.data?.getRoutes}');
      return response;
    } catch (e) {
      log('예상치 못한 오류: $e');
      throw Exception('서비스 연결에 문제가 발생했습니다.');
    }
  }

  // getRouteById
  Future<OperationResponse<GGetRouteByIdData, GGetRouteByIdVars>> getRouteById(
      String id) async {
    try {
      final request = GGetRouteByIdReq((b) => b..vars.id = id);

      final response = await executeQuery(request);
      return response;
    } catch (e) {
      log('예상치 못한 오류: $e');
      throw Exception('서비스 연결에 문제가 발생했습니다.');
    }
  }

  // getRouteByName
  Future<OperationResponse<GGetRouteByNameData, GGetRouteByNameVars>>
      getRouteByName(String name) async {
    try {
      final request = GGetRouteByNameReq((b) => b..vars.name = name);

      final response = await executeQuery(request);
      return response;
    } catch (e) {
      log('예상치 못한 오류: $e');
      throw Exception('서비스 연결에 문제가 발생했습니다.');
    }
  }
}
