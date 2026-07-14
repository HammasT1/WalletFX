import 'package:flutter/material.dart';

import '../models/card_gradient_theme.dart';

class GradientSwatchPicker extends StatelessWidget {
  const GradientSwatchPicker({
    super.key,
    required this.themes,
    required this.selectedTheme,
    required this.onSelected,
  });

  final List<CardGradientTheme> themes;
  final CardGradientTheme selectedTheme;
  final ValueChanged<CardGradientTheme> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 14,
      runSpacing: 14,
      children: themes.map((theme) {
        final isSelected = theme == selectedTheme;
        return GestureDetector(
          onTap: () => onSelected(theme),
          child: AnimatedScale(
            duration: const Duration(milliseconds: 180),
            scale: isSelected ? 1.14 : 1.0,
            curve: Curves.easeOut,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: theme.colors.last.withOpacity(0.34),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.white24,
                  width: isSelected ? 2.2 : 1.0,
                ),
                gradient: theme.gradient,
              ),
              child: Center(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isSelected ? 1 : 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
