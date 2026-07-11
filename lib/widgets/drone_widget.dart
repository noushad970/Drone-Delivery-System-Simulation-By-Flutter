import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Animated drone widget with rotating propellers.
///
/// Used both as the moving agent on the map and as a static illustration on
/// the home screen.
class DroneWidget extends StatefulWidget {
  final double size;
  final double rotationRadians;
  final bool propellerSpin;
  final Color bodyColor;
  final Color propellerColor;

  const DroneWidget({
    super.key,
    this.size = 64,
    this.rotationRadians = 0,
    this.propellerSpin = true,
    this.bodyColor = AppColors.primary,
    this.propellerColor = AppColors.accent,
  });

  @override
  State<DroneWidget> createState() => _DroneWidgetState();
}

class _DroneWidgetState extends State<DroneWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    if (widget.propellerSpin) _ctrl.repeat();
  }

  @override
  void didUpdateWidget(covariant DroneWidget old) {
    super.didUpdateWidget(old);
    if (widget.propellerSpin) {
      _ctrl.repeat();
    } else {
      _ctrl.stop();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Soft glow underneath the drone.
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: widget.bodyColor.withOpacity(0.5),
                      blurRadius: widget.size * 0.4,
                      spreadRadius: widget.size * 0.05,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Rotating body.
          AnimatedRotation(
            turns: widget.rotationRadians / (2 * math.pi),
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            child: CustomPaint(
              size: Size.square(widget.size),
              painter: _DronePainter(
                bodyColor: widget.bodyColor,
                propellerColor: widget.propellerColor,
              ),
            ),
          ),
          // Spinning propellers on top, transparent to rotation.
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (context, _) => CustomPaint(
                size: Size.square(widget.size),
                painter: _PropellerPainter(
                  color: widget.propellerColor,
                  progress: _ctrl.value,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DronePainter extends CustomPainter {
  final Color bodyColor;
  final Color propellerColor;

  _DronePainter({required this.bodyColor, required this.propellerColor});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;

    final arm = Paint()
      ..color = Colors.white.withOpacity(0.85)
      ..strokeWidth = w * 0.06
      ..strokeCap = StrokeCap.round;

    // X-shaped arms.
    canvas.drawLine(Offset(cx - w * 0.35, cy - h * 0.35),
        Offset(cx + w * 0.35, cy + h * 0.35), arm);
    canvas.drawLine(Offset(cx - w * 0.35, cy + h * 0.35),
        Offset(cx + w * 0.35, cy - h * 0.35), arm);

    // Body circle.
    final body = Paint()
      ..shader = RadialGradient(
        colors: [bodyColor, bodyColor.withOpacity(0.8)],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: w * 0.22));
    canvas.drawCircle(Offset(cx, cy), w * 0.22, body);

    // Camera dot.
    final cam = Paint()..color = AppColors.accent;
    canvas.drawCircle(Offset(cx, cy + h * 0.05), w * 0.05, cam);

    // Arm endpoints (motor housings).
    final motor = Paint()..color = Colors.white.withOpacity(0.9);
    final motors = [
      Offset(cx - w * 0.35, cy - h * 0.35),
      Offset(cx + w * 0.35, cy - h * 0.35),
      Offset(cx - w * 0.35, cy + h * 0.35),
      Offset(cx + w * 0.35, cy + h * 0.35),
    ];
    for (final m in motors) {
      canvas.drawCircle(m, w * 0.08, motor);
    }
  }

  @override
  bool shouldRepaint(covariant _DronePainter old) =>
      old.bodyColor != bodyColor || old.propellerColor != propellerColor;
}

class _PropellerPainter extends CustomPainter {
  final Color color;
  final double progress; // 0..1

  _PropellerPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;
    final angle = progress * 2 * math.pi;

    final motorPositions = [
      Offset(cx - w * 0.35, cy - h * 0.35),
      Offset(cx + w * 0.35, cy - h * 0.35),
      Offset(cx - w * 0.35, cy + h * 0.35),
      Offset(cx + w * 0.35, cy + h * 0.35),
    ];

    final blade = Paint()
      ..color = color.withOpacity(0.7)
      ..strokeWidth = w * 0.04
      ..strokeCap = StrokeCap.round;

    final blurredBlade = Paint()
      ..color = color.withOpacity(0.18)
      ..strokeWidth = w * 0.12
      ..strokeCap = StrokeCap.round;

    for (final p in motorPositions) {
      canvas.save();
      canvas.translate(p.dx, p.dy);
      canvas.rotate(angle);
      // Two crossing blades.
      canvas.drawLine(Offset(-w * 0.12, 0), Offset(w * 0.12, 0), blurredBlade);
      canvas.drawLine(Offset(0, -w * 0.12), Offset(0, w * 0.12), blurredBlade);
      canvas.drawLine(Offset(-w * 0.1, 0), Offset(w * 0.1, 0), blade);
      canvas.drawLine(Offset(0, -w * 0.1), Offset(0, w * 0.1), blade);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _PropellerPainter old) =>
      old.color != color || old.progress != progress;
}