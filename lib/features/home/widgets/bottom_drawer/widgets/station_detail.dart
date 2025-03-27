import 'package:client/features/home/widgets/bottom_drawer/widgets/station_detail_info.dart';
import 'package:client/data/providers/route_providers.dart';
import 'package:client/data/providers/station_providers.dart';
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
  Map<String, dynamic> routeCache = {}; // 노선 데이터 캐시

  @override
  void initState() {
    super.initState();
    // 모든 노선 데이터를 미리 로드
    _preloadRouteData();
  }

  Future<void> _preloadRouteData() async {
    for (final routeId in widget.routeIds) {
      try {
        final route =
            await ref.read(RouteProviders.routeByIdProvider(routeId).future);
        routeCache[routeId] = {
          'route': route,
          'color': route.color,
        };
      } catch (e) {
        // 오류 처리
      }
    }
    if (mounted) setState(() {});
  }

  void _onRouteButtonPressed(String id, Color color) {
    setState(() {
      selectedId = id;
      selectedColor = color;
    });
  }

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
                  routeId: selectedId,
                  color: selectedColor,
                  routeCache: routeCache, // 캐시된 노선 데이터 전달
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
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: routes.length,
        itemBuilder: (context, index) {
          final routeId = routes[index];

          if (routeCache.containsKey(routeId)) {
            final cachedData = routeCache[routeId];
            final route = cachedData['route'];
            return SizedBox(
              height: 40,
              child: RouteButton(
                isSelected: selectedId == route.id,
                onPressed: () => _onRouteButtonPressed(route.id, route.color),
                text: route.name.split("호차")[0],
                size: ButtonSize.md,
                color: route.color,
              ),
            );
          }

          return const SizedBox(width: 50, height: 40);
        },
      ),
    );
  }
}
