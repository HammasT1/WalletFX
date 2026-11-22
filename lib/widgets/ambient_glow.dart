import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../models/card_gradient_theme.dart';

/// The blurred background glow that takes its colors from [theme].
class AmbientGlow extends StatelessWidget {
  const AmbientGlow({super.key, required this.theme});

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

/// The dark backdrop with an ambient glow that cross-fades between themes.
class GlowBackground extends StatelessWidget {
  const GlowBackground({super.key, required this.theme, required this.child});

  final CardGradientTheme theme;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
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
              child: AmbientGlow(key: ValueKey(theme.name), theme: theme),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
