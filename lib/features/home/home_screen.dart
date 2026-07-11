import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/constants/enums.dart';
import '../../core/theme/app_colors.dart';
import '../../data/providers/providers.dart';
import '../../widgets/animated_count.dart';
import '../../widgets/animated_button.dart';
import '../../widgets/drone_widget.dart';
import '../map/map_screen.dart';
import '../statistics/statistics_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoCtrl;
  late final AnimationController _droneBobCtrl;
  late final AnimationController _entryCtrl;

  @override
  void initState() {
    super.initState();
    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _droneBobCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _droneBobCtrl.dispose();
    _entryCtrl.dispose();
    super.dispose();
  }

  void _openSimulation() {
    ref.read(notificationServiceProvider).push(
          'Mission Ready',
          'Select a package and destination to begin.',
          type: NotificationType.info,
        );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const MapScreen(),
        fullscreenDialog: true,
      ),
    );
  }

  void _openStatistics() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const StatisticsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(statisticsProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _entryCtrl.drive(
              Tween<double>(begin: 0, end: 1)
                  .chain(CurveTween(curve: Curves.easeOut)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppDimensions.md),
                  _AnimatedLogo(controller: _logoCtrl),
                  const SizedBox(height: AppDimensions.md),
                  AnimatedBuilder(
                    animation: _droneBobCtrl,
                    builder: (ctx, child) {
                      final v = Tween<double>(begin: -8, end: 8)
                          .transform(_droneBobCtrl.value);
                      return Transform.translate(
                        offset: Offset(0, v),
                        child: child,
                      );
                    },
                    child: const Center(
                      child: DroneWidget(size: 180),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.md),
                  const Center(
                    child: Text(
                      'Aerologix Drone Delivery',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Center(
                    child: Text(
                      'Autonomous last-mile logistics, simulated end-to-end.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.lg),
                  _StatsBanner(stats: stats),
                  const SizedBox(height: AppDimensions.lg),
                  const SizedBox(height: AppDimensions.lg),
                  AnimatedButton(
                    onPressed: _openSimulation,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.flight_takeoff_rounded,
                            color: AppColors.textPrimary),
                        SizedBox(width: 10),
                        Text(
                          'Start Simulation',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  Row(
                    children: [
                      Expanded(
                        child: AnimatedButton(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.primaryDark,
                              AppColors.primary,
                            ],
                          ),
                          onPressed: _openStatistics,
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.bar_chart_rounded,
                                  color: AppColors.textPrimary),
                              SizedBox(width: 8),
                              Text(
                                'Statistics',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.sm),
                      Expanded(
                        child: AnimatedButton(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.surfaceElevated,
                              AppColors.surfaceAlt,
                            ],
                          ),
                          onPressed: () => _showAboutDialog(context),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.info_outline_rounded,
                                  color: AppColors.textPrimary),
                              SizedBox(width: 8),
                              Text(
                                'About',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.lg),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Aerologix Drone Delivery',
      applicationVersion: '1.0.0',
      applicationLegalese:
          '\nA premium Flutter simulation demonstrating autonomous last-mile delivery with hand-drawn maps, animated drone mechanics, and live telemetry.',
    );
  }
}

class _AnimatedLogo extends StatelessWidget {
  final AnimationController controller;
  const _AnimatedLogo({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 130,
        height: 130,
        child: AnimatedBuilder(
          animation: controller,
          builder: (ctx, _) {
            return CustomPaint(
              painter: _LogoPainter(progress: controller.value),
            );
          },
        ),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  final double progress;
  _LogoPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final glow = Paint()
      ..color = AppColors.primary.withOpacity(0.45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    final ring = Paint()
      ..shader = const SweepGradient(
        colors: [
          AppColors.primary,
          AppColors.accent,
          AppColors.primary,
        ],
      ).createShader(Rect.fromCircle(
        center: size.center(Offset.zero),
        radius: size.shortestSide / 2,
      ))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(size.center(Offset.zero), size.shortestSide / 2, glow);

    final start = -1.5708 + (progress * 6.2831);
    canvas.drawArc(
      Rect.fromCircle(
        center: size.center(Offset.zero),
        radius: size.shortestSide / 2 - 6,
      ),
      start,
      4.7,
      false,
      ring,
    );

    final icon = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;
    final c = size.center(Offset.zero);
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(progress * 6.2831);
    canvas.restore();

    final path = Path();
    path.moveTo(c.dx, c.dy - 22);
    path.lineTo(c.dx + 18, c.dy + 12);
    path.lineTo(c.dx, c.dy + 4);
    path.lineTo(c.dx - 18, c.dy + 12);
    path.close();
    canvas.drawPath(path, icon);

    final core = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.fill;
    canvas.drawCircle(c, 6, core);
  }

  @override
  bool shouldRepaint(covariant _LogoPainter old) => old.progress != progress;
}

class _StatsBanner extends StatelessWidget {
  final dynamic stats;
  const _StatsBanner({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.surfaceElevated, AppColors.surface],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.15),
            blurRadius: 24,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _bannerItem(
            'Deliveries',
            stats.totalDeliveries.toDouble(),
            Icons.local_shipping_rounded,
            AppColors.primary,
            isInt: true,
          ),
          _bannerItem(
            'Earnings',
            stats.totalEarnings,
            Icons.attach_money_rounded,
            AppColors.success,
            prefix: r'$',
          ),
          _bannerItem(
            'Distance',
            stats.totalDistanceKm,
            Icons.straighten_rounded,
            AppColors.accent,
            suffix: ' km',
          ),
        ],
      ),
    );
  }

  Widget _bannerItem(
    String label,
    double value,
    IconData icon,
    Color color, {
    bool isInt = false,
    String? prefix,
    String? suffix,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 6),
        AnimatedCount(
          target: value,
          duration: const Duration(milliseconds: 700),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
          formatter: (v) =>
              '${prefix ?? ''}${isInt ? v.toInt().toString() : v.toStringAsFixed(isInt ? 0 : 2)}${suffix ?? ''}',
          decimals: isInt ? 0 : 2,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 10,
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }
}
