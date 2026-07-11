import 'dart:async';
import 'package:flutter/material.dart';

import '../core/constants/enums.dart';
import '../core/utils/geo_utils.dart';
import 'delivery_calculator.dart';

/// One frame of the simulated mission.
///
/// Emitted by [MissionSimulator] on each animation tick so the UI can
/// rebuild at ~60 FPS.
class MissionFrame {
  final Offset dronePosition;
  final double altitude;
  final double batteryPercent;
  final double speedKmh;
  final double rotationRadians;
  final MissionStage stage;
  final DroneStatus status;
  final double routeProgress; // 0..1 along the current leg
  final Offset currentLegStart;
  final Offset currentLegEnd;
  final Duration elapsed;

  const MissionFrame({
    required this.dronePosition,
    required this.altitude,
    required this.batteryPercent,
    required this.speedKmh,
    required this.rotationRadians,
    required this.stage,
    required this.status,
    required this.routeProgress,
    required this.currentLegStart,
    required this.currentLegEnd,
    required this.elapsed,
  });
}

/// Controls a single delivery mission in real time using a `Ticker`-style loop.
///
/// The simulator emits [MissionFrame]s that the UI uses to animate the drone,
/// update battery, and drive the route visualization.
class MissionSimulator {
  MissionSimulator();

  // Public configuration
  Size canvasSize = const Size(1000, 600);
  Duration tickInterval = const Duration(milliseconds: 16); // ~60 FPS
  double cruiseAltitude = 60; // pixels above ground
  double ascentSeconds = 0.8;
  double descentSeconds = 0.8;
  double landingPauseSeconds = 0.6;
  double deliveryPauseSeconds = 0.8;

  // Hard cap on total mission time.
  static const double maxTotalSeconds = 58.0;

  // Internal state
  Timer? _timer;
  Offset _home = const Offset(0, 0);
  Offset _destination = const Offset(0, 0);
  double _distanceKm = 0;
  double _weightKg = 1;
  double _battery = 100;
  double _speed = 0;
  MissionStage _stage = MissionStage.idle;
  DroneStatus _status = DroneStatus.idle;
  DateTime? _startedAt;
  Duration _elapsed = Duration.zero;
  Offset _currentLegStart = const Offset(0, 0);
  Offset _currentLegEnd = const Offset(0, 0);
  double _legProgress = 0; // 0..1
  double _currentAltitude = 0;
  bool _paused = false;
  bool _completed = false;
  bool _goingHome = false;

  // Per-mission phase budget (seconds) computed from estimateTime so that
  // every flight fits inside [maxTotalSeconds].
  double _outboundLegSeconds = 10;
  double _returnLegSeconds = 10;

  final _controller = StreamController<MissionFrame>.broadcast();
  Stream<MissionFrame> get stream => _controller.stream;

  /// Latest frame, useful for the UI to show the current state.
  MissionFrame? get lastFrame => _lastFrame;
  MissionFrame? _lastFrame;

  /// Whether the simulator is currently running.
  bool get isRunning => _timer != null;
  bool get isPaused => _paused;
  bool get isCompleted => _completed;

  /// Begin a delivery mission. Sets up the route, altitude, etc.
  void start({
    required Size canvasSize,
    required Offset home,
    required Offset destination,
    required double distanceKm,
    required double weightKg,
    double initialBattery = 100,
  }) {
    stop(reset: true);

    this.canvasSize = canvasSize;
    _home = home;
    _destination = destination;
    _distanceKm = distanceKm;
    _weightKg = weightKg;
    _battery = initialBattery;
    _currentAltitude = 0;
    _legProgress = 0;
    _stage = MissionStage.preparing;
    _status = DroneStatus.flying;
    _startedAt = DateTime.now();
    _elapsed = Duration.zero;
    _paused = false;
    _completed = false;
    _goingHome = false;

    _currentLegStart = _home;
    _currentLegEnd = _home; // stay put while preparing

    // Compute leg budgets. estimateTime is clamped to 25 s per leg so we
    // also clamp the total budget to fit comfortably within maxTotalSeconds.
    final oneWay = DeliveryCalculator.estimateTime(
        distanceKm: distanceKm, weightKg: weightKg);
    _outboundLegSeconds = oneWay.clamp(3.0, 22.0);
    _returnLegSeconds = oneWay.clamp(3.0, 22.0);

    _emitFrame(rotationOverride: GeoUtils.angleRadians(_home, _destination));
    _startTimer();
  }

