import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/destination_model.dart';
import '../../data/providers/providers.dart';
import '../../simulation/city_map_data.dart';

/// Horizontal carousel of destination cards. Selecting one updates
/// `selectedDestinationProvider`. This is the second selection method
/// alongside tapping directly on the map.
class DestinationSelector extends ConsumerWidget {
  const DestinationSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final destinations = ref.watch(destinationsProvider);
    final selected = ref.watch(selectedDestinationProvider);

    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
        itemBuilder: (context, i) {
          final d = destinations[i];
          final isSelected = selected?.id == d.id;
          final distance = CityMapData.distanceFromBaseTo(d);
          return _DestinationCard(
            destination: d,
            distanceKm: distance,
            isSelected: isSelected,
            onTap: () {
              ref.read(selectedDestinationProvider.notifier).state =
                  isSelected ? null : d;
            },
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: AppDimensions.md),
        itemCount: destinations.length,
      ),
    );
  }
}

class _DestinationCard extends StatelessWidget {
  final DestinationModel destination;
  final double distanceKm;
  final bool isSelected;
  final VoidCallback onTap;

  const _DestinationCard({
    required this.destination,
    required this.distanceKm,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        width: 160,
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              destination.color.withOpacity(isSelected ? 0.45 : 0.18),
              destination.color.withOpacity(isSelected ? 0.22 : 0.06),
            ],
          ),
          border: Border.all(
            color: isSelected
                ? destination.color.withOpacity(0.9)
                : Colors.white.withOpacity(0.06),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: destination.color.withOpacity(0.5),
                blurRadius: 24,
                spreadRadius: 1,
                offset: const Offset(0, 8),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 280),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: destination.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child:
                    Icon(destination.icon, color: destination.color, size: 22),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  destination.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${distanceKm.toStringAsFixed(2)} km • ${destination.district}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
