import 'package:book_store_app/app/data/models/ai_studio/ai_generate_response.dart';
import 'package:book_store_app/app/data/repositories/ai_studio_repository.dart';
import 'package:book_store_app/app/data/repositories/seller_product_repository.dart';
import 'package:book_store_app/app/modules/ai_studio/controllers/ai_generate_handling_mixin.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class ListingWriterController extends GetxController with AiGenerateHandlingMixin {
  final AiStudioRepository _repo = AiStudioRepository();
  final SellerProductRepository _productRepo = SellerProductRepository();

  static const tones = ['professional', 'friendly', 'academic'];

  @override
  String storeId = '';

  final productTypeCtrl = TextEditingController();
  final keywordsCtrl = TextEditingController();
  final RxString tone = 'professional'.obs;

  final RxList<Map<String, dynamic>> products = <Map<String, dynamic>>[].obs;
  final Rx<Map<String, dynamic>?> selectedProduct = Rx<Map<String, dynamic>?>(null);

  final Rx<AiGenerateResponse?> result = Rx<AiGenerateResponse?>(null);
  final RxBool accepted = false.obs;
  final RxBool isAccepting = false.obs;

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  @override
  void onClose() {
    productTypeCtrl.dispose();
    keywordsCtrl.dispose();
    super.onClose();
  }

  Future<void> _init() async {
    storeId = await AppPreferences.getStoreId() ?? '';
    if (storeId.isEmpty) {
      debugPrint('⚠️ ListingWriterController: no storeId in prefs');
      return;
    }
    final inventory = await _productRepo.fetchStoreInventory(storeId: storeId, limit: 100);
    products.assignAll(inventory.products);
  }

  void pickProduct(Map<String, dynamic> product) => selectedProduct.value = product;
  void clearProduct() => selectedProduct.value = null;

  Future<void> generate() => _generate();
  Future<void> regenerate() => _generate(regenerateFromId: result.value?.generationId);

  Future<void> _generate({String? regenerateFromId}) async {
    final productType = productTypeCtrl.text.trim();
    final keywords = keywordsCtrl.text.split(',').map((k) => k.trim()).where((k) => k.isNotEmpty).toList();
    if (productType.isEmpty) {
      ToastUtil.showToast('Enter a product type');
      return;
    }
    if (keywords.isEmpty) {
      ToastUtil.showToast('Enter at least one keyword');
      return;
    }

    final response = await runGenerate(() => _repo.generateListing(
          storeId,
          productType: productType,
          keywords: keywords,
          tone: tone.value,
          productId: selectedProduct.value?['productId'] as String?,
          regenerateFromId: regenerateFromId,
        ));
    if (response != null) {
      result.value = response;
      accepted.value = false;
    }
  }

  Future<void> accept({bool applyToProduct = false}) async {
    final current = result.value;
    if (current == null || isAccepting.value) return;
    isAccepting.value = true;
    final updated = await _repo.acceptGeneration(
      storeId,
      current.generationId,
      applyToProduct: applyToProduct,
      productId: selectedProduct.value?['productId'] as String?,
    );
    isAccepting.value = false;
    if (updated != null) {
      accepted.value = true;
      ToastUtil.showToast(applyToProduct ? 'Applied to product' : 'Marked as accepted');
    }
  }
}
