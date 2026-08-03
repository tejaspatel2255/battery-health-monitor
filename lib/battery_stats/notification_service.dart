import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:home_widget/home_widget.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;
  static bool _permissionGranted = false;
  static const String _permissionKey = 'notification_permission_granted';

  /// Returns cached permission state from persistent storage
  static Future<bool> isPermissionGrantedCached() async {
    try {
      final bool? granted = await HomeWidget.getWidgetData<bool>(_permissionKey);
      return granted ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Initializes plugin and channel.
  /// Set [requestPermission] to `true` ONLY from foreground UI isolates.
  static Future<void> initialize({bool requestPermission = true}) async {
    if (!_isInitialized) {
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: androidSettings);
      await _notificationsPlugin.initialize(settings: initSettings);

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

        if (requestPermission) {
          final granted = await androidImplementation.requestNotificationsPermission();
          _permissionGranted = granted ?? false;
          await HomeWidget.saveWidgetData<bool>(_permissionKey, _permissionGranted);
        } else {
          _permissionGranted = await isPermissionGrantedCached();
        }
      }
      _isInitialized = true;
    }
  }

  /// Evaluates temperature threshold and fires alert if permission is granted.
  /// Set [isBackground] to `true` when invoked from background isolates.
  static Future<void> checkAndTriggerTemperatureWarning(
    double tempCelsius, {
    bool isBackground = false,
  }) async {
    if (tempCelsius >= 40.0) {
      await initialize(requestPermission: !isBackground);

      final hasPermission = !isBackground
          ? _permissionGranted
          : await isPermissionGrantedCached();

      if (!hasPermission) {
        debugPrint('NotificationService: Skipping alert, permission unconfirmed/denied.');
        return;
      }

      const androidDetails = AndroidNotificationDetails(
        'battery_temp_alerts',
        'Battery Overheating Warnings',
        channelDescription: 'Alerts when battery temperature exceeds safety limits',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const notificationDetails = NotificationDetails(android: androidDetails);

      await _notificationsPlugin.show(
        id: 101,
        title: '⚠️ Battery Overheating Warning!',
        body: 'Battery temperature is high (${tempCelsius.toStringAsFixed(1)} °C). Pause heavy usage or unplug fast charger.',
        notificationDetails: notificationDetails,
      );
    }
  }
}