  /// Pause the simulation. Battery and timer freeze.
  void pause() {
    if (!_paused && _timer != null) {
      _paused = true;
      _timer?.cancel();
      _timer = null;
      _status = DroneStatus.paused;
      _emitFrame();
    }
  }

  /// Resume from a paused state.
  void resume() {
    if (_paused && !_completed) {
      _paused = false;
      _status = _goingHome ? DroneStatus.returning : DroneStatus.flying;
      _startTimer();
    }
  }

  /// Stop and reset.
  void stop({bool reset = true}) {
    _timer?.cancel();
    _timer = null;
    if (reset) {
      _stage = MissionStage.idle;
      _status = DroneStatus.idle;
      _battery = 100;
      _currentAltitude = 0;
      _legProgress = 0;
      _elapsed = Duration.zero;
      _completed = false;
      _goingHome = false;
      _lastFrame = null;
    }
  }

  void dispose() {
    stop(reset: false);
    _controller.close();
  }

  // ---- Internals ----

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(tickInterval, (_) => _tick());
  }

  Duration get elapsed => _elapsed;

  Offset _lastPositionOverride = const Offset(0, 0);

  void _tick() {
    final now = DateTime.now();
    if (_startedAt != null) {
      _elapsed = now.difference(_startedAt!);
    }

    final t = _elapsed.inMilliseconds / 1000.0;

    // Hard cap on mission length so a trip can never exceed ~58 s.
    if (t > maxTotalSeconds && !_completed) {
      _stage = MissionStage.returning;
      _goingHome = true;
      _legProgress = (_legProgress).clamp(0.0, 1.0);
    }

    _advanceStage(t);

    switch (_stage) {
      case MissionStage.preparing:
        _currentAltitude = 0;
        _speed = 0;
        _currentLegStart = _home;
        _currentLegEnd = _home;
        _legProgress = 0;
        _lastPositionOverride = _home;
        break;

      case MissionStage.takingOff:
        final p = ((t - _phaseStart) / ascentSeconds).clamp(0.0, 1.0);
        _currentAltitude = cruiseAltitude * Curves.easeOutCubic.transform(p);
        _speed = 30 * p;
        _currentLegStart = _home;
        _currentLegEnd = _destination;
        _legProgress = 0;
        _lastPositionOverride = _home;
        break;

      case MissionStage.flying:
        {
          final p = ((t - _phaseStart) / _outboundLegSeconds).clamp(0.0, 1.0);
          _legProgress = p;
          _currentLegStart = _home;
          _currentLegEnd = _destination;
          _currentAltitude = cruiseAltitude;
          _lastPositionOverride = GeoUtils.lerp(_home, _destination, p);
          _speed = DeliveryCalculator.effectiveSpeedKmh(
            DeliveryCalculator.baseSpeedKmh,
            _weightKg,
          );
          // Battery drain proportional to elapsed flight time.
          _battery -= DeliveryCalculator.batteryDrainPerKm *
              (_distanceKm * tickInterval.inMilliseconds / 1000 / 80);
        }
        break;

      case MissionStage.landing:
        final p = ((t - _phaseStart) / descentSeconds).clamp(0.0, 1.0);
        _currentAltitude =
            cruiseAltitude * (1 - Curves.easeInCubic.transform(p));
        _speed = 20 * (1 - p);
        // Land at destination.
        _currentLegStart = _home;
        _currentLegEnd = _destination;
        _lastPositionOverride = _destination;
        _legProgress = 1;
        break;

      case MissionStage.delivering:
        _currentAltitude = 0;
        _speed = 0;
        _currentLegStart = _home;
        _currentLegEnd = _destination;
        _lastPositionOverride = _destination;
        _legProgress = 1;
        break;

      case MissionStage.returning:
        {
          final p = ((t - _phaseStart) / _returnLegSeconds).clamp(0.0, 1.0);
          _legProgress = p;
          _currentLegStart = _destination;
          _currentLegEnd = _home;
          _currentAltitude = cruiseAltitude;
          _lastPositionOverride = GeoUtils.lerp(_destination, _home, p);
          _speed = DeliveryCalculator.effectiveSpeedKmh(
            DeliveryCalculator.baseSpeedKmh,
            _weightKg,
          );
          _battery -= DeliveryCalculator.batteryDrainPerKm *
              (_distanceKm * tickInterval.inMilliseconds / 1000 / 80);
        }
        break;

      case MissionStage.completed:
        _currentAltitude = 0;
        _speed = 0;
        _currentLegStart = _home;
        _currentLegEnd = _home;
        _lastPositionOverride = _home;
        _legProgress = 1;
        _completeMission();
        break;

      case MissionStage.failed:
        _currentAltitude = 0;
        _speed = 0;
        _failMission();
        break;

      case MissionStage.idle:
        _speed = 0;
        break;
    }

    // Battery clamp + safety floor: if battery hits zero mid-flight, return
    // home quickly.
    if (_battery <= 0 && !_completed) {
      _battery = 0;
      if (!_goingHome) {
        _goingHome = true;
        _stage = MissionStage.returning;
        _phaseStart = t;
      }
    }
    _battery = _battery.clamp(0, 100).toDouble();

    _emitFrame();
  }

  // Track the start time of the current phase so each segment can compute
  // its own local progress from [0, phaseDuration].
  double _phaseStart = 0;

  void _advanceStage(double t) {
    if (_goingHome) {
      // During the return phase.
      if (_stage == MissionStage.returning) {
        final p = (t - _phaseStart) / _returnLegSeconds;
        if (p >= 1.0) {
          _stage = MissionStage.landing;
          _phaseStart = t;
        }
      } else if (_stage == MissionStage.landing) {
        if (t - _phaseStart >= descentSeconds) {
          _stage = MissionStage.completed;
          _completed = true;
          _timer?.cancel();
          _timer = null;
        }
      }
      return;
    }

    // Outbound leg.
    if (_stage == MissionStage.preparing &&
        t - _phaseStart >= landingPauseSeconds) {
      _stage = MissionStage.takingOff;
      _phaseStart = t;
    } else if (_stage == MissionStage.takingOff &&
        t - _phaseStart >= ascentSeconds) {
      _stage = MissionStage.flying;
      _phaseStart = t;
    } else if (_stage == MissionStage.flying) {
      if ((t - _phaseStart) / _outboundLegSeconds >= 1.0) {
        _stage = MissionStage.landing;
        _phaseStart = t;
      }
    } else if (_stage == MissionStage.landing) {
      if (t - _phaseStart >= descentSeconds) {
        _stage = MissionStage.delivering;
        _phaseStart = t;
      }
    } else if (_stage == MissionStage.delivering) {
      if (t - _phaseStart >= deliveryPauseSeconds) {
        _stage = MissionStage.returning;
        _goingHome = true;
        _phaseStart = t;
      }
    }
  }

  void _completeMission() {
    _stage = MissionStage.completed;
    _completed = true;
    _timer?.cancel();
    _timer = null;
    _currentAltitude = 0;
    _speed = 0;
  }

  void _failMission() {
    _stage = MissionStage.failed;
    _completed = true;
    _timer?.cancel();
    _timer = null;
    _currentAltitude = 0;
    _speed = 0;
  }

  void _emitFrame({double? rotationOverride}) {
    final pos = _lastPositionOverride;
    final rotation = rotationOverride ??
        GeoUtils.angleRadians(_currentLegStart, _currentLegEnd);

    final frame = MissionFrame(
      dronePosition: pos,
      altitude: _currentAltitude,
      batteryPercent: _battery,
      speedKmh: _speed,
      rotationRadians: rotation,
      stage: _stage,
      status: _status,
      routeProgress: _legProgress,
      currentLegStart: _currentLegStart,
      currentLegEnd: _currentLegEnd,
      elapsed: _elapsed,
    );
    _lastFrame = frame;
    if (!_controller.isClosed) _controller.add(frame);
  }
}
