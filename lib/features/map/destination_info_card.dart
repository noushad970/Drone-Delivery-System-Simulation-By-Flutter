import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/destination_model.dart';
import '../../data/providers/providers.dart';
import '../../simulation/city_map_data.dart';
import '../../widgets/glass_card.dart';

/// Side panel that displays information about the currently selected
/// destination.
class DestinationInfoCard extends ConsumerWidget {
  const DestinationInfoCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedDestinationProvider);

    if (selected == null) {
      return const GlassCard(
        child: Row(
          children: [
            Icon(Icons.touch_app_rounded, color: AppColors.primary),
            SizedBox(width: AppDimensions.md),
            Expanded(
              child: Text(
                'Tap a destination on the map to select it.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      );
    }

    final distance = CityMapData.distanceFromBaseTo(selected);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: selected.color.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(selected.icon, color: selected.color, size: 24),
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selected.name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      selected.district,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded,
                    color: AppColors.textSecondary),
                onPressed: () {
                  ref.read(selectedDestinationProvider.notifier).state = null;
                },
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          Row(
            children: [
              _infoChip(
                Icons.straighten_rounded,
                '${distance.toStringAsFixed(2)} km',
                AppColors.primary,
              ),
              const SizedBox(width: AppDimensions.sm),
              _infoChip(
                Icons.alt_route_rounded,
                '~${(distance * 1.5).toStringAsFixed(1)} min',
                AppColors.accent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
