import '../../core/constants/enums.dart';

/// Live state of the simulated drone.
class DroneModel {
  final double batteryPercent;
  final double speedKmh;
  final double altitudeMeters;
  final double rotationRadians; // 0 means facing right
  final MissionStage stage;
  final DroneStatus status;
  final String missionName;

  const DroneModel({
    this.batteryPercent = 100,
    this.speedKmh = 0,
    this.altitudeMeters = 0,
    this.rotationRadians = 0,
    this.stage = MissionStage.idle,
    this.status = DroneStatus.idle,
    this.missionName = 'Standby',
  });

  DroneModel copyWith({
    double? batteryPercent,
    double? speedKmh,
    double? altitudeMeters,
    double? rotationRadians,
    MissionStage? stage,
    DroneStatus? status,
    String? missionName,
  }) {
    return DroneModel(
      batteryPercent: batteryPercent ?? this.batteryPercent,
      speedKmh: speedKmh ?? this.speedKmh,
      altitudeMeters: altitudeMeters ?? this.altitudeMeters,
      rotationRadians: rotationRadians ?? this.rotationRadians,
      stage: stage ?? this.stage,
      status: status ?? this.status,
      missionName: missionName ?? this.missionName,
    );
  }

  factory DroneModel.fromJson(Map<String, dynamic> json) => DroneModel(
        batteryPercent: (json['battery'] as num?)?.toDouble() ?? 100,
        speedKmh: (json['speed'] as num?)?.toDouble() ?? 0,
        altitudeMeters: (json['altitude'] as num?)?.toDouble() ?? 0,
        stage: MissionStage.values.firstWhere(
          (e) => e.name == json['stage'],
          orElse: () => MissionStage.idle,
        ),
        status: DroneStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => DroneStatus.idle,
        ),
      );

  Map<String, dynamic> toJson() => {
        'battery': batteryPercent,
        'speed': speedKmh,
        'altitude': altitudeMeters,
        'stage': stage.name,
        'status': status.name,
      };
}
