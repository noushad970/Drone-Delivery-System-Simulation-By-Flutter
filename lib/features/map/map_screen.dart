import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/constants/enums.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/delivery_record.dart';
import '../../data/models/delivery_model.dart';
import '../../data/models/destination_model.dart';
import '../../data/models/package_model.dart';
import '../../data/providers/providers.dart';
import '../../simulation/city_map_data.dart';
import '../../simulation/delivery_calculator.dart';
import '../../widgets/drone_widget.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/map_painter.dart';
import '../controls/simulation_controls.dart';
import '../drone/drone_info_panel.dart';
import '../notifications/notification_overlay.dart';
import '../package/package_selector.dart';
import '../summary/delivery_summary_dialog.dart';
import 'destination_info_card.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final GlobalKey _mapKey = GlobalKey();
  bool _summaryShown = false;
  late final DeliveryModel order;

  void _onMapTap(TapDownDetails details, BoxConstraints constraints) {
    final size = Size(constraints.maxWidth, constraints.maxHeight);
    ref.read(mapSizeProvider.notifier).state = size;
    final tap = details.localPosition;
    final destinations = ref.read(destinationsProvider);
    DestinationModel? nearest;
    double best = double.infinity;
    for (final d in destinations) {
      final p = d.toScreen(size);
      final dist = (p - tap).distance;
      if (dist < best && dist < 30) {
        best = dist;
        nearest = d;
      }
    }
    if (nearest != null) {
      ref.read(selectedDestinationProvider.notifier).state = nearest;
    } else {
      ref.read(selectedDestinationProvider.notifier).state = null;
    }
  }

  void _startDelivery() {
    final dest = ref.read(selectedDestinationProvider);
    final pkg = ref.read(selectedPackageProvider);
    if (dest == null || pkg == null) {
      ref.read(notificationServiceProvider).push(
            'Select package & destination',
            'Tap a destination on the map and choose a package.',
            type: NotificationType.warning,
          );
      return;
    }
    final generator = ref.read(orderGeneratorProvider);
    try {
      order = generator.nextOrder(
        preferredPackage: pkg,
        destinationOverride: dest,
      );
    } catch (_) {
      order = generator.nextOrder();
    }
    ref.read(currentDeliveryProvider.notifier).state = order;
    ref.read(selectedDestinationProvider.notifier).state = null;
    ref.read(selectedPackageProvider.notifier).state = null;
    _summaryShown = false;
    _beginMission(order);
    ref.read(notificationServiceProvider).push(
          'Mission Launched',
          'Delivering ${order.package.name} to ${order.destination.name}',
          type: NotificationType.success,
        );
  }

  void _beginMission(DeliveryModel order) {
    final mapSize = ref.read(mapSizeProvider);
    if (mapSize == Size.zero) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _beginMission(order);
      });
      return;
    }
    final home = CityMapData.homeBaseOn(mapSize);
    final dest = order.destination.toScreen(mapSize);
    final drain = DeliveryCalculator.batteryDrainPercent(
      distanceKm: order.distanceKm,
      weightKg: order.weightKg,
    );
    final initialBattery = (100 - drain).clamp(20, 100).toDouble();
    ref.read(missionControllerProvider).start(
          canvasSize: mapSize,
          home: home,
          destination: dest,
          distanceKm: order.distanceKm,
          weightKg: order.weightKg,
          initialBattery: initialBattery,
        );
  }

  void _onNewOrder() {
    final generator = ref.read(orderGeneratorProvider);
    final pkg = ref.read(selectedPackageProvider);
    ref.read(currentDeliveryProvider.notifier).state =
        generator.nextOrder(preferredPackage: pkg);
    final order = ref.read(currentDeliveryProvider);
    if (order != null) {
      _summaryShown = false;
      _beginMission(order);
    }
  }

  void _onStageCompleted() {
    final order = ref.read(currentDeliveryProvider);
    if (order == null || _summaryShown) return;
    _summaryShown = true;
    final record = DeliveryRecord(
      id: '${order.id}-${DateTime.now().millisecondsSinceEpoch}',
      order: order,
      completedAt: DateTime.now(),
      actualDurationSeconds: DeliveryCalculator.estimateTime(
        distanceKm: order.distanceKm,
        weightKg: order.weightKg,
      ),
      batteryUsedPercent: DeliveryCalculator.batteryDrainPercent(
        distanceKm: order.distanceKm,
        weightKg: order.weightKg,
      ),
      totalCost: order.estimatedCost,
      finalStage: MissionStage.completed,
    );
    ref.read(statisticsProvider.notifier).addRecord(record);
    ref.read(notificationServiceProvider).push(
          'Delivery Complete',
          '${order.package.name} delivered to ${order.destination.name}',
          type: NotificationType.success,
        );
    Future.microtask(() {
      if (mounted) showDeliverySummary(context, ref, record: record);
    });
  }

  void _showSummary() {
    final order = ref.read(currentDeliveryProvider);
    if (order == null) return;
    final record = DeliveryRecord(
      id: '${order.id}-summary',
      order: order,
      completedAt: DateTime.now(),
      actualDurationSeconds: DeliveryCalculator.estimateTime(
        distanceKm: order.distanceKm,
        weightKg: order.weightKg,
      ),
      batteryUsedPercent: DeliveryCalculator.batteryDrainPercent(
        distanceKm: order.distanceKm,
        weightKg: order.weightKg,
      ),
      totalCost: order.estimatedCost,
      finalStage: MissionStage.completed,
    );
    showDeliverySummary(context, ref, record: record);
  }

  @override
  Widget build(BuildContext context) {
    final destinations = ref.watch(destinationsProvider);
    final selectedDest = ref.watch(selectedDestinationProvider);
    final order = ref.watch(currentDeliveryProvider);

    ref.listen(missionControllerProvider, (prev, next) {
      if (next.value?.stage == MissionStage.completed) {
        _onStageCompleted();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _MapHeader(onBack: () => Navigator.of(context).pop()),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.md),
                    child: LayoutBuilder(
                      builder: (ctx, constraints) {
                        return _MapArea(
                          key: _mapKey,
                          constraints: constraints,
                          destinations: destinations,
                          onTap: (d) => _onMapTap(d, constraints),
                        );
                      },
                    ),
                  ),
                ),
                if (selectedDest != null) const DestinationInfoCard(),
                if (selectedDest == null && order == null)
                  const PackageSelector(),
                const SizedBox(height: AppDimensions.sm),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppDimensions.md),
                  child: DroneInfoPanel(
                    order: order,
                    selectedDestination: order?.destination ?? selectedDest,
                  ),
                ),
                const SizedBox(height: AppDimensions.sm),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppDimensions.md),
                  child: GlassCard(
                    padding: const EdgeInsets.all(AppDimensions.sm),
                    child: SimulationControls(
                      onStartDelivery: _startDelivery,
                      onShowSummary: _showSummary,
                      onNewOrder: _onNewOrder,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.md),
              ],
            ),
          ),
          const NotificationOverlay(),
        ],
      ),
    );
  }
}

