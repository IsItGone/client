import 'package:client/core/theme/theme.dart';
import 'package:client/data/models/station_model.dart';
import 'package:flutter/material.dart';

class StationDetailInfo extends StatelessWidget {
  const StationDetailInfo({
    super.key,
    required this.station,
    required this.stationId,
    required this.color,
  });

  final StationModel station;
  final String stationId;
  final Color color;

  @override
  Widget build(BuildContext context) {
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
                  text: "유성문화원", // TODO
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    topRight: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                  color: color,
                ),
                SizedBox(
                  width: centerWidth - 5,
                ),
                AdjacentStationButton(
                  alignment: MainAxisAlignment.end,
                  icon: Icons.chevron_right,
                  text: "현충원역", // TODO
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
          onPressed: () {},
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
                  overflow: TextOverflow.ellipsis,
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
