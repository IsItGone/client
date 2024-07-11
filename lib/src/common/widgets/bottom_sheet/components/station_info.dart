import 'package:client/src/config/theme.dart';
import 'package:flutter/material.dart';

class StationInfo extends StatefulWidget {
  const StationInfo({
    super.key,
    required this.stationId,
    required this.routes,
    required this.selectedIndex,
  });

  final String stationId;
  final List<String> routes;
  final int selectedIndex;

  @override
  State<StatefulWidget> createState() => _StationInfoState();
}

class _StationInfoState extends State<StationInfo> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  @override
  void didUpdateWidget(covariant StationInfo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      setState(() {
        _selectedIndex = widget.selectedIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          alignment: AlignmentDirectional.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildAdjacentStationButton(
                  context,
                  alignment: MainAxisAlignment.start,
                  icon: Icons.chevron_left,
                  text: "유성문화원",
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    topRight: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 3 - 5,
                ),
                _buildAdjacentStationButton(
                  context,
                  alignment: MainAxisAlignment.end,
                  icon: Icons.chevron_right,
                  text: "현충원역",
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    bottomLeft: Radius.circular(4),
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: MediaQuery.of(context).size.width / 3,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(20),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      side: BorderSide(
                          color: AppTheme.lineColors[_selectedIndex], width: 4),
                      backgroundColor: AppTheme.mainWhite,
                    ),
                    onPressed: () {},
                    child: const Text(
                      '유성온천역\n맥도날드 앞',
                      // '정류장 ${widget.stationId}\n 노선 ${widget.routes[_selectedIndex]}',
                      style: TextStyle(
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
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAdjacentStationButton(
    BuildContext context, {
    required MainAxisAlignment alignment,
    required IconData icon,
    required String text,
    required BorderRadius borderRadius,
  }) {
    return Expanded(
      flex: 1,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          color: AppTheme.lineColors[_selectedIndex],
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
              if (alignment == MainAxisAlignment.start) Icon(icon),
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
              if (alignment == MainAxisAlignment.end) Icon(icon),
            ],
          ),
        ),
      ),
    );
  }
}
