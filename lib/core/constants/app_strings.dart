/// All user-facing strings live here so localization would be a single edit later.
class AppStrings {
  AppStrings._();

  static const String appName = 'AeroLogix';
  static const String appTagline = 'Drone Delivery Simulation';

  // Home
  static const String startSimulation = 'Start Simulation';
  static const String statistics = 'Statistics';
  static const String exit = 'Exit';

  // Mission stages
  static const String stagePreparing = 'Preparing';
  static const String stageTakingOff = 'Taking Off';
  static const String stageFlying = 'Flying';
  static const String stageLanding = 'Landing';
  static const String stageDelivering = 'Delivering';
  static const String stageReturning = 'Returning';
  static const String stageCompleted = 'Completed';
  static const String stageIdle = 'Idle';

  // Controls
  static const String start = 'Start';
  static const String pause = 'Pause';
  static const String resume = 'Resume';
  static const String reset = 'Reset';
  static const String newOrder = 'New Order';
  static const String accept = 'Accept';
  static const String skip = 'Skip';
  static const String regenerate = 'Regenerate';

  // Packages
  static const String pkgFood = 'Food';
  static const String pkgMedicine = 'Medicine';
  static const String pkgParcel = 'Parcel';
  static const String pkgDocuments = 'Documents';

  // Notifications
  static const String notifNewOrder = 'New Order Received';
  static const String notifMissionStarted = 'Mission Started';
  static const String notifTakingOff = 'Drone Taking Off';
  static const String notifArrived = 'Drone Arrived at Destination';
  static const String notifDelivered = 'Package Delivered';
  static const String notifReturning = 'Returning Home';
  static const String notifCompleted = 'Mission Completed';
  static const String notifBatteryLow = 'Battery Low — Returning Home';

  // Summary
  static const String deliverySummary = 'Delivery Summary';
  static const String newDelivery = 'New Delivery';
  static const String close = 'Close';
}