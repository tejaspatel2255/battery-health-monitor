import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'battery_stats/background_service.dart';
import 'ui/history_screen.dart';
import 'ui/home_screen.dart';
import 'ui/theme.dart';
import 'ui/unsupported_platform_screen.dart';
import 'ui/wear_estimator_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (defaultTargetPlatform == TargetPlatform.android) {
    await BackgroundService.initialize();
  }
  runApp(const BatteryHealthApp());
}

class BatteryHealthApp extends StatelessWidget {
  const BatteryHealthApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isAndroid = defaultTargetPlatform == TargetPlatform.android;

    return MaterialApp(
      title: 'Battery Health Monitor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: isAndroid
          ? const MainNavigationWrapper()
          : const UnsupportedPlatformScreen(),
    );
  }
}

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    HistoryScreen(),
    WearEstimatorScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.show_chart_rounded),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_rounded),
            label: 'Wear Estimator',
          ),
        ],
      ),
    );
  }
}
