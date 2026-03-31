import 'package:book_store_app/app/modules/help_center/models/faq_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:book_store_app/app/data/repositories/faq_repository.dart';

class FaqController extends GetxController {
  final FaqRepository _faqRepository = FaqRepository();

  // ─── State ───────────────────────────────
  final RxList<FaqModel> faqs = <FaqModel>[].obs;
  final RxList<FaqModel> filteredFaqs = <FaqModel>[].obs;
  final RxList<String> categories = <String>[].obs;

  final RxBool isLoading = false.obs;
  final RxBool isSearching = false.obs;

  final RxString selectedCategory = 'all'.obs;
  final RxString searchQuery = ''.obs;

  final RxInt expandedIndex = (-1).obs; // For accordion

  @override
  void onInit() {
    super.onInit();
    fetchFaqs();
    fetchCategories();
  }

  // ─────────────────────────────────────────
  // FETCH FAQs
  // ─────────────────────────────────────────

  Future<void> fetchFaqs({String? category}) async {
    try {
      isLoading.value = true;
      final result = await _faqRepository.fetchFaqs(
        category: category == 'all' ? null : category,
      );
      faqs.assignAll(result);
      filteredFaqs.assignAll(result);
      debugPrint('✅ FAQs loaded: ${faqs.length}');
    } catch (e) {
      debugPrint('❌ Error loading FAQs: $e');
      faqs.clear();
      filteredFaqs.clear();
    } finally {
      isLoading.value = false;
    }
  }

  // ─────────────────────────────────────────
  // FETCH CATEGORIES
  // ─────────────────────────────────────────

  Future<void> fetchCategories() async {
    try {
      final result = await _faqRepository.fetchCategories();
      categories.assignAll(['all', ...result]);
    } catch (e) {
      debugPrint('❌ Error loading categories: $e');
    }
  }

  // ─────────────────────────────────────────
  // FILTER BY CATEGORY
  // ─────────────────────────────────────────

  void filterByCategory(String category) {
    selectedCategory.value = category;
    searchQuery.value = ''; // Clear search
    fetchFaqs(category: category);
  }

  // ─────────────────────────────────────────
  // SEARCH
  // ─────────────────────────────────────────

  Future<void> searchFaqs(String query) async {
    searchQuery.value = query;

    if (query.trim().isEmpty) {
      filteredFaqs.assignAll(faqs);
      return;
    }

    try {
      isSearching.value = true;
      final result = await _faqRepository.searchFaqs(query);
      filteredFaqs.assignAll(result);
    } catch (e) {
      debugPrint('❌ Search error: $e');
    } finally {
      isSearching.value = false;
    }
  }

  // ─────────────────────────────────────────
  // TOGGLE ACCORDION
  // ─────────────────────────────────────────

  void toggleExpanded(int index) {
    if (expandedIndex.value == index) {
      expandedIndex.value = -1; // Collapse
    } else {
      expandedIndex.value = index; // Expand
    }
  }

  // ─────────────────────────────────────────
  // REFRESH
  // ─────────────────────────────────────────

  @override
  Future<void> refresh() async {
    await fetchFaqs(category: selectedCategory.value);
  }
}
