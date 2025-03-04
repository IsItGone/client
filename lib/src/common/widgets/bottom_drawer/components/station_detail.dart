import 'dart:developer';

import 'package:client/src/common/widgets/bottom_drawer/components/station_detail_info.dart';
import 'package:client/src/common/widgets/bottom_drawer/providers/bottom_drawer_provider.dart';
import 'package:client/src/common/widgets/route_button.dart';
import 'package:client/src/config/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class StationDetail extends ConsumerStatefulWidget {
  final String stationId;
  const StationDetail(this.stationId, {super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _StationDetailState();
}

class _StationDetailState extends ConsumerState<StationDetail> {
  final List<String> routes = ['1', '2', '3'];
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  void _onRouteButtonPressed(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final drawerState = ref.watch(bottomDrawerProvider);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Column(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: List.generate(
                      routes.length,
                      (index) {
                        return RouteButton(
                          index: int.parse(routes[index]),
                          isSelected: selectedIndex == index,
                          onPressed: () => _onRouteButtonPressed(index),
                          text: routes[index],
                          size: ButtonSize.md,
                        );
                      },
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    final routeId = routes[selectedIndex];
                    log('$routeId ${widget.stationId} ${drawerState.infoId}');
                    context.push('/linear-routes/$routeId', extra: {
                      'stationId': drawerState.infoId,
                    });
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
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: StationDetailInfo(
              stationId: widget.stationId,
              selectedIndex: int.parse(routes[selectedIndex]),
            ),
          ),
        ],
      ),
    );
  }
}
