import 'package:book_store_app/app/data/models/subscriptions/buyer_subscription_model.dart';

/// A per-store credit wallet granted by a membership's `credits` benefit,
/// as returned by `GET api/subscriptions/my/credits`.
class BuyerCreditWalletModel {
  final String id;
  final String storeId;
  final String subscriptionId;
  final String creditType; // download | service
  final double balance;
  final double totalGranted;
  final double totalSpent;
  final BuyerMembershipStoreModel? store;

  const BuyerCreditWalletModel({
    required this.id,
    required this.storeId,
    required this.subscriptionId,
    required this.creditType,
    required this.balance,
    required this.totalGranted,
    required this.totalSpent,
    this.store,
  });

  factory BuyerCreditWalletModel.fromJson(Map<String, dynamic> json) {
    return BuyerCreditWalletModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      storeId: json['storeId'] as String? ?? '',
      subscriptionId: json['subscriptionId'] as String? ?? '',
      creditType: json['creditType'] as String? ?? 'download',
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
      totalGranted: (json['totalGranted'] as num?)?.toDouble() ?? 0,
      totalSpent: (json['totalSpent'] as num?)?.toDouble() ?? 0,
      store: json['store'] is Map<String, dynamic>
          ? BuyerMembershipStoreModel.fromJson(json['store'] as Map<String, dynamic>)
          : null,
    );
  }
}
