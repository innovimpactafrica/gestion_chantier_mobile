// ignore_for_file: file_names
import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    NotificationSettings settings =
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('🔐 Permission status: ${settings.authorizationStatus}');

    String? token = await _firebaseMessaging.getToken();
    print('🔥 FCM TOKEN: $token');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📩 Message foreground: ${message.notification?.title}');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📲 App opened from notification');
    });
  }

  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }
}


/*
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

@pragma('vm:entry-point')
class PushNotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    await Firebase.initializeApp();

    /// 🔐 Permission iOS
    if (Platform.isIOS) {
      await _firebaseMessaging.getAPNSToken();
    }

    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint('🔔 Permission status: ${settings.authorizationStatus}');

    await _setupLocalNotifications();

    final token = await _firebaseMessaging.getToken();
    debugPrint('🔥 FCM Token: $token');

    FirebaseMessaging.onBackgroundMessage(
      PushNotificationService.firebaseMessagingBackgroundHandler,
    );

    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_onNotificationOpened);
  }

  /// 🔧 Local notifications setup
  Future<void> _setupLocalNotifications() async {
    const androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(settings);

    /// Android channel uniquement
    if (Platform.isAndroid) {
      const channel = AndroidNotificationChannel(
        'default_channel',
        'Notifications',
        importance: Importance.max,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  /// 🌙 Background
  @pragma('vm:entry-point')
  static Future<void> firebaseMessagingBackgroundHandler(
      RemoteMessage message,
      ) async {
    await Firebase.initializeApp();
  }

  /// 📲 Foreground
  Future<void> _onForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final details = NotificationDetails(
      android: const AndroidNotificationDetails(
        'default_channel',
        'Notifications',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      notification.title,
      notification.body,
      details,
    );
  }

  /// 📂 Opened
  void _onNotificationOpened(RemoteMessage message) {
    debugPrint('📬 Notification opened: ${message.data}');
  }

  /// 📡 Topics
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }
}
*/