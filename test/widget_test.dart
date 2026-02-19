import 'package:flutter_test/flutter_test.dart';
import 'package:forgevault/main.dart';

void main() {
  testWidgets('ForgeVault root renders', (WidgetTester tester) async {
    await tester.pumpWidget(const ForgeVaultRoot());

    // Auth screen should be the first thing visible
    expect(find.text('ForgeVault'), findsOneWidget);
  });
}
