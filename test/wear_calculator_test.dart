import 'package:battery_health_monitor/battery_stats/battery_wear_calculator.dart';
import 'package:battery_health_monitor/storage/battery_log_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BatteryWearCalculator Unit Tests', () {
    test('Test Case 1: Empty logs list returns zero values', () {
      final estimate = BatteryWearCalculator.calculate([]);
      expect(estimate.estimatedCycles, equals(0.0));
      expect(estimate.daysOfData, equals(0.0));
      expect(estimate.estimatedHealthPercentage, isNull);
      expect(estimate.totalLogsCount, equals(0));
    });

    test('Test Case 2: Positive charge gains sum into correct cycle count', () {
      final now = DateTime.now();
      final logs = [
        BatteryLog(timestamp: now, batteryLevel: 20, batteryState: 'Charging'),
        BatteryLog(
            timestamp: now.add(const Duration(hours: 1)),
            batteryLevel: 70,
            batteryState: 'Charging'), // +50%
        BatteryLog(
            timestamp: now.add(const Duration(hours: 2)),
            batteryLevel: 50,
            batteryState: 'Discharging'),
        BatteryLog(
            timestamp: now.add(const Duration(hours: 3)),
            batteryLevel: 100,
            batteryState: 'Charging'), // +50%
      ];

      final estimate = BatteryWearCalculator.calculate(logs);
      // 50% + 50% = 100% gain = 1.0 full cycle
      expect(estimate.estimatedCycles, equals(1.0));
      expect(estimate.totalLogsCount, equals(4));
    });

    test('Test Case 3: Discharging deltas are ignored in cycle count', () {
      final now = DateTime.now();
      final logs = [
        BatteryLog(
            timestamp: now, batteryLevel: 100, batteryState: 'Discharging'),
        BatteryLog(
            timestamp: now.add(const Duration(hours: 5)),
            batteryLevel: 20,
            batteryState: 'Discharging'),
      ];

      final estimate = BatteryWearCalculator.calculate(logs);
      expect(estimate.estimatedCycles, equals(0.0));
    });

    test('Test Case 4: Calculates correct fractional days of data', () {
      final start = DateTime(2026, 1, 1, 0, 0);
      final end = DateTime(2026, 1, 3, 12, 0); // 2.5 days

      final logs = [
        BatteryLog(
            timestamp: start, batteryLevel: 50, batteryState: 'Charging'),
        BatteryLog(timestamp: end, batteryLevel: 80, batteryState: 'Charging'),
      ];

      final estimate = BatteryWearCalculator.calculate(logs);
      expect(estimate.daysOfData, equals(2.5));
    });
  });
}
