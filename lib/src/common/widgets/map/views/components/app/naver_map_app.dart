import 'package:client/src/common/widgets/bottom_drawer/providers/bottom_sheet_provider.dart';
import 'package:client/src/common/widgets/map/views/components/app/naver_map_container.dart';
import 'package:client/src/common/widgets/map_search_bar.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NaverMapWidget extends ConsumerStatefulWidget {
  const NaverMapWidget({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NaverMapWidgetState();
}

class _NaverMapWidgetState extends ConsumerState<NaverMapWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    ref.read(bottomSheetProvider).setAnimationController(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        Stack(
          children: [
            NaverMapContainer(),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: MapSearchBar(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
