import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/constants/enums.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/delivery_record.dart';
import '../../data/models/delivery_model.dart';
import '../../data/models/destination_model.dart';
import '../../data/models/package_model.dart';
import '../../data/providers/providers.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/animated_battery.dart';
import '../../widgets/stage_tracker.dart';

/// The drone info panel: battery, speed, mission progress, current package,
/// and destination.
class DroneInfoPanel extends ConsumerWidget {
  final DeliveryModel? order;
  final DestinationModel? selectedDestination;

  const DroneInfoPanel({
    super.key,
    required this.order,
    required this.selectedDestination,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mission = ref.watch(missionControllerProvider);
    final frame = mission.value;

    final battery = frame?.batteryPercent ?? 100;
    final speed = frame?.speedKmh ?? 0;
    final stage = frame?.stage ?? MissionStage.idle;
    final status = frame?.status ?? DroneStatus.idle;
    final elapsed = frame?.elapsed ?? Duration.zero;

    return GlassCard(
      padding: const EdgeInsets.all(AppDimensions.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'DRONE STATUS',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  letterSpacing: 1.6,
                ),
              ),
              const Spacer(),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(status).withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.name.toUpperCase(),
                  style: TextStyle(
                    color: _statusColor(status),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          Row(
            children: [
              AnimatedBatteryRing(
                percent: battery,
                size: 110,
                strokeWidth: 10,
              ),
              const SizedBox(width: AppDimensions.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _statRow(Icons.speed_rounded, 'Speed',
                        '${speed.toStringAsFixed(0)} km/h'),
                    const SizedBox(height: AppDimensions.sm),
                    _statRow(Icons.timer_outlined, 'Mission',
                        Formatters.duration(elapsed)),
                    const SizedBox(height: AppDimensions.sm),
                    _statRow(Icons.flight_rounded, 'Stage', stage.label),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.lg),
          StageTracker(currentStage: stage),
          const SizedBox(height: AppDimensions.lg),
          if (order != null) ...[
            _LabelValueRow(
              icon: order!.package.icon,
              color: order!.package.color,
              label: 'Package',
              value: '${order!.package.name} • ${order!.weightKg.toStringAsFixed(2)} kg',
            ),
            const SizedBox(height: AppDimensions.sm),
            _LabelValueRow(
              icon: Icons.location_on_rounded,
              color: selectedDestination?.color ?? AppColors.primary,
              label: 'Destination',
              value: selectedDestination?.name ?? '—',
            ),
            const SizedBox(height: AppDimensions.sm),
            _LabelValueRow(
              icon: Icons.straighten_rounded,
              color: AppColors.accent,
              label: 'Distance',
              value: '${order!.distanceKm.toStringAsFixed(2)} km',
            ),
          ] else
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppDimensions.md),
              child: Text(
                'Select a package and destination to begin a delivery.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
        ],
      ),
    );
  }

  Widget _statRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Color _statusColor(DroneStatus s) {
    switch (s) {
      case DroneStatus.idle:
        return AppColors.textMuted;
      case DroneStatus.flying:
        return AppColors.info;
      case DroneStatus.returning:
        return AppColors.warning;
      case DroneStatus.delivered:
        return AppColors.success;
      case DroneStatus.paused:
        return AppColors.textSecondary;
    }
  }
}

class _LabelValueRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _LabelValueRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: AppDimensions.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Helper to construct DeliveryRecord from a mission.
DeliveryRecord buildDeliveryRecord({
  required DeliveryModel order,
  required Duration actualDuration,
  required double batteryUsed,
  required double totalCost,
}) {
  return DeliveryRecord(
    id: '${order.id}-r',
    order: order,
    completedAt: DateTime.now(),
    actualDurationSeconds: actualDuration.inMilliseconds / 1000,
    batteryUsedPercent: batteryUsed,
    totalCost: totalCost,
    finalStage: MissionStage.completed,
  );
}

// Re-export of PackageModel so feature consumers can import from here.
typedef PackageExport = PackageModel; // ignore: unused_element