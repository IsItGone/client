import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:client/src/config/theme.dart';
import 'package:go_router/go_router.dart';

class LinearRouteButton extends StatelessWidget {
  final String routeId;
  final String? stationId;

  const LinearRouteButton({
    required this.routeId,
    this.stationId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        log('$routeId $stationId');
        context.push(
          '/linear-routes/$routeId',
          extra: stationId != null ? {'stationId': stationId} : null,
        );
      },
      child: Row(
        children: [
          Image.asset(
            'assets/icons/linear_routes.png',
            width: 20,
            height: 20,
          ),
          const SizedBox(width: 6),
          Text(
            "노선표",
            style: AppTheme.textTheme.titleLarge,
          ),
        ],
      ),
    );
  }
}
