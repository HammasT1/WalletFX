import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/card_gradient_theme.dart';
import '../models/wallet_card.dart';

/// Holds the wallet's cards and saved looks, and keeps them on the device.
class WalletController extends ChangeNotifier {
  WalletController({List<WalletCard>? cards})
    : _cards = [...(cards ?? sampleWalletCards)];

  // Each entry is "<card id>|<theme name>".
  static const cardThemesKey = 'card_themes';
  static const savedThemesKey = 'saved_themes';
  // Written by versions with a single card; read once to carry it over.
  static const legacySelectedThemeKey = 'selected_theme';

  final List<WalletCard> _cards;
  final List<CardGradientTheme> _savedThemes = [];
  // Set once the user changes anything, so a slow restore never overwrites it.
  bool _hasUserChanges = false;
  bool _disposed = false;

  List<WalletCard> get cards => List.unmodifiable(_cards);
  List<CardGradientTheme> get savedThemes => List.unmodifiable(_savedThemes);

  WalletCard cardById(String id) => _cards.firstWhere((card) => card.id == id);

  /// Brings back each card's theme and the saved looks from the previous
  /// launch. Themes are stored by name; names that no longer exist are skipped.
  Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();
    if (_disposed || _hasUserChanges) {
      return;
    }

    var changed = false;
    final storedCardThemes = prefs.getStringList(cardThemesKey);
    if (storedCardThemes != null) {
      for (final entry in storedCardThemes) {
        final separator = entry.indexOf('|');
        if (separator <= 0) {
          continue;
        }
        final id = entry.substring(0, separator);
        final theme = cardGradientThemeByName(entry.substring(separator + 1));
        final index = _cards.indexWhere((card) => card.id == id);
        if (theme != null && index != -1) {
          _cards[index] = _cards[index].copyWith(theme: theme);
          changed = true;
        }
      }
    } else {
      final legacy = cardGradientThemeByName(
        prefs.getString(legacySelectedThemeKey),
      );
      if (legacy != null && _cards.isNotEmpty) {
        _cards[0] = _cards[0].copyWith(theme: legacy);
        changed = true;
      }
    }

    for (final name in prefs.getStringList(savedThemesKey) ?? const []) {
      final theme = cardGradientThemeByName(name);
      if (theme != null && !_savedThemes.contains(theme)) {
        _savedThemes.add(theme);
        changed = true;
      }
    }

    if (changed) {
      notifyListeners();
    }
  }

  /// Returns false when the card already uses [theme].
  bool setCardTheme(String cardId, CardGradientTheme theme) {
    final index = _cards.indexWhere((card) => card.id == cardId);
    if (index == -1 || _cards[index].theme == theme) {
      return false;
    }
    _hasUserChanges = true;
    _cards[index] = _cards[index].copyWith(theme: theme);
    notifyListeners();
    _persist();
    return true;
  }

  /// Returns false when [theme] is already in the saved row.
  bool saveLook(CardGradientTheme theme) {
    _hasUserChanges = true;
    if (_savedThemes.contains(theme)) {
      return false;
    }
    _savedThemes.add(theme);
    notifyListeners();
    _persist();
    return true;
  }

  CardGradientTheme? removeSavedLookAt(int index) {
    if (index < 0 || index >= _savedThemes.length) {
      return null;
    }
    _hasUserChanges = true;
    final removed = _savedThemes.removeAt(index);
    notifyListeners();
    _persist();
    return removed;
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(cardThemesKey, [
      for (final card in _cards) '${card.id}|${card.theme.name}',
    ]);
    await prefs.setStringList(savedThemesKey, [
      for (final theme in _savedThemes) theme.name,
    ]);
    await prefs.remove(legacySelectedThemeKey);
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
