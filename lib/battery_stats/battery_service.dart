import 'dart:async';
import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'battery_model.dart';

class BatteryService {
  static const MethodChannel _channel =
      MethodChannel('com.batteryhealth.monitor/battery_extra');

  final Battery _battery = Battery();

  Future<Map<String, dynamic>> _fetchExtraStats() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return {};
    }
    try {
      final Map<dynamic, dynamic>? result =
          await _channel.invokeMethod('getBatteryExtraStats');
      if (result != null) {
        return Map<String, dynamic>.from(result);
      }
    } on PlatformException catch (_) {
      // Platform channel error or non-Android fallback
    }
    return {};
  }

  Future<BatteryInfo> fetchCurrentBatteryInfo() async {
    final level = await _battery.batteryLevel;
    final state = await _battery.batteryState;
    final extras = await _fetchExtraStats();

    return BatteryInfo(
      batteryLevel: level,
      batteryState: state,
      temperature: (extras['temperature'] as num?)?.toDouble(),
      voltage: (extras['voltage'] as num?)?.toDouble(),
      technology: (extras['technology'] as String?) ?? 'Unknown',
      healthFlag: (extras['healthFlag'] as String?) ?? 'UNKNOWN',
      currentMa: (extras['currentMa'] as num?)?.toDouble(),
      wattage: (extras['wattage'] as num?)?.toDouble(),
    );
  }

  Stream<BatteryInfo> get batteryInfoStream async* {
    await for (final state in _battery.onBatteryStateChanged) {
      final level = await _battery.batteryLevel;
      final extras = await _fetchExtraStats();

      yield BatteryInfo(
        batteryLevel: level,
        batteryState: state,
        temperature: (extras['temperature'] as num?)?.toDouble(),
        voltage: (extras['voltage'] as num?)?.toDouble(),
        technology: (extras['technology'] as String?) ?? 'Unknown',
        healthFlag: (extras['healthFlag'] as String?) ?? 'UNKNOWN',
        currentMa: (extras['currentMa'] as num?)?.toDouble(),
        wattage: (extras['wattage'] as num?)?.toDouble(),
      );
    }
  }
}
