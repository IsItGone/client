import 'package:client/src/features/home/home_screen.dart';
import 'package:client/src/features/linear_routes/linear_routes_screen.dart';

import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      // GoRoute(
      //   path: '/test',
      //   builder: (context, state) => const TestScreen(),
      // ),
      GoRoute(
        path: '/linear-routes/:routeId',
        builder: (context, state) {
          final routeId = state.pathParameters['routeId']!;
          final extra = state.extra as Map<String, dynamic>?;
          final stationId =
              extra != null ? extra['stationId'] as String? : null;
          return LinearRoutesScreen(routeId: routeId, stationId: stationId);
        },
      ),
      // Add more routes here
    ],
  );
});
