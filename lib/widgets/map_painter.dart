import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../data/models/destination_model.dart';

/// CustomPainter that draws the stylized city map (roads, parks, water,
/// buildings, home base, and markers).
class MapPainter extends CustomPainter {
  final Size size;
  final List<DestinationModel> destinations;
  final DestinationModel? selected;
  final Offset? dronePosition;
  final Offset homeBase;
  final List<Offset> route;

  MapPainter({
    required this.size,
    required this.destinations,
    required this.homeBase,
    this.selected,
    this.dronePosition,
    this.route = const [],
  });

  @override
  void paint(Canvas canvas, Size _) {
    canvas.save();
    _drawBackground(canvas);
    _drawParks(canvas);
    _drawWater(canvas);
    _drawBuildings(canvas);
    _drawRoads(canvas);
    _drawRoute(canvas);
    _drawHomeBase(canvas);
    _drawDestinations(canvas);
    if (dronePosition != null) {
      _drawDroneShadow(canvas, dronePosition!);
    }
    canvas.restore();
  }

  void _drawBackground(Canvas canvas) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0B1530), Color(0xFF111A2E)],
      ).createShader(rect);
    canvas.drawRect(rect, paint);

    // Subtle grid for a map feel.
    final grid = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 1;
    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
  }

  void _drawParks(Canvas canvas) {
    final p = Paint()..color = AppColors.park.withOpacity(0.35);
    canvas.drawCircle(Offset(size.width * 0.12, size.height * 0.68), 60, p);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.5), 30, p);
  }

  void _drawWater(Canvas canvas) {
    final path = Path()
      ..moveTo(size.width * 0.7, 0)
      ..quadraticBezierTo(
        size.width * 0.95,
        size.height * 0.25,
        size.width * 0.7,
        size.height * 0.5,
      )
      ..lineTo(size.width, size.height * 0.5)
      ..lineTo(size.width, 0)
      ..close();
    final paint = Paint()..color = AppColors.water.withOpacity(0.55);
    canvas.drawPath(path, paint);
  }

  void _drawBuildings(Canvas canvas) {
    final rng = _seededRng(42);
    final paint = Paint()..color = AppColors.building.withOpacity(0.9);
    final paintDark = Paint()..color = AppColors.building.withOpacity(0.55);
    for (int i = 0; i < 36; i++) {
      final w = 18 + rng.nextDouble() * 22;
      final h = 18 + rng.nextDouble() * 26;
      final x = rng.nextDouble() * (size.width - w);
      final y = rng.nextDouble() * (size.height - h);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, w, h),
          const Radius.circular(4),
        ),
        (i % 3 == 0) ? paintDark : paint,
      );
    }
  }

  void _drawRoads(Canvas canvas) {
    final road = Paint()
      ..color = AppColors.road
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    final center = Paint()
      ..color = Colors.white.withOpacity(0.18)
      ..strokeWidth = 1.4;

    // Horizontal roads
    final hLines = [0.25, 0.5, 0.75];
    for (final f in hLines) {
      final y = size.height * f;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), road);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), center);
    }
    // Vertical roads
    final vLines = [0.2, 0.4, 0.6, 0.8];
    for (final f in vLines) {
      final x = size.width * f;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), road);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), center);
    }
  }

  void _drawRoute(Canvas canvas) {
    if (route.length < 2) return;
    final path = Path()..moveTo(route.first.dx, route.first.dy);
    for (var i = 1; i < route.length; i++) {
      path.lineTo(route[i].dx, route[i].dy);
    }
    final dashed = Paint()
      ..color = AppColors.accent.withOpacity(0.7)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, dashed);

    // Glow
    final glow = Paint()
      ..color = AppColors.accent.withOpacity(0.25)
      ..strokeWidth = 10
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, glow);
  }

  void _drawHomeBase(Canvas canvas) {
    final center = homeBase;
    final halo = Paint()
      ..color = AppColors.homeBase.withOpacity(0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    canvas.drawCircle(center, 28, halo);

    final p = Paint()..color = AppColors.homeBase;
    canvas.drawCircle(center, 14, p);
    canvas.drawCircle(
      center,
      14,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final icon = Paint()..color = Colors.black87;
    canvas.drawCircle(center, 5, icon);

    final tp = TextPainter(
      text: const TextSpan(
        text: 'BASE',
        style: TextStyle(
          color: AppColors.homeBase,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center + const Offset(14, -6));
  }

  void _drawDestinations(Canvas canvas) {
    for (final d in destinations) {
      final pos = d.toScreen(size);
      final isSelected = selected?.id == d.id;
      final color = d.color;

      final halo = Paint()
        ..color = color.withOpacity(isSelected ? 0.5 : 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
      canvas.drawCircle(pos, isSelected ? 26 : 18, halo);

      final p = Paint()..color = color;
      canvas.drawCircle(pos, isSelected ? 14 : 11, p);

      canvas.drawCircle(
        pos,
        isSelected ? 14 : 11,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      // Inner pin
      canvas.drawCircle(pos, 4, Paint()..color = Colors.white);

      // Label
      if (isSelected) {
        final tp = TextPainter(
          text: TextSpan(
            text: d.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: 160);
        tp.paint(canvas, pos + const Offset(18, -8));
      }
    }
  }

  void _drawDroneShadow(Canvas canvas, Offset pos) {
    final shadow = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(pos + const Offset(0, 6), 14, shadow);
  }

  @override
  bool shouldRepaint(covariant MapPainter old) {
    return old.size != size ||
        old.selected != selected ||
        old.dronePosition != dronePosition ||
        old.homeBase != homeBase ||
        old.route.length != route.length;
  }
}

/// Tiny seeded RNG so the city map looks the same every render.
class _SeededRng {
  int _seed;
  _SeededRng(int seed) : _seed = seed;
  double nextDouble() {
    _seed = (_seed * 9301 + 49297) % 233280;
    return _seed / 233280.0;
  }
}

_SeededRng _seededRng(int seed) => _SeededRng(seed);
