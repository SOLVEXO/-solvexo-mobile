import 'package:book_store_app/app/data/models/ai_studio/ai_generate_response.dart';
import 'package:book_store_app/app/data/repositories/ai_studio_repository.dart';
import 'package:book_store_app/app/data/repositories/seller_product_repository.dart';
import 'package:book_store_app/app/modules/ai_studio/controllers/ai_generate_handling_mixin.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:get/get.dart';

class EmailCampaignController extends GetxController with AiGenerateHandlingMixin {
  final AiStudioRepository _repo = AiStudioRepository();
  final SellerProductRepository _productRepo = SellerProductRepository();

  static const goals = ['promo', 'newsletter', 'abandoned_cart', 'new_arrival', 'restock', 'thank_you'];
  static const tones = ['professional', 'friendly', 'academic'];
  static const maxProducts = 10;

  @override
  String storeId = '';

  final RxString campaignGoal = goals.first.obs;
  final RxString tone = 'friendly'.obs;

  final RxList<Map<String, dynamic>> products = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> selectedProducts = <Map<String, dynamic>>[].obs;

  final Rx<AiGenerateResponse?> result = Rx<AiGenerateResponse?>(null);
  final RxBool accepted = false.obs;
  final RxBool isAccepting = false.obs;

  List<Map<String, dynamic>> get pickableProducts =>
      products.where((p) => !selectedProducts.any((s) => s['productId'] == p['productId'])).toList();

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    storeId = await AppPreferences.getStoreId() ?? '';
    if (storeId.isEmpty) return;
    final inventory = await _productRepo.fetchStoreInventory(storeId: storeId, limit: 100);
    products.assignAll(inventory.products);
  }

  void addProduct(Map<String, dynamic> product) {
    if (selectedProducts.length >= maxProducts) {
      ToastUtil.showToast('You can feature up to $maxProducts products');
      return;
    }
    selectedProducts.add(product);
  }

  void removeProduct(Map<String, dynamic> product) => selectedProducts.remove(product);

  Future<void> generate() => _generate();
  Future<void> regenerate() => _generate(regenerateFromId: result.value?.generationId);

  Future<void> _generate({String? regenerateFromId}) async {
    final response = await runGenerate(() => _repo.generateEmail(
          storeId,
          campaignGoal: campaignGoal.value,
          tone: tone.value,
          productIds: selectedProducts.map((p) => p['productId'] as String).toList(),
          regenerateFromId: regenerateFromId,
        ));
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
