import 'package:flutter/material.dart';

class NeoBox extends StatelessWidget {
  final double? width;
  final double? height;
  final Widget child;
  final Color color;
  final Color shadowColor;
  final Color borderColor;
  final double borderWidth;
  final Offset shadowOffset;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;

  const NeoBox({
    super.key,
    this.width,
    this.height,
    required this.child,
    this.color = Colors.white,
    this.shadowColor = Colors.black,
    this.borderColor = Colors.black,
    this.borderWidth = 3.0,
    this.shadowOffset = const Offset(4, 4),
    this.padding,
    this.margin,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius ?? BorderRadius.circular(0), // Sharp or slightly rounded
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            offset: shadowOffset,
            blurRadius: 0, // Hard shadow
          ),
        ],
      ),
      padding: padding,
      child: child,
    );
  }
}
