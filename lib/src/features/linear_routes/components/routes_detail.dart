import 'package:client/src/config/theme.dart';
import 'package:flutter/material.dart';

class RoutesDetail extends StatelessWidget {
  const RoutesDetail({super.key});
  @override
  Widget build(BuildContext context) {
    List<bool> routeStatus = [
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
      child: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return RouteStop(
            isHighlighted: routeStatus[index],
            stopName: '정류장 ${index + 1}',
            isFirst: index == 0,
            isTurnAround: index == 5,
            isLast: index == 9,
            index: index,
          );
        },
      ),
    );
  }
}

class RouteStop extends StatelessWidget {
  final String stopName;
  final bool isFirst;
  final bool isTurnAround;
  final bool isLast;
  final int index;
  final bool isHighlighted;

  const RouteStop({
    super.key,
    required this.stopName,
    this.isFirst = false,
    this.isTurnAround = false,
    this.isLast = false,
    required this.index,
    required this.isHighlighted,
  });
  @override
  Widget build(BuildContext context) {
    Color lineColor = isHighlighted
        ? AppTheme.primarySwatch
        : AppTheme.primarySwatch.withAlpha(77);

    const double barHeight = 65;
    const double iconWidth = 50;
    const double iconHeight = 25;
    const double iconSize = 16;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(right: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (isFirst)
                Container(
                  width: 6,
                  height: barHeight / 2,
                  color: Colors.transparent,
                ),
              isTurnAround
                  ? Container(
                      width: iconWidth,
                      height: iconHeight,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppTheme.primarySwatch,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "회차",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(width: 1),
                          Icon(
                            color: Colors.white,
                            Icons.u_turn_right,
                            size: iconSize,
                          ),
                        ],
                      ),
                    )
                  : Container(
                      width: iconWidth,
                      height: iconHeight - 5,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: AppTheme.primarySwatch,
                          width: 1,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                          child: Icon(
                        Icons.keyboard_arrow_down,
                        size: iconSize + 2,
                        color: AppTheme.primarySwatch,
                      )),
                    ),
              if (!isLast)
                Container(
                  width: 6,
                  height: barHeight,
                  color: lineColor,
                ),
            ],
          ),
        ),
        Expanded(
          child: Transform.translate(
            offset: const Offset(0, -(barHeight / 4)),
            child: Container(
              margin: EdgeInsets.fromLTRB(
                0,
                index == 0 ? barHeight / 2 + 8 : 0, // divider margin 포함
                0,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stopName,
                        style: AppTheme.textTheme.titleLarge,
                      ),
                      const Text(
                        "도착 시간 :",
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  if (!isLast)
                    Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: const Divider(
                            color: AppTheme.lightGray,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
