import 'dart:ui';
import 'package:flutter/material.dart';

class GlassBox extends StatelessWidget {
  final double? width;
  final double? height;
  final Widget child;
  final double blur;
  final double opacity;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BoxBorder? border;
  final LinearGradient? gradient;

  const GlassBox({
    super.key,
    this.width,
    this.height,
    required this.child,
    this.blur = 15.0,
    this.opacity = 0.1,
    this.borderRadius,
    this.padding,
    this.margin,
    this.border,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    // Default border radius if not provided
    final radius = borderRadius ?? BorderRadius.circular(20);

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: gradient == null ? Colors.white.withValues(alpha: opacity) : null,
              gradient: gradient,
              borderRadius: radius,
              border: border ?? Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