class _MapHeader extends StatelessWidget {
  final VoidCallback onBack;
  const _MapHeader({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.sm,
        AppDimensions.sm,
        AppDimensions.md,
        AppDimensions.xs,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            'Mission Control',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withOpacity(0.5)),
            ),
            child: const Text(
              'LIVE',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapArea extends ConsumerWidget {
  final BoxConstraints constraints;
  final List<DestinationModel> destinations;
  final void Function(TapDownDetails) onTap;

  const _MapArea({
    super.key,
    required this.constraints,
    required this.destinations,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mission = ref.watch(missionControllerProvider);
    final selectedDest = ref.watch(selectedDestinationProvider);
    final order = ref.watch(currentDeliveryProvider);

    return AspectRatio(
      aspectRatio: 16 / 11,
      child: GestureDetector(
        onTapDown: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.25),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.12),
                blurRadius: 22,
                spreadRadius: 1,
              ),
            ],
          ),
          clipBehavior: Clip.hardEdge,
          child: LayoutBuilder(
            builder: (ctx, c) {
              final size = Size(c.maxWidth, c.maxHeight);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ref.read(mapSizeProvider.notifier).state = size;
              });

              return Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: MapPainter(
                        size: size,
                        destinations: destinations,
                        homeBase: CityMapData.homeBaseOn(size),
                        selected: selectedDest,
                        dronePosition: mission.value?.dronePosition,
                        route: mission.value == null || order == null
                            ? const []
                            : <Offset>[
                                CityMapData.homeBaseOn(size),
                                order.destination.toScreen(size),
                              ],
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: ValueListenableBuilder<int>(
                      valueListenable: mission.ticks,
                      builder: (ctx, _, __) {
                        final frame = mission.value;
                        if (frame == null) return const SizedBox.shrink();
                        return Stack(
                          children: [
                            Positioned(
                              left: frame.dronePosition.dx - 18,
                              top: frame.dronePosition.dy - 18 - frame.altitude,
                              child: Transform.rotate(
                                angle: frame.rotationRadians,
                                child: DroneWidget(size: 36),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
