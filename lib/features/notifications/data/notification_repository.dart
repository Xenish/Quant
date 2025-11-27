import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/models/app_notification.dart';

class NotificationRepository {
  static const String _storageKey = 'saved_notifications';

  Future<List<AppNotification>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_storageKey) ?? [];

    return rawList
        .map((entry) => AppNotification.fromJson(jsonDecode(entry)))
        .toList()
      ..sort((a, b) => b.receivedAt.compareTo(a.receivedAt));
  }

  Future<void> saveNotification(AppNotification notification) async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_storageKey) ?? [];

    rawList.add(jsonEncode(notification.toJson()));

    if (rawList.length > 50) {
      rawList.removeAt(0);
    }

    await prefs.setStringList(_storageKey, rawList);
  }

  Future<void> markAllAsRead() async {
    final prefs = await SharedPreferences.getInstance();
    final notifications = await getNotifications();

    final updatedList =
        notifications.map((n) => n.copyWith(isRead: true)).toList();
    final rawList = updatedList.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_storageKey, rawList);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
