import '../../core/constants/enums.dart';
import 'destination_model.dart';
import 'package_model.dart';

/// A pending or in-progress delivery order.
class DeliveryModel {
  final String id;
  final PackageModel package;
  final double weightKg;
  final DestinationModel destination;
  final double distanceKm;
  final double estimatedCost;
  final double estimatedTimeSeconds;
  final DateTime createdAt;

  const DeliveryModel({
    required this.id,
    required this.package,
    required this.weightKg,
    required this.destination,
    required this.distanceKm,
    required this.estimatedCost,
    required this.estimatedTimeSeconds,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'packageType': package.type.name,
        'weight': weightKg,
        'destinationId': destination.id,
        'distance': distanceKm,
        'cost': estimatedCost,
        'time': estimatedTimeSeconds,
        'createdAt': createdAt.toIso8601String(),
      };

  factory DeliveryModel.fromJson(
    Map<String, dynamic> json, {
    required PackageModel Function(PackageType) packageResolver,
    required DestinationModel Function(String) destinationResolver,
  }) {
    final type = PackageType.values.firstWhere(
      (t) => t.name == json['packageType'],
      orElse: () => PackageType.parcel,
    );
    return DeliveryModel(
      id: json['id'] as String,
      package: packageResolver(type),
      weightKg: (json['weight'] as num).toDouble(),
      destination: destinationResolver(json['destinationId'] as String),
      distanceKm: (json['distance'] as num).toDouble(),
      estimatedCost: (json['cost'] as num).toDouble(),
      estimatedTimeSeconds: (json['time'] as num).toDouble(),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
