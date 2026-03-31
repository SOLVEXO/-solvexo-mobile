import 'package:book_store_app/app/modules/help_center/models/faq_model.dart';
import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:flutter/material.dart';

class FaqRepository {
  final BaseClient _baseClient = BaseClient();

  // ─────────────────────────────────────────
  // GET ALL ACTIVE FAQs (PUBLIC)
  // ─────────────────────────────────────────

  Future<List<FaqModel>> fetchFaqs({String? category}) async {
    try {
      debugPrint(
        '🔄 Fetching FAQs${category != null ? ' - category: $category' : ''}...',
      );

      final url = category != null
          ? '${ApiConstants.faqs}?category=$category'
          : ApiConstants.faqs;

      final response = await _baseClient.get(url);

      if (response.data['success'] == true) {
        final list = response.data['data'] as List? ?? [];
        final faqs = list.map((e) => FaqModel.fromJson(e)).toList();
        debugPrint('✅ Fetched ${faqs.length} FAQs');
        return faqs;
      }

      return [];
    } catch (e) {
      debugPrint('❌ Error fetching FAQs: $e');
      return [];
    }
  }

  // ─────────────────────────────────────────
  // SEARCH FAQs (PUBLIC)
  // ─────────────────────────────────────────

  Future<List<FaqModel>> searchFaqs(String query) async {
    try {
      if (query.trim().isEmpty) return [];

      debugPrint('🔍 Searching FAQs: $query');

      final response = await _baseClient.get(
        '${ApiConstants.faqs}/search?q=${Uri.encodeComponent(query)}',
      );

      if (response.data['success'] == true) {
        final list = response.data['data'] as List? ?? [];
        final faqs = list.map((e) => FaqModel.fromJson(e)).toList();
        debugPrint('✅ Found ${faqs.length} FAQs');
        return faqs;
      }

      return [];
    } catch (e) {
      debugPrint('❌ Error searching FAQs: $e');
      return [];
    }
  }

  // ─────────────────────────────────────────
  // GET CATEGORIES (PUBLIC)
  // ─────────────────────────────────────────

  Future<List<String>> fetchCategories() async {
    try {
      debugPrint('🔄 Fetching FAQ categories...');

      final response = await _baseClient.get('${ApiConstants.faqs}/categories');

      if (response.data['success'] == true) {
        final list = response.data['data'] as List? ?? [];
        final categories = list.map((e) => e.toString()).toList();
        debugPrint('✅ Fetched ${categories.length} categories');
        return categories;
      }

      return [];
    } catch (e) {
      debugPrint('❌ Error fetching categories: $e');
      return [];
    }
  }
}
