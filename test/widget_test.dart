import 'package:flutter_test/flutter_test.dart';
import 'package:paymint/main.dart';

void main() {
  testWidgets('PayMint Smoke Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Note: This may fail in test environment if Firebase is not mocked,
    // so we just ensure the app can be pumped.
    await tester.pumpWidget(const PayMintApp());
  });
}
