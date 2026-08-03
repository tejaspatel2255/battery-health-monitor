import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';
import '../storage/battery_database.dart';
import '../storage/battery_log_model.dart';
import '../widgets_home/home_widget_service.dart';
import 'battery_service.dart';
import 'battery_wear_calculator.dart';
import 'notification_service.dart';
import 'root_battery_service.dart';

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

      // Check cached root status before invoking root shell from background isolate
      final rootBatteryService = RootBatteryService();
      final isRootGranted = await rootBatteryService.isRootGrantedCached();
      final rootInfo = isRootGranted
          ? await rootBatteryService.fetchRootBatteryInfo()
          : const RootBatteryInfo(
              isRootAvailable: false,
              isRootGranted: false,
            );

      final logs = await BatteryDatabase.instance.getAllLogs();
      final estimate = BatteryWearCalculator.calculate(logs);

      await HomeWidgetService.updateWidgets(
        batteryInfo: info,
        rootInfo: rootInfo,
        wearEstimate: estimate,
      );

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

  static Future<void> reRegisterPeriodicTask({
    ExistingPeriodicWorkPolicy policy = ExistingPeriodicWorkPolicy.replace,
  }) async {
    await Workmanager().registerPeriodicTask(
      'battery_logging_task',
      batteryPeriodicTask,
      frequency: const Duration(minutes: 15),
      existingWorkPolicy: policy,
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
