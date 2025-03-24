import 'package:client/features/home/widgets/bottom_drawer/widgets/station_detail_info.dart';
import 'package:client/shared/widgets/linear_route_button.dart';
import 'package:client/shared/widgets/route_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StationDetail extends ConsumerStatefulWidget {
  final String stationId;
  const StationDetail(this.stationId, {super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _StationDetailState();
}

class _StationDetailState extends ConsumerState<StationDetail> {
  final List<String> routes = ['1', '4', '5'];
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
                LinearRouteButton(
                  routeId: routes[selectedIndex],
                  stationId: widget.stationId,
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
