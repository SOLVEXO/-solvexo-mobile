/// Buyer-facing, unauthenticated homepage trust stats — server-cached
/// `GET /api/store/public/platform-stats` (600s). A plain typed class
/// (not a record) since it's carried in `HomeController`'s `Rx` state and
/// read from multiple widgets, where a named type reads better than a
/// positional/record shape.
class PlatformStatsModel {
  final int sellersCount;
  final int storesCount;
  final double gmv;
  final double avgRating;
  final int ratingCount;

  const PlatformStatsModel({
    required this.sellersCount,
    required this.storesCount,
    required this.gmv,
    required this.avgRating,
    required this.ratingCount,
  });

  factory PlatformStatsModel.fromJson(Map<String, dynamic> json) {
    return PlatformStatsModel(
      sellersCount: (json['sellersCount'] as num?)?.toInt() ?? 0,
      storesCount: (json['storesCount'] as num?)?.toInt() ?? 0,
      gmv: (json['gmv'] as num?)?.toDouble() ?? 0,
      avgRating: (json['avgRating'] as num?)?.toDouble() ?? 0,
      ratingCount: (json['ratingCount'] as num?)?.toInt() ?? 0,
    );
  }
}
