import 'package:client/data/providers/route_providers.dart';
import 'package:client/shared/widgets/linear_route_button.dart';
import 'package:client/shared/widgets/route_button.dart';
import 'package:client/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RouteDetail extends ConsumerWidget {
  final String? routeId;
  const RouteDetail(this.routeId, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (routeId == null) {
      return const Center(child: Text('노선을 선택하세요.'));
    }

    final routeAsync = ref.watch(RouteProviders.routeDetailProvider(routeId!));

    return Container(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: routeAsync.when(
            data: (route) => Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 12.0),
                                child: Text(
                                  "노선 정보",
                                  style: AppTheme.textTheme.displaySmall,
                                ),
                              ),
                              RouteButton(
                                isSelected: true,
                                text: route.name,
                                size: ButtonSize.lg,
                                color: route.color,
                              ),
                            ],
                          ),
                          LinearRouteButton(
                            routeId: route.id,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          if (route.departureStations.isEmpty ||
                              route.departureStations.first.name == null ||
                              route.departureStations.last.name == null)
                            Text(
                              "정보 없음",
                              style: AppTheme.textTheme.titleSmall,
                            )
                          else ...[
                            Flexible(
                              child: Text(
                                "${route.departureStations.first.name}",
                                style: AppTheme.textTheme.titleSmall,
                                softWrap: true,
                                maxLines: 2,
                                overflow: TextOverflow.visible,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(
                                color: AppTheme.mainGray,
                                Icons.sync_alt_rounded,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                "${route.departureStations.last.name}",
                                style: AppTheme.textTheme.titleSmall,
                                softWrap: true,
                                maxLines: 2,
                                overflow: TextOverflow.visible,
                              ),
                            )
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            Text("승차 운행 시간"),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            route.departureStations.isEmpty ||
                                    route.departureStations.first.stopTime ==
                                        null ||
                                    route.departureStations.last.stopTime ==
                                        null
                                ? '-'
                                : '${route.departureStations.first.stopTime} ~ ${route.departureStations.last.stopTime}',
                            style: AppTheme.textTheme.titleLarge,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Text('에러 발생: $err'),
          ),
        ));
  }
}
