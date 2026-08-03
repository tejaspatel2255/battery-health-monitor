import 'package:battery_health_monitor/main.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class MockFlutterLocalNotificationsPlatform extends FlutterLocalNotificationsPlatform {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    // Set fallback platform instance for flutter_local_notifications in unit/widget test environment
    FlutterLocalNotificationsPlatform.instance = MockFlutterLocalNotificationsPlatform();

    // 1. Mock battery_plus channel
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/battery'),
      (MethodCall call) async {
        if (call.method == 'getBatteryLevel') return 80;
        if (call.method == 'getBatteryState') return 'discharging';
        return null;
      },
    );

    // 2. Mock custom battery_extra channel
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('com.batteryhealth.monitor/battery_extra'),
      (MethodCall call) async {
        return <String, dynamic>{
          'temperature': 31.5,
          'voltage': 4.1,
          'technology': 'Li-ion',
          'healthFlag': 'GOOD',
          'currentMa': 450.0,
          'wattage': 1.84,
        };
      },
    );

    // 3. Mock custom root_battery channel
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('com.batteryhealth.monitor/root_battery'),
      (MethodCall call) async {
        if (call.method == 'checkRootAvailability') return false;
        return <String, dynamic>{
          'isRootAvailable': false,
          'isRootGranted': false,
        };
      },
    );

    // 4. Mock home_widget channel
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('es.antonborri.home_widget'),
      (MethodCall call) async {
        return true;
      },
    );

    // 5. Mock flutter_local_notifications channel
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('dexterous.com/flutter/local_notifications'),
      (MethodCall call) async {
        if (call.method == 'initialize') return true;
        if (call.method == 'requestNotificationsPermission') return true;
        if (call.method == 'createNotificationChannel') return true;
        return true;
      },
    );
  });

  testWidgets('Battery Health App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const BatteryHealthApp());
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Battery Health Monitor'), findsWidgets);
  });
}
