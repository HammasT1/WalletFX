import 'card_controls.dart';
import 'card_gradient_theme.dart';

/// One card in the wallet. The details are placeholder data for the showcase.
class WalletCard {
  const WalletCard({
    required this.id,
    required this.label,
    required this.number,
    required this.cardholder,
    required this.expiry,
    required this.cvv,
    required this.theme,
    required this.monthlySpent,
    required this.controls,
  });

  final String id;
  final String label;
  final String number;
  final String cardholder;
  final String expiry;
  final String cvv;
  final CardGradientTheme theme;

  /// What has been spent this month, measured against the spending limit.
  final double monthlySpent;
  final CardControls controls;

  String get lastFour => number.substring(number.length - 4);

  /// Shared by the stacked card and the detail card so they fly as one.
  String get heroTag => 'wallet-card-$id';

  WalletCard copyWith({CardGradientTheme? theme, CardControls? controls}) {
    return WalletCard(
      id: id,
      label: label,
      number: number,
      cardholder: cardholder,
      expiry: expiry,
      cvv: cvv,
      theme: theme ?? this.theme,
      monthlySpent: monthlySpent,
      controls: controls ?? this.controls,
    );
  }
}

/// The cards the wallet starts with, back of the stack first.
final List<WalletCard> sampleWalletCards = [
  WalletCard(
    id: 'personal',
    label: 'Personal',
    number: '0562992173814242',
    cardholder: 'MUHAMMAD HAMMAS',
    expiry: '12/28',
    cvv: '742',
    theme: cardGradientThemes[0],
    monthlySpent: 1240,
    controls: const CardControls(spendingLimit: 3000),
  ),
  WalletCard(
    id: 'travel',
    label: 'Travel',
    number: '3714496353988005',
    cardholder: 'MUHAMMAD HAMMAS',
    expiry: '04/29',
    cvv: '318',
    theme: cardGradientThemes[2],
    monthlySpent: 2860,
    controls: const CardControls(spendingLimit: 3000),
  ),
  WalletCard(
    id: 'business',
    label: 'Business',
    number: '5425233430108317',
    cardholder: 'MUHAMMAD HAMMAS',
    expiry: '09/27',
    cvv: '506',
    theme: cardGradientThemes[1],
    monthlySpent: 4120,
    controls: const CardControls(spendingLimit: 8000),
  ),
  WalletCard(
    id: 'savings',
    label: 'Savings',
    number: '6011000990131129',
    cardholder: 'MUHAMMAD HAMMAS',
    expiry: '02/30',
    cvv: '921',
    theme: cardGradientThemes[3],
    monthlySpent: 180,
    controls: const CardControls(spendingLimit: 1000),
  ),
];
