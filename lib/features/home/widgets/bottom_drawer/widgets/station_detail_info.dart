import 'package:client/core/theme/theme.dart';
import 'package:client/data/models/station_model.dart';
import 'package:client/data/providers/route_providers.dart';

import 'package:client/features/home/widgets/map/providers/naver_map_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdjacentStation {
  final StationModel? station;
  final String direction;

  AdjacentStation(this.station, this.direction);
}

class StationDetailInfo extends ConsumerWidget {
  const StationDetailInfo({
    super.key,
    required this.station,
    required this.stationId,
    required this.routeId,
    required this.color,
    required this.routeCache,
  });

  final StationModel station;
  final String stationId, routeId;
  final Color color;
  final Map<String, dynamic> routeCache;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 캐시된 데이터가 있으면 사용
    if (routeCache.containsKey(routeId)) {
      final route = routeCache[routeId]['route'];
      return _buildContent(context, route, ref);
    }

    // 캐시된 데이터가 없으면 API 호출
    final routeAsync = ref.watch(RouteProviders.routeByIdProvider(routeId));

    return routeAsync.when(
      data: (route) => _buildContent(context, route, ref),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('오류가 발생했습니다: $error')),
    );
  }

  Widget _buildContent(BuildContext context, dynamic route, WidgetRef ref) {
    // 이전/다음 정류장 찾기
    final previousStation = _findAdjacentStation(route, stationId, true);
    final nextStation = _findAdjacentStation(route, stationId, false);

    return LayoutBuilder(
      builder: (context, constraints) {
        final centerWidth = constraints.maxWidth / 3;
        final centerHeight = constraints.maxHeight / 2.5;
        return Stack(
          alignment: const AlignmentDirectional(0, -0.2),
          children: [
            Positioned(
              height: 30,
              top: 25,
              left: 10,
              right: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                textDirection: TextDirection.ltr,
                children: [
                  SizedBox(
                    width: centerWidth,
                    // height: centerHeight,
                    child: Text(
                      previousStation!.direction,
                      style: AppTheme.textTheme.bodySmall,
                      textAlign: TextAlign.start,
                      maxLines: 2,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                  SizedBox(
                    width: centerWidth,
                    child: Text(
                      nextStation!.direction,
                      style: AppTheme.textTheme.bodySmall,
                      textAlign: TextAlign.end,
                      maxLines: 2,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AdjacentStationButton(
                  station: previousStation.station,
                  isPrevious: true,
                  color: color,
                  onStationTapped: (station) =>
                      _navigateToStation(context, station, ref),
                ),
                SizedBox(width: centerWidth - 5),
                AdjacentStationButton(
                  station: nextStation.station,
                  isPrevious: false,
                  color: color,
                  onStationTapped: (station) =>
                      _navigateToStation(context, station, ref),
                ),
              ],
            ),
            Align(
              alignment: const Alignment(0, -0.3),
              child: SizedBox(
                width: centerWidth,
                height: centerHeight,
                child: CurrentStationButton(
                  text: station.name ?? "",
                  color: color,
                ),
              ),
            ),
            Positioned(
              top: centerHeight * 1.65,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Text(
                    station.description ?? "",
                    style: AppTheme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    station.address ?? "",
                    style: AppTheme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // 인접 정류장으로 이동하는 함수
  void _navigateToStation(
      BuildContext context, StationModel? station, WidgetRef ref) {
    if (station == null) return;

    ref.read(naverMapViewModelProvider.notifier).onStationSelected(
          station.id,
          station.latitude!,
          station.longitude!,
          routeId,
        );
  }

  // 인접 정류장 찾기 함수
  AdjacentStation? _findAdjacentStation(
      dynamic route, String stationId, bool isPrevious) {
    final isDeparture = station.isDeparture ?? true;
    final stations =
        isDeparture ? route.departureStations : route.arrivalStations;

    // 정류장 인덱스 찾기
    int index = stations.indexWhere((s) => s.id == stationId);

    if (index == -1) return AdjacentStation(null, "");

    // 이전 또는 다음 정류장 반환
    if (isPrevious) {
      // 회차 정류장인 경우
      if (index == 0 && !isDeparture) {
        return AdjacentStation(
          route.departureStations[route.departureStations.length - 2],
          route.departureStations[0].name + " 방면",
        );
      }
      if (index > 0) {
        StationModel? prevStation = stations[index - 1];
        String direction = isDeparture
            ? route.departureStations[0].name + " 방면"
            : "삼성화재 연수원 방면";
        return AdjacentStation(prevStation, direction);
      }
      return AdjacentStation(null, "");
    } else {
      // 회차 정류장인 경우
      if (index == stations.length - 1 && isDeparture) {
        return AdjacentStation(
          route.arrivalStations[1],
          route.arrivalStations.last.name + " 방면",
        );
      } else {
        if (index < stations.length - 1) {
          StationModel? nextStation = stations[index + 1];
          String direction = isDeparture
              ? "삼성화재 연수원 방면"
              : route.arrivalStations.last.name + " 방면";
          return AdjacentStation(nextStation, direction);
        }

        return AdjacentStation(null, "");
      }
    }
  }
}

class AdjacentStationButton extends StatelessWidget {
  const AdjacentStationButton({
    super.key,
    required this.station,
    required this.isPrevious,
    required this.color,
    required this.onStationTapped, // 콜백 함수 추가
  });

  final StationModel? station;
  final bool isPrevious;
  final Color color;
  final Function(StationModel?) onStationTapped;

  @override
  Widget build(BuildContext context) {
    final String text = station?.name ?? '${isPrevious ? "이전" : "다음"} 정류장 없음';
    final IconData icon = isPrevious ? Icons.chevron_left : Icons.chevron_right;
    final MainAxisAlignment alignment =
        isPrevious ? MainAxisAlignment.start : MainAxisAlignment.end;
    final BorderRadius borderRadius = isPrevious
        ? const BorderRadius.only(
            topLeft: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            topRight: Radius.circular(4),
            bottomRight: Radius.circular(4),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(4),
            bottomLeft: Radius.circular(4),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          );

    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        child: FilledButton(
          style: FilledButton.styleFrom(
            fixedSize: Size(0, 50),
            padding: const EdgeInsets.symmetric(horizontal: 6),
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius,
            ),
            backgroundColor: color,
            disabledBackgroundColor: color.withValues(alpha: 0.7),
          ),
          onPressed: station == null
              ? null
              : () {
                  onStationTapped(station);
                },
          child: Row(
            mainAxisAlignment: alignment,
            children: [
              if (isPrevious) Icon(icon, color: AppTheme.mainWhite),
              Flexible(
                child: Text(
                  text,
                  style: AppTheme.textTheme.labelLarge?.copyWith(
                    fontVariations: [FontVariation('wght', 700)],
                    color: AppTheme.mainWhite,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.visible,
                ),
              ),
              if (!isPrevious) Icon(icon, color: AppTheme.mainWhite),
            ],
          ),
        ),
      ),
    );
  }
}

class CurrentStationButton extends StatelessWidget {
  const CurrentStationButton({
    super.key,
    required this.text,
    required this.color,
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.all(20),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          side: BorderSide(color: color, width: 4),
          backgroundColor: AppTheme.mainWhite,
        ),
        onPressed: null,
        child: Text(
          text,
          style: AppTheme.textTheme.labelLarge?.copyWith(
            fontVariations: [FontVariation('wght', 700)],
            color: AppTheme.subBlack,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.visible,
          softWrap: true,
          textWidthBasis: TextWidthBasis.longestLine,
        ),
      ),
    );
  }
}
