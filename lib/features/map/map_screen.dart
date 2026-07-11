import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/constants/enums.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/delivery_record.dart';
import '../../data/models/delivery_model.dart';
import '../../data/models/destination_model.dart';
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
import 'destination_selector.dart';

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
    final selectionMode = ref.watch(destinationSelectionModeProvider);
    final media = MediaQuery.of(context);
    final isWide = media.size.width >= 720;
    final isLandscape = media.orientation == Orientation.landscape;

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
                _MapHeader(
                  onBack: () => Navigator.of(context).pop(),
                  selectionMode: selectionMode,
                  onToggleSelectionMode: () {
                    ref.read(destinationSelectionModeProvider.notifier).state =
                        selectionMode == DestinationSelectionMode.map
                            ? DestinationSelectionMode.list
                            : DestinationSelectionMode.map;
                  },
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (ctx, constraints) {
                      if (isWide || isLandscape) {
                        return _wideLayout(
                          constraints: constraints,
                          destinations: destinations,
                          selectedDest: selectedDest,
                          order: order,
                          selectionMode: selectionMode,
                        );
                      }
                      return _narrowLayout(
                        constraints: constraints,
                        destinations: destinations,
                        selectedDest: selectedDest,
                        order: order,
                        selectionMode: selectionMode,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const NotificationOverlay(),
        ],
      ),
    );
  }

  /// Layout used on narrow phones — stacked vertically with a scrollable
  /// bottom panel so all controls remain reachable.
  Widget _narrowLayout({
    required BoxConstraints constraints,
    required List<DestinationModel> destinations,
    required DestinationModel? selectedDest,
    required DeliveryModel? order,
    required DestinationSelectionMode selectionMode,
  }) {
    final mapHeight = constraints.maxHeight * 0.45;
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
            child: SizedBox(
              height: mapHeight.clamp(220.0, 360.0),
              child: _MapArea(
                key: _mapKey,
                constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth,
                  maxHeight: mapHeight.clamp(220.0, 360.0),
                ),
                destinations: destinations,
                onTap: (d) => _onMapTap(
                    d,
                    BoxConstraints(
                      maxWidth: constraints.maxWidth,
                      maxHeight: mapHeight.clamp(220.0, 360.0),
                    )),
                selectionMode: selectionMode,
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.sm),
          _selectionPanel(
            selectedDest: selectedDest,
            order: order,
            selectionMode: selectionMode,
          ),
          const SizedBox(height: AppDimensions.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
            child: DroneInfoPanel(
              order: order,
              selectedDestination: order?.destination ?? selectedDest,
            ),
          ),
          const SizedBox(height: AppDimensions.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
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
    );
  }

  /// Layout used on tablets / landscape — map on the left, controls
  /// stacked on the right.
  Widget _wideLayout({
    required BoxConstraints constraints,
    required List<DestinationModel> destinations,
    required DestinationModel? selectedDest,
    required DeliveryModel? order,
    required DestinationSelectionMode selectionMode,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: _MapArea(
              key: _mapKey,
              constraints: BoxConstraints(
                maxWidth: constraints.maxWidth * 0.6,
                maxHeight: constraints.maxHeight,
              ),
              destinations: destinations,
              onTap: (d) => _onMapTap(
                  d,
                  BoxConstraints(
                    maxWidth: constraints.maxWidth * 0.6,
                    maxHeight: constraints.maxHeight,
                  )),
              selectionMode: selectionMode,
            ),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _selectionPanel(
                    selectedDest: selectedDest,
                    order: order,
                    selectionMode: selectionMode,
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  DroneInfoPanel(
                    order: order,
                    selectedDestination: order?.destination ?? selectedDest,
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  GlassCard(
                    padding: const EdgeInsets.all(AppDimensions.sm),
                    child: SimulationControls(
                      onStartDelivery: _startDelivery,
                      onShowSummary: _showSummary,
                      onNewOrder: _onNewOrder,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.md),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Shows the appropriate picker/info card depending on which selection
  /// mode is active and whether a destination is already chosen.
  Widget _selectionPanel({
    required DestinationModel? selectedDest,
    required DeliveryModel? order,
    required DestinationSelectionMode selectionMode,
  }) {
    if (order != null) return const SizedBox.shrink();

    if (selectedDest != null) {
      return const DestinationInfoCard();
    }

    if (selectionMode == DestinationSelectionMode.list) {
      return const DestinationSelector();
    }

    return const PackageSelector();
  }
}

class _MapHeader extends StatelessWidget {
  final VoidCallback onBack;
  final DestinationSelectionMode selectionMode;
  final VoidCallback onToggleSelectionMode;

  const _MapHeader({
    required this.onBack,
    required this.selectionMode,
    required this.onToggleSelectionMode,
  });

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
          const Flexible(
            child: Text(
              'Mission Control',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.sm),
          _SelectionModeToggle(
            mode: selectionMode,
            onTap: onToggleSelectionMode,
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

/// Compact segmented control letting the user switch between picking the
/// destination directly on the map or selecting it from a card list.
class _SelectionModeToggle extends StatelessWidget {
  final DestinationSelectionMode mode;
  final VoidCallback onTap;
  const _SelectionModeToggle({required this.mode, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isMap = mode == DestinationSelectionMode.map;
    return Tooltip(
      message: isMap ? 'Map pick' : 'List pick',
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated.withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withOpacity(0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isMap ? Icons.map_rounded : Icons.view_list_rounded,
                size: 14,
                color: AppColors.primary,
              ),
              const SizedBox(width: 4),
              Text(
                isMap ? 'Map' : 'List',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapArea extends ConsumerWidget {
  final BoxConstraints constraints;
  final List<DestinationModel> destinations;
  final void Function(TapDownDetails) onTap;
  final DestinationSelectionMode selectionMode;

  const _MapArea({
    super.key,
    required this.constraints,
    required this.destinations,
    required this.onTap,
    required this.selectionMode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mission = ref.watch(missionControllerProvider);
    final selectedDest = ref.watch(selectedDestinationProvider);
    final order = ref.watch(currentDeliveryProvider);
    final tapEnabled = selectionMode == DestinationSelectionMode.map;

    return LayoutBuilder(
      builder: (ctx, c) {
        // Use a fluid aspect ratio that adapts to the available space,
        // falling back to 16:11 when very wide.
        final aspect = c.maxWidth / c.maxHeight;
        final clamped = aspect.clamp(0.85, 2.4);
        return AspectRatio(
          aspectRatio: clamped,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: tapEnabled ? onTap : null,
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
                builder: (ctx, inner) {
                  final size = Size(inner.maxWidth, inner.maxHeight);
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
                                  top: frame.dronePosition.dy -
                                      18 -
                                      frame.altitude,
                                  child: Transform.rotate(
                                    angle: frame.rotationRadians,
                                    child: const DroneWidget(size: 36),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      if (!tapEnabled)
                        Positioned(
                          left: 12,
                          top: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.45),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'List pick active — choose a destination below',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
