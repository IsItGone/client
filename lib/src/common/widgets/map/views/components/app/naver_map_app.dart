import 'package:client/src/common/widgets/bottom_drawer/bottom_drawer.dart';
import 'package:client/src/common/widgets/bottom_drawer/components/station_detail.dart';
import 'package:client/src/common/widgets/bottom_drawer/providers/bottom_drawer_provider.dart';
import 'package:client/src/common/widgets/map/views/components/app/naver_map_container.dart';
import 'package:client/src/common/widgets/map_search_bar.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NaverMapWidget extends ConsumerWidget {
  const NaverMapWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drawerState = ref.watch(bottomDrawerProvider);

    return Stack(
      children: [
        const Stack(
          children: [
            NaverMapContainer(),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: MapSearchBar(),
              ),
            ),
          ],
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          bottom: drawerState.isDrawerOpen
              ? 0
              : -MediaQuery.of(context).size.height * 0.33,
          left: 0,
          right: 0,
          child: BottomDrawer(
            isDrawerOpen: drawerState.isDrawerOpen,
            child: StationDetail(drawerState.stationId),
          ),
        ),
      ],
    );
  }
}
