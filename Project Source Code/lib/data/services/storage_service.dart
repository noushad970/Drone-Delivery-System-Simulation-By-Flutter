import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/statistics.dart';
import '../models/package_model.dart';
import '../../simulation/city_map_data.dart';

/// Local storage service backed by `SharedPreferences`.
///
/// Everything is serialized as JSON strings, so the app stays 100% offline
/// without needing Hive or a database.
class StorageService {
  StorageService(this._prefs);

  final SharedPreferences _prefs;

  static const _kStats = 'aerologix.stats.v1';
  static const _kSettings = 'aerologix.settings.v1';
  static const _kLastDrone = 'aerologix.last_drone.v1';

  static Future<StorageService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // ---------- Statistics ----------

  Future<DeliveryStatistics> loadStatistics() async {
    final raw = _prefs.getString(_kStats);
    if (raw == null || raw.isEmpty) return const DeliveryStatistics();
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return DeliveryStatistics.fromJson(
        json,
        packageResolver: (t) => PackageModel.byType(t),
        destinationResolver: (id) =>
            CityMapData.findById(id) ?? CityMapData.destinations.first,
      );
    } catch (_) {
      // Corrupted data — fall back to empty so the app keeps running.
      return const DeliveryStatistics();
    }
  }

  Future<void> saveStatistics(DeliveryStatistics stats) async {
    await _prefs.setString(_kStats, jsonEncode(stats.toJson()));
  }

  Future<void> clearStatistics() async {
    await _prefs.remove(_kStats);
  }

  // ---------- Settings ----------

  Future<Map<String, dynamic>> loadSettings() async {
    final raw = _prefs.getString(_kSettings);
    if (raw == null) return <String, dynamic>{};
    try {
      return (jsonDecode(raw) as Map).cast<String, dynamic>();
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  Future<void> saveSettings(Map<String, dynamic> settings) async {
    await _prefs.setString(_kSettings, jsonEncode(settings));
  }

  // ---------- Last drone snapshot ----------

  Future<Map<String, dynamic>?> loadLastDrone() async {
    final raw = _prefs.getString(_kLastDrone);
    if (raw == null) return null;
    try {
      return (jsonDecode(raw) as Map).cast<String, dynamic>();
    } catch (_) {
      return null;
    }
  }

  Future<void> saveLastDrone(Map<String, dynamic> data) async {
    await _prefs.setString(_kLastDrone, jsonEncode(data));
  }

  Future<void> clearLastDrone() async {
    await _prefs.remove(_kLastDrone);
  }
}
