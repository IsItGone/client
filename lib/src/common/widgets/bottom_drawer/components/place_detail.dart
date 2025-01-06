import 'package:client/src/common/widgets/bottom_drawer/components/place_detail_info.dart';
import 'package:client/src/config/theme.dart';
import 'package:flutter/material.dart';

class PlaceDetail extends StatelessWidget {
  const PlaceDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "주변 정류장 목록",
                    style: AppTheme.textTheme.displaySmall,
                  ),
                ],
              ),
            ),
          ),
          const Expanded(
            flex: 3,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: CustomScrollView(
                slivers: [
                  PlaceDetailInfo(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
