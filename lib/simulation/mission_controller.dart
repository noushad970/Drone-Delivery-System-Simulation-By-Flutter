import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'mission_simulator.dart';

/// Thin controller wrapper that owns the [MissionSimulator] lifecycle and
/// exposes a [ValueListenable] of the latest [MissionFrame] so widgets can
/// listen via `ValueListenableBuilder`.
class MissionController extends ValueNotifier<MissionFrame?> {
  MissionController() : super(null);

  final MissionSimulator simulator = MissionSimulator();
  late final ValueNotifier<int> _tickNotifier = ValueNotifier(0);

  /// Emit a notification so dependents (animated overlays) can rebuild.
  ValueListenable<int> get ticks => _tickNotifier;

  void start({
    required Size canvasSize,
    required Offset home,
    required Offset destination,
    required double distanceKm,
    required double weightKg,
    double initialBattery = 100,
  }) {
    simulator.start(
      canvasSize: canvasSize,
      home: home,
      destination: destination,
      distanceKm: distanceKm,
      weightKg: weightKg,
      initialBattery: initialBattery,
    );
    simulator.stream.listen((frame) {
      value = frame;
      _tickNotifier.value++;
    });
  }

  void pause() => simulator.pause();
  void resume() => simulator.resume();
  void stop({bool reset = true}) => simulator.stop(reset: reset);

  @override
  void dispose() {
    simulator.dispose();
    _tickNotifier.dispose();
    super.dispose();
  }
}
