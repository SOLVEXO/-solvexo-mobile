import 'package:book_store_app/app/modules/home/models/banner_model.dart';
import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:flutter/material.dart';

class BannersRepository {
  final BaseClient _baseClient = BaseClient();

  /// [placement] is optional — when omitted, behavior is 100% unchanged
  /// (unscoped, used by the live homepage carousel). Pass it to scope the
  /// request to a specific placement slot once a caller needs that.
  Future<List<BannerModel>> fetchBanners({String? placement}) async {
    try {
      debugPrint('🔄 Fetching banners...');

      final res = await _baseClient.get(
        ApiConstants.banners,
        queryParameters: placement != null ? {'placement': placement} : null,
      );

      // ✅ Backend returns: { success, count, remaining, data: [...] }
      final list = res.data['data'] as List? ?? [];

      final banners = List<BannerModel>.from(
        list.map((e) => BannerModel.fromJson(e as Map<String, dynamic>)),
      );

      debugPrint('✅ Fetched ${banners.length} banners');
      return banners;
    } catch (e) {
      debugPrint('❌ Error fetching banners: $e');
      return []; // return empty list on error — app won't crash
    }
  }
}
