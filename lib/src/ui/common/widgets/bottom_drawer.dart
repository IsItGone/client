import 'package:client/src/config/theme.dart';
import 'package:client/src/state/drawer_state.dart';
import 'package:client/src/ui/features/map/widgets/app/naver_map_app.dart';

import 'package:flutter/material.dart';

class BottomDrawer extends StatelessWidget {
  final DrawerState drawerState;
  final DrawerState drawerNotifier;
  final Widget? child;

  const BottomDrawer({
    super.key,
    required this.drawerState,
    required this.drawerNotifier,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: GestureDetector(
        onVerticalDragUpdate: (details) {
          double newHeight = drawerState.drawerHeight - details.delta.dy;
          if (newHeight < 0) {
            newHeight = 0;
          } else if (newHeight > MediaQuery.of(context).size.height) {
            newHeight = MediaQuery.of(context).size.height;
          }
          drawerNotifier.setDrawerHeight(newHeight);
        },
        child: Offstage(
          offstage: !drawerState.isDrawerOpen,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: drawerState.drawerHeight,
            color: Colors.transparent,
            child: Transform.translate(
              offset: Offset(0, drawerState.isDrawerOpen ? -20 : 0),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppTheme.mainWhite,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onVerticalDragUpdate: (details) {
                        double newHeight =
                            drawerState.drawerHeight - details.delta.dy;
                        drawerNotifier.setDrawerHeight(newHeight);
                      },
                      child: const SizedBox(
                        height: 40,
                        child: DragHandle(),
                      ),
                    ),
                    if (child != null) child!,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DragHandle extends StatelessWidget {
  const DragHandle({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        margin: const EdgeInsets.only(top: 10, bottom: 10), // optional margin
        width: 40,
        height: 6,
        decoration: BoxDecoration(
          color: AppTheme.lightGray, // 원하는 색상으로 변경
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}
