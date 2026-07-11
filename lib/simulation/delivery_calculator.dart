/// Pure functions for delivery cost, time, and battery calculations.
///
/// Keeping these as pure functions (no globals, no services) makes them
/// trivial to unit-test.
class DeliveryCalculator {
  DeliveryCalculator._();

  // Pricing
  static const double costPerKm = 1.20;
  static const double costPerKg = 1.50;

  // Timing — tuned so the full round-trip finishes inside 1 minute.
// Cruise speed is intentionally high: we're simulating, not flying.
  static const double baseSpeedKmh = 360.0; // cruise speed
  static const double takeoffLandingOverheadSeconds = 1.5;
  static const double weightPenaltySecondsPerKg = 0.4;

  // Battery
  static const double batteryDrainPerKm = 0.6; // %
  static const double batteryDrainPerKg = 1.2; // %
  static const double missionOverheadDrain = 1.0; // % per full mission

  /// Returns the total cost for a delivery.
  static double calculateCost({
    required double baseCost,
    required double distanceKm,
    required double weightKg,
  }) {
    final raw = baseCost + (distanceKm * costPerKm) + (weightKg * costPerKg);
    // Round to two decimals.
    return (raw * 100).round() / 100;
  }

  /// Estimated one-way mission time in seconds.
  ///
  /// The estimate is intentionally capped at ~25 s so the whole
  /// round-trip (with all pauses) finishes inside ~60 s.
  static double estimateTime({
    required double distanceKm,
    required double weightKg,
  }) {
    final hours = distanceKm / baseSpeedKmh;
    final raw = hours * 3600 +
        takeoffLandingOverheadSeconds +
        (weightKg * weightPenaltySecondsPerKg);
    // Cap each leg at 25 s.
    return raw.clamp(2.0, 25.0);
  }

  /// Battery drain in percent for a full round-trip mission.
  static double batteryDrainPercent({
    required double distanceKm,
    required double weightKg,
  }) {
    final total = (distanceKm * batteryDrainPerKm) +
        (weightKg * batteryDrainPerKg) +
        missionOverheadDrain;
    // Round-trip doubles the distance-based drain.
    final roundTrip = total + (distanceKm * batteryDrainPerKm);
    return roundTrip;
  }

  /// Slow the drone down slightly when carrying heavier packages.
  static double effectiveSpeedKmh(double baseSpeed, double weightKg) {
    final factor = (1.0 - (weightKg * 0.05)).clamp(0.6, 1.0);
    return baseSpeed * factor;
  }
}
