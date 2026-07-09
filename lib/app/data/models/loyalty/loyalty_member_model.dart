class LoyaltyMemberModel {
  final String id;
  final String userId;
  final int pointsBalance;
  final int lifetimePoints;
  final String? currentTier;
  final DateTime? lastActivityAt;
  final String userName;
  final String userEmail;

  const LoyaltyMemberModel({
    required this.id,
    required this.userId,
    required this.pointsBalance,
    required this.lifetimePoints,
    this.currentTier,
    this.lastActivityAt,
    required this.userName,
    required this.userEmail,
  });

  factory LoyaltyMemberModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    return LoyaltyMemberModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      pointsBalance: (json['pointsBalance'] as num?)?.toInt() ?? 0,
      lifetimePoints: (json['lifetimePoints'] as num?)?.toInt() ?? 0,
      currentTier: json['currentTier'] as String?,
      lastActivityAt: json['lastActivityAt'] != null ? DateTime.tryParse(json['lastActivityAt'] as String) : null,
      userName: user?['name'] as String? ?? 'Unknown',
      userEmail: user?['email'] as String? ?? '',
    );
  }
}

class LoyaltyTransactionModel {
  final String id;
  final String type;
  final int points;
  final String? orderId;
  final int balanceAfter;
  final String? description;
  final DateTime? createdAt;

  const LoyaltyTransactionModel({
    required this.id,
    required this.type,
    required this.points,
    this.orderId,
    required this.balanceAfter,
    this.description,
    this.createdAt,
  });

  factory LoyaltyTransactionModel.fromJson(Map<String, dynamic> json) {
    return LoyaltyTransactionModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      type: json['type'] as String? ?? '',
      points: (json['points'] as num?)?.toInt() ?? 0,
      orderId: json['orderId'] as String?,
      balanceAfter: (json['balanceAfter'] as num?)?.toInt() ?? 0,
      description: json['description'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) : null,
    );
  }
}
