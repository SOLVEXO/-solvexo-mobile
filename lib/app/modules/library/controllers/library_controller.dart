import 'dart:async';

import 'package:book_store_app/app/data/repositories/library_repository.dart';
import 'package:book_store_app/app/modules/library/models/library_models.dart';
import 'package:book_store_app/app/services/digital_download_service.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      unawaited(maybeShowResumePopup());
    } catch (_) {
      coursesState.value = LibraryLoad.error;
    }
  }

  Future<void> download(LibraryFile f) => downloads.download(
        busyKey: f.key,
        orderId: f.orderId,
        productId: f.productId,
      );

  // ── Resume popup (docs §5.10: "Pick up where you left off", snooze 30 min)

  static const resumeSnoozeKey = 'course_resume_snooze_until';
  static const resumeSnooze = Duration(minutes: 30);
  bool _resumeShown = false;

  /// Once per screen visit, unless snoozed in the last 30 minutes.
  Future<void> maybeShowResumePopup() async {
    final c = resumeCourse;
    if (c == null || c.slug == null || _resumeShown) return;
    final prefs = await SharedPreferences.getInstance();
    final until = prefs.getInt(resumeSnoozeKey) ?? 0;
    if (DateTime.now().millisecondsSinceEpoch < until) return;
    _resumeShown = true;
    final go = await Get.dialog<bool>(AlertDialog(
      title: Text('Pick up where you left off'.tr),
      content: Text(c.title),
      actions: [
        TextButton(
          key: const Key('resumeLater'),
          style: TextButton.styleFrom(minimumSize: const Size(64, 48)),
          onPressed: () => Get.back(result: false),
          child: Text('Later'.tr),
        ),
        FilledButton(
          key: const Key('resumeContinue'),
          style: FilledButton.styleFrom(minimumSize: const Size(64, 48)),
          onPressed: () => Get.back(result: true),
          child: Text('Continue learning'.tr),
        ),
      ],
    ));
    if (go == true) {
      await Get.toNamed(Routes.coursePlayer, arguments: {'slug': c.slug});
    } else {
      await prefs.setInt(resumeSnoozeKey, DateTime.now().add(resumeSnooze).millisecondsSinceEpoch);
    }
  }
}
