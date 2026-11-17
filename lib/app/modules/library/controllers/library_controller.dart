import 'package:book_store_app/app/data/repositories/library_repository.dart';
import 'package:book_store_app/app/modules/library/models/library_models.dart';
import 'package:book_store_app/app/services/digital_download_service.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:get/get.dart';

enum LibraryLoad { loading, ready, error, guest }

class LibraryController extends GetxController {
  LibraryController({LibraryRepository? repository})
      : _repo = repository ?? LibraryRepository();

  final LibraryRepository _repo;
  final DigitalDownloadService downloads = DigitalDownloadService();

  final Rx<LibraryLoad> filesState = LibraryLoad.loading.obs;
  final Rx<LibraryLoad> coursesState = LibraryLoad.loading.obs;
  final RxList<LibraryFile> files = <LibraryFile>[].obs;
  final RxList<LibraryCourse> courses = <LibraryCourse>[].obs;

  /// Files filter: only the last 30 days.
  final RxBool recentOnly = false.obs;

  List<LibraryFile> get visibleFiles {
    if (!recentOnly.value) return files;
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    return files.where((f) => f.purchasedAt.isAfter(cutoff)).toList();
  }

  /// First course that is started but not finished ("Pick up where you left off").
  LibraryCourse? get resumeCourse {
    for (final c in courses) {
      if (c.started && (c.progress ?? 0) < 100) return c;
    }
    return null;
  }

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  Future<void> loadAll() async {
    if (!await AppPreferences.isLoggedIn()) {
      filesState.value = LibraryLoad.guest;
      coursesState.value = LibraryLoad.guest;
      files.clear();
      courses.clear();
      return;
    }
    await Future.wait([loadFiles(), loadCourses()]);
  }

  Future<void> loadFiles() async {
    filesState.value = LibraryLoad.loading;
    try {
      files.assignAll(await _repo.fetchFiles());
      filesState.value = LibraryLoad.ready;
    } catch (_) {
      filesState.value = LibraryLoad.error;
    }
  }

  Future<void> loadCourses() async {
    coursesState.value = LibraryLoad.loading;
    try {
      courses.assignAll(await _repo.fetchCourses());
      coursesState.value = LibraryLoad.ready;
    } catch (_) {
      coursesState.value = LibraryLoad.error;
    }
  }

  Future<void> download(LibraryFile f) => downloads.download(
        busyKey: f.key,
        orderId: f.order.orderId,
        productId: f.item.productId,
      );
}
