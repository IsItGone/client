import 'package:client/core/theme/theme.dart';
import 'package:client/data/models/station_model.dart';
import 'package:client/data/providers/route_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      return _buildContent(context, route);
    }

    // 캐시된 데이터가 없으면 API 호출
    final routeAsync = ref.watch(RouteProviders.routeByIdProvider(routeId));

    return routeAsync.when(
      data: (route) => _buildContent(context, route),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('오류가 발생했습니다: $error')),
    );
  }

  Widget _buildContent(BuildContext context, dynamic route) {
    // 이전/다음 정류장 찾기
    final previousStation = _findAdjacentStation(route, stationId, true, false);
    final nextStation = _findAdjacentStation(route, stationId, false, false);

    return LayoutBuilder(
      builder: (context, constraints) {
        final centerWidth = constraints.maxWidth / 3;
        final centerHeight = constraints.maxHeight / 2.5;
        return Stack(
          alignment: const AlignmentDirectional(0, -0.4),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AdjacentStationButton(
                  alignment: MainAxisAlignment.start,
                  icon: Icons.chevron_left,
                  text: previousStation?.name ?? "이전 정류장 없음",
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    topRight: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                  color: color,
                ),
                SizedBox(width: centerWidth - 5),
                AdjacentStationButton(
                  alignment: MainAxisAlignment.end,
                  icon: Icons.chevron_right,
                  text: nextStation?.name ?? "다음 정류장 없음",
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    bottomLeft: Radius.circular(4),
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  color: color,
                ),
              ],
            ),
            Align(
              alignment: const Alignment(0, -0.5),
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
              top: centerHeight * 1.5,
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

  // 인접 정류장 찾기 함수
  StationModel? _findAdjacentStation(
      dynamic route, String stationId, bool isPrevious, bool useCompositeId) {
    final isDeparture = station.isDeparture ?? true;
    final stations =
        isDeparture ? route.departureStations : route.arrivalStations;

    // 정류장 인덱스 찾기
    int index = -1;
    for (int i = 0; i < stations.length; i++) {
      final station = stations[i];
      final id = useCompositeId ? station.id : station.id.split('_')[0];
      if (id == stationId) {
        index = i;
        break;
      }
    }

    if (index == -1) return null;

    // 이전 또는 다음 정류장 반환
    if (isPrevious) {
      return index > 0 ? stations[index - 1] : null;
    } else {
      return index < stations.length - 1 ? stations[index + 1] : null;
    }
  }
}

class AdjacentStationButton extends StatelessWidget {
  const AdjacentStationButton({
    super.key,
    required this.alignment,
    required this.icon,
    required this.text,
    required this.borderRadius,
    required this.color,
  });

  final MainAxisAlignment alignment;
  final IconData icon;
  final String text;
  final BorderRadius borderRadius;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          color: color,
        ),
        child: FilledButton(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            shape: RoundedRectangleBorder(borderRadius: borderRadius),
            backgroundColor: Colors.transparent,
          ),
          onPressed: () {}, // TODO:
          child: Row(
            mainAxisAlignment: alignment,
            children: [
              if (alignment == MainAxisAlignment.start)
                Icon(icon, color: AppTheme.mainWhite),
              Flexible(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.mainWhite,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.visible,
                ),
              ),
              if (alignment == MainAxisAlignment.end)
                Icon(icon, color: AppTheme.mainWhite),
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
        onPressed: () {},
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
            color: AppTheme.mainBlack,
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
