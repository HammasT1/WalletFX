import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/wallet_screen.dart';

void main() {
  runApp(const CardFlowApp());
}

class CardFlowApp extends StatelessWidget {
  const CardFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF4F8CFF);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WalletFX',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: accent,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        textTheme: Typography.whiteMountainView,
        sliderTheme: SliderThemeData(
          activeTrackColor: accent,
          inactiveTrackColor: Colors.white.withValues(alpha: 0.14),
          thumbColor: Colors.white,
          overlayColor: accent.withValues(alpha: 0.16),
          trackHeight: 5,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            return states.contains(WidgetState.selected)
                ? Colors.white
                : Colors.white70;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            return states.contains(WidgetState.selected)
                ? accent
                : Colors.white.withValues(alpha: 0.16);
          }),
          trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.06),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: accent),
          ),
        ),
      ),
      builder: (context, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            systemNavigationBarColor: Color(0xFF121212),
            systemNavigationBarIconBrightness: Brightness.light,
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const WalletScreen(),
    );
  }
}
