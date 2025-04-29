import 'package:client/core/graphql/client.dart';
import 'package:ferry/ferry.dart';

abstract class GraphQLRepository {
  final Client _client = GraphQLClient.client;

  Future<T> run<T, D, V>(
    OperationRequest<D, V> req, {
    T Function(D data)? convert,
  }) async {
    final res = await _client.request(req).take(2).last;
    if (res.hasErrors) throw Exception(res.graphqlErrors?.first.message);
    if (res.data == null) throw Exception('데이터 없음');
    return convert != null ? convert(res.data as D) : res.data as T;
  }
}
