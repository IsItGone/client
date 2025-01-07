import 'package:client/src/common/widgets/bottom_drawer/components/place_detail.dart';
import 'package:client/src/common/widgets/bottom_drawer/components/route_detail.dart';
import 'package:client/src/common/widgets/bottom_drawer/components/station_detail.dart';
import 'package:client/src/common/widgets/bottom_drawer/providers/bottom_drawer_provider.dart';
import 'package:client/src/common/widgets/bottom_drawer/view_models/bottom_drawer_view_model.dart';
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
        InfoType.station => StationDetail(drawerState.infoId),
        InfoType.place => const PlaceDetail(),
        InfoType.route => RouteDetail(drawerState.infoId),
      },
    );
  }
}
