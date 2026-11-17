import 'package:book_store_app/app/data/models/activity_log/activity_log_model.dart';
import 'package:book_store_app/app/data/repositories/promotions_repository.dart';
import 'package:get/get.dart';

/// Backs [PromotionDetailView] — just the request's activity timeline; the
/// header (placement/status/price/etc.) comes straight from the
/// [PromotionRequestModel] already held by the list screen, no re-fetch
/// needed for that part.
class PromotionDetailController extends GetxController {
  PromotionDetailController({required this.requestId, PromotionsRepository? repository})
      : _repo = repository ?? PromotionsRepository();

  final String requestId;
  final PromotionsRepository _repo;

  final RxBool isLoading = true.obs;
  final RxList<ActivityLogModel> logs = <ActivityLogModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    isLoading.value = true;
    logs.assignAll(await _repo.timeline(requestId));
    isLoading.value = false;
  }

  @override
  Future<void> refresh() => _load();
}
