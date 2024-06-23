import 'package:client/src/common/widgets/bottom_drawer/components/drag_handle.dart';
import 'package:client/src/config/theme.dart';
import 'package:client/src/common/widgets/bottom_drawer/view_models/bottom_drawer_view_model.dart';

import 'package:flutter/material.dart';

class BottomDrawer extends StatelessWidget {
  final BottomDrawerViewModel drawerState;
  final BottomDrawerViewModel drawerNotifier;
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
            duration: const Duration(milliseconds: 200),
            height: drawerState.drawerHeight,
            color: Colors.transparent,
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
                  if (child != null)
                    Expanded(
                      child: child!,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
