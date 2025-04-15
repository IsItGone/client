import 'package:client/core/graphql/client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:client/core/router/router.dart';
import 'package:client/core/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); //플러터 엔진 초기화

  // GraphQL 클라이언트 초기화
  await GraphQLClient.initClient();
  runApp(const ProviderScope(child: IsItGoneApp()));
}

class IsItGoneApp extends ConsumerWidget {
  const IsItGoneApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: "지나갔나요?",
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
