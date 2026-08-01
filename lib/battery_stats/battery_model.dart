import 'package:battery_plus/battery_plus.dart';

class BatteryInfo {
  final int batteryLevel;
  final BatteryState batteryState;
  final double? temperature; // In Celsius
  final double? voltage; // In Volts
  final String technology;
  final String healthFlag; // Coarse Android health flag

  const BatteryInfo({
    required this.batteryLevel,
    required this.batteryState,
    this.temperature,
    this.voltage,
    this.technology = 'Unknown',
    this.healthFlag = 'UNKNOWN',
  });

  String get batteryStateLabel {
    switch (batteryState) {
      case BatteryState.charging:
        return 'Charging';
      case BatteryState.discharging:
        return 'Discharging';
      case BatteryState.full:
        return 'Full';
      case BatteryState.connectedNotCharging:
        return 'Connected (Not Charging)';
      case BatteryState.unknown:
        return 'Unknown';
    }
  }
}
