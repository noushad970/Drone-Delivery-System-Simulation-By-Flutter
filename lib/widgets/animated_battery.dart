import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Circular battery indicator with animated value and color transitions.
class AnimatedBatteryRing extends StatelessWidget {
  final double percent;
  final double size;
  final double strokeWidth;
  final Widget? center;

  const AnimatedBatteryRing({
    super.key,
    required this.percent,
    this.size = 120,
    this.strokeWidth = 12,
    this.center,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: percent.clamp(0, 100)),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        final color = AppColors.batteryColor(value);
        return SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _BatteryPainter(value: value, color: color, stroke: strokeWidth),
            child: Center(child: center ?? _DefaultBatteryLabel(value: value, color: color)),
          ),
        );
      },
    );
  }
}

class _DefaultBatteryLabel extends StatelessWidget {
  final double value;
  final Color color;
  const _DefaultBatteryLabel({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${value.toStringAsFixed(0)}%',
          style: TextStyle(
            color: color,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Text(
          'BATTERY',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 10,
            letterSpacing: 1.6,
          ),
        ),
      ],
    );
  }
}

class _BatteryPainter extends CustomPainter {
  final double value; // 0..100
  final Color color;
  final double stroke;

  _BatteryPainter({required this.value, required this.color, required this.stroke});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - stroke / 2;

    final track = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final progress = Paint()
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: 3 * math.pi / 2,
        colors: [color.withOpacity(0.5), color],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, track);

    final sweep = (value / 100) * 2 * math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweep,
      false,
      progress,
    );

    // Glow
    final glow = Paint()
      ..color = color.withOpacity(0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweep,
      false,
      glow,
    );
  }

  @override
  bool shouldRepaint(covariant _BatteryPainter old) =>
      old.value != value || old.color != color || old.stroke != stroke;
}