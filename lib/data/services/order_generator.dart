import 'dart:math';
import 'package:uuid/uuid.dart';

import '../../core/constants/enums.dart';
import '../models/delivery_model.dart';
import '../models/destination_model.dart';
import '../models/package_model.dart';
import '../../simulation/delivery_calculator.dart';
import '../../simulation/city_map_data.dart';

/// Generates random delivery orders, optionally seeded for repeatable tests.
class OrderGenerator {
  OrderGenerator({int? seed}) : _random = Random(seed);

  final Random _random;
  final _uuid = const Uuid();

  /// Produces a new [DeliveryModel] with randomized package, weight, and
  /// destination.
  DeliveryModel nextOrder({
    PackageType? preferredPackage,
    DestinationModel? destinationOverride,
  }) {
    final pkg = preferredPackage != null
        ? PackageModel.byType(preferredPackage)
        : PackageModel.catalog[_random.nextInt(PackageModel.catalog.length)];

    // Use override destination if provided, otherwise pick a random one.
    final destinations = CityMapData.destinations;
    final destination = destinationOverride ??
        destinations[_random.nextInt(destinations.length)];

    // Slightly vary weight (±25%) to make stats more interesting.
    final weightJitter = 0.75 + _random.nextDouble() * 0.5;
    final weight = pkg.baseWeightKg * weightJitter;

    // Distance estimate: pick the destination's distance from base as a guide.
    final distance = CityMapData.distanceFromBaseTo(destination);
    // Add small noise so values aren't identical.
    final noisyDistance = distance * (0.9 + _random.nextDouble() * 0.2);

    final cost = DeliveryCalculator.calculateCost(
      baseCost: pkg.baseCost,
      distanceKm: noisyDistance,
      weightKg: weight,
    );
    final time = DeliveryCalculator.estimateTime(
      distanceKm: noisyDistance,
      weightKg: weight,
    );

    return DeliveryModel(
      id: _uuid.v4(),
      package: pkg,
      weightKg: weight,
      destination: destination,
      distanceKm: noisyDistance,
      estimatedCost: cost,
      estimatedTimeSeconds: time,
      createdAt: DateTime.now(),
    );
  }
}
