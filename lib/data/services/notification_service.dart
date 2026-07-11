import 'dart:async';
import 'package:uuid/uuid.dart';

import '../models/notification_model.dart';
import '../../core/constants/enums.dart';

/// In-memory notification queue with auto-dismiss.
///
/// The list is intentionally kept small so the UI stays uncluttered.
class NotificationService {
  NotificationService();

  final _uuid = const Uuid();
  final _controller = StreamController<List<AppNotification>>.broadcast();
  List<AppNotification> _items = [];

  Stream<List<AppNotification>> get stream => _controller.stream;
  List<AppNotification> get current => List.unmodifiable(_items);

  void push(
    String title,
    String message, {
    NotificationType type = NotificationType.info,
    Duration autoDismissAfter = const Duration(seconds: 4),
  }) {
    final n = AppNotification(
      id: _uuid.v4(),
      title: title,
      message: message,
      type: type,
      createdAt: DateTime.now(),
      autoDismissAfter: autoDismissAfter,
    );
    _items = [..._items, n];
    _controller.add(_items);

    // Auto-dismiss.
    Future.delayed(autoDismissAfter, () => dismiss(n.id));
  }

  void dismiss(String id) {
    final before = _items.length;
    _items = _items.where((e) => e.id != id).toList();
    if (_items.length != before) {
      _controller.add(_items);
    }
  }

  void clear() {
    _items = [];
    _controller.add(_items);
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}