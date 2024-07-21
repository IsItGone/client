import 'package:flutter/material.dart';

class BottomDrawer extends StatelessWidget {
  const BottomDrawer({
    super.key,
    required this.isDrawerOpen,
    required this.child,
  });

  final bool isDrawerOpen;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: isDrawerOpen ? MediaQuery.of(context).size.height * 0.33 : 0,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: child,
    );
  }
}
