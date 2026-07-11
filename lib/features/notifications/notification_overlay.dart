import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/constants/enums.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/notification_model.dart';
import '../../data/providers/providers.dart';

class NotificationOverlay extends ConsumerStatefulWidget {
  const NotificationOverlay({super.key});

  @override
  ConsumerState<NotificationOverlay> createState() =>
      _NotificationOverlayState();
}

class _NotificationOverlayState extends ConsumerState<NotificationOverlay>
    with SingleTickerProviderStateMixin {
  final List<AppNotification> _active = [];
  final Map<String, AnimationController> _controllers = {};

  @override
  void initState() {
    super.initState();
    ref.listenManual<AsyncValue<List<AppNotification>>>(
      notificationsProvider,
      (prev, next) {
        next.whenData((list) {
          for (final n in list) {
            if (_active.any((a) => a.id == n.id)) continue;
            _show(n);
          }
        });
      },
    );
  }

  void _show(AppNotification n) {
    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _controllers[n.id] = controller;
    setState(() => _active.add(n));

    Future.delayed(Duration(milliseconds: 400), () {
      if (!mounted) return;
      controller.forward();
    });

    final totalMs = n.autoDismissAfter.inMilliseconds;
    Future.delayed(Duration(milliseconds: totalMs + 400), () {
      if (!mounted) return;
      _dismiss(n, controller);
    });
  }

  void _dismiss(AppNotification n, AnimationController controller) {
    controller.reverse().then((_) {
      if (!mounted) return;
      setState(() => _active.removeWhere((a) => a.id == n.id));
      _controllers.remove(n.id)?.dispose();
      ref.read(notificationServiceProvider).dismiss(n.id);
    });
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Color _colorFor(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return AppColors.success;
      case NotificationType.warning:
        return AppColors.warning;
      case NotificationType.error:
      case NotificationType.danger:
        return AppColors.danger;
      case NotificationType.info:
        return AppColors.primary;
    }
  }

  IconData _iconFor(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return Icons.check_circle_rounded;
      case NotificationType.warning:
        return Icons.warning_amber_rounded;
      case NotificationType.error:
      case NotificationType.danger:
        return Icons.error_rounded;
      case NotificationType.info:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: _active.isEmpty,
      child: Stack(
        children: [
          for (int i = 0; i < _active.length; i++)
            Positioned(
              top: AppDimensions.md + (i * 76),
              right: AppDimensions.md,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _NotificationBubble(
                  key: ValueKey(_active[i].id),
                  notification: _active[i],
                  color: _colorFor(_active[i].type),
                  icon: _iconFor(_active[i].type),
                  onDismiss: () {
                    final c = _controllers[_active[i].id];
                    if (c != null) _dismiss(_active[i], c);
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NotificationBubble extends StatelessWidget {
  final AppNotification notification;
  final Color color;
  final IconData icon;
  final VoidCallback onDismiss;

  const _NotificationBubble({
    super.key,
    required this.notification,
    required this.color,
    required this.icon,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320, minWidth: 260),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.surfaceAlt.withOpacity(0.95),
              AppColors.surface.withOpacity(0.95),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.55)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.25),
              blurRadius: 18,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    notification.message,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onDismiss,
              child: const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
