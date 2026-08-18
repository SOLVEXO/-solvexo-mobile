import 'package:book_store_app/app/data/models/onboarding_slide_model.dart';
import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:flutter/material.dart';

/// Admin-managed first-launch intro slides — unauthenticated, matches
/// `AnnouncementsRepository`/`BannersRepository`'s philosophy: every failure
/// is swallowed and an empty list returned so onboarding never crashes.
class OnboardingSlidesRepository {
  final BaseClient _client = BaseClient();

  Future<List<OnboardingSlideModel>> fetchSlides() async {
    try {
      final res = await _client.get(ApiConstants.onboardingSlides);
      final list = res.data['data'] as List? ?? [];
      return List<OnboardingSlideModel>.from(
        list.map((e) => OnboardingSlideModel.fromJson(e as Map<String, dynamic>)),
      );
    } catch (e) {
      debugPrint('❌ Error fetching onboarding slides: $e');
      return [];
    }
  }
}
