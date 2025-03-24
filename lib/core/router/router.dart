import 'package:client/features/home/views/home_screen.dart';
import 'package:client/features/linear_routes/views/linear_routes_screen.dart';
import 'package:client/features/search/views/search_screen.dart';

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
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),
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
