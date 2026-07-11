import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../services/order_generator.dart';
import '../../simulation/mission_controller.dart';
import '../models/destination_model.dart';
import '../models/delivery_model.dart';
import '../models/delivery_record.dart';
import '../models/statistics.dart';
import '../models/notification_model.dart';
import '../../core/constants/enums.dart';
import '../../simulation/city_map_data.dart';

// ----- Async bootstrap -----

/// Holds the initialized [StorageService] after `main` runs the override.
final storageProvider = Provider<StorageService>((ref) {
  throw UnimplementedError('storageProvider must be overridden in main()');
});

// ----- Notifications -----

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final svc = NotificationService();
  ref.onDispose(svc.dispose);
  return svc;
});

final notificationsProvider = StreamProvider<List<AppNotification>>((ref) {
  final svc = ref.watch(notificationServiceProvider);
  return svc.stream;
});

// ----- Order generator -----

final orderGeneratorProvider = Provider<OrderGenerator>(
  (ref) => OrderGenerator(),
);

// ----- Current delivery -----

/// Holds the delivery currently being prepared or executed.
final currentDeliveryProvider = StateProvider<DeliveryModel?>((ref) => null);

/// Selected package type (before a delivery is generated).
final selectedPackageProvider = StateProvider<PackageType?>((ref) => null);

/// Selected destination on the map (before a delivery is generated).
final selectedDestinationProvider = StateProvider<DestinationModel?>(
  (ref) => null,
);

// ----- Mission simulator -----

/// Lives for the duration of the simulation screen. Disposed when the user
/// leaves the simulation.
final missionControllerProvider =
    ChangeNotifierProvider.autoDispose<MissionController>((ref) {
  final controller = MissionController();
  ref.onDispose(controller.dispose);
  return controller;
});

// ----- Statistics -----

class StatisticsNotifier extends StateNotifier<DeliveryStatistics> {
  StatisticsNotifier(this._storage) : super(const DeliveryStatistics()) {
    _load();
  }

  final StorageService _storage;

  Future<void> _load() async {
    final stats = await _storage.loadStatistics();
    state = stats;
  }

  Future<void> addRecord(DeliveryRecord record) async {
    final updated = [...state.history, record];
    final stats = DeliveryStatistics.fromHistory(updated);
    state = stats;
    await _storage.saveStatistics(stats);
  }

  Future<void> clear() async {
    state = const DeliveryStatistics();
    await _storage.clearStatistics();
  }
}

final statisticsProvider =
    StateNotifierProvider<StatisticsNotifier, DeliveryStatistics>((ref) {
  final storage = ref.watch(storageProvider);
  return StatisticsNotifier(storage);
});

// ----- Camera mode -----

final cameraModeProvider = StateProvider<CameraMode>(
  (ref) => CameraMode.defaultView,
);

// ----- Map size -----

/// Holds the latest canvas size for the city map so the simulator can map
/// fractions to pixels.
final mapSizeProvider = StateProvider<Size>((ref) => Size.zero);

// ----- Destination helper -----

final destinationsProvider = Provider<List<DestinationModel>>(
  (ref) => CityMapData.destinations,
);
