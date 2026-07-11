import 'package_model.dart';
import 'destination_model.dart';
import 'delivery_record.dart';
import '../../core/constants/enums.dart';

/// Aggregated statistics shown on the statistics dashboard.
class DeliveryStatistics {
  final int totalDeliveries;
  final double totalEarnings;
  final double totalDistanceKm;
  final double totalDurationSeconds;
  final double averageCost;
  final double averageTimeSeconds;
  final double averageDistanceKm;
  final List<DeliveryRecord> history;

  const DeliveryStatistics({
    this.totalDeliveries = 0,
    this.totalEarnings = 0,
    this.totalDistanceKm = 0,
    this.totalDurationSeconds = 0,
    this.averageCost = 0,
    this.averageTimeSeconds = 0,
    this.averageDistanceKm = 0,
    this.history = const [],
  });

  factory DeliveryStatistics.fromHistory(List<DeliveryRecord> records) {
    if (records.isEmpty) return const DeliveryStatistics();

    double totalCost = 0;
    double totalDist = 0;
    double totalDur = 0;
    for (final r in records) {
      totalCost += r.totalCost;
      totalDist += r.order.distanceKm;
      totalDur += r.actualDurationSeconds;
    }
    final n = records.length;
    return DeliveryStatistics(
      totalDeliveries: n,
      totalEarnings: totalCost,
      totalDistanceKm: totalDist,
      totalDurationSeconds: totalDur,
      averageCost: totalCost / n,
      averageDistanceKm: totalDist / n,
      averageTimeSeconds: totalDur / n,
      history: records,
    );
  }

  Map<String, dynamic> toJson() => {
        'totalDeliveries': totalDeliveries,
        'totalEarnings': totalEarnings,
        'totalDistanceKm': totalDistanceKm,
        'totalDurationSeconds': totalDurationSeconds,
        'averageCost': averageCost,
        'averageTimeSeconds': averageTimeSeconds,
        'averageDistanceKm': averageDistanceKm,
        'history': history.map((h) => h.toJson()).toList(),
      };

  factory DeliveryStatistics.fromJson(
    Map<String, dynamic> json, {
    required PackageModel Function(PackageType) packageResolver,
    required DestinationModel Function(String) destinationResolver,
  }) {
    final historyJson = (json['history'] as List?) ?? const [];
    final records = historyJson
        .cast<Map<String, dynamic>>()
        .map(
          (j) => DeliveryRecord.fromJson(
            j,
            packageResolver: packageResolver,
            destinationResolver: destinationResolver,
          ),
        )
        .toList();
    return DeliveryStatistics(
      totalDeliveries: (json['totalDeliveries'] as num?)?.toInt() ?? 0,
      totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0,
      totalDistanceKm: (json['totalDistanceKm'] as num?)?.toDouble() ?? 0,
      totalDurationSeconds:
          (json['totalDurationSeconds'] as num?)?.toDouble() ?? 0,
      averageCost: (json['averageCost'] as num?)?.toDouble() ?? 0,
      averageTimeSeconds: (json['averageTimeSeconds'] as num?)?.toDouble() ?? 0,
      averageDistanceKm: (json['averageDistanceKm'] as num?)?.toDouble() ?? 0,
      history: records,
    );
  }
}
