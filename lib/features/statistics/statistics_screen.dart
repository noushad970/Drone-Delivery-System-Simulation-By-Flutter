import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/delivery_record.dart';
import '../../data/providers/providers.dart';
import '../../widgets/animated_count.dart';
import '../../widgets/glass_card.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statisticsProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: AppColors.textPrimary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Statistics',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  if (stats.totalDeliveries > 0)
                    TextButton.icon(
                      onPressed: () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: AppColors.surfaceElevated,
                            title: const Text(
                              'Clear statistics?',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            content: const Text(
                              'All delivery history will be erased. This cannot be undone.',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(true),
                                child: const Text(
                                  'Clear',
                                  style: TextStyle(
                                    color: AppColors.danger,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                        if (ok == true) {
                          await ref.read(statisticsProvider.notifier).clear();
                        }
                      },
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.danger,
                        size: 18,
                      ),
                      label: const Text(
                        'Clear',
                        style: TextStyle(color: AppColors.danger),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppDimensions.sm),
              _KpiRow(stats: stats),
              const SizedBox(height: AppDimensions.md),
              _EarningsChart(history: stats.history),
              const SizedBox(height: AppDimensions.md),
              _DistributionChart(history: stats.history),
              const SizedBox(height: AppDimensions.md),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppDimensions.xs),
                child: Text(
                  'Delivery History',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.sm),
              if (stats.history.isEmpty)
                const GlassCard(
                  padding: EdgeInsets.all(AppDimensions.lg),
                  child: Center(
                    child: Text(
                      'No deliveries yet. Start a mission to build your history.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                Column(
                  children: [
                    for (final r in stats.history.reversed)
                      _HistoryTile(record: r),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KpiRow extends StatelessWidget {
  final dynamic stats;
  const _KpiRow({required this.stats});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, c) {
        final isWide = c.maxWidth > 480;
        final cards = [
          _Kpi(
            label: 'Deliveries',
            value: stats.totalDeliveries.toDouble(),
            icon: Icons.local_shipping_rounded,
            color: AppColors.primary,
            isInt: true,
          ),
          _Kpi(
            label: 'Earnings',
            value: stats.totalEarnings,
            icon: Icons.attach_money_rounded,
            color: AppColors.success,
            prefix: r'$',
          ),
          _Kpi(
            label: 'Distance',
            value: stats.totalDistanceKm,
            icon: Icons.straighten_rounded,
            color: AppColors.accent,
            suffix: ' km',
          ),
          _Kpi(
            label: 'Avg Time',
            value: stats.averageTimeSeconds,
            icon: Icons.timer_rounded,
            color: AppColors.warning,
            formatter: (v) =>
                Formatters.duration(Duration(milliseconds: (v * 1000).round())),
          ),
        ];
        return Wrap(
          spacing: AppDimensions.sm,
          runSpacing: AppDimensions.sm,
          children: [
            for (final card in cards)
              SizedBox(
                width: isWide
                    ? (c.maxWidth - AppDimensions.sm * 3) / 4
                    : (c.maxWidth - AppDimensions.sm) / 2,
                child: card,
              ),
          ],
        );
      },
    );
  }
}

class _Kpi extends StatelessWidget {
  final String label;
  final double value;
  final IconData icon;
  final Color color;
  final String? prefix;
  final String? suffix;
  final bool isInt;
  final String Function(num)? formatter;

  const _Kpi({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.prefix,
    this.suffix,
    this.isInt = false,
    this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppDimensions.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    letterSpacing: 0.6,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (formatter != null)
            AnimatedCount(
              target: value,
              duration: const Duration(milliseconds: 800),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
              formatter: formatter,
            )
          else
            AnimatedCount(
              target: value,
              duration: const Duration(milliseconds: 800),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
              formatter: (v) =>
                  '${prefix ?? ''}${isInt ? v.toInt().toString() : v.toStringAsFixed(isInt ? 0 : 2)}${suffix ?? ''}',
              decimals: isInt ? 0 : 2,
            ),
        ],
      ),
    );
  }
}

class _EarningsChart extends StatelessWidget {
  final List<DeliveryRecord> history;
  const _EarningsChart({required this.history});

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[];
    for (var i = 0; i < history.length; i++) {
      spots.add(FlSpot(i.toDouble(), history[i].totalCost));
    }

    return GlassCard(
      padding: const EdgeInsets.all(AppDimensions.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Earnings per Delivery',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppDimensions.sm),
          SizedBox(
            height: 180,
            child: spots.isEmpty
                ? const Center(
                    child: Text(
                      'No data yet',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  )
                : LineChart(
                    LineChartData(
                      minX: 0,
                      maxX: (spots.length - 1)
                          .clamp(1, double.infinity)
                          .toDouble(),
                      minY: 0,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 5,
                        getDrawingHorizontalLine: (_) => const FlLine(
                          color: AppColors.divider,
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 22,
                            interval: spots.length > 5 ? 2 : 1,
                            getTitlesWidget: (v, _) {
                              final i = v.toInt();
                              if (i < 0 || i >= spots.length) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  '${i + 1}',
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 10,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 32,
                            getTitlesWidget: (v, _) => Text(
                              r'$${v.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          curveSmoothness: 0.3,
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.accent,
                            ],
                          ),
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (s, _, __, ___) =>
                                FlDotCirclePainter(
                              radius: 4,
                              color: AppColors.accent,
                              strokeColor: AppColors.surface,
                              strokeWidth: 2,
                            ),
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.primary.withOpacity(0.35),
                                AppColors.primary.withOpacity(0.0),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _DistributionChart extends StatelessWidget {
  final List<DeliveryRecord> history;
  const _DistributionChart({required this.history});

  Map<String, int> _tallyByPackage() {
    final m = <String, int>{};
    for (final r in history) {
      final k = r.order.package.type.name;
      m[k] = (m[k] ?? 0) + 1;
    }
    return m;
  }

  Color _colorForKey(String key) {
    switch (key) {
      case 'food':
        return AppColors.warning;
      case 'medicine':
        return AppColors.danger;
      case 'parcel':
        return AppColors.primary;
      case 'documents':
        return AppColors.accent;
      default:
        return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tally = _tallyByPackage();
    final total = tally.values.fold<int>(0, (a, b) => a + b);
    final entries = tally.entries.toList();

    return GlassCard(
      padding: const EdgeInsets.all(AppDimensions.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Package Mix',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppDimensions.sm),
          SizedBox(
            height: 180,
            child: total == 0
                ? const Center(
                    child: Text(
                      'No data yet',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  )
                : Row(
                    children: [
                      Expanded(
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 3,
                            centerSpaceRadius: 40,
                            sections: [
                              for (final e in entries)
                                PieChartSectionData(
                                  value: e.value.toDouble(),
                                  color: _colorForKey(e.key),
                                  title: '${e.value}',
                                  radius: 56,
                                  titleStyle: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.sm),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final e in entries)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 3),
                              child: Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: _colorForKey(e.key),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    e.key,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 11,
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final DeliveryRecord record;
  const _HistoryTile({required this.record});

  @override
  Widget build(BuildContext context) {
    final success = record.finalStage.name == 'completed';
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.sm),
      child: GlassCard(
        padding: const EdgeInsets.all(AppDimensions.sm + 2),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (success ? AppColors.success : AppColors.danger)
                    .withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: Icon(
                success ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: success ? AppColors.success : AppColors.danger,
                size: 18,
              ),
            ),
            const SizedBox(width: AppDimensions.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.order.destination.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${record.order.package.name} - '
                    '${record.order.distanceKm.toStringAsFixed(2)} km - '
                    '${Formatters.duration(Duration(milliseconds: (record.actualDurationSeconds * 1000).round()))}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    DateFormat('MMM d, HH:mm').format(record.completedAt),
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              r'$${record.totalCost.toStringAsFixed(2)}',
              style: const TextStyle(
                color: AppColors.success,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
