import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';

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
  static const String _rootGrantedKey = 'is_root_granted';

  Future<bool> isRootAvailable() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return false;
    }
    try {
      final bool? available =
          await _channel.invokeMethod('checkRootAvailability');
      return available ?? false;
    } on PlatformException catch (_) {
      return false;
    }
  }

  Future<bool> isRootGrantedCached() async {
    try {
      final bool? granted =
          await HomeWidget.getWidgetData<bool>(_rootGrantedKey);
      return granted ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<RootBatteryInfo> fetchRootBatteryInfo() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return const RootBatteryInfo(
        isRootAvailable: false,
        isRootGranted: false,
      );
    }

    try {
      final Map<dynamic, dynamic>? result =
          await _channel.invokeMethod('getRootBatteryStats');
      if (result != null) {
        final map = Map<String, dynamic>.from(result);
        final isAvailable = (map['isRootAvailable'] as bool?) ?? false;
        final isGranted = (map['isRootGranted'] as bool?) ?? false;

        await HomeWidget.saveWidgetData<bool>(_rootGrantedKey, isGranted);

        return RootBatteryInfo(
          isRootAvailable: isAvailable,
          isRootGranted: isGranted,
          chargeFull: (map['chargeFull'] as num?)?.toInt(),
          chargeFullDesign: (map['chargeFullDesign'] as num?)?.toInt(),
          cycleCount: (map['cycleCount'] as num?)?.toInt(),
        );
      }
    } on PlatformException catch (_) {
      // Platform error
    }

    await HomeWidget.saveWidgetData<bool>(_rootGrantedKey, false);

    return const RootBatteryInfo(
      isRootAvailable: false,
      isRootGranted: false,
    );
  }
}
