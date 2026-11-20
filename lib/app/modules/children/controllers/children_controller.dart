import 'package:book_store_app/app/data/repositories/children_repository.dart';
import 'package:book_store_app/app/data/repositories/premium_repository.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:get/get.dart';

/// My children (B4, docs §5.11). The limit comes from the server
/// (GET /api/premium/me entitlements.childrenLimit; 8, Premium 15).
class ChildrenController extends GetxController {
  ChildrenController({ChildrenRepository? repository, PremiumRepository? premium})
      : _repo = repository ?? ChildrenRepository(),
        _premium = premium ?? PremiumRepository();

  final ChildrenRepository _repo;
  final PremiumRepository _premium;

  final RxBool isLoading = true.obs;
  final RxBool failed = false.obs;
  final RxBool saving = false.obs;
  final RxList<Child> children = <Child>[].obs;
  final RxInt limit = 8.obs;

  bool get atLimit => children.length >= limit.value;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    failed.value = false;
    try {
      children.assignAll(await _repo.list());
      try {
        limit.value = (await _premium.me()).childrenLimit;
      } catch (_) {}
    } catch (_) {
      failed.value = true;
    }
    isLoading.value = false;
  }

  /// Same rules as children.service.ts; null = valid.
  static Map<String, String> validate({required String name, required String? gradeLabel, required String age, required List<String> subjects}) {
    final e = <String, String>{};
    final n = name.trim();
    if (n.isEmpty || n.length > 60) e['name'] = 'Child name must be 1-60 characters'.tr;
    if (gradeLabel == null) e['class'] = 'Choose a class'.tr;
    if (age.trim().isNotEmpty) {
      final a = int.tryParse(age.trim());
      if (a == null || a < 2 || a > 25) e['age'] = 'Age must be a whole number between 2 and 25'.tr;
    }
    if (subjects.length > 10) e['subjects'] = 'At most 10 subjects'.tr;
    if (subjects.any((s) => s.length > 40)) e['subjects'] = 'Subject is too long (max 40)'.tr;
    return e;
  }

  Future<bool> save(Child c) async {
    if (saving.value) return false;
    saving.value = true;
    final err = await _repo.save(c);
    saving.value = false;
    if (err != null) {
      ToastUtil.showToast(err);
      return false;
    }
    await load();
    return true;
  }

  Future<void> remove(Child c) async {
    final err = await _repo.remove(c.id);
    if (err != null) {
      ToastUtil.showToast(err);
      return;
    }
    children.removeWhere((x) => x.id == c.id);
  }
}
