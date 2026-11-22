import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';

import '../models/wallet_card.dart';
import 'credit_card_widget.dart';

/// Flies the resting card face in both directions, so the detail screen's
/// interactive card is never rebuilt mid-flight.
Widget walletCardHeroShuttle(
  BuildContext flightContext,
  Animation<double> animation,
  HeroFlightDirection flightDirection,
  BuildContext fromHeroContext,
  BuildContext toHeroContext,
) {
  final stackSide = flightDirection == HeroFlightDirection.push
      ? fromHeroContext
      : toHeroContext;
  return (stackSide.widget as Hero).child;
}

/// The wallet's cards stacked on top of each other, back card first.
///
/// Dragging down fans the stack out and dragging up closes it; on release it
/// springs to whichever state is nearer, or the one the fling points to.
class WalletCardStack extends StatefulWidget {
  const WalletCardStack({
    super.key,
    required this.cards,
    required this.onCardTap,
  });

  final List<WalletCard> cards;
  final ValueChanged<WalletCard> onCardTap;

  @override
  State<WalletCardStack> createState() => _WalletCardStackState();
}

class _WalletCardStackState extends State<WalletCardStack>
    with TickerProviderStateMixin {
  static const _maxPeek = 58.0;
  static const _minPeek = 36.0;
  static const _fannedGap = 16.0;
  static const _minCardHeight = 120.0;

  // 0 is closed and 1 is fanned out; the spring may briefly go past either.
  late final AnimationController _fan = AnimationController.unbounded(
    vsync: this,
  );
  late final AnimationController _entry = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  // The drag distance that takes the stack from closed to fanned out.
  double _dragRange = 0;
  bool _isFanned = false;

  @override
  void dispose() {
    _fan.dispose();
    _entry.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_dragRange <= 0) {
      return;
    }
    _fan.stop();
    // A little give past either end, like a rubber band.
    _fan.value = (_fan.value + details.primaryDelta! / _dragRange).clamp(
      -0.12,
      1.12,
    );
  }

  void _onDragEnd(DragEndDetails details) {
    if (_dragRange <= 0) {
      return;
    }
    final velocity = details.primaryVelocity ?? 0;
    final bool fanOut;
    if (velocity.abs() > 400) {
      fanOut = velocity > 0;
    } else {
      fanOut = _fan.value > 0.5;
    }
    _settle(fanOut, velocity / _dragRange);
  }

  void _settle(bool fanOut, [double velocity = 0]) {
    if (fanOut != _isFanned) {
      _isFanned = fanOut;
      HapticFeedback.selectionClick();
    }
    _fan.animateWith(
      SpringSimulation(
        const SpringDescription(mass: 1, stiffness: 240, damping: 21),
        _fan.value,
        fanOut ? 1 : 0,
        velocity,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cards = widget.cards;

    return LayoutBuilder(
      builder: (context, constraints) {
        final gaps = math.max(cards.length - 1, 0);
        // Cards are laid out at this width and scaled down when space is
        // short, so their text never has to squeeze.
        final designWidth = constraints.maxWidth;
        var cardWidth = designWidth;
        var cardHeight = cardWidth / 1.586;
        var collapsedPeek = _maxPeek;
        var fannedSpacing = cardHeight + _fannedGap;

        if (constraints.hasBoundedHeight && gaps > 0) {
          // On short screens, first tighten the closed stack, then shrink.
          collapsedPeek = ((constraints.maxHeight - cardHeight) / gaps).clamp(
            _minPeek,
            _maxPeek,
          );
          final fitHeight = constraints.maxHeight - gaps * collapsedPeek;
          if (cardHeight > fitHeight) {
            cardHeight = math.max(fitHeight, _minCardHeight);
            cardWidth = cardHeight * 1.586;
          }
          // Fan out only as far as the space allows.
          fannedSpacing = ((constraints.maxHeight - cardHeight) / gaps).clamp(
            collapsedPeek,
            cardHeight + _fannedGap,
          );
        }
        _dragRange = gaps * (fannedSpacing - collapsedPeek);

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onVerticalDragUpdate: _onDragUpdate,
          onVerticalDragEnd: _onDragEnd,
          child: Align(
            alignment: Alignment.topCenter,
            child: AnimatedBuilder(
              animation: Listenable.merge([_fan, _entry]),
              builder: (context, _) {
                final spacing = lerpDouble(
                  collapsedPeek,
                  fannedSpacing,
                  _fan.value,
                )!;
                final stackHeight = cardHeight + gaps * math.max(spacing, 0);

                return SizedBox(
                  width: cardWidth,
                  height: stackHeight,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      for (var index = 0; index < cards.length; index++)
                        Positioned(
                          top: index * spacing,
                          left: 0,
                          width: cardWidth,
                          height: cardHeight,
                          child: _StackedCard(
                            key: ValueKey(cards[index].id),
                            card: cards[index],
                            designWidth: designWidth,
                            entry: _entryProgress(index, cards.length),
                            onTap: () => widget.onCardTap(cards[index]),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  // Cards rise into place one after another, the back card first.
  double _entryProgress(int index, int count) {
    final start = count <= 1 ? 0.0 : index * (0.4 / (count - 1));
    final end = math.min(start + 0.6, 1.0);
    final t = ((_entry.value - start) / (end - start)).clamp(0.0, 1.0);
    return Curves.easeOutCubic.transform(t);
  }
}

class _StackedCard extends StatelessWidget {
  const _StackedCard({
    super.key,
    required this.card,
    required this.designWidth,
    required this.entry,
    required this.onTap,
  });

  final WalletCard card;
  final double designWidth;
  final double entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: entry,
      child: Transform.translate(
        offset: Offset(0, 48 * (1 - entry)),
        child: Semantics(
          button: true,
          label: '${card.label} card ending in ${card.lastFour}',
          child: GestureDetector(
            // The face ignores pointers, so the detector claims the area.
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: Hero(
              tag: card.heroTag,
              flightShuttleBuilder: walletCardHeroShuttle,
              // The Hero flies this whole box, so the face scales smoothly
              // between the stack and the detail screen.
              child: FittedBox(
                child: SizedBox(
                  width: designWidth,
                  child: CreditCardFace(card: card),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
