import 'package:client/src/config/theme.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '노선표 - Route: $routeId',
        ),
        foregroundColor: AppTheme.mainWhite,
        backgroundColor: AppTheme.lineColors[int.parse(routeId) - 1],
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
          children: [
            Text('Route ID: $routeId'),
            if (stationId != null) Text('Station ID: $stationId'),
          ],
        ),
      ),
    );
  }
}
