class LoyaltyTierDistribution {
  final String tier;
  final int members;
  final int percent;

  const LoyaltyTierDistribution({required this.tier, required this.members, required this.percent});

  factory LoyaltyTierDistribution.fromJson(Map<String, dynamic> json) {
    return LoyaltyTierDistribution(
      tier: json['tier'] as String? ?? '',
      members: json['members'] as int? ?? 0,
      percent: json['percent'] as int? ?? 0,
    );
  }
}

class LoyaltyOverviewModel {
  final bool programEnabled;
  final int programMembers;
  final int pointsIssuedLast30Days;
  final int pointsRedeemedTotal;
  final double revenueFromMembersLast30Days;
  final List<LoyaltyTierDistribution> memberDistribution;
  final Map<String, int> pointsActivityLast30Days;

  const LoyaltyOverviewModel({
    required this.programEnabled,
    required this.programMembers,
    required this.pointsIssuedLast30Days,
    required this.pointsRedeemedTotal,
    required this.revenueFromMembersLast30Days,
    required this.memberDistribution,
    required this.pointsActivityLast30Days,
  });

  static const empty = LoyaltyOverviewModel(
    programEnabled: false,
    programMembers: 0,
    pointsIssuedLast30Days: 0,
    pointsRedeemedTotal: 0,
    revenueFromMembersLast30Days: 0,
    memberDistribution: [],
    pointsActivityLast30Days: {},
  );

  factory LoyaltyOverviewModel.fromJson(Map<String, dynamic> json) {
    final distribution = (json['memberDistribution'] as List? ?? [])
        .cast<Map<String, dynamic>>()
        .map(LoyaltyTierDistribution.fromJson)
        .toList();
    final activity = (json['pointsActivityLast30Days'] as Map<String, dynamic>? ?? {})
        .map((k, v) => MapEntry(k, (v as num?)?.toInt() ?? 0));

    return LoyaltyOverviewModel(
      programEnabled: json['programEnabled'] as bool? ?? false,
      programMembers: json['programMembers'] as int? ?? 0,
      pointsIssuedLast30Days: json['pointsIssuedLast30Days'] as int? ?? 0,
      pointsRedeemedTotal: json['pointsRedeemedTotal'] as int? ?? 0,
      revenueFromMembersLast30Days: (json['revenueFromMembersLast30Days'] as num?)?.toDouble() ?? 0,
      memberDistribution: distribution,
      pointsActivityLast30Days: activity,
    );
  }
}
