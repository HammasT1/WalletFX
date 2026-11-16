import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:walletfx/main.dart';

void main() {
  testWidgets('app boots with no saved looks', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const CardFlowApp());
    await tester.pumpAndSettle();

    expect(find.text('WalletFX'), findsOneWidget);
    expect(find.text('Saved looks appear here.'), findsOneWidget);
  });

  testWidgets('saved looks are restored from the previous launch', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'selected_theme': 'Ocean Blue',
      'saved_themes': ['Rose Gold', 'Ocean Blue', 'No Longer Exists'],
    });

    await tester.pumpWidget(const CardFlowApp());
    await tester.pumpAndSettle();

    expect(find.text('Saved looks appear here.'), findsNothing);
    expect(find.text('•••• 4242'), findsNWidgets(2));
  });

  testWidgets('saving the same look twice keeps a single copy', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    // Haptics go through the platform channel, which has no host in tests.
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async => null,
    );

    await tester.pumpWidget(const CardFlowApp());
    await tester.pumpAndSettle();

    // The default 800x600 test surface puts the button below the fold.
    await tester.ensureVisible(find.text('Save this look'));
    await tester.tap(find.text('Save this look'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save this look'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('•••• 4242'), findsOneWidget);
    expect(find.text('Midnight Purple is already saved.'), findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('saved_themes'), ['Midnight Purple']);
  });
}
