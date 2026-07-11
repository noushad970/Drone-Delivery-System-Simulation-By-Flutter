import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/package_model.dart';
import '../../data/providers/providers.dart';

/// Horizontal carousel of package cards. Selecting one updates the
/// `selectedPackageProvider` and animates the chosen card.
class PackageSelector extends ConsumerWidget {
  const PackageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedPackageProvider);
    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
        itemBuilder: (context, i) {
          final pkg = PackageModel.catalog[i];
          final isSelected = selected == pkg.type;
          return _PackageCard(
            package: pkg,
            isSelected: isSelected,
            onTap: () {
              ref.read(selectedPackageProvider.notifier).state = isSelected
                  ? null
                  : pkg.type;
            },
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: AppDimensions.md),
        itemCount: PackageModel.catalog.length,
      ),
    );
  }
}

class _PackageCard extends StatelessWidget {
  final PackageModel package;
  final bool isSelected;
  final VoidCallback onTap;

  const _PackageCard({
    required this.package,
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
              package.color.withOpacity(isSelected ? 0.45 : 0.18),
              package.color.withOpacity(isSelected ? 0.22 : 0.06),
            ],
          ),
          border: Border.all(
            color: isSelected
                ? package.color.withOpacity(0.9)
                : Colors.white.withOpacity(0.06),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: package.color.withOpacity(0.5),
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
                  color: package.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(package.icon, color: package.color, size: 22),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  package.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '\$${package.baseCost.toStringAsFixed(2)} • ${package.baseWeightKg.toStringAsFixed(2)} kg',
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
