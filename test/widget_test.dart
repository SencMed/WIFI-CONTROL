import 'package:flutter_test/flutter_test.dart';
import 'package:wifi_control/main.dart';

void main() {
  testWidgets('muestra el panel principal de WIFI CONTROL', (tester) async {
    await tester.pumpWidget(const WifiControlApp());
    expect(find.text('WIFI CONTROL'), findsOneWidget);
    expect(find.text('Módulos'), findsOneWidget);
  });
}
