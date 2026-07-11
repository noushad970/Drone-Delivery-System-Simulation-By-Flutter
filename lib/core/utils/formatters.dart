import 'package:intl/intl.dart';

/// Common formatters so the UI stays consistent.
class Formatters {
  Formatters._();

  static final NumberFormat _money = NumberFormat.currency(
    symbol: r'$',
    decimalDigits: 2,
  );
  static final NumberFormat _compact = NumberFormat.compact();
  static final DateFormat _dateTime = DateFormat('MMM d • HH:mm');
  static final DurationFormatter _duration = DurationFormatter();

  static String money(num value) => _money.format(value);
  static String compact(num value) => _compact.format(value);
  static String dateTime(DateTime dt) => _dateTime.format(dt);
  static String duration(Duration d) => _duration.format(d);
}

/// Formats [Duration] in a human friendly way: H:MM:SS or MM:SS.
class DurationFormatter {
  String format(Duration d) {
    final negative = d.isNegative;
    final abs = d.abs();
    final h = abs.inHours;
    final m = abs.inMinutes.remainder(60);
    final s = abs.inSeconds.remainder(60);
    final mm = m.toString().padLeft(2, '0');
    final ss = s.toString().padLeft(2, '0');
    if (h > 0) {
      return '${negative ? '-' : ''}$h:$mm:$ss';
    }
    return '${negative ? '-' : ''}$mm:$ss';
  }
}