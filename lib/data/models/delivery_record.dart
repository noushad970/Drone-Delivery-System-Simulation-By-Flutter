import '../../core/constants/enums.dart';
import 'delivery_model.dart';
import 'destination_model.dart';
import 'package_model.dart';

/// A completed (or failed) delivery kept in the delivery history.
class DeliveryRecord {
  final String id;
  final DeliveryModel order;
  final DateTime completedAt;
  final double actualDurationSeconds;
  final double batteryUsedPercent;
  final double totalCost;
  final MissionStage finalStage;

  const DeliveryRecord({
    required this.id,
    required this.order,
    required this.completedAt,
    required this.actualDurationSeconds,
    required this.batteryUsedPercent,
    required this.totalCost,
    required this.finalStage,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'order': order.toJson(),
        'completedAt': completedAt.toIso8601String(),
        'actualDuration': actualDurationSeconds,
        'batteryUsed': batteryUsedPercent,
        'totalCost': totalCost,
        'finalStage': finalStage.name,
      };

  factory DeliveryRecord.fromJson(
    Map<String, dynamic> json, {
    required PackageModel Function(PackageType) packageResolver,
    required DestinationModel Function(String) destinationResolver,
  }) {
    final orderJson = json['order'] as Map<String, dynamic>;
    final order = DeliveryModel.fromJson(
      orderJson,
      packageResolver: packageResolver,
      destinationResolver: destinationResolver,
    );
    return DeliveryRecord(
      id: json['id'] as String,
      order: order,
      completedAt: DateTime.tryParse(json['completedAt'] as String? ?? '') ??
          DateTime.now(),
      actualDurationSeconds: (json['actualDuration'] as num).toDouble(),
      batteryUsedPercent: (json['batteryUsed'] as num).toDouble(),
      totalCost: (json['totalCost'] as num).toDouble(),
      finalStage: MissionStage.values.firstWhere(
        (e) => e.name == (json['finalStage'] as String? ?? ''),
        orElse: () => MissionStage.completed,
      ),
    );
  }
}
