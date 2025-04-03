import 'package:client/core/constants/route_colors.dart';
import 'package:client/data/graphql/queries/route/index.dart';
import 'package:client/data/models/route_model.dart';
import 'package:client/data/repositories/route_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// TODO:
// // 공통 오류 처리 및 데이터 변환 함수
// Future<RouteModel> fetchRouteData(
//     Future<OperationResponse> Function() queryFunction) async {
//   final response = await queryFunction();

// if (response.hasErrors) {
//   final errorMessage =
//       response.graphqlErrors?.first.message ?? '알 수 없는 오류가 발생했습니다.';
//   throw Exception('노선 데이터를 불러오는데 실패했습니다: $errorMessage');
// } else if (response.data == null) {
//   throw Exception('노선 데이터가 없습니다.');
// }

//   return RouteModel.fromRouteList(response.data);
// }

mixin RouteProviders {
  static final routeRepositoryProvider = Provider((ref) => RouteRepository());

  static final routesDataProvider =
      FutureProvider<List<RouteModel>>((ref) async {
    final repository = ref.watch(routeRepositoryProvider);
    final response = await repository.getRoutes();

    if (response.hasErrors) {
      final errorMessage =
          response.graphqlErrors?.first.message ?? '알 수 없는 오류가 발생했습니다.';
      throw Exception('노선 데이터를 불러오는데 실패했습니다: $errorMessage');
    } else if (response.data == null) {
      throw Exception('노선 데이터가 없습니다.');
    }

    final routes = response.data!.getRoutes!
        .map((routeData) => RouteModel.fromRouteList(routeData!))
        .toList();
    RouteColors.initializeColors(routes.map((route) => route.id).toList());

    return routes;
  });

  static final routeByIdProvider =
      FutureProvider.family.autoDispose<RouteModel, String>((ref, id) async {
    final repository = ref.watch(routeRepositoryProvider);
    final response = await repository.getRouteById(id);

    if (response.hasErrors) {
      final errorMessage =
          response.graphqlErrors?.first.message ?? '알 수 없는 오류가 발생했습니다.';
      throw Exception('노선 데이터를 불러오는데 실패했습니다: $errorMessage');
    } else if (response.data == null) {
      throw Exception('노선 데이터가 없습니다.');
    }

    return RouteModel.fromRoute(response.data!.getRouteById!);
  });

  static final routeByNameProvider =
      FutureProvider.family.autoDispose<RouteModel, String>((ref, name) async {
    final repository = ref.watch(routeRepositoryProvider);
    final response = await repository.getRouteByName(name);

    if (response.hasErrors) {
      final errorMessage =
          response.graphqlErrors?.first.message ?? '알 수 없는 오류가 발생했습니다.';
      throw Exception('노선 데이터를 불러오는데 실패했습니다: $errorMessage');
    } else if (response.data == null) {
      throw Exception('노선 데이터가 없습니다.');
    }

    return RouteModel.fromRoute(
        response.data!.getRouteByName! as GGetRouteByIdData_getRouteById);
  });
}
