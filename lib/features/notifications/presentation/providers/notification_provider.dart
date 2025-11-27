import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/notification_repository.dart';
import '../../domain/models/app_notification.dart';

final notificationRepoProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository();
});

class NotificationNotifier extends StateNotifier<List<AppNotification>> {
  NotificationNotifier(this._repo) : super(const []) {
    loadNotifications();
  }

  final NotificationRepository _repo;
  final _uuid = const Uuid();

  Future<void> loadNotifications() async {
    final list = await _repo.getNotifications();
    state = list;
  }

  Future<void> addNotification(
      {required String title, required String body}) async {
    final newNotification = AppNotification(
      id: _uuid.v4(),
      title: title,
      body: body,
      receivedAt: DateTime.now(),
    );

    state = [newNotification, ...state];
    await _repo.saveNotification(newNotification);
  }

  Future<void> markAllRead() async {
    state = state.map((n) => n.copyWith(isRead: true)).toList();
    await _repo.markAllAsRead();
  }

  Future<void> clearAll() async {
    state = const [];
    await _repo.clearAll();
  }

  int get unreadCount => state.where((n) => !n.isRead).length;
}

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, List<AppNotification>>((ref) {
  return NotificationNotifier(ref.watch(notificationRepoProvider));
});
