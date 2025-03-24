import 'package:flutter/material.dart';
import 'package:client/core/theme/theme.dart';

enum ButtonSize { sm, md, lg }

class RouteButton extends StatelessWidget {
  final int index;
  final bool isSelected;
  final VoidCallback? onPressed;
  final String text;
  final ButtonSize size;
  final EdgeInsetsGeometry? padding;

  const RouteButton({
    super.key,
    required this.index,
    required this.isSelected,
    required this.text,
    this.onPressed,
    this.size = ButtonSize.md,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    double width;
    double height;
    EdgeInsetsGeometry defaultPadding;

    switch (size) {
      case ButtonSize.sm:
        width = 32;
        height = 32;
        defaultPadding = EdgeInsets.zero;
        break;
      case ButtonSize.lg:
        width = 64;
        height = 36;
        defaultPadding =
            const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0);
        break;
      case ButtonSize.md:
        width = 48;
        height = 48;
        defaultPadding =
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0);
        break;
    }

    final buttonTextStyle = TextStyle(
      color: isSelected ? Colors.white : AppTheme.lineColors[index],
      fontSize: size == ButtonSize.sm ? 14 : 16,
      fontWeight: FontWeight.bold,
    );

    if (onPressed != null) {
      final buttonStyle = isSelected
          ? FilledButton.styleFrom(
              padding: padding ?? defaultPadding,
              backgroundColor: AppTheme.lineColors[index],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(size == ButtonSize.sm ? 8 : 12),
                ),
              ),
              minimumSize: Size(width, height),
            )
          : OutlinedButton.styleFrom(
              padding: padding ?? defaultPadding,
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(size == ButtonSize.sm ? 8 : 12),
                ),
              ),
              side: BorderSide(color: AppTheme.lineColors[index]),
              minimumSize: Size(width, height),
            );

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: isSelected
            ? FilledButton(
                onPressed: onPressed,
                style: buttonStyle,
                child: Text(
                  text,
                  style: buttonTextStyle,
                ),
              )
            : OutlinedButton(
                onPressed: onPressed,
                style: buttonStyle,
                child: Text(
                  text,
                  style: buttonTextStyle,
                ),
              ),
      );
    } else {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppTheme.lineColors[index],
          borderRadius: BorderRadius.circular(size == ButtonSize.sm ? 8 : 12),
        ),
        child: Center(
          child: Text(
            text,
            style: buttonTextStyle,
          ),
        ),
      );
    }
  }
}
