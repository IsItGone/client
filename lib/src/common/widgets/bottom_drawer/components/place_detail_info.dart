import 'package:client/src/config/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const List<Map<String, dynamic>> nearStations = [
  {
    'name': '유성온천역 맥도날드 앞',
    'lines': ['3', '5', '6'],
    'distance': '200m',
  },
  {
    'name': '유성문화원',
    'lines': ['2'],
    'distance': '403m',
  },
  {
    'name': '월평역',
    'lines': ['1'],
    'distance': '510m',
  },
  {
    'name': '현충원역',
    'lines': ['6'],
    'distance': '730m',
  },
  {
    'name': '덕명네거리',
    'lines': ['4'],
    'distance': '960m',
  },
  {
    'name': '덕명중학교',
    'lines': ['3'],
    'distance': '960m',
  },
];

class PlaceDetailInfo extends StatefulWidget {
  const PlaceDetailInfo({super.key});

  @override
  State<PlaceDetailInfo> createState() => _PlaceDetailInfoState();
}

class _PlaceDetailInfoState extends State<PlaceDetailInfo> {
  @override
  Widget build(BuildContext context) {
    return SliverList(
      // // builder (대량의 데이터)
      // delegate: SliverChildBuilderDelegate(
      //   (context, index) => StationItem(station: nearStations[index]),
      //   childCount: nearStations.length,
      // ),

      // list (적은 양의 데이터)
      delegate: SliverChildListDelegate(
        nearStations.map((station) => StationItem(station: station)).toList(),
      ),
    );
  }
}

class StationItem extends StatelessWidget {
  final Map<String, dynamic> station;

  const StationItem({super.key, required this.station});

  @override
  Widget build(BuildContext context) {
    const gap = kIsWeb ? 8.0 : 18.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Text(
            station['name'],
            style: AppTheme.textTheme.bodyLarge,
          ),
          const SizedBox(width: gap),
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (station['lines'] as List<String>)
                  .map((line) => LineButton(line: line))
                  .toList(),
            ),
          ),
          const SizedBox(width: gap),
          Text(
            station['distance'],
            style: AppTheme.textTheme.labelLarge,
          ),
        ],
      ),
    );
  }
}

class LineButton extends StatelessWidget {
  final String line;

  const LineButton({super.key, required this.line});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppTheme.lineColors[int.parse(line) - 1],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          line,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
