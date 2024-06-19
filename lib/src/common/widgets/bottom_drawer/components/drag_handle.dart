import 'package:client/src/config/theme.dart';
import 'package:flutter/material.dart';

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
