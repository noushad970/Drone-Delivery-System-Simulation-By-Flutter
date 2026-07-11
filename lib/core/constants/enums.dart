/// Enumerations shared across the app.
library;

enum MissionStage {
  idle,
  preparing,
  takingOff,
  flying,
  landing,
  delivering,
  returning,
  completed,
  failed,
}

enum DroneStatus { idle, flying, returning, delivered, paused }

enum PackageType { food, medicine, parcel, documents }

enum CameraMode { defaultView, followDrone, topView }

enum NotificationType { info, success, warning, danger, error }

extension MissionStageX on MissionStage {
  String get label {
    switch (this) {
      case MissionStage.idle:
        return 'Idle';
      case MissionStage.preparing:
        return 'Preparing';
      case MissionStage.takingOff:
        return 'Taking Off';
      case MissionStage.flying:
        return 'Flying';
      case MissionStage.landing:
        return 'Landing';
      case MissionStage.delivering:
        return 'Delivering';
      case MissionStage.returning:
        return 'Returning';
      case MissionStage.completed:
        return 'Completed';
      case MissionStage.failed:
        return 'Failed';
    }
  }

  /// Progress 0..1 used for the stage tracker.
  double get progress {
    switch (this) {
      case MissionStage.idle:
        return 0.0;
      case MissionStage.preparing:
        return 0.1;
      case MissionStage.takingOff:
        return 0.2;
      case MissionStage.flying:
        return 0.45;
      case MissionStage.landing:
        return 0.6;
      case MissionStage.delivering:
        return 0.75;
      case MissionStage.returning:
        return 0.9;
      case MissionStage.completed:
        return 1.0;
      case MissionStage.failed:
        return 0.0;
      default:
        return 0.0;
    }
  }
}
