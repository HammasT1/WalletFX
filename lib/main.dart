import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'models/card_gradient_theme.dart';
import 'widgets/credit_card_widget.dart';
import 'widgets/gradient_swatch_picker.dart';

void main() {
  runApp(const CardFlowApp());
}

class CardFlowApp extends StatelessWidget {
  const CardFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CardFlow',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F8CFF),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        textTheme: Typography.whiteMountainView,
      ),
      home: const CardFlowHomePage(),
    );
  }
}

class CardFlowHomePage extends StatefulWidget {
  const CardFlowHomePage({super.key});

  @override
  State<CardFlowHomePage> createState() => _CardFlowHomePageState();
}

class _CardFlowHomePageState extends State<CardFlowHomePage> {
  late CardGradientTheme _selectedTheme;
  final List<CardGradientTheme> _savedThemes = [];
  final GlobalKey<AnimatedListState> _savedThemesListKey =
      GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();
    _selectedTheme = cardGradientThemes.first;
  }

  Future<void> _selectTheme(CardGradientTheme theme) async {
    if (theme == _selectedTheme) {
      return;
    }

    // Light haptic feedback makes the swatch selection feel tactile.
    await HapticFeedback.lightImpact();
    setState(() {
      _selectedTheme = theme;
    });
  }

  Future<void> _saveCurrentLook() async {
    await HapticFeedback.selectionClick();

    final insertIndex = _savedThemes.length;
    setState(() {
      _savedThemes.add(_selectedTheme);
    });
    _savedThemesListKey.currentState?.insertItem(insertIndex);
  }

  Future<void> _removeSavedTheme(int index) async {
    final removedTheme = _savedThemes[index];

    await HapticFeedback.lightImpact();
    setState(() {
      _savedThemes.removeAt(index);
    });

    _savedThemesListKey.currentState?.removeItem(
      index,
      (context, animation) => _SavedThemeThumbnail(
        theme: removedTheme,
        animation: animation,
        onTap: () {},
        isSelected: removedTheme == _selectedTheme,
        isRemoving: true,
      ),
      duration: const Duration(milliseconds: 280),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.25,
                  colors: [Color(0xFF1C1C1E), Color(0xFF121212)],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 520),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: _AmbientGlow(
                  key: ValueKey(_selectedTheme.name),
                  theme: _selectedTheme,
                ),
              ),
            ),
          ),
          SafeArea(
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
                          Text(
                            'WalletFX',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                ),
                          ),
                          const SizedBox(height: 28),
                          CreditCardWidget(theme: _selectedTheme),
                          const SizedBox(height: 28),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Theme Library',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
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
                            selectedTheme: _selectedTheme,
                            onSelected: _selectTheme,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 96,
                            child: _savedThemes.isEmpty
                                ? Center(
                                    child: Text(
                                      'Saved looks appear here.',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: Colors.white54),
                                    ),
                                  )
                                : AnimatedList(
                                    key: _savedThemesListKey,
                                    scrollDirection: Axis.horizontal,
                                    initialItemCount: _savedThemes.length,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 2,
                                    ),
                                    itemBuilder: (context, index, animation) {
                                      final theme = _savedThemes[index];
                                      return _SavedThemeThumbnail(
                                        theme: theme,
                                        animation: animation,
                                        isSelected: theme == _selectedTheme,
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
        ],
      ),
    );
  }
}

class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow({super.key, required this.theme});

  final CardGradientTheme theme;

  @override
  Widget build(BuildContext context) {
    final start = theme.colors.first.withOpacity(0.36);
    final end = theme.colors.last.withOpacity(0.22);

    return Stack(
      children: [
        Center(
          child: Container(
            width: 620,
            height: 620,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [start, end, Colors.transparent],
                stops: const [0, 0.52, 1],
              ),
            ),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 70, sigmaY: 70),
              child: const SizedBox.expand(),
            ),
          ),
        ),
        Positioned(
          top: 120,
          right: -70,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  theme.colors.last.withOpacity(0.18),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
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
