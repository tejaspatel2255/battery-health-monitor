class BatteryLog {
  final int? id;
  final DateTime timestamp;
  final int batteryLevel;
  final String batteryState;
  final double? temperature;

  const BatteryLog({
    this.id,
    required this.timestamp,
    required this.batteryLevel,
    required this.batteryState,
    this.temperature,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'batteryLevel': batteryLevel,
      'batteryState': batteryState,
      'temperature': temperature,
    };
  }

  factory BatteryLog.fromMap(Map<String, dynamic> map) {
    return BatteryLog(
      id: map['id'] as int?,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      batteryLevel: map['batteryLevel'] as int,
      batteryState: map['batteryState'] as String,
      temperature: (map['temperature'] as num?)?.toDouble(),
    );
  }
}
