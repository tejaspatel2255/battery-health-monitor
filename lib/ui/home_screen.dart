import 'dart:async';
import 'package:flutter/material.dart';
import '../battery_stats/battery_model.dart';
import '../battery_stats/battery_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final BatteryService _batteryService = BatteryService();
  BatteryInfo? _batteryInfo;
  StreamSubscription<BatteryInfo>? _subscription;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _loadInitialInfo();
    // Listen to state changes stream from battery_plus
    _subscription = _batteryService.batteryInfoStream.listen((info) {
      if (mounted) {
        setState(() {
          _batteryInfo = info;
        });
      }
    });

    // Periodic poll every 5 seconds to keep temperature/voltage telemetry fresh
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _loadInitialInfo();
    });
  }

  Future<void> _loadInitialInfo() async {
    final info = await _batteryService.fetchCurrentBatteryInfo();
    if (mounted) {
      setState(() {
        _batteryInfo = info;
      });
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _pollingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final info = _batteryInfo;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Battery Health Monitor'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadInitialInfo,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildMainStatusCard(info),
                const SizedBox(height: 16),
                _buildMetricsGrid(info),
                const SizedBox(height: 16),
                _buildHealthFlagCard(info),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainStatusCard(BatteryInfo? info) {
    final level = info?.batteryLevel ?? 0;
    final stateLabel = info?.batteryStateLabel ?? 'Loading...';

    Color levelColor = Colors.tealAccent;
    if (level <= 20) {
      levelColor = Colors.redAccent;
    } else if (level <= 50) {
      levelColor = Colors.orangeAccent;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: level / 100.0,
                    strokeWidth: 10,
                    color: levelColor,
                    backgroundColor: Colors.white10,
                  ),
                ),
                Text(
                  '$level%',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: levelColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              stateLabel,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsGrid(BatteryInfo? info) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _buildMetricTile(
          icon: Icons.thermostat_rounded,
          label: 'Temperature',
          value: info?.temperature != null
              ? '${info!.temperature!.toStringAsFixed(1)} °C'
              : 'N/A',
          color: Colors.deepOrangeAccent,
        ),
        _buildMetricTile(
          icon: Icons.electric_bolt_rounded,
          label: 'Voltage',
          value: info?.voltage != null
              ? '${info!.voltage!.toStringAsFixed(2)} V'
              : 'N/A',
          color: Colors.amberAccent,
        ),
        _buildMetricTile(
          icon: Icons.memory_rounded,
          label: 'Technology',
          value: info?.technology ?? 'N/A',
          color: Colors.lightBlueAccent,
        ),
        _buildMetricTile(
          icon: Icons.sync_rounded,
          label: 'Live Stream',
          value: 'Active',
          color: Colors.greenAccent,
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthFlagCard(BatteryInfo? info) {
    final healthFlag = info?.healthFlag ?? 'UNKNOWN';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.health_and_safety_rounded,
                    color: Colors.tealAccent),
                const SizedBox(width: 8),
                const Text(
                  'System health flag',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.teal.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.tealAccent),
                  ),
                  child: Text(
                    healthFlag,
                    style: const TextStyle(
                      color: Colors.tealAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Note: This status is reported directly by the Android OS sticky broadcast. It is usually "GOOD" unless hardware overheating/dead status occurs, and is not a precise indicator of battery capacity wear.',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
