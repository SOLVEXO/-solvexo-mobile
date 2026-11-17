import 'package:book_store_app/app/data/models/seo/seo_product_list_item_model.dart';
import 'package:book_store_app/app/data/repositories/seo_repository.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

class SellerSeoProductsController extends GetxController {
  final SeoRepository _repo = SeoRepository();

  String storeId = '';
  static const _limit = 20;
  int _page = 1;

  final ScrollController scrollController = ScrollController();

  final RxBool isLoading = true.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;
  final RxBool isSavingProduct = false.obs;
  final RxBool isApplyingTemplate = false.obs;
  final RxBool isExporting = false.obs;

  final RxList<SeoProductListItemModel> products = <SeoProductListItemModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    _init();
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
      loadMore();
    }
  }

  Future<void> _init() async {
    storeId = await AppPreferences.getStoreId() ?? '';
    if (storeId.isEmpty) {
      debugPrint('⚠️ SellerSeoProductsController: no storeId in prefs');
      isLoading.value = false;
      return;
    }
    await refresh();
  }

  @override
  Future<void> refresh() async {
    isLoading.value = true;
    _page = 1;
    final result = await _repo.getProducts(storeId, page: _page, limit: _limit);
    products.assignAll(result.items);
    hasMore.value = _page < result.pages;
    isLoading.value = false;
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value) return;
    isLoadingMore.value = true;
    final nextPage = _page + 1;
    final result = await _repo.getProducts(storeId, page: nextPage, limit: _limit);
    products.addAll(result.items);
    _page = nextPage;
    hasMore.value = _page < result.pages;
    isLoadingMore.value = false;
  }

  Future<void> saveProductSeo(
    String productId, {
    String? metaTitle,
    String? metaDescription,
    List<String>? keywords,
    bool? noindex,
  }) async {
    if (isSavingProduct.value) return;
    isSavingProduct.value = true;
    try {
      final updated = await _repo.updateProductSeo(
        storeId,
        productId,
        metaTitle: metaTitle,
        metaDescription: metaDescription,
        keywords: keywords,
        noindex: noindex,
      );
      if (updated != null) {
        final idx = products.indexWhere((p) => p.id == productId);
        if (idx != -1) {
          products[idx] = products[idx].copyWith(seo: updated);
        }
      }
    } finally {
      isSavingProduct.value = false;
    }
  }

  Future<void> applyBulkTemplate({
    String? titleTemplate,
    String? descriptionTemplate,
    bool onlyMissing = false,
  }) async {
    if (isApplyingTemplate.value) return;
    isApplyingTemplate.value = true;
    try {
      final updated = await _repo.bulkApplyTemplate(
        storeId,
        titleTemplate: titleTemplate,
        descriptionTemplate: descriptionTemplate,
        onlyMissing: onlyMissing,
      );
      if (updated != null) await refresh();
    } finally {
      isApplyingTemplate.value = false;
    }
  }

  Future<void> exportCsv() async {
    if (isExporting.value) return;
    isExporting.value = true;
    try {
      final bytes = await _repo.exportProductsCsv(storeId);
      if (bytes != null) {
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile.fromData(Uint8List.fromList(bytes), name: 'product-seo-$storeId.csv', mimeType: 'text/csv')],
          ),
        );
      }
    } finally {
      isExporting.value = false;
    }
  }
}
