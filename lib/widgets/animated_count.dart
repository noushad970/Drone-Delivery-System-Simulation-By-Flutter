import 'package:flutter/material.dart';

/// Counts up from 0 to a target value using a tween animation.
class AnimatedCount extends StatelessWidget {
  final num target;
  final TextStyle? style;
  final Duration duration;
  final String Function(num value)? formatter;
  final int decimals;

  const AnimatedCount({
    super.key,
    required this.target,
    this.style,
    this.duration = const Duration(milliseconds: 900),
    this.formatter,
    this.decimals = 0,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: target.toDouble()),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        final formatted = formatter != null
            ? formatter!(value)
            : value.toStringAsFixed(decimals);
        return Text(formatted, style: style);
      },
    );
  }
}