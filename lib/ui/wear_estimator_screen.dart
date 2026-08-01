import 'package:flutter/material.dart';
import '../battery_stats/battery_wear_calculator.dart';
import '../storage/battery_database.dart';
import '../storage/battery_log_model.dart';

class WearEstimatorScreen extends StatefulWidget {
  const WearEstimatorScreen({super.key});

  @override
  State<WearEstimatorScreen> createState() => _WearEstimatorScreenState();
}

class _WearEstimatorScreenState extends State<WearEstimatorScreen> {
  bool _isLoading = true;
  BatteryWearEstimate? _estimate;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final logs = await BatteryDatabase.instance.getAllLogs();
    final estimate = BatteryWearCalculator.calculate(logs);
    if (mounted) {
      setState(() {
        _estimate = estimate;
        _isLoading = false;
      });
    }
  }

  Future<void> _addSampleLog() async {
    // Helper to log a sample manually for testing
    final lastLogs = await BatteryDatabase.instance.getAllLogs();
    final lastLevel = lastLogs.isNotEmpty ? lastLogs.last.batteryLevel : 50;
    final nextLevel = (lastLevel + 5) % 100;

    await BatteryDatabase.instance.insertLog(
      BatteryLog(
        timestamp: DateTime.now(),
        batteryLevel: nextLevel == 0 ? 100 : nextLevel,
        batteryState: 'Charging',
        temperature: 32.5,
      ),
    );
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final est = _estimate;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wear Estimator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadData,
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildCyclesCard(est),
                      const SizedBox(height: 16),
                      _buildStatsRow(est),
                      const SizedBox(height: 16),
                      _buildDisclaimerCard(),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _addSampleLog,
                        icon: const Icon(Icons.add_location_alt_rounded),
                        label: const Text('Add Test Log Entry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildCyclesCard(BatteryWearEstimate? est) {
    final cycles = est?.estimatedCycles ?? 0.0;
    final health = est?.estimatedHealthPercentage;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(
              Icons.autorenew_rounded,
              size: 48,
              color: Colors.tealAccent,
            ),
            const SizedBox(height: 8),
            Text(
              '$cycles',
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Text(
              'Estimated Cycles Logged',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            if (health != null) ...[
              const Divider(height: 32, color: Colors.white10),
              Text(
                'Estimated Capacity Health: $health%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.tealAccent,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(BatteryWearEstimate? est) {
    return Row(
      children: [
        Expanded(
          child: _buildStatTile(
            title: 'Days Collected',
            value: '${est?.daysOfData ?? 0.0} days',
            icon: Icons.calendar_today_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatTile(
            title: 'Logs Recorded',
            value: '${est?.totalLogsCount ?? 0}',
            icon: Icons.list_alt_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildStatTile({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.tealAccent, size: 20),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 4),
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

  Widget _buildDisclaimerCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline_rounded,
                color: Colors.amberAccent, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Estimation Disclaimer',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.amberAccent,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Non-root battery wear estimation relies on cumulative background charge delta integration. Estimated wear % requires ~2-3 weeks of continuous data collection to stabilize accurately.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
