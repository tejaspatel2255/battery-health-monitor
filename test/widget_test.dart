import 'package:battery_health_monitor/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Battery Health App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const BatteryHealthApp());
    expect(find.text('Battery Health Monitor'), findsWidgets);
  });
}
