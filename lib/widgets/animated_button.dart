import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' show Matrix4;

import '../core/theme/app_colors.dart';

/// Animated button with hover, press, and ripple feedback.
class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? color;
  final Gradient? gradient;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double minWidth;

  const AnimatedButton({
    super.key,
    required this.child,
    this.onPressed,
    this.color,
    this.gradient,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    this.radius = 16,
    this.minWidth = 120,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> {
  bool _hovering = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: widget.padding,
          constraints: BoxConstraints(minWidth: widget.minWidth),
          transform: Matrix4.identity()
            ..translate(0.0, _pressed ? 1.5 : (_hovering ? -2 : 0)),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: widget.gradient ?? AppColors.primaryGradient,
            color: widget.color,
            borderRadius: BorderRadius.circular(widget.radius),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(_hovering ? 0.45 : 0.25),
                blurRadius: _hovering ? 24 : 12,
                offset: Offset(0, _hovering ? 14 : 8),
              ),
            ],
          ),
          child: DefaultTextStyle.merge(
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
            child: Center(child: widget.child),
          ),
        ),
      ),
    );
  }
}
