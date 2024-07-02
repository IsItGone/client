import 'package:client/src/common/widgets/bottom_drawer/components/station_info.dart';
import 'package:client/src/config/theme.dart';
import 'package:flutter/material.dart';

class StationDetail extends StatefulWidget {
  final String stationId;
  const StationDetail(this.stationId, {super.key});

  @override
  State<StatefulWidget> createState() => _StationDetailState();
}

class _StationDetailState extends State<StationDetail> {
  final List<String> routes = ['1', '2', '3'];
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  Widget _buildRouteButton(int index) {
    final isSelected = selectedIndex == index;
    final buttonStyle = isSelected
        ? FilledButton.styleFrom(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            backgroundColor: AppTheme.lineColors[index],
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            minimumSize: Size.zero,
          )
        : OutlinedButton.styleFrom(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            side: BorderSide(color: AppTheme.lineColors[index]),
            minimumSize: Size.zero,
          );

    final buttonTextStyle = TextStyle(
      color: isSelected ? Colors.white : AppTheme.lineColors[index],
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0), // 버튼 사이 간격
      child: isSelected
          ? FilledButton(
              onPressed: () {
                setState(() {
                  selectedIndex = index;
                });
              },
              style: buttonStyle,
              child: Text(
                routes[index],
                style: buttonTextStyle,
              ),
            )
          : OutlinedButton(
              onPressed: () {
                setState(() {
                  selectedIndex = index;
                });
              },
              style: buttonStyle,
              child: Text(
                routes[index],
                style: buttonTextStyle,
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // decoration: BoxDecoration(color: Colors.pink[50]),
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: List.generate(
                  routes.length,
                  (index) {
                    return _buildRouteButton(index);
                  },
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Row(
                  children: [
                    Image.asset(
                      'assets/icons/linear_routes.png',
                      width: 20,
                      height: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "노선표",
                      style: AppTheme.textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Expanded(
            child: StationInfo(
              stationId: widget.stationId,
              routes: routes,
              selectedIndex: selectedIndex,
            ),
          ),
        ],
      ),
    );
  }
}
