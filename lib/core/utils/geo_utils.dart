import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Lightweight 2D geometry helpers used by the simulation.
class GeoUtils {
  GeoUtils._();

  /// Euclidean distance between two offset points (used in screen space).
  static double distance(Offset a, Offset b) {
    final dx = a.dx - b.dx;
    final dy = a.dy - b.dy;
    return math.sqrt(dx * dx + dy * dy);
  }

  /// Linearly interpolate between two points by [t] in [0,1].
  static Offset lerp(Offset a, Offset b, double t) {
    final clamped = t.clamp(0.0, 1.0);
    return Offset(
      a.dx + (b.dx - a.dx) * clamped,
      a.dy + (b.dy - a.dy) * clamped,
    );
  }

  /// Angle in radians from [a] to [b]. 0 means pointing right, pi/2 down.
  static double angleRadians(Offset a, Offset b) {
    return math.atan2(b.dy - a.dy, b.dx - a.dx);
  }

  /// Angle in degrees from [a] to [b] (clamped).
  static double angleDegrees(Offset a, Offset b) {
    return angleRadians(a, b) * 180 / math.pi;
  }

  /// Map screen pixel distance to simulated kilometers using a scale.
  static double pixelsToKm(double pixels, {double pxPerKm = 40}) {
    return pixels / pxPerKm;
  }

  /// Convert km back to pixels (inverse of [pixelsToKm]).
  static double kmToPixels(double km, {double pxPerKm = 40}) {
    return km * pxPerKm;
  }
}