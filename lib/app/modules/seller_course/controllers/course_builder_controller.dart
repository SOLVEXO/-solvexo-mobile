import 'package:book_store_app/app/data/repositories/seller_course_repository.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:get/get.dart';

/// Course builder (checklist #14a). Arguments: {productId, name}.
/// Everything is edited locally and sent in one PUT (the API replaces the
/// course); lesson ids are sent back so student progress is kept.
class CourseBuilderController extends GetxController {
  CourseBuilderController({SellerCourseRepository? repository, String? storeId, String? productId})
      : _repo = repository ?? SellerCourseRepository(),
        _storeIdOverride = storeId,
        _productIdOverride = productId;

  final SellerCourseRepository _repo;
  final String? _storeIdOverride, _productIdOverride;
  SellerCourseRepository get repo => _repo;

  String storeId = '';
  String productId = '';
  String title = 'Course';

  final RxBool isLoading = true.obs;
  final RxBool failed = false.obs;
  /// The server's reason when loading failed (e.g. "Invalid id"), else null.
  final RxnString loadError = RxnString();
  final RxBool saving = false.obs;
  final RxBool dirty = false.obs;
  final Rx<CourseContent?> content = Rx<CourseContent?>(null);

  @override
  void onInit() {
    super.onInit();
    final a = Get.arguments;
    if (a is Map) {
      productId = '${a['productId'] ?? ''}';
      title = '${a['name'] ?? title}';
    }
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    failed.value = false;
    loadError.value = null;
    storeId = _storeIdOverride ?? await AppPreferences.getStoreId() ?? '';
    productId = _productIdOverride ?? productId;
    try {
      content.value = await _repo.load(storeId, productId);
      dirty.value = false;
    } on CourseLoadException catch (e) {
      loadError.value = e.message;
      failed.value = true;
    } catch (_) {
      failed.value = true;
    }
    isLoading.value = false;
  }

  void _changed() {
    dirty.value = true;
    content.refresh();
  }

  CourseContent get c => content.value!;

  // ── Sections ──────────────────────────────────────────────────────────────
  void addSection(String name) {
    c.sections.add(CourseSection(title: name.trim()));
    _changed();
  }

  void renameSection(int i, String name) {
    c.sections[i].title = name.trim();
    _changed();
  }

  void removeSection(int i) {
    c.sections.removeAt(i);
    _changed();
  }

  void moveSection(int i, int delta) {
    final j = i + delta;
    if (j < 0 || j >= c.sections.length) return;
    final s = c.sections.removeAt(i);
    c.sections.insert(j, s);
    _changed();
  }

  // ── Lessons ───────────────────────────────────────────────────────────────
  void putLesson(int section, CourseLesson lesson, {int? index}) {
    final list = c.sections[section].lessons;
    index == null ? list.add(lesson) : list[index] = lesson;
    _changed();
  }

  void removeLesson(int section, int index) {
    c.sections[section].lessons.removeAt(index);
    _changed();
  }

  void moveLesson(int section, int index, int delta) {
    final list = c.sections[section].lessons;
    final j = index + delta;
    if (j < 0 || j >= list.length) return;
    list.insert(j, list.removeAt(index));
    _changed();
  }

  // ── Course details ───────────────────────────────────────────────────────
  void setOutcomes(List<String> v) {
    c.outcomes
      ..clear()
      ..addAll(v.map((e) => e.trim()).where((e) => e.isNotEmpty));
    _changed();
  }

  void setInstructor(String name, String bio) {
    c.instructorName = name.trim();
    c.instructorBio = bio.trim();
    _changed();
  }

  void setAccessDays(int? days) {
    c.accessDays = days;
    _changed();
  }

  void setCertificate(String key, dynamic value) {
    c.certificate[key] = value is String && value.trim().isEmpty ? null : value;
    _changed();
  }

  void setCertificateEnabled(bool v) {
    c.certificateEnabled = v;
    _changed();
  }

  static String? validateAccessDays(String raw) {
    final v = int.tryParse(raw.trim());
    if (v == null || v < 1 || v > CourseContent.maxAccessDays) return 'Enter 1 to 3650 days.';
    return null;
  }

  Future<bool> save() async {
    final content = this.content.value;
    if (content == null) return false;
    final err = content.validate();
    if (err != null) {
      ToastUtil.showToast(err);
      return false;
    }
    saving.value = true;
    try {
      final r = await _repo.save(storeId, productId, content);
      if (r.ok && r.saved != null) {
        this.content.value = r.saved;
        dirty.value = false;
        ToastUtil.showToast('Course saved');
        return true;
      }
      ToastUtil.showToast(r.message ?? 'Could not save the course.');
      return false;
    } finally {
      saving.value = false;
    }
  }
}
