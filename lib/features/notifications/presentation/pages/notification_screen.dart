import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/notification_provider.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationProvider);
    final notifier = ref.read(notificationProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.done_all),
              tooltip: 'Mark all as read',
              onPressed: notifier.markAllRead,
            ),
          if (notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Clear all',
              onPressed: notifier.clearAll,
            ),
        ],
      ),
      body: notifications.isEmpty
          ? _buildEmptyState(
              context,
              onSimulate: () => notifier.addNotification(
                title: 'Test Notification',
                body: 'This is a local test message to check the list.',
              ),
            )
          : ListView.separated(
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = notifications[index];
                final primary = Theme.of(context).colorScheme.primary;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: item.isRead
                        ? _colorWithOpacity(Colors.grey, 0.2)
                        : _colorWithOpacity(primary, 0.2),
                    child: Icon(
                      Icons.notifications,
                      color: item.isRead ? Colors.grey : primary,
                    ),
                  ),
                  title: Text(
                    item.title,
                    style: TextStyle(
                      fontWeight:
                          item.isRead ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(item.body),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('MMM d, HH:mm').format(item.receivedAt),
                        style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                  tileColor:
                      item.isRead ? null : _colorWithOpacity(primary, 0.05),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context, {
    required VoidCallback onSimulate,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 64,
            color: Colors.grey[700],
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: onSimulate,
            child: const Text('Simulate Notification'),
          ),
        ],
      ),
    );
  }
}

Color _colorWithOpacity(Color color, double opacity) {
  final scaledAlpha = (color.a * opacity).clamp(0, 255).round();
  return color.withAlpha(scaledAlpha);
}
