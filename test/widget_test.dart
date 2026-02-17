import 'package:flutter_test/flutter_test.dart';
import 'package:vitavault/main.dart';

void main() {
  testWidgets('VitaVault root renders', (WidgetTester tester) async {
    await tester.pumpWidget(const VitaVaultRoot());

    // Auth screen should be the first thing visible
    expect(find.text('VITAVAULT'), findsOneWidget);
  });
}
