import 'dart:convert';
import 'dart:io';

import 'package:book_store_app/app/data/repositories/course_repository.dart';
import 'package:book_store_app/app/modules/course_player/controllers/course_player_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

// Live GET /api/courses/learn/basic-computer-skills-course and a lesson,
// as the test buyer (2026-11-20).
Map<String, dynamic> _f(String n) => jsonDecode(File('test/fixtures/$n.json').readAsStringSync())['data'] as Map<String, dynamic>;

class _Repo extends CourseRepository {
  _Repo(this.course);
  final Map<String, dynamic> course;
  final completedCalls = <String>[];
  @override
  Future<LearnCourse> learn(String idOrSlug) async => LearnCourse.fromJson(course);
  @override
  Future<LessonContent> lesson(String idOrSlug, String lessonId) async =>
      LessonContent.fromJson({'_id': lessonId, 'title': 'L', 'type': 'text', 'text': 'Read me'});
  @override
  Future<({Map? data, String? error})> complete(String idOrSlug, String lessonId) async {
    completedCalls.add(lessonId);
    return (data: {'completedLessonIds': [lessonId], 'certificateCode': null, 'certificateDetailsRequired': false}, error: null);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => Get.testMode = true);

  test('learn payload: sections, progress, resume point, certificate', () {
    final c = LearnCourse.fromJson(_f('course_learn'));
    expect(c.slug, 'basic-computer-skills-course');
    expect(c.lessons.map((l) => l.id), ['7050ecba2df2', 'b593bb5dbe14']);
    expect(c.lastLessonId, 'b593bb5dbe14');
    expect(c.certificateCode, 'EDU-8C00AFD7');
    expect(c.isFinished, isTrue);
  });

  test('lesson payload: uploaded file is a native video', () {
    final l = LessonContent.fromJson(_f('course_lesson'));
    expect(l.isNativeVideo, isTrue);
    expect(l.isExternalVideo, isFalse);
  });

  test('YouTube / Vimeo links become embed URLs', () {
    expect(LessonContent.embedUrl('https://www.youtube.com/watch?v=dQw4w9WgXcQ'), startsWith('https://www.youtube.com/embed/dQw4w9WgXcQ'));
    expect(LessonContent.embedUrl('https://youtu.be/dQw4w9WgXcQ'), startsWith('https://www.youtube.com/embed/dQw4w9WgXcQ'));
    expect(LessonContent.embedUrl('https://vimeo.com/76979871'), 'https://player.vimeo.com/video/76979871');
    expect(LessonContent.embedUrl('https://example.com/x'), isNull);
  });

  test('lessons open in order; Next locked until the current one is done', () async {
    final fresh = Map<String, dynamic>.from(_f('course_learn'))..['progress'] = {'completedLessonIds': [], 'lastLessonId': null};
    final repo = _Repo(fresh);
    final c = CoursePlayerController(repository: repo, slug: 'basic-computer-skills-course');
    await c.load();
    expect(c.currentId.value, '7050ecba2df2');
    expect(c.isUnlocked('b593bb5dbe14'), isFalse);
    expect(c.canGoNext, isFalse);
    expect(c.canMarkComplete, isTrue, reason: 'text lesson');
    await c.markComplete();
    expect(repo.completedCalls, ['7050ecba2df2']);
    expect(c.canGoNext, isTrue);
    expect(c.percent, 50);
    await c.goNext();
    expect(c.currentId.value, 'b593bb5dbe14');
    c.onClose();
  });

  test('a finished course reopens on the server resume lesson; all free', () async {
    final c = CoursePlayerController(repository: _Repo(_f('course_learn')), slug: 'x');
    await c.load();
    expect(c.currentId.value, 'b593bb5dbe14');
    expect(c.isUnlocked('7050ecba2df2'), isTrue);
    c.onClose();
  });
}
