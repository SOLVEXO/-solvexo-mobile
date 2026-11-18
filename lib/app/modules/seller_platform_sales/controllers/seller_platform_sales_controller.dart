import 'package:book_store_app/app/data/models/marketing/campaign_model.dart';
import 'package:book_store_app/app/data/repositories/campaigns_repository.dart';
import 'package:book_store_app/app/data/repositories/seller_product_repository.dart';
import 'package:book_store_app/app/modules/seller_products/controllers/seller_products_controller.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:get/get.dart';

/// Platform Sales (docs 2.6 / 6.12): Edudeen-run sales; the seller picks
/// which products take part, one product at a time (`Product.campaignIds`,
/// PATCH bulk-offers campaign_add / campaign_remove). A product is in
/// Premium or in a platform sale, not both - the server decides and its
/// reasons are shown.
class SellerPlatformSalesController extends GetxController {
  SellerPlatformSalesController({CampaignsRepository? campaigns, SellerProductRepository? products})
      : _campaigns = campaigns ?? CampaignsRepository(),
        _products = products ?? SellerProductRepository();

  final CampaignsRepository _campaigns;
  final SellerProductRepository _products;

  final RxBool isLoading = true.obs;
  final RxBool failed = false.obs;
  final RxList<CampaignModel> campaigns = <CampaignModel>[].obs;

  final RxBool productsLoading = false.obs;
  final RxBool productsFailed = false.obs;
  final RxList<SellerProduct> products = <SellerProduct>[].obs;
  final RxBool moreProducts = false.obs;
  final RxBool saving = false.obs;

  String _storeId = '';

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    failed.value = false;
    _storeId = await AppPreferences.getStoreId() ?? '';
    if (_storeId.isEmpty) {
      failed.value = true;
      isLoading.value = false;
      return;
    }
    final r = await _campaigns.fetchCampaigns(storeId: _storeId);
    campaigns.assignAll(r.items);
    failed.value = r.failed;
    isLoading.value = false;
  }

  /// Live products the seller can put into a sale (first 100).
  Future<void> loadProducts() async {
    productsLoading.value = true;
    productsFailed.value = false;
    final r = await _products.fetchStoreInventory(storeId: _storeId, limit: 100, status: 'active');
    productsFailed.value = r.failed;
    products.assignAll(r.products.map(SellerProduct.fromApiJson));
    moreProducts.value = r.hasMore;
    productsLoading.value = false;
  }

  Set<String> productIdsIn(CampaignModel c) =>
      {for (final p in products) if (p.campaignIds.contains(c.id)) p.id};

  /// Sends the difference: adds then removes. Returns the server's skipped
  /// reasons (e.g. a product that is in Premium).
  Future<List<String>> save(CampaignModel c, Set<String> chosen) async {
    final before = productIdsIn(c);
    final add = chosen.difference(before).toList();
    final remove = before.difference(chosen).toList();
    if (add.isEmpty && remove.isEmpty) return const [];
    saving.value = true;
    final skipped = <String>[];
    var changed = 0;
    try {
      for (final (action, ids) in [('campaign_add', add), ('campaign_remove', remove)]) {
        if (ids.isEmpty) continue;
        final r = await _products.setOffers(storeId: _storeId, productIds: ids, action: action, campaignId: c.id);
        changed += r.updated;
        skipped.addAll(r.skipped);
        if (r.updated == 0 && r.skipped.isEmpty && r.message != null) skipped.add(r.message!);
      }
      if (changed > 0) ToastUtil.showToast('Sale products saved');
      await loadProducts();
      return skipped;
    } finally {
      saving.value = false;
    }
  }
}
