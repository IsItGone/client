import 'package:client/core/graphql/client.dart';
import 'package:ferry/ferry.dart';

abstract class GraphQLRepository {
  final Client _client = GraphQLClient.client;

  // 쿼리 실행 메서드
  Stream<OperationResponse<TData, TVars>> executeQuery<TData, TVars>(
    OperationRequest<TData, TVars> request, {
    FetchPolicy? fetchPolicy,
  }) {
    return _client.request(
      request,
      //  fetchPolicy: fetchPolicy
    );
  }
}
