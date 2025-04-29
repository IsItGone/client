import 'package:ferry/ferry.dart';
import 'package:ferry_hive_store/ferry_hive_store.dart';
import 'package:gql_http_link/gql_http_link.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'config.dart';

class GraphQLClient {
  static Client? _client;

  static Future<Client> initClient() async {
    if (_client != null) return _client!;

    // Hive 초기화
    await Hive.initFlutter();

    // 캐시 스토어 설정
    final box = await Hive.openBox('graphql');
    final store = HiveStore(box);
    final cache = Cache(
      store: store,
      typePolicies: {
        'Station': TypePolicy(
          keyFields: {
            'id': true,
            'compositeId': true
          }, // ID와 compositeId를 함께 사용하여 캐시 키 생성
        ),
      },
    );

    // HTTP 링크 설정
    final httpLink = HttpLink(GraphQLConfig.apiUrl,
        defaultHeaders: GraphQLConfig.defaultHeaders);

    // 클라이언트 생성
    _client = Client(
      link: httpLink,
      cache: cache,
      defaultFetchPolicies: {
        OperationType.query: FetchPolicy.CacheAndNetwork,
        OperationType.mutation: FetchPolicy.NetworkOnly,
        OperationType.subscription: FetchPolicy.CacheFirst,
      },
    );

    return _client!;
  }

  static Client get client {
    if (_client == null) {
      throw Exception('GraphQL 클라이언트가 초기화되지 않았습니다.');
    }
    return _client!;
  }
}
