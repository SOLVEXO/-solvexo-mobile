import 'dart:async';

import 'package:book_store_app/app/data/repositories/course_repository.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

/// Course player (B1, docs §5.10 / §7). Arguments: `{slug}` (or a String).
///
/// Watch rules are client rules (the server does not enforce them):
/// - uploaded video: no seeking past the furthest point watched; the lesson
///   completes when the video ends; Next unlocks then;
/// - completed lessons are free (seek anywhere, open any time);
/// - a lesson opens only when every earlier lesson is complete;
/// - 60 s without any touch while a video plays pauses it behind
///   "Are you still there?".
/// YouTube / Vimeo play in an embed whose seek bar the app cannot police:
/// "Mark as watched" unlocks after the lesson's length (30 s if unknown).
class CoursePlayerController extends GetxController {
  CoursePlayerController({CourseRepository? repository, String? slug})
      : _repo = repository ?? CourseRepository(),
        _slugOverride = slug;

  final CourseRepository _repo;
  final String? _slugOverride;
  String slug = '';

  static const inactivityLimit = Duration(seconds: 60);

  final RxBool isLoading = true.obs;
  final RxBool failed = false.obs;
  final Rx<LearnCourse?> course = Rx<LearnCourse?>(null);
  final RxSet<String> completed = <String>{}.obs;

  final RxnString currentId = RxnString();
  final RxBool lessonLoading = false.obs;
  final RxBool lessonFailed = false.obs;
  final Rx<LessonContent?> lesson = Rx<LessonContent?>(null);
  final RxBool completing = false.obs;
  final RxBool askingStillThere = false.obs;

  /// Certificate state (B2): code once issued; details needed first.
  final RxnString certificateCode = RxnString();
  final RxBool certificateDetailsRequired = false.obs;

  VideoPlayerController? video;
  final RxInt videoTick = 0.obs; // rebuilds the controls
  Duration _maxWatched = Duration.zero;

  /// External embeds: seconds left before "Mark as watched" unlocks.
  final RxInt externalWait = 0.obs;
  Timer? _externalTimer;
  Timer? _idleTimer;

  @override
  void onInit() {
    super.onInit();
    final a = Get.arguments;
    slug = _slugOverride ?? (a is Map ? '${a['slug'] ?? ''}' : (a is String ? a : ''));
    load();
  }

  @override
  void onClose() {
    _disposeMedia();
    super.onClose();
  }

  List<CourseLessonRef> get lessons => course.value?.lessons ?? const [];
  int get percent => lessons.isEmpty ? 0 : (lessons.where((l) => completed.contains(l.id)).length * 100 / lessons.length).round();
  bool isDone(String id) => completed.contains(id);

  /// Open only when every earlier lesson is complete (completed ones are free).
  bool isUnlocked(String id) {
    for (final l in lessons) {
      if (l.id == id) return true;
      if (!completed.contains(l.id)) return false;
    }
    return false;
  }

  CourseLessonRef? get current => lessons.firstWhereOrNull((l) => l.id == currentId.value);
  CourseLessonRef? get next {
    final i = lessons.indexWhere((l) => l.id == currentId.value);
    return i >= 0 && i + 1 < lessons.length ? lessons[i + 1] : null;
  }

  bool get canGoNext => next != null && currentId.value != null && isDone(currentId.value!);

  Future<void> load() async {
    isLoading.value = true;
    failed.value = false;
    try {
      final c = await _repo.learn(slug);
      course.value = c;
      completed.assignAll(c.completed);
      certificateCode.value = c.certificateCode;
      certificateDetailsRequired.value = c.certificateDetailsRequired;
      // Resume: the server's last lesson if still open, else the first open one.
      final start = (c.lastLessonId != null && isUnlocked(c.lastLessonId!)) ? c.lastLessonId : lessons.firstWhereOrNull((l) => !isDone(l.id))?.id ?? lessons.firstOrNull?.id;
      if (start != null) await openLesson(start);
    } catch (_) {
      failed.value = true;
    }
    isLoading.value = false;
  }

