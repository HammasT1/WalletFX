import 'package:flutter_test/flutter_test.dart';

import 'package:walletfx/main.dart';

void main() {
  testWidgets('CardFlow app boots', (WidgetTester tester) async {
    await tester.pumpWidget(const CardFlowApp());
    expect(find.text('CardFlow'), findsOneWidget);
  });
}
