import 'package:flutter/material.dart';

import 'screens/wallet_screen.dart';

void main() {
  runApp(const CardFlowApp());
}

class CardFlowApp extends StatelessWidget {
  const CardFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WalletFX',
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
      home: const WalletScreen(),
    );
  }
}
