import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/wallet_card.dart';
import '../state/wallet_controller.dart';
import '../widgets/ambient_glow.dart';
import '../widgets/wallet_card_stack.dart';
import 'card_detail_screen.dart';

/// The home screen: every card in a stack that fans out when dragged.
class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final WalletController _controller = WalletController();

  @override
  void initState() {
    super.initState();
    _controller.restore();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openCard(WalletCard card) async {
    HapticFeedback.lightImpact();
    await Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 520),
        reverseTransitionDuration: const Duration(milliseconds: 460),
        pageBuilder: (context, animation, secondaryAnimation) =>
            CardDetailScreen(controller: _controller, cardId: card.id),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
                reverseCurve: Curves.easeInCubic,
              ),
              child: child,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final cards = _controller.cards;

        return Scaffold(
          body: GlowBackground(
            // The front card is the one fully in view, so it sets the glow.
            theme: cards.last.theme,
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final cardWidth = math.min(
                    constraints.maxWidth < 700
                        ? constraints.maxWidth * 0.92
                        : 560.0,
                    constraints.maxWidth - 40,
                  );

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: SizedBox(
                        width: cardWidth,
                        child: Column(
                          children: [
                            Text(
                              'WalletFX',
                              style: textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${cards.length} cards',
                              style: textTheme.bodyMedium?.copyWith(
                                color: Colors.white54,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Expanded(
                              child: WalletCardStack(
                                cards: cards,
                                onCardTap: _openCard,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Drag to fan out  ·  Tap a card to open it',
                              style: textTheme.bodySmall?.copyWith(
                                color: Colors.white54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
