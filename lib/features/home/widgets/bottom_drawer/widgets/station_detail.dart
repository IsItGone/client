import 'package:client/features/home/widgets/bottom_drawer/widgets/station_detail_info.dart';
import 'package:client/features/home/widgets/map/providers/route_providers.dart';
import 'package:client/features/home/widgets/map/providers/station_providers.dart';
import 'package:client/shared/widgets/linear_route_button.dart';
import 'package:client/shared/widgets/route_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StationDetail extends ConsumerStatefulWidget {
  final String stationId;
  final List<String> routeIds;
  final Color firstColor;

  const StationDetail(
    this.stationId, {
    required this.firstColor,
    required this.routeIds,
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _StationDetailState();
}

class _StationDetailState extends ConsumerState<StationDetail> {
  late String selectedId = widget.routeIds[0];
  late Color selectedColor = widget.firstColor;

  @override
  Widget build(BuildContext context) {
    final stationAsync =
        ref.watch(StationProviders.stationByIdProvider(widget.stationId));

    return stationAsync.when(
      data: (station) {
        if (station.routes == null || station.routes!.isEmpty) {
          return const Center(child: Text('노선 정보가 없습니다.'));
        }

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          child: Column(
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _buildRouteButtonList(station.routes!),
                    ),
                    LinearRouteButton(
                      routeId: selectedId,
                      stationId: widget.stationId,
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: StationDetailInfo(
                  station: station,
                  stationId: widget.stationId,
                  color: selectedColor,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('오류가 발생했습니다: $error')),
    );
  }

  Widget _buildRouteButtonList(List<String> routes) {
    return SizedBox(
      height: 40, // RouteButton의 원하는 높이로 설정
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: routes.map((routeId) {
            return FutureBuilder(
              future:
                  ref.read(RouteProviders.routeByIdProvider(routeId).future),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(width: 50, height: 40); // 로딩 중 빈 공간
                }
                if (snapshot.hasError) {
                  return Text('오류: ${snapshot.error}');
                }
                final route = snapshot.data!;
                return SizedBox(
                  child: RouteButton(
                    isSelected: selectedId == route.id,
                    onPressed: () =>
                        _onRouteButtonPressed(route.id, route.color),
                    text: route.name.split("호차")[0],
                    size: ButtonSize.md,
                    color: route.color,
                  ),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _onRouteButtonPressed(String id, Color color) {
    setState(() {
      selectedId = id;
      selectedColor = color;
    });
  }
}
