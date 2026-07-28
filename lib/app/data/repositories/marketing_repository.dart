import 'package:book_store_app/app/data/models/marketing/public_campaign_model.dart';
import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:flutter/material.dart';

/// Buyer-facing, unauthenticated homepage marketing content — distinct from
/// the seller-only join/leave campaign endpoints (`api/marketing/:storeId/
/// campaigns`, already covered by the seller campaigns UI). Non-critical
/// homepage content: every failure is swallowed and an empty list returned,
/// matching `BannersRepository`'s philosophy exactly.
class MarketingRepository {
  final BaseClient _client = BaseClient();

  Future<List<PublicCampaignModel>> getActiveCampaigns() async {
    try {
      final res = await _client.get(ApiConstants.publicActiveCampaigns);
      final list = res.data['data'] as List? ?? [];
      return List<PublicCampaignModel>.from(
        list.map((e) => PublicCampaignModel.fromJson(e as Map<String, dynamic>)),
      );
    } catch (e) {
      debugPrint('❌ Error fetching active campaigns: $e');
      return [];
    }
  }
}
