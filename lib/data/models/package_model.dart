import 'package:flutter/material.dart';
import '../../core/constants/enums.dart';
import '../../core/constants/app_strings.dart';

/// Represents a package type that the drone can carry.
///
/// Costs and weights are baseline values — the random order generator
/// perturbs them per order.
class PackageModel {
  final PackageType type;
  final String name;
  final IconData icon;
  final double baseCost;
  final double baseWeightKg;
  final Color color;

  const PackageModel({
    required this.type,
    required this.name,
    required this.icon,
    required this.baseCost,
    required this.baseWeightKg,
    required this.color,
  });

  /// Static catalog used by the UI.
  static const List<PackageModel> catalog = [
    PackageModel(
      type: PackageType.food,
      name: AppStrings.pkgFood,
      icon: Icons.restaurant_rounded,
      baseCost: 5.99,
      baseWeightKg: 0.8,
      color: Color(0xFFFF7A59),
    ),
    PackageModel(
      type: PackageType.medicine,
      name: AppStrings.pkgMedicine,
      icon: Icons.medical_services_rounded,
      baseCost: 12.50,
      baseWeightKg: 0.4,
      color: Color(0xFF22C55E),
    ),
    PackageModel(
      type: PackageType.parcel,
      name: AppStrings.pkgParcel,
      icon: Icons.inventory_2_rounded,
      baseCost: 8.75,
      baseWeightKg: 1.6,
      color: Color(0xFF1E88FF),
    ),
    PackageModel(
      type: PackageType.documents,
      name: AppStrings.pkgDocuments,
      icon: Icons.description_rounded,
      baseCost: 4.50,
      baseWeightKg: 0.2,
      color: Color(0xFFA855F7),
    ),
  ];

  static PackageModel byType(PackageType t) =>
      catalog.firstWhere((p) => p.type == t);
}