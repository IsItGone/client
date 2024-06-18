import 'package:flutter/material.dart';

class DragHandle extends StatelessWidget {
  const DragHandle({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        height: 24,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
        ),
        alignment: Alignment.center,
        child: Container(
          width: 60,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
