import 'package:flutter/material.dart';

class CardGradientTheme {
  const CardGradientTheme({
    required this.name,
    required this.colors,
    required this.assetPath,
  });

  final String name;
  final List<Color> colors;
  final String assetPath;

  LinearGradient get gradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: colors,
  );
}

const List<CardGradientTheme> cardGradientThemes = [
  CardGradientTheme(
    name: 'Midnight Purple',
    colors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)],
    assetPath: 'assets/visa.svg',
  ),
  CardGradientTheme(
    name: 'Sunset Orange',
    colors: [Color(0xFFFF512F), Color(0xFFF09819)],
    assetPath: 'assets/mastercard.svg',
  ),
  CardGradientTheme(
    name: 'Ocean Blue',
    colors: [Color(0xFF2193B0), Color(0xFF6DD5ED)],
    assetPath: 'assets/americanexpress.svg',
  ),
  CardGradientTheme(
    name: 'Emerald Green',
    colors: [Color(0xFF134E5E), Color(0xFF71B280)],
    assetPath: 'assets/discover.svg',
  ),
  CardGradientTheme(
    name: 'Rose Gold',
    colors: [Color(0xFFB76E79), Color(0xFFE8C4C4)],
    assetPath: 'assets/visa.svg',
  ),
];