  Future<void> openLesson(String id) async {
    if (!isUnlocked(id)) {
      ToastUtil.showToast('Finish the earlier lessons first.'.tr);
      return;
    }
    _disposeMedia();
    currentId.value = id;
    lesson.value = null;
    lessonFailed.value = false;
    lessonLoading.value = true;
    try {
      final l = await _repo.lesson(slug, id);
      lesson.value = l;
      if (l.isNativeVideo) {
        final v = VideoPlayerController.networkUrl(Uri.parse(l.url!));
        video = v;
        await v.initialize();
        _maxWatched = Duration.zero;
        v.addListener(_onVideo);
      } else if (l.isExternalVideo && !isDone(id)) {
        final mins = current?.durationMinutes;
        externalWait.value = mins != null && mins > 0 ? mins * 60 : 30;
        _externalTimer = Timer.periodic(const Duration(seconds: 1), (t) {
          if (externalWait.value > 0) externalWait.value--;
          if (externalWait.value <= 0) t.cancel();
        });
      }
    } catch (_) {
      lessonFailed.value = true;
    }
    lessonLoading.value = false;
  }

  void _onVideo() {
    final v = video;
    if (v == null || !v.value.isInitialized) return;
    final pos = v.value.position;
    final done = isDone(currentId.value ?? '');
    // Watching normally moves the "watched" mark forward (1.5 s tolerance).
    if (pos > _maxWatched && pos - _maxWatched < const Duration(milliseconds: 1500)) _maxWatched = pos;
    if (!done && pos > _maxWatched + const Duration(milliseconds: 1500)) {
      v.seekTo(_maxWatched); // a skip ahead (e.g. system controls) is undone
    }
    final ended = v.value.duration > Duration.zero && pos >= v.value.duration - const Duration(milliseconds: 500);
    if (ended && !done && !completing.value) markComplete();
    if (v.value.isPlaying) {
      _idleTimer ??= Timer(inactivityLimit, _stillThere);
    }
    videoTick.value++;
  }

  /// Any touch restarts the inactivity clock.
  void touched() {
    _idleTimer?.cancel();
    _idleTimer = null;
    if (video?.value.isPlaying == true) _idleTimer = Timer(inactivityLimit, _stillThere);
  }

  Future<void> _stillThere() async {
    _idleTimer = null;
    final v = video;
    if (v == null || !v.value.isPlaying || askingStillThere.value) return;
    await v.pause();
    askingStillThere.value = true;
  }

  Future<void> resumeAfterIdle() async {
    askingStillThere.value = false;
    await video?.play();
    touched();
  }

  /// Seek request from the slider: never past the watched mark unless done.
  Future<void> seek(Duration target) async {
    final v = video;
    if (v == null) return;
    final allowed = isDone(currentId.value ?? '') ? target : (target > _maxWatched ? _maxWatched : target);
    await v.seekTo(allowed);
    touched();
  }

  Duration get maxWatched => _maxWatched;

  Future<void> togglePlay() async {
    final v = video;
    if (v == null) return;
    v.value.isPlaying ? await v.pause() : await v.play();
    touched();
  }

  bool get canMarkComplete {
    final l = lesson.value;
    if (l == null || isDone(l.id) || completing.value) return false;
    if (l.isNativeVideo) return false; // completes itself at the end
    if (l.isExternalVideo) return externalWait.value <= 0;
    return l.type == 'text' || l.type == 'pdf';
  }

  Future<void> markComplete() async {
    final id = currentId.value;
    if (id == null || completing.value) return;
    completing.value = true;
    final r = await _repo.complete(slug, id);
    completing.value = false;
    if (r.error != null) {
      ToastUtil.showToast(r.error!);
      return;
    }
    final ids = r.data?['completedLessonIds'];
    if (ids is List) {
      completed.assignAll(ids.map((e) => '$e'));
    } else {
      completed.add(id);
    }
    if (r.data?['certificateCode'] is String) certificateCode.value = r.data!['certificateCode'] as String;
    if (r.data?.containsKey('certificateDetailsRequired') == true) {
      certificateDetailsRequired.value = r.data!['certificateDetailsRequired'] == true;
    }
  }

  Future<void> goNext() async {
    final n = next;
    if (n != null && canGoNext) await openLesson(n.id);
  }

  void _disposeMedia() {
    _idleTimer?.cancel();
    _idleTimer = null;
    _externalTimer?.cancel();
    _externalTimer = null;
    externalWait.value = 0;
    askingStillThere.value = false;
    final v = video;
    video = null;
    v?.removeListener(_onVideo);
    v?.dispose();
  }
}
