import '../../core/constants/enums.dart';

/// A transient UI notification shown in the top-right.
class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime createdAt;
  final Duration autoDismissAfter;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.autoDismissAfter = const Duration(seconds: 4),
  });
}