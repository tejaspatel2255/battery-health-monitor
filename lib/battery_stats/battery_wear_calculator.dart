import '../storage/battery_log_model.dart';

class BatteryWearEstimate {
  final double estimatedCycles;
  final double daysOfData;
  final double? estimatedHealthPercentage;
  final int totalLogsCount;

  const BatteryWearEstimate({
    required this.estimatedCycles,
    required this.daysOfData,
    this.estimatedHealthPercentage,
    required this.totalLogsCount,
  });
}

class BatteryWearCalculator {
  /// Calculates estimated charge cycles and wear from battery logs.
  /// Pure Dart logic with zero Flutter UI dependencies for unit testability.
  static BatteryWearEstimate calculate(List<BatteryLog> logs) {
    if (logs.isEmpty) {
      return const BatteryWearEstimate(
        estimatedCycles: 0.0,
        daysOfData: 0.0,
        estimatedHealthPercentage: null,
        totalLogsCount: 0,
      );
    }

    final firstTimestamp = logs.first.timestamp;
    final lastTimestamp = logs.last.timestamp;
    final durationDiff = lastTimestamp.difference(firstTimestamp);
    final daysOfData = (durationDiff.inMinutes / (60 * 24)).clamp(0.0, 3650.0);

    double totalChargeGainPercent = 0.0;

    for (int i = 1; i < logs.length; i++) {
      final prev = logs[i - 1];
      final curr = logs[i];

      // Sum positive deltas (charging gains)
      if (curr.batteryLevel > prev.batteryLevel) {
        totalChargeGainPercent += (curr.batteryLevel - prev.batteryLevel);
      }
    }

    // 1 Full Cycle = 100% cumulative charge delivered
    final estimatedCycles = totalChargeGainPercent / 100.0;

    // Standard battery degradation model estimate: ~20% capacity loss per 500 full cycles
    double? estimatedHealth;
    if (daysOfData >= 1.0 && logs.length >= 10) {
      final capacityLoss = (estimatedCycles / 500.0) * 20.0;
      estimatedHealth = (100.0 - capacityLoss).clamp(50.0, 100.0);
    }

    return BatteryWearEstimate(
      estimatedCycles: double.parse(estimatedCycles.toStringAsFixed(2)),
      daysOfData: double.parse(daysOfData.toStringAsFixed(1)),
      estimatedHealthPercentage: estimatedHealth != null
          ? double.parse(estimatedHealth.toStringAsFixed(1))
          : null,
      totalLogsCount: logs.length,
    );
  }
}
