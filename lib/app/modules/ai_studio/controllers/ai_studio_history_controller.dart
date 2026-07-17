import 'package:book_store_app/app/data/models/ai_studio/ai_generation_model.dart';
import 'package:book_store_app/app/data/repositories/ai_studio_repository.dart';
import 'package:book_store_app/app/modules/ai_studio/ai_tool_meta.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class AiStudioHistoryController extends GetxController {
  final AiStudioRepository _repo = AiStudioRepository();

  final ScrollController scrollController = ScrollController();

  String storeId = '';
  final RxBool isLoading = true.obs;
  final RxBool isLoadingMore = false.obs;
  final RxnString filterToolType = RxnString();
  final RxList<AiGenerationModel> items = <AiGenerationModel>[].obs;
  final RxInt total = 0.obs;
  int _page = 1;
  static const _limit = 20;

  List<AiToolMeta?> get filterOptions => [null, ...AiToolMeta.all];

  @override
  void onInit() {
    super.onInit();
    _init();
    scrollController.addListener(() {
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
        loadMore();
      }
    });
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  Future<void> _init() async {
    storeId = await AppPreferences.getStoreId() ?? '';
    if (storeId.isEmpty) {
      debugPrint('⚠️ AiStudioHistoryController: no storeId in prefs');
      isLoading.value = false;
      return;
    }
    await refresh();
  }

  @override
  Future<void> refresh() async {
    isLoading.value = true;
    _page = 1;
    final result = await _repo.getGenerations(storeId, toolType: filterToolType.value, page: _page, limit: _limit);
    items.assignAll(result.items);
    total.value = result.total;
    isLoading.value = false;
  }

  void setFilter(String? toolType) {
    if (filterToolType.value == toolType) return;
    filterToolType.value = toolType;
    refresh();
  }

  bool get hasMore => items.length < total.value;

  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore) return;
    isLoadingMore.value = true;
    _page++;
    final result = await _repo.getGenerations(storeId, toolType: filterToolType.value, page: _page, limit: _limit);
    items.addAll(result.items);
    isLoadingMore.value = false;
  }

  void openDetail(AiGenerationModel generation) {
    Get.toNamed(Routes.aiStudioGenerationDetail, arguments: generation.id);
  }
}
