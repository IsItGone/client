import 'dart:developer';

import 'package:client/core/constants/route_colors.dart' show RouteColors;
import 'package:client/features/home/widgets/bottom_drawer/widgets/place_detail.dart';
import 'package:client/features/home/widgets/bottom_drawer/widgets/route_detail.dart';
import 'package:client/features/home/widgets/bottom_drawer/widgets/station_detail.dart';
import 'package:client/features/home/widgets/bottom_drawer/models/info_type.dart';
import 'package:client/features/home/widgets/bottom_drawer/providers/bottom_drawer_provider.dart';
import 'package:client/data/providers/station_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BottomDrawer extends ConsumerWidget {
  const BottomDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drawerState = ref.watch(bottomDrawerProvider);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: drawerState.isDrawerOpen
          ? MediaQuery.of(context).size.height * 0.33
          : 0,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: switch (drawerState.infoType) {
        InfoType.station => _buildStationDetail(
            ref,
            drawerState.stationId,
            drawerState.routeId,
          ),
        InfoType.place => const PlaceDetail(),
        InfoType.route => RouteDetail(drawerState.routeId),
      },
    );
  }
}

Widget _buildStationDetail(WidgetRef ref, String? stationId, String? routeId) {
  if (stationId == null) {
    return const Center(child: Text('정류장을 선택하세요.'));
  }

  final stationAsync =
      ref.watch(StationProviders.stationByIdProvider(stationId));

  return stationAsync.when(
    data: (station) {
      if (station.routes == null || station.routes!.isEmpty) {
        return const Center(
          child: Text('해당 정류장에 연결된 노선이 없습니다.'),
        );
      }

      String selectedRouteId;
      log('routeId: $routeId');

      if (routeId != null &&
          routeId.isNotEmpty &&
          station.routes!.contains(routeId)) {
        selectedRouteId = routeId;
      } else {
        selectedRouteId = station.routes![0];
      }
      final selectedColor = RouteColors.getColor(selectedRouteId);

      return StationDetail(
        stationId,
        routeIds: station.routes!,
        selectedRouteId: selectedRouteId,
        selectedColor: selectedColor,
      );
    },
    loading: () => const Center(child: CircularProgressIndicator()),
    error: (error, stack) => Center(child: Text('오류가 발생했습니다: $error')),
  );
}
