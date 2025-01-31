import 'dart:developer';

import 'package:client/src/common/widgets/bottom_drawer/components/station_detail_info.dart';
import 'package:client/src/common/widgets/bottom_drawer/providers/bottom_drawer_provider.dart';
import 'package:client/src/config/theme.dart';
import 'package:flutter/foundation.dart';
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

  Widget _buildRouteButton(int index) {
    final isSelected = selectedIndex == index;
    final buttonStyle = isSelected
        ? FilledButton.styleFrom(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            backgroundColor: AppTheme.lineColors[index],
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            minimumSize: const Size(0, kIsWeb ? 48 : 36),
          )
        : OutlinedButton.styleFrom(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            side: BorderSide(color: AppTheme.lineColors[index]),
            minimumSize: const Size(0, kIsWeb ? 48 : 36),
          );

    final buttonTextStyle = TextStyle(
      color: isSelected ? Colors.white : AppTheme.lineColors[index],
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0), // 버튼 사이 간격
      child: isSelected
          ? FilledButton(
              onPressed: () {
                setState(() {
                  selectedIndex = index;
                });
              },
              style: buttonStyle,
              child: Text(
                routes[index],
                style: buttonTextStyle,
              ),
            )
          : OutlinedButton(
              onPressed: () {
                setState(() {
                  selectedIndex = index;
                });
              },
              style: buttonStyle,
              child: Text(
                routes[index],
                style: buttonTextStyle,
              ),
            ),
    );
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
                        return _buildRouteButton(index);
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
              routes: routes,
              selectedIndex: selectedIndex,
            ),
          ),
        ],
      ),
    );
  }
}
