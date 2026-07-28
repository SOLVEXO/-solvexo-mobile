import 'package:book_store_app/app/data/models/announcement_model.dart';
import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:flutter/material.dart';

/// Active platform announcements banner — unauthenticated, shared by both
/// the buyer home (audience='buyers') and seller home (audience='sellers').
/// Non-critical homepage content: every failure is swallowed and an empty
/// list returned, matching `BannersRepository`'s philosophy exactly.
class AnnouncementsRepository {
  final BaseClient _client = BaseClient();

  /// [audience] is 'buyers' or 'sellers'.
  Future<List<AnnouncementModel>> getActive(String audience) async {
    try {
      final res = await _client.get(ApiConstants.publicAnnouncements(audience));
      final list = res.data['data'] as List? ?? [];
      return List<AnnouncementModel>.from(
        list.map((e) => AnnouncementModel.fromJson(e as Map<String, dynamic>)),
      );
    } catch (e) {
      debugPrint('❌ Error fetching announcements ($audience): $e');
      return [];
    }
  }
}
