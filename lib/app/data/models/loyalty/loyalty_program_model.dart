class LoyaltyTierModel {
  final String name;
  final int minPoints;
  final List<String> benefits;

  const LoyaltyTierModel({required this.name, required this.minPoints, this.benefits = const []});

  factory LoyaltyTierModel.fromJson(Map<String, dynamic> json) {
    return LoyaltyTierModel(
      name: json['name'] as String? ?? '',
      minPoints: json['minPoints'] as int? ?? 0,
      benefits: (json['benefits'] as List? ?? []).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() => {'name': name, 'minPoints': minPoints, 'benefits': benefits};
}

class LoyaltyProgramModel {
  final bool isEnabled;
  final int pointsPerDollar;
  final int pointsPerReview;
  final int pointsPerReferral;
  final int birthdayBonusPoints;
  final int? pointsExpiryMonths;
  final List<LoyaltyTierModel> tiers;

  const LoyaltyProgramModel({
    required this.isEnabled,
    required this.pointsPerDollar,
    required this.pointsPerReview,
    required this.pointsPerReferral,
    required this.birthdayBonusPoints,
    this.pointsExpiryMonths,
    required this.tiers,
  });

  static const empty = LoyaltyProgramModel(
    isEnabled: false,
    pointsPerDollar: 1,
    pointsPerReview: 0,
    pointsPerReferral: 0,
    birthdayBonusPoints: 0,
    tiers: [],
  );

  factory LoyaltyProgramModel.fromJson(Map<String, dynamic> json) {
    return LoyaltyProgramModel(
      isEnabled: json['isEnabled'] as bool? ?? false,
      pointsPerDollar: (json['pointsPerDollar'] as num?)?.toInt() ?? 1,
      pointsPerReview: (json['pointsPerReview'] as num?)?.toInt() ?? 0,
      pointsPerReferral: (json['pointsPerReferral'] as num?)?.toInt() ?? 0,
      birthdayBonusPoints: (json['birthdayBonusPoints'] as num?)?.toInt() ?? 0,
      pointsExpiryMonths: json['pointsExpiryMonths'] as int?,
      tiers: (json['tiers'] as List? ?? []).cast<Map<String, dynamic>>().map(LoyaltyTierModel.fromJson).toList(),
    );
  }
}
