import 'dart:async';
import 'package:flutter/material.dart';
import '../battery_stats/battery_model.dart';
import '../battery_stats/battery_service.dart';
import '../battery_stats/battery_wear_calculator.dart';
import '../battery_stats/notification_service.dart';
import '../battery_stats/root_battery_service.dart';
import '../storage/battery_database.dart';
import '../widgets_home/home_widget_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final BatteryService _batteryService = BatteryService();
  final RootBatteryService _rootBatteryService = RootBatteryService();

  BatteryInfo? _batteryInfo;
  RootBatteryInfo? _rootInfo;
  BatteryWearEstimate? _wearEstimate;
  StreamSubscription<BatteryInfo>? _subscription;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    NotificationService.initialize();
    _loadDashboardData();

    _subscription = _batteryService.batteryInfoStream.listen((info) {
      if (mounted) {
        setState(() {
          _batteryInfo = info;
        });
      }
    });

    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _loadDashboardData();
    });
  }

  Future<void> _loadDashboardData() async {
    final info = await _batteryService.fetchCurrentBatteryInfo();
    final rootInfo = await _rootBatteryService.fetchRootBatteryInfo();
    final logs = await BatteryDatabase.instance.getAllLogs();
    final estimate = BatteryWearCalculator.calculate(logs);

    if (mounted) {
      setState(() {
        _batteryInfo = info;
        _rootInfo = rootInfo;
        _wearEstimate = estimate;
      });
      if (info.temperature != null) {
        NotificationService.checkAndTriggerTemperatureWarning(info.temperature!);
      }
      HomeWidgetService.updateWidgets(
        batteryInfo: info,
        rootInfo: rootInfo,
        wearEstimate: estimate,
      );
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
    final root = _rootInfo;
    final wear = _wearEstimate;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Battery Health Monitor'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadDashboardData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildGaugeCard(info),
                const SizedBox(height: 16),
                _buildHealthSourceBadgeCard(root, wear),
                const SizedBox(height: 16),
                _buildMetricsGrid(info, wear, root),
                const SizedBox(height: 16),
                _buildAppDrainProfilerCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGaugeCard(BatteryInfo? info) {
    final level = info?.batteryLevel ?? 0;
    final stateLabel = info?.batteryStateLabel ?? 'Loading...';

    Color levelColor = Colors.tealAccent;
    if (level <= 20) {
      levelColor = Colors.redAccent;
    } else if (level <= 50) {
      levelColor = Colors.orangeAccent;
    }

    final wattageText = info?.wattage != null
        ? '${info!.wattage!.toStringAsFixed(1)} W'
        : null;
    final currentText = info?.currentMa != null
        ? '${info!.currentMa!.toStringAsFixed(0)} mA'
        : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 130,
                  height: 130,
                  child: CircularProgressIndicator(
                    value: level / 100.0,
                    strokeWidth: 12,
                    color: levelColor,
                    backgroundColor: Colors.white10,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$level%',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: levelColor,
                      ),
                    ),
                    Text(
                      info?.technology ?? '',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white38,
                      ),
                    ),
                  ],
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
            if (wattageText != null || currentText != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amberAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt_rounded, color: Colors.amberAccent, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${wattageText ?? ''} ${currentText != null ? "($currentText)" : ""}',
                      style: const TextStyle(
                        color: Colors.amberAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHealthSourceBadgeCard(
      RootBatteryInfo? root, BatteryWearEstimate? wear) {
    final isRootActive =
        root != null && root.isRootAvailable && root.isRootGranted;

    final badgeLabel =
        isRootActive ? 'Health Source: Measured (Root)' : 'Health Source: Estimated (No Root)';
    final badgeColor = isRootActive ? Colors.greenAccent : Colors.tealAccent;
    final healthVal = isRootActive
        ? (root.measuredHealthPercentage != null
            ? '${root.measuredHealthPercentage}%'
            : 'N/A')
        : (wear?.estimatedHealthPercentage != null
            ? '${wear!.estimatedHealthPercentage}%'
            : 'Calculated in ~2-3 wks');

    return Card(
      color: const Color(0xFF161F28),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              isRootActive
                  ? Icons.verified_user_rounded
                  : Icons.auto_awesome_rounded,
              color: badgeColor,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: badgeColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badgeLabel,
                      style: TextStyle(
                        color: badgeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Health: $healthVal',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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

  Widget _buildMetricsGrid(
      BatteryInfo? info, BatteryWearEstimate? wear, RootBatteryInfo? root) {
    final cyclesDisplay = (root != null && root.cycleCount != null)
        ? '${root.cycleCount} (HW)'
        : '${wear?.estimatedCycles ?? 0.0} (Est)';

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.35,
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
          icon: Icons.autorenew_rounded,
          label: 'Cycle Count',
          value: cyclesDisplay,
          color: Colors.tealAccent,
        ),
        _buildMetricTile(
          icon: Icons.calendar_today_rounded,
          label: 'Days Tracked',
          value: '${wear?.daysOfData ?? 0.0} days',
          color: Colors.lightBlueAccent,
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
        padding: const EdgeInsets.all(14.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
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
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppDrainProfilerCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.pie_chart_rounded, color: Colors.purpleAccent, size: 22),
                SizedBox(width: 8),
                Text(
                  'App Battery Drain Profiler',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildAppDrainRow('Display & System', '38%', Colors.purpleAccent),
            _buildAppDrainRow('Social & Media Apps', '27%', Colors.deepPurpleAccent),
            _buildAppDrainRow('Background Services', '18%', Colors.blueAccent),
            _buildAppDrainRow('Idle & Standby', '17%', Colors.white38),
          ],
        ),
      ),
    );
  }

  Widget _buildAppDrainRow(String name, String percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                name,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
          Text(
            percentage,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
