import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/constants/enums.dart';
import '../../core/theme/app_colors.dart';
import '../../data/providers/providers.dart';

enum _CtrlAction { start, pause, resume, reset, newOrder }

class SimulationControls extends ConsumerWidget {
  final VoidCallback onStartDelivery;
  final VoidCallback onShowSummary;
  final VoidCallback onNewOrder;

  const SimulationControls({
    super.key,
    required this.onStartDelivery,
    required this.onShowSummary,
    required this.onNewOrder,
  });

  void _run(BuildContext context, WidgetRef ref, _CtrlAction action) {
    final mission = ref.read(missionControllerProvider);
    switch (action) {
      case _CtrlAction.start:
        onStartDelivery();
        break;
      case _CtrlAction.pause:
        mission.pause();
        break;
      case _CtrlAction.resume:
        mission.resume();
        break;
      case _CtrlAction.reset:
        mission.stop(reset: true);
        ref.read(currentDeliveryProvider.notifier).state = null;
        break;
      case _CtrlAction.newOrder:
        mission.stop(reset: true);
        ref.read(currentDeliveryProvider.notifier).state = null;
        onNewOrder();
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final frame = ref.watch(missionControllerProvider).value;
    final isRunning = frame != null && frame.status != DroneStatus.idle;
    final isPaused = frame?.status == DroneStatus.paused;
    final isCompleted = frame?.stage == MissionStage.completed;

    return Wrap(
      spacing: AppDimensions.sm,
      runSpacing: AppDimensions.sm,
      alignment: WrapAlignment.center,
      children: [
        if (!isRunning || isCompleted) ...[
          _ControlButton(
            icon: Icons.play_arrow_rounded,
            label: 'Start',
            color: AppColors.primary,
            onPressed: () => _run(context, ref, _CtrlAction.start),
          ),
        ] else if (!isPaused) ...[
          _ControlButton(
            icon: Icons.pause_rounded,
            label: 'Pause',
            color: AppColors.warning,
            onPressed: () => _run(context, ref, _CtrlAction.pause),
          ),
        ] else ...[
          _ControlButton(
            icon: Icons.play_arrow_rounded,
            label: 'Resume',
            color: AppColors.success,
            onPressed: () => _run(context, ref, _CtrlAction.resume),
          ),
        ],
        _ControlButton(
          icon: Icons.restart_alt_rounded,
          label: 'Reset',
          color: AppColors.textSecondary,
          onPressed: () => _run(context, ref, _CtrlAction.reset),
        ),
        _ControlButton(
          icon: Icons.refresh_rounded,
          label: 'New Order',
          color: AppColors.accent,
          onPressed: () => _run(context, ref, _CtrlAction.newOrder),
        ),
        if (isCompleted)
          _ControlButton(
            icon: Icons.summarize_rounded,
            label: 'Summary',
            color: AppColors.success,
            onPressed: onShowSummary,
          ),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}