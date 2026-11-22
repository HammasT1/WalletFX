import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:walletfx/main.dart';
import 'package:walletfx/widgets/credit_card_widget.dart';
import 'package:walletfx/widgets/wallet_card_stack.dart';

// Taps a stacked card on its top strip, the part the cards above leave visible.
Future<void> openCard(WidgetTester tester, String id) async {
  final card = find.byKey(ValueKey(id));
  await tester.tapAt(tester.getTopLeft(card) + const Offset(60, 20));
  await tester.pumpAndSettle();
}

// A tall phone-shaped surface, so the stack has room to fan out.
void usePhoneSurface(WidgetTester tester) {
  tester.view.devicePixelRatio = 2;
  tester.view.physicalSize = const Size(1120, 2000);
  addTearDown(tester.view.reset);
}

void main() {
  setUp(() {
    // Haptics go through the platform channel, which has no host in tests.
    TestWidgetsFlutterBinding.ensureInitialized().defaultBinaryMessenger
        .setMockMethodCallHandler(
          SystemChannels.platform,
          (call) async => null,
        );
  });

  testWidgets('wallet shows every card in a stack', (tester) async {
    usePhoneSurface(tester);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const CardFlowApp());
    await tester.pumpAndSettle();

    expect(find.text('WalletFX'), findsOneWidget);
    expect(find.text('4 cards'), findsOneWidget);
    expect(find.byType(CreditCardFace), findsNWidgets(4));
  });

  testWidgets('dragging down fans the stack out and dragging up closes it', (
    tester,
  ) async {
    usePhoneSurface(tester);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const CardFlowApp());
    await tester.pumpAndSettle();

    final frontCard = find.byType(CreditCardFace).last;
    final closedTop = tester.getTopLeft(frontCard).dy;

    await tester.drag(find.byType(WalletCardStack), const Offset(0, 300));
    await tester.pumpAndSettle();
    final fannedTop = tester.getTopLeft(frontCard).dy;
    expect(fannedTop, greaterThan(closedTop));

    await tester.drag(find.byType(WalletCardStack), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(
      tester.getTopLeft(frontCard).dy,
      moreOrLessEquals(closedTop, epsilon: 0.5),
    );
  });

  testWidgets('tapping a card opens it and the back button returns', (
    tester,
  ) async {
    usePhoneSurface(tester);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const CardFlowApp());
    await tester.pumpAndSettle();

    await openCard(tester, 'travel');
    expect(find.text('Travel'), findsOneWidget);
    expect(find.text('•••• 8005'), findsOneWidget);
    expect(find.byType(CreditCardWidget), findsOneWidget);
    expect(find.text('Saved looks appear here.'), findsOneWidget);

    await tester.tap(find.byTooltip('Back to wallet'));
    await tester.pumpAndSettle();
    expect(find.byType(CreditCardWidget), findsNothing);
    expect(find.text('4 cards'), findsOneWidget);
  });

  testWidgets('a theme picked for one card is kept for that card only', (
    tester,
  ) async {
    usePhoneSurface(tester);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const CardFlowApp());
    await tester.pumpAndSettle();

    await openCard(tester, 'business');
    // The fifth swatch is Rose Gold.
    final swatches = find.descendant(
      of: find.byType(Wrap),
      matching: find.byType(GestureDetector),
    );
    await tester.ensureVisible(swatches.at(4));
    await tester.tap(swatches.at(4));
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('card_themes'), [
      'personal|Midnight Purple',
      'travel|Ocean Blue',
      'business|Rose Gold',
      'savings|Emerald Green',
    ]);
  });

  testWidgets('card themes and saved looks are restored', (tester) async {
    usePhoneSurface(tester);
    SharedPreferences.setMockInitialValues({
      'card_themes': ['travel|Rose Gold', 'gone|Ocean Blue', 'savings|Nope'],
      'saved_themes': ['Rose Gold', 'Ocean Blue', 'No Longer Exists'],
    });

    await tester.pumpWidget(const CardFlowApp());
    await tester.pumpAndSettle();

    await openCard(tester, 'travel');
    expect(find.text('Saved looks appear here.'), findsNothing);
    expect(find.text('•••• 4242'), findsNWidgets(2));
  });

  testWidgets('a theme saved by the single-card version moves to the first '
      'card', (tester) async {
    usePhoneSurface(tester);
    SharedPreferences.setMockInitialValues({
      'selected_theme': 'Ocean Blue',
      'saved_themes': ['Rose Gold'],
    });

    await tester.pumpWidget(const CardFlowApp());
    await tester.pumpAndSettle();

    await openCard(tester, 'business');
    await tester.ensureVisible(find.text('Save this look'));
    await tester.tap(find.text('Save this look'));
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('card_themes')?.first, 'personal|Ocean Blue');
    expect(prefs.getString('selected_theme'), isNull);
  });

  testWidgets('saving the same look twice keeps a single copy', (tester) async {
    usePhoneSurface(tester);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const CardFlowApp());
    await tester.pumpAndSettle();
    // Travel's header shows its own last four, so only thumbnails show 4242.
    await openCard(tester, 'travel');

    await tester.ensureVisible(find.text('Save this look'));
    await tester.tap(find.text('Save this look'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save this look'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('•••• 4242'), findsOneWidget);
    expect(find.text('Ocean Blue is already saved.'), findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('saved_themes'), ['Ocean Blue']);
  });

  testWidgets('card controls can be changed and restored', (tester) async {
    usePhoneSurface(tester);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const CardFlowApp());
    await tester.pumpAndSettle();

    await openCard(tester, 'travel');
    await tester.ensureVisible(find.byKey(const ValueKey('freeze_card')));
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('freeze_card')),
        matching: find.byType(Switch),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const ValueKey('online_payments')));
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('online_payments')),
        matching: find.byType(Switch),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(
      find.byKey(const ValueKey('contactless_payments')),
    );
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('contactless_payments')),
        matching: find.byType(Switch),
      ),
    );
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    final stored = jsonDecode(prefs.getString('card_controls')!) as Map;
    final travelControls = stored['travel'] as Map;
    expect(travelControls['frozen'], isTrue);
    expect(travelControls['onlinePayments'], isFalse);
    expect(travelControls['contactless'], isFalse);
  });
}
