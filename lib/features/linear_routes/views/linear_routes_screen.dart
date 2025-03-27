import 'package:client/core/constants/route_colors.dart';
import 'package:client/core/theme/theme.dart';
import 'package:client/data/providers/route_providers.dart';
import 'package:client/features/linear_routes/widgets/linear_routes_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LinearRoutesScreen extends ConsumerWidget {
  final String routeId;
  final String? stationId;

  const LinearRoutesScreen({
    super.key,
    required this.routeId,
    this.stationId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routebyIdAsync = ref.watch(RouteProviders.routeByIdProvider(routeId));

    return routebyIdAsync.when(
      data: (route) {
        return Scaffold(
            appBar: AppBar(
              title: Text(
                route.name,
              ),
              foregroundColor: AppTheme.mainWhite,
              backgroundColor: RouteColors.getColor(routeId),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  context.pop();
                },
              ),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: LinearRoutesDetail(
                      stationId,
                      routeId: routeId,
                      departureStations: route.departureStations,
                      arrivalStations: route.arrivalStations,
                    ),
                  ),
                  // Text('Route ID: $routeId'),
                  // if (stationId != null) Text('Station ID: $stationId'),
                ],
              ),
            ));
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Text('오류가 발생했습니다: $error'),
      ),
    );
  }
}
