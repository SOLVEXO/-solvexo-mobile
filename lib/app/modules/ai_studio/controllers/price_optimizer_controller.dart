import 'package:book_store_app/app/data/models/ai_studio/ai_generate_response.dart';
import 'package:book_store_app/app/data/repositories/ai_studio_repository.dart';
import 'package:book_store_app/app/data/repositories/category_repository.dart';
import 'package:book_store_app/app/data/repositories/seller_product_repository.dart';
import 'package:book_store_app/app/modules/ai_studio/controllers/ai_generate_handling_mixin.dart';
import 'package:book_store_app/app/modules/category/models/category_model.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class PriceOptimizerController extends GetxController with AiGenerateHandlingMixin {
  final AiStudioRepository _repo = AiStudioRepository();
  final SellerProductRepository _productRepo = SellerProductRepository();
  final CategoryRepository _categoryRepo = CategoryRepository();

  @override
  String storeId = '';

  /// true = pick an existing product; false = pick a category + attributes.
  final RxBool fromProduct = true.obs;

  final attributesCtrl = TextEditingController();

  final RxList<Map<String, dynamic>> products = <Map<String, dynamic>>[].obs;
  final Rx<Map<String, dynamic>?> selectedProduct = Rx<Map<String, dynamic>?>(null);

  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final Rx<CategoryModel?> selectedCategory = Rx<CategoryModel?>(null);

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
    attributesCtrl.dispose();
    super.onClose();
  }

  Future<void> _init() async {
    storeId = await AppPreferences.getStoreId() ?? '';
    if (storeId.isEmpty) return;
    final results = await Future.wait([
      _productRepo.fetchStoreInventory(storeId: storeId, limit: 100),
      _categoryRepo.getAllCategoriesFlat(),
    ]);
    products.assignAll((results[0] as ({List<Map<String, dynamic>> products, int totalProducts, bool hasMore})).products);
    categories.assignAll(results[1] as List<CategoryModel>);
  }

  void setMode(bool useProduct) {
    fromProduct.value = useProduct;
  }

  void pickProduct(Map<String, dynamic> product) => selectedProduct.value = product;
  void pickCategory(CategoryModel category) => selectedCategory.value = category;

  Future<void> generate() => _generate();
  Future<void> regenerate() => _generate(regenerateFromId: result.value?.generationId);

  Future<void> _generate({String? regenerateFromId}) async {
    AiGenerateResponse? response;
    if (fromProduct.value) {
      final product = selectedProduct.value;
      if (product == null) {
        ToastUtil.showToast('Select a product');
        return;
      }
      response = await runGenerate(() => _repo.generatePrice(
            storeId,
            productId: product['productId'] as String?,
            regenerateFromId: regenerateFromId,
          ));
    } else {
      final category = selectedCategory.value;
      if (category == null) {
        ToastUtil.showToast('Select a category');
        return;
      }
      response = await runGenerate(() => _repo.generatePrice(
            storeId,
            categoryId: category.id,
            attributes: attributesCtrl.text.trim(),
            regenerateFromId: regenerateFromId,
          ));
    }
    if (response != null) {
      result.value = response;
      accepted.value = false;
    }
  }

  Future<void> accept() async {
    final current = result.value;
    if (current == null || isAccepting.value) return;
    isAccepting.value = true;
    final updated = await _repo.acceptGeneration(storeId, current.generationId);
    isAccepting.value = false;
    if (updated != null) {
      accepted.value = true;
      ToastUtil.showToast('Marked as accepted');
    }
  }
}
