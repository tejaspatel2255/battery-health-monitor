import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';
import '../storage/battery_database.dart';
import '../storage/battery_log_model.dart';
import 'battery_service.dart';
import 'notification_service.dart';

const String batteryPeriodicTask = 'com.batteryhealth.monitor.periodicTask';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      final batteryService = BatteryService();
      final info = await batteryService.fetchCurrentBatteryInfo();

      final log = BatteryLog(
        timestamp: DateTime.now(),
        batteryLevel: info.batteryLevel,
        batteryState: info.batteryStateLabel,
        temperature: info.temperature,
      );

      if (info.temperature != null) {
        await NotificationService.checkAndTriggerTemperatureWarning(info.temperature!);
      }

      await BatteryDatabase.instance.insertLog(log);
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  });
}

class BackgroundService {
  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
    );

    // Register 15-minute periodic task (Android enforces 15 min minimum)
    await Workmanager().registerPeriodicTask(
      'battery_logging_task',
      batteryPeriodicTask,
      frequency: const Duration(minutes: 15),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      constraints: Constraints(
        networkType: NetworkType.notRequired,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
    );
  }
}
