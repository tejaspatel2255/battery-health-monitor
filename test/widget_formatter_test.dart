import 'package:battery_health_monitor/battery_stats/battery_model.dart';
import 'package:battery_health_monitor/battery_stats/root_battery_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Widget & Telemetry Data Formatter Tests', () {
    test('Test Case 5: Root measured health ratio percentage calculation', () {
      const rootInfo = RootBatteryInfo(
        isRootAvailable: true,
        isRootGranted: true,
        chargeFull: 4000,
        chargeFullDesign: 5000,
        cycleCount: 150,
      );

      // (4000 / 5000) * 100 = 80.0%
      expect(rootInfo.measuredHealthPercentage, equals(80.0));
    });

    test('Test Case 6: Handles null charge values in RootBatteryInfo gracefully', () {
      const rootInfo = RootBatteryInfo(
        isRootAvailable: true,
        isRootGranted: false,
        chargeFull: null,
        chargeFullDesign: 5000,
      );

      expect(rootInfo.measuredHealthPercentage, isNull);
    });

    test('Test Case 7: BatteryInfo state label formatting', () {
      const info = BatteryInfo(
        batteryLevel: 85,
        batteryState: BatteryState.charging,
        temperature: 31.4,
        voltage: 4.12,
      );

      expect(info.batteryStateLabel, equals('Charging'));
      expect(info.temperature, equals(31.4));
    });
  });
}
