import 'dart:developer' as developer;
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dashboard/presentation/providers/dashboard_provider.dart';
import '../presentation/providers/notification_provider.dart';

class FCMService {
  FCMService(this._ref);

  final Ref _ref;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      developer.log('FCM: Skipping initialization on unsupported platform');
      return;
    }

    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      developer.log('FCM: Permission declined');
      return;
    }

    developer.log('FCM: Permission granted');

    final token = await _firebaseMessaging.getToken();
    if (token != null) {
      await _registerTokenWithBackend(token);
    }

    _firebaseMessaging.onTokenRefresh.listen((token) {
      _registerTokenWithBackend(token);
    });

    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) {
        return;
      }
      developer
          .log('FCM: Message received in foreground: ${notification.title}');
      _ref.read(notificationProvider.notifier).addNotification(
            title: notification.title ?? 'New Alert',
            body: notification.body ?? '',
          );
    });
  }

  Future<void> _registerTokenWithBackend(String token) async {
    developer.log('FCM Token: $token');
    try {
      final dioClient = _ref.read(dioClientProvider);
      await dioClient.post(
        '/api/notifications/register_device',
        data: {
          'device_token': token,
          'platform': Platform.isAndroid ? 'android' : 'ios',
        },
      );
      developer.log('FCM: Token registered with backend.');
    } catch (e) {
      developer.log('FCM: Failed to register token: $e');
    }
  }
}

final fcmServiceProvider = Provider<FCMService>((ref) => FCMService(ref));
