import 'package:client/core/theme/theme.dart';
import 'package:flutter/material.dart';

enum ButtonSize { sm, md, lg }

class RouteButton extends StatelessWidget {
  final Color? color;
  final bool isSelected;
  final VoidCallback? onPressed;
  final String text;
  final ButtonSize size;
  final EdgeInsetsGeometry? padding;

  const RouteButton({
    super.key,
    this.color,
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
      color: isSelected ? AppTheme.mainWhite : color,
      fontSize: size == ButtonSize.sm ? 14 : 16,
      fontWeight: FontWeight.w700,
    );

    if (onPressed != null) {
      final buttonStyle = isSelected
          ? FilledButton.styleFrom(
              padding: padding ?? defaultPadding,
              backgroundColor: color,
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
              side: BorderSide(color: color ?? Colors.grey),
              minimumSize: Size(width, height),
            );

      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 4.0,
          vertical: size == ButtonSize.md ? 12.0 : 0,
        ),
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
          color: color,
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
