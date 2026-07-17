import 'package:book_store_app/app/data/models/ai_studio/ai_generate_response.dart';
import 'package:book_store_app/app/data/repositories/ai_studio_repository.dart';
import 'package:book_store_app/app/data/repositories/seller_product_repository.dart';
import 'package:book_store_app/app/modules/ai_studio/controllers/ai_generate_handling_mixin.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class SeoBoosterController extends GetxController with AiGenerateHandlingMixin {
  final AiStudioRepository _repo = AiStudioRepository();
  final SellerProductRepository _productRepo = SellerProductRepository();

  @override
  String storeId = '';

  /// true = pick an existing product; false = enter title/description/tags manually.
  final RxBool fromProduct = true.obs;

  final titleCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();
  final tagsCtrl = TextEditingController();

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
    titleCtrl.dispose();
    descriptionCtrl.dispose();
    tagsCtrl.dispose();
    super.onClose();
  }

  Future<void> _init() async {
    storeId = await AppPreferences.getStoreId() ?? '';
    if (storeId.isEmpty) return;
    final inventory = await _productRepo.fetchStoreInventory(storeId: storeId, limit: 100);
    products.assignAll(inventory.products);
  }

  void setMode(bool useProduct) {
    fromProduct.value = useProduct;
    if (useProduct) selectedProduct.value = null;
  }

  void pickProduct(Map<String, dynamic> product) => selectedProduct.value = product;

  Future<void> generate() => _generate();
  Future<void> regenerate() => _generate(regenerateFromId: result.value?.generationId);

  Future<void> _generate({String? regenerateFromId}) async {
    final tags = tagsCtrl.text.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();

    if (fromProduct.value) {
      final product = selectedProduct.value;
      if (product == null) {
        ToastUtil.showToast('Select a product to optimize');
        return;
      }
      final response = await runGenerate(() => _repo.generateSeo(
            storeId,
            productId: product['productId'] as String?,
            currentTags: tags.isNotEmpty ? tags : null,
            regenerateFromId: regenerateFromId,
          ));
      _handleResult(response);
      return;
    }

    final title = titleCtrl.text.trim();
    if (title.isEmpty) {
      ToastUtil.showToast('Enter a title to optimize');
      return;
    }
    final response = await runGenerate(() => _repo.generateSeo(
          storeId,
          title: title,
          description: descriptionCtrl.text.trim(),
          currentTags: tags,
          regenerateFromId: regenerateFromId,
        ));
    _handleResult(response);
  }

  void _handleResult(AiGenerateResponse? response) {
    if (response == null) return;
    result.value = response;
    accepted.value = false;
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
