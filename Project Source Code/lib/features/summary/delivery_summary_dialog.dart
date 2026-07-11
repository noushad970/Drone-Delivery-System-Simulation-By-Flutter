import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/constants/enums.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/delivery_record.dart';
import '../../data/providers/providers.dart';
import '../../widgets/animated_count.dart';
import '../../widgets/glass_card.dart';

Future<void> showDeliverySummary(
  BuildContext context,
  WidgetRef ref, {
  required DeliveryRecord record,
}) {
  return showGeneralDialog(
    context: context,
    barrierLabel: 'summary',
    barrierColor: Colors.black.withOpacity(0.55),
    barrierDismissible: true,
    transitionDuration: const Duration(milliseconds: 320),
    pageBuilder: (ctx, anim1, anim2) => _SummaryContent(record: record),
    transitionBuilder: (ctx, anim1, anim2, child) {
      final scale = Tween<double>(begin: 0.85, end: 1.0).animate(
        CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic),
      );
      final fade = Tween<double>(begin: 0, end: 1).animate(anim1);
      return FadeTransition(
        opacity: fade,
        child: ScaleTransition(scale: scale, child: child),
      );
    },
  );
}

class _SummaryContent extends ConsumerWidget {
  final DeliveryRecord record;
  const _SummaryContent({required this.record});

  Color _statusColor() {
    switch (record.finalStage) {
      case MissionStage.completed:
        return AppColors.success;
      case MissionStage.failed:
        return AppColors.danger;
      default:
        return AppColors.warning;
    }
  }

  IconData _statusIcon() {
    switch (record.finalStage) {
      case MissionStage.completed:
        return Icons.check_circle_rounded;
      case MissionStage.failed:
        return Icons.cancel_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = _statusColor();
    final icon = _statusIcon();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: GlassCard(
            padding: const EdgeInsets.all(AppDimensions.lg),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.18),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.45),
                              blurRadius: 18,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Icon(icon, color: color, size: 28),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Delivery ${record.finalStage.name.toUpperCase()}',
                              style: TextStyle(
                                color: color,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Mission Summary',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.md),
                  _row(Icons.local_shipping_rounded, 'Package',
                      record.order.package.name),
                  _row(Icons.place_rounded, 'Destination',
                      record.order.destination.name),
                  _row(Icons.scale_rounded, 'Weight',
                      '${record.order.weightKg.toStringAsFixed(2)} kg'),
                  _row(Icons.straighten_rounded, 'Distance',
                      '${record.order.distanceKm.toStringAsFixed(2)} km'),
                  _row(
                      Icons.timer_rounded,
                      'Delivery Time',
                      Formatters.duration(Duration(
                          milliseconds:
                              (record.actualDurationSeconds * 1000).round()))),
                  _row(Icons.battery_alert_rounded, 'Battery Used',
                      '${record.batteryUsedPercent.toStringAsFixed(1)}%'),
                  const Divider(
                    color: AppColors.divider,
                    height: AppDimensions.lg,
                  ),
                  Center(
                    child: Column(
                      children: [
                        const Text(
                          'Total Cost',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        AnimatedCount(
                          target: record.totalCost,
                          duration: const Duration(milliseconds: 900),
                          decimals: 2,
                          formatter: (v) => '\$${v.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.lg),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            ref
                                .read(missionControllerProvider)
                                .stop(reset: true);
                            ref.read(currentDeliveryProvider.notifier).state =
                                null;
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textPrimary,
                            side: const BorderSide(
                              color: AppColors.divider,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Close'),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.sm),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            ref
                                .read(missionControllerProvider)
                                .stop(reset: true);
                            ref.read(currentDeliveryProvider.notifier).state =
                                null;
                            final gen = ref.read(orderGeneratorProvider);
                            ref.read(currentDeliveryProvider.notifier).state =
                                gen.nextOrder();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('New Delivery'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(width: 10),
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
