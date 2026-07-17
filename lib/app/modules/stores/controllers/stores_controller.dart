import 'package:book_store_app/app/data/models/storefront/store_list_item_model.dart';
import 'package:book_store_app/app/data/repositories/stores_repository.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Buyer-facing "browse all stores" screen — sortable by followers, rating,
/// or newest (see `StoreService.listPublicStores`).
class StoresController extends GetxController {
  final StoresRepository _storesRepository = StoresRepository();

  final RxList<StoreListItemModel> stores = <StoreListItemModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isFetchingMore = false.obs;

  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxBool hasMore = true.obs;

  // followers | rating | newest
  final RxString sort = 'followers'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchStores();
  }

  Future<void> fetchStores({bool reset = true}) async {
    if (reset) {
      currentPage.value = 1;
      isLoading.value = true;
    }

    try {
      final result = await _storesRepository.listStores(
        page: currentPage.value,
        limit: 20,
        sort: sort.value,
      );

      if (reset) {
        stores.assignAll(result.stores);
      } else {
        stores.addAll(result.stores);
      }

      totalPages.value = result.totalPages;
      hasMore.value = result.hasMore;
    } catch (e) {
      debugPrint('❌ Error fetching stores: $e');
      ToastUtil.showToast('Failed to load stores');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isFetchingMore.value || !hasMore.value) return;
    isFetchingMore.value = true;
    currentPage.value++;
    try {
      await fetchStores(reset: false);
    } catch (e) {
      currentPage.value--;
    } finally {
      isFetchingMore.value = false;
    }
  }

  void changeSort(String value) {
    if (sort.value == value) return;
    sort.value = value;
    fetchStores();
  }

  Future<void> refreshStores() => fetchStores();
}
