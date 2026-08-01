import 'package:flutter/material.dart';
import '../battery_stats/battery_wear_calculator.dart';
import '../battery_stats/root_battery_service.dart';
import '../storage/battery_database.dart';
import '../storage/battery_log_model.dart';

class WearEstimatorScreen extends StatefulWidget {
  const WearEstimatorScreen({super.key});

  @override
  State<WearEstimatorScreen> createState() => _WearEstimatorScreenState();
}

class _WearEstimatorScreenState extends State<WearEstimatorScreen> {
  final RootBatteryService _rootBatteryService = RootBatteryService();
  bool _isLoading = true;
  BatteryWearEstimate? _estimate;
  RootBatteryInfo? _rootInfo;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final logs = await BatteryDatabase.instance.getAllLogs();
    final estimate = BatteryWearCalculator.calculate(logs);
    final rootInfo = await _rootBatteryService.fetchRootBatteryInfo();

    if (mounted) {
      setState(() {
        _estimate = estimate;
        _rootInfo = rootInfo;
        _isLoading = false;
      });
    }
  }

  Future<void> _addSampleLog() async {
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
    final root = _rootInfo;

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
                      if (root != null &&
                          root.isRootAvailable &&
                          root.isRootGranted)
                        _buildMeasuredRootCard(root)
                      else
                        _buildEstimatedNoRootCard(est),
                      const SizedBox(height: 16),
                      _buildStatsRow(est, root),
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

  Widget _buildMeasuredRootCard(RootBatteryInfo root) {
    final measuredHealth = root.measuredHealthPercentage;

    return Card(
      color: const Color(0xFF1C2834),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.verified_rounded, color: Colors.greenAccent),
                SizedBox(width: 8),
                Text(
                  'Measured Health (Root Sysfs)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.greenAccent,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              measuredHealth != null ? '$measuredHealth%' : 'N/A',
              style: const TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Full: ${root.chargeFull ?? '?'} / Design: ${root.chargeFullDesign ?? '?'}',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstimatedNoRootCard(BatteryWearEstimate? est) {
    final cycles = est?.estimatedCycles ?? 0.0;
    final health = est?.estimatedHealthPercentage;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.auto_awesome_rounded, color: Colors.tealAccent),
                SizedBox(width: 8),
                Text(
                  'Estimated Health (No Root)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.tealAccent,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
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
                'Estimated Capacity Retention: $health%',
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

  Widget _buildStatsRow(BatteryWearEstimate? est, RootBatteryInfo? root) {
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
            title: 'Root Hardware Cycles',
            value: (root != null && root.cycleCount != null)
                ? '${root.cycleCount}'
                : 'N/A (No Root)',
            icon: Icons.developer_board_rounded,
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
                fontSize: 14,
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
                    'Precision Paths Comparison',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.amberAccent,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    '• Measured Health (Root): Directly reads charge_full and charge_full_design sysfs hardware registers via Superuser.\n• Estimated Health (No Root): Calculates background delta integration, requiring ~2-3 weeks of data collection to stabilize.',
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
