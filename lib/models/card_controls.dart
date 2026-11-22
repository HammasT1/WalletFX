/// The settings a cardholder can change for one card.
class CardControls {
  const CardControls({
    this.frozen = false,
    required this.spendingLimit,
    this.onlinePayments = true,
    this.contactless = true,
    this.atmWithdrawals = true,
  });

  static const double minLimit = 500;
  static const double maxLimit = 10000;
  static const double limitStep = 250;

  /// A frozen card blocks every payment until it is unfrozen.
  final bool frozen;
  final double spendingLimit;
  final bool onlinePayments;
  final bool contactless;
  final bool atmWithdrawals;

  CardControls copyWith({
    bool? frozen,
    double? spendingLimit,
    bool? onlinePayments,
    bool? contactless,
    bool? atmWithdrawals,
  }) {
    return CardControls(
      frozen: frozen ?? this.frozen,
      spendingLimit: spendingLimit ?? this.spendingLimit,
      onlinePayments: onlinePayments ?? this.onlinePayments,
      contactless: contactless ?? this.contactless,
      atmWithdrawals: atmWithdrawals ?? this.atmWithdrawals,
    );
  }

  Map<String, Object> toJson() => {
    'frozen': frozen,
    'spendingLimit': spendingLimit,
    'onlinePayments': onlinePayments,
    'contactless': contactless,
    'atmWithdrawals': atmWithdrawals,
  };

  /// Reads stored values, keeping [fallback]'s value for anything missing or
  /// malformed so an old or damaged entry never breaks the card.
  factory CardControls.fromJson(
    Map<String, dynamic> json, {
    required CardControls fallback,
  }) {
    bool readBool(String key, bool orElse) =>
        json[key] is bool ? json[key] as bool : orElse;
    final limit = json['spendingLimit'];

    return CardControls(
      frozen: readBool('frozen', fallback.frozen),
      spendingLimit: limit is num
          ? limit.toDouble().clamp(minLimit, maxLimit)
          : fallback.spendingLimit,
      onlinePayments: readBool('onlinePayments', fallback.onlinePayments),
      contactless: readBool('contactless', fallback.contactless),
      atmWithdrawals: readBool('atmWithdrawals', fallback.atmWithdrawals),
    );
  }
}
