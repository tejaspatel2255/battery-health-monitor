import 'package:home_widget/home_widget.dart';
import '../battery_stats/battery_model.dart';
import '../battery_stats/battery_wear_calculator.dart';
import '../battery_stats/root_battery_service.dart';

class HomeWidgetService {
  static const String _smallProvider = 'SmallWidgetProvider';
  static const String _mediumProvider = 'MediumWidgetProvider';
  static const String _largeProvider = 'LargeWidgetProvider';
  static const String _adaptiveProvider = 'AdaptiveWidgetProvider';

  static Future<void> updateWidgets({
    required BatteryInfo batteryInfo,
    required RootBatteryInfo rootInfo,
    required BatteryWearEstimate wearEstimate,
  }) async {
    final isRootActive = rootInfo.isRootAvailable && rootInfo.isRootGranted;
    final badgeText = isRootActive
        ? 'Health: Measured (${rootInfo.measuredHealthPercentage ?? '?'}%)'
        : 'Health: Est (${wearEstimate.estimatedCycles} cyc)';

    final tempText = batteryInfo.temperature != null
        ? '${batteryInfo.temperature!.toStringAsFixed(1)} °C'
        : '-- °C';

    await HomeWidget.saveWidgetData<int>('battery_level', batteryInfo.batteryLevel);
    await HomeWidget.saveWidgetData<String>('battery_status', batteryInfo.batteryStateLabel);
    await HomeWidget.saveWidgetData<String>('battery_temp', tempText);
    await HomeWidget.saveWidgetData<String>('battery_badge', badgeText);
    await HomeWidget.saveWidgetData<String>('battery_cycles', '${wearEstimate.estimatedCycles}');

    // Broadcast trigger update to all 4 native Kotlin AppWidgetProviders
    await HomeWidget.updateWidget(name: _smallProvider);
    await HomeWidget.updateWidget(name: _mediumProvider);
    await HomeWidget.updateWidget(name: _largeProvider);
    await HomeWidget.updateWidget(name: _adaptiveProvider);
  }
}
