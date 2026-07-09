class NextLoyaltyTier {
  final String name;
  final int pointsNeeded;

  const NextLoyaltyTier({required this.name, required this.pointsNeeded});

  factory NextLoyaltyTier.fromJson(Map<String, dynamic> json) {
    return NextLoyaltyTier(
      name: json['name'] as String? ?? '',
      pointsNeeded: (json['pointsNeeded'] as num?)?.toInt() ?? 0,
    );
  }
}

class MyLoyaltyBalanceModel {
  final int pointsBalance;
  final int lifetimePoints;
  final String? currentTier;
  final NextLoyaltyTier? nextTier;

  const MyLoyaltyBalanceModel({
    required this.pointsBalance,
    required this.lifetimePoints,
    this.currentTier,
    this.nextTier,
  });

  static const empty = MyLoyaltyBalanceModel(pointsBalance: 0, lifetimePoints: 0);

  factory MyLoyaltyBalanceModel.fromJson(Map<String, dynamic> json) {
    return MyLoyaltyBalanceModel(
      pointsBalance: (json['pointsBalance'] as num?)?.toInt() ?? 0,
      lifetimePoints: (json['lifetimePoints'] as num?)?.toInt() ?? 0,
      currentTier: json['currentTier'] as String?,
      nextTier: json['nextTier'] != null ? NextLoyaltyTier.fromJson(json['nextTier'] as Map<String, dynamic>) : null,
    );
  }
}
