import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Glassmorphic card with soft shadow and rounded corners.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double intensity;
  final Color? borderColor;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 20,
    this.intensity = 1,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: borderColor ?? Colors.white.withOpacity(0.06),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35 * intensity),
            blurRadius: 24 * intensity,
            spreadRadius: 1,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}