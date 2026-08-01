import 'package:flutter/services.dart';

class RootBatteryInfo {
  final bool isRootAvailable;
  final bool isRootGranted;
  final int? chargeFull; // mAh or uAh
  final int? chargeFullDesign; // mAh or uAh
  final int? cycleCount;

  const RootBatteryInfo({
    required this.isRootAvailable,
    required this.isRootGranted,
    this.chargeFull,
    this.chargeFullDesign,
    this.cycleCount,
  });

  double? get measuredHealthPercentage {
    if (chargeFull != null &&
        chargeFullDesign != null &&
        chargeFullDesign! > 0) {
      final ratio = (chargeFull! / chargeFullDesign!) * 100.0;
      return double.parse(ratio.clamp(1.0, 150.0).toStringAsFixed(1));
    }
    return null;
  }
}

class RootBatteryService {
  static const MethodChannel _channel =
      MethodChannel('com.batteryhealth.monitor/root_battery');

  Future<bool> isRootAvailable() async {
    try {
      final bool? available =
          await _channel.invokeMethod('checkRootAvailability');
      return available ?? false;
    } on PlatformException catch (_) {
      return false;
    }
  }

  Future<RootBatteryInfo> fetchRootBatteryInfo() async {
    try {
      final Map<dynamic, dynamic>? result =
          await _channel.invokeMethod('getRootBatteryStats');
      if (result != null) {
        final map = Map<String, dynamic>.from(result);
        return RootBatteryInfo(
          isRootAvailable: (map['isRootAvailable'] as bool?) ?? false,
          isRootGranted: (map['isRootGranted'] as bool?) ?? false,
          chargeFull: (map['chargeFull'] as num?)?.toInt(),
          chargeFullDesign: (map['chargeFullDesign'] as num?)?.toInt(),
          cycleCount: (map['cycleCount'] as num?)?.toInt(),
        );
      }
    } on PlatformException catch (_) {
      // Platform error
    }

    return const RootBatteryInfo(
      isRootAvailable: false,
      isRootGranted: false,
    );
  }
}
