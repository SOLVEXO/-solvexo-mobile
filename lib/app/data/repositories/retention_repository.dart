import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:book_store_app/app/network/api_error.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:dio/dio.dart';

// Wishlist sharing + referrals (B6). Backend 5adba44 src/retention.

/// {active, token, url} (url = `https://www.edudeen.com/wishlist/shared/<token>`).
class WishlistShare {
  const WishlistShare({required this.active, this.token, this.url});
  final bool active;
  final String? token, url;
  factory WishlistShare.fromJson(Map j) => WishlistShare(active: j['active'] == true, token: j['token'] as String?, url: j['url'] as String?);
}

/// GET /api/referrals/me -> {enabled, code, shareUrl, reward{type,value,label,
/// friendLabel,expiryDays}, stats{pending,rewarded,cap}, referredByAnyone}.
class ReferralInfo {
  const ReferralInfo(this.raw);
  final Map raw;
  bool get enabled => raw['enabled'] == true;
  String? get code => raw['code'] as String?;
  String? get shareUrl => raw['shareUrl'] as String?;
  Map get reward => raw['reward'] is Map ? raw['reward'] as Map : const {};
  Map get stats => raw['stats'] is Map ? raw['stats'] as Map : const {};
  bool get referredByAnyone => raw['referredByAnyone'] == true;
}

class RetentionRepository {
  RetentionRepository({BaseClient? client}) : _client = client ?? BaseClient();
  final BaseClient _client;

  Map _data(Response r) => (r.data as Map)['data'] as Map;

  Future<WishlistShare> myShare() async => WishlistShare.fromJson(_data(await _client.get(ApiConstants.wishlistShare('mine'), requiresAuth: true)));
  Future<WishlistShare> createShare() async => WishlistShare.fromJson(_data(await _client.post(ApiConstants.wishlistShare(''), data: {}, requiresAuth: true)));
  Future<WishlistShare> revokeShare() async => WishlistShare.fromJson(_data(await _client.delete(ApiConstants.wishlistShare(''), requiresAuth: true)));

  /// Public. {count, items: [product]}. Throws; 404 = link off / unknown.
  Future<List<Map>> sharedWishlist(String token) async {
    final d = _data(await _client.get(ApiConstants.wishlistShare('public/$token')));
    return d['items'] is List ? (d['items'] as List).whereType<Map>().toList() : const [];
  }

  Future<ReferralInfo> myReferral() async => ReferralInfo(_data(await _client.get(ApiConstants.referralsMe, requiresAuth: true)));

  /// Null = applied, else the server's reason.
  Future<String?> applyReferral(String code) async {
    try {
      await _client.post(ApiConstants.referralsApply, data: {'code': code.trim()}, requiresAuth: true);
      return null;
    } on DioException catch (e) {
      return ApiError.fromDio(e) ?? 'That referral code is not valid';
    }
  }
}
