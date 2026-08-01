import 'package:battery_health_monitor/battery_stats/notification_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotificationService Tests', () {
    test('Test Case 8: Notification threshold check logic', () async {
      // Below threshold (38.5 °C) - should not trigger
      await NotificationService.checkAndTriggerTemperatureWarning(38.5);

      // At/above threshold (41.2 °C)
      await NotificationService.checkAndTriggerTemperatureWarning(41.2);
    });
  });
}
