/// Layout and spacing tokens. Centralizing them keeps the UI consistent
/// and avoids magic numbers across widgets.
class AppDimensions {
  AppDimensions._();

  // Spacing scale
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  // Radii
  static const double radiusSm = 8;
  static const double radiusMd = 14;
  static const double radiusLg = 20;
  static const double radiusXl = 28;

  // Animation
  static const Duration durFast = Duration(milliseconds: 200);
  static const Duration durMed = Duration(milliseconds: 400);
  static const Duration durSlow = Duration(milliseconds: 800);
  static const Duration durVerySlow = Duration(milliseconds: 1400);

  // Sizes
  static const double droneSize = 64;
  static const double mapMarkerSize = 36;
  static const double iconLg = 32;
  static const double iconMd = 24;
  static const double iconSm = 18;
}