import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/card_gradient_theme.dart';
import '../state/wallet_controller.dart';
import '../widgets/ambient_glow.dart';
import '../widgets/credit_card_widget.dart';
import '../widgets/gradient_swatch_picker.dart';
import '../widgets/wallet_card_stack.dart';

/// One card up close: flip, tilt and peek, plus its theme and saved looks.
class CardDetailScreen extends StatefulWidget {
  const CardDetailScreen({
    super.key,
    required this.controller,
    required this.cardId,
  });

  final WalletController controller;
  final String cardId;

  @override
  State<CardDetailScreen> createState() => _CardDetailScreenState();
}

class _CardDetailScreenState extends State<CardDetailScreen> {
  final GlobalKey<AnimatedListState> _savedThemesListKey =
      GlobalKey<AnimatedListState>();

  WalletController get _controller => widget.controller;

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1600),
        ),
      );
  }

  Future<void> _selectTheme(CardGradientTheme theme) async {
    if (theme == _controller.cardById(widget.cardId).theme) {
      return;
    }

    // Light haptic feedback makes the swatch selection feel tactile.
    await HapticFeedback.lightImpact();
    if (!mounted) {
      return;
    }
    _controller.setCardTheme(widget.cardId, theme);
  }

  Future<void> _saveCurrentLook() async {
    await HapticFeedback.selectionClick();
    if (!mounted) {
      return;
    }

    final theme = _controller.cardById(widget.cardId).theme;
    final insertIndex = _controller.savedThemes.length;
    if (!_controller.saveLook(theme)) {
      _showMessage('${theme.name} is already saved.');
      return;
    }
    _savedThemesListKey.currentState?.insertItem(insertIndex);
  }

  Future<void> _removeSavedTheme(int index) async {
    await HapticFeedback.lightImpact();
    if (!mounted) {
      return;
    }
    final removedTheme = _controller.removeSavedLookAt(index);
    if (removedTheme == null) {
      return;
    }

    final selectedTheme = _controller.cardById(widget.cardId).theme;
    _savedThemesListKey.currentState?.removeItem(
      index,
      (context, animation) => _SavedThemeThumbnail(
        theme: removedTheme,
        animation: animation,
        onTap: () {},
        isSelected: removedTheme == selectedTheme,
        isRemoving: true,
      ),
      duration: const Duration(milliseconds: 280),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final card = _controller.cardById(widget.cardId);
        final savedThemes = _controller.savedThemes;

        return Scaffold(
          body: GlowBackground(
            theme: card.theme,
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final maxCardWidth = constraints.maxWidth < 700
                      ? constraints.maxWidth * 0.92
                      : 560.0;

                  return Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 24,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxCardWidth),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  icon: const Icon(Icons.arrow_back_rounded),
                                  tooltip: 'Back to wallet',
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    card.label,
                                    style: textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                ),
                                Text(
                                  '•••• ${card.lastFour}',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: Colors.white54,
                                    letterSpacing: 1.4,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Hero(
                              tag: card.heroTag,
                              flightShuttleBuilder: walletCardHeroShuttle,
                              child: CreditCardWidget(
                                card: card,
                                animateEntry: false,
                              ),
                            ),
                            const SizedBox(height: 28),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Theme Library',
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: _saveCurrentLook,
                                  icon: const Icon(Icons.bookmark_add_outlined),
                                  label: const Text('Save this look'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            GradientSwatchPicker(
                              themes: cardGradientThemes,
                              selectedTheme: card.theme,
                              onSelected: _selectTheme,
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 96,
                              child: savedThemes.isEmpty
                                  ? Center(
                                      child: Text(
                                        'Saved looks appear here.',
                                        style: textTheme.bodySmall?.copyWith(
                                          color: Colors.white54,
                                        ),
                                      ),
                                    )
                                  : AnimatedList(
                                      key: _savedThemesListKey,
                                      scrollDirection: Axis.horizontal,
                                      initialItemCount: savedThemes.length,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 2,
                                      ),
                                      itemBuilder: (context, index, animation) {
                                        final theme =
                                            _controller.savedThemes[index];
                                        return _SavedThemeThumbnail(
                                          theme: theme,
                                          animation: animation,
                                          isSelected: theme == card.theme,
                                          onTap: () => _selectTheme(theme),
                                          onLongPress: () =>
                                              _removeSavedTheme(index),
                                        );
                                      },
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

class _SavedThemeThumbnail extends StatelessWidget {
  const _SavedThemeThumbnail({
    required this.theme,
    required this.animation,
    required this.onTap,
    this.onLongPress,
    required this.isSelected,
    this.isRemoving = false,
  });

  final CardGradientTheme theme;
  final Animation<double> animation;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;
  final bool isRemoving;

  @override
  Widget build(BuildContext context) {
    final growAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeIn,
    );

    return SizeTransition(
      sizeFactor: animation,
      axis: Axis.horizontal,
      child: FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: isRemoving
              ? Tween<double>(begin: 1, end: 0.85).animate(animation)
              : growAnimation,
          child: GestureDetector(
            onTap: onTap,
            onLongPress: onLongPress,
            child: Container(
              width: 118,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: theme.gradient,
                boxShadow: [
                  BoxShadow(
                    color: theme.colors.last.withOpacity(0.3),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.white24,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      width: 18,
                      height: 14,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.white.withOpacity(0.24),
                        border: Border.all(color: Colors.white24, width: 0.8),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.22),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 10,
                    right: 10,
                    bottom: 12,
                    child: Text(
                      '•••• 4242',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
