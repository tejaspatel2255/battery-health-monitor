import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;
  static bool _permissionGranted = true;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _notificationsPlugin.initialize(
      settings: initSettings,
    );

    const androidChannel = AndroidNotificationChannel(
      'battery_temp_alerts',
      'Battery Overheating Warnings',
      description: 'Alerts when battery temperature exceeds safety limits',
      importance: Importance.high,
    );

    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.createNotificationChannel(androidChannel);
      final granted = await androidImplementation.requestNotificationsPermission();
      _permissionGranted = granted ?? false;
      if (!_permissionGranted) {
        debugPrint('NotificationService: User denied notification permissions.');
      }
    }

    _isInitialized = true;
  }

  static Future<void> checkAndTriggerTemperatureWarning(double tempCelsius) async {
    if (tempCelsius >= 40.0) {
      await initialize();

      if (!_permissionGranted) {
        debugPrint('NotificationService: Skipping alert, notification permission denied.');
        return;
      }

      const androidDetails = AndroidNotificationDetails(
        'battery_temp_alerts',
        'Battery Overheating Warnings',
        channelDescription:
            'Alerts when battery temperature exceeds safety limits',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const notificationDetails = NotificationDetails(android: androidDetails);

      await _notificationsPlugin.show(
        id: 101,
        title: '⚠️ Battery Overheating Warning!',
        body:
            'Battery temperature is high (${tempCelsius.toStringAsFixed(1)} °C). Pause heavy usage or unplug fast charger.',
        notificationDetails: notificationDetails,
      );
    }
  }
}
