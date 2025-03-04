import 'package:client/src/common/widgets/linear_route_button.dart';
import 'package:client/src/common/widgets/route_button.dart';
import 'package:client/src/config/theme.dart';
import 'package:flutter/material.dart';

class RouteDetail extends StatelessWidget {
  final String routeId;
  const RouteDetail(this.routeId, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: SingleChildScrollView(
        child: Column(
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
                            index: int.parse(routeId),
                            isSelected: true,
                            text: '$routeId호차',
                            size: ButtonSize.lg,
                          ),
                        ],
                      ),
                      LinearRouteButton(
                        routeId: routeId,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        "출발지",
                        style: AppTheme.textTheme.titleSmall,
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(
                          color: AppTheme.mainGray,
                          Icons.sync_alt_rounded,
                        ),
                      ),
                      Text(
                        "도착지",
                        style: AppTheme.textTheme.titleSmall,
                      ),
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
                        "07:35 ~ 08:30",
                        style: AppTheme.textTheme.titleLarge,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
