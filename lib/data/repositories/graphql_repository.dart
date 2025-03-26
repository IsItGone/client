import 'package:client/core/graphql/client.dart';
import 'package:ferry/ferry.dart';

abstract class GraphQLRepository {
  final Client _client = GraphQLClient.client;

  // 쿼리 실행 메서드
  Future<OperationResponse<TData, TVars>> executeQuery<TData, TVars>(
    OperationRequest<TData, TVars> request, {
    FetchPolicy? fetchPolicy,
  }) async {
    try {
      // GraphQL 요청 실행
      final response = await _client.request(request).first;
      return response;
    } catch (e) {
      throw Exception('GraphQL 요청 중 오류 발생: $e');
    }
  }
}
