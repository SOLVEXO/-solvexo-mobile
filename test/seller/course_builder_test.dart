import 'dart:convert';
import 'dart:io';

import 'package:book_store_app/app/data/repositories/seller_course_repository.dart';
import 'package:book_store_app/app/modules/seller_course/controllers/course_builder_controller.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;

// #14a. Fixture = real PUT /api/courses/seller/:storeId/:productId response
// on the test draft (2026-11-18): one uploaded lesson, one Vimeo lesson.
final _course = jsonDecode(File('test/fixtures/course_content.json').readAsStringSync()) as Map<String, dynamic>;

class _Client extends BaseClient {
  dynamic put_;

  @override
  Future<Response> get(String url, {Map<String, dynamic>? queryParameters, dynamic data, bool requiresAuth = false, ResponseType? responseType}) async =>
      Response(requestOptions: RequestOptions(path: url), statusCode: 200, data: {'success': true, 'data': _course});

  @override
  Future<Response> put(String url, {dynamic data, Map<String, dynamic>? queryParameters, bool requiresAuth = true}) async {
    put_ = data;
    final ro = RequestOptions(path: url);
    if ((data['outcomes'] as List).length > 10) {
      throw DioException(requestOptions: ro, response: Response(requestOptions: ro, statusCode: 400, data: {
        'message': 'Add up to 10 learning outcomes', 'error': 'Bad Request', 'statusCode': 400,
      }));
    }
    return Response(requestOptions: ro, statusCode: 200, data: {'success': true, 'message': 'Course saved', 'data': {..._course, ...data as Map}});
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => Get.testMode = true);

  test('parses the real course and sends it back with ids', () {
    final c = CourseContent.fromJson(_course);
    expect(c.productName, startsWith('TEST DRAFT'));
    expect(c.accessDays, isNull, reason: 'null = lifetime');
    final up = c.sections.single.lessons.first;
    expect(up.isUpload, isTrue);
    expect(up.sourceLabel, 'Video: test-lesson.mp4');
    expect(c.sections.single.lessons.last.sourceLabel, 'Vimeo link');

    final body = c.toBody();
    final s = (body['sections'] as List).single as Map;
    expect(s['_id'], '956cc9252265');
    final lessons = s['lessons'] as List;
    expect(lessons.first, {
      '_id': '38820db42282',
      'title': 'Uploaded renamed',
      'type': 'video',
      'file': {
        'url': 'r2/private/digital-products/b1846d05-fde3-46a8-ba7d-4283146646ae-test-lesson.mp4',
        'name': 'test-lesson.mp4',
        'size': 2239,
        'mimeType': 'video/mp4',
      },
      'isPreview': false,
    });
    expect(lessons.last['videoUrl'], 'https://vimeo.com/76979871');
    expect(body['accessDays'], isNull);
    expect((body['certificateConfig'] as Map).keys, containsAll(CourseContent.certificateKeys));
  });

  test('older pdf/text/quiz lessons go back unchanged', () {
    final legacy = CourseLesson.fromJson({'_id': 'old1', 'title': 'Worksheet', 'type': 'pdf', 'file': {'url': 'r2/x.pdf'}, 'text': '', 'quiz': null});
    expect(legacy.isLegacy, isTrue);
    legacy.title = 'Worksheet 1';
    expect(legacy.toJson(), {'_id': 'old1', 'title': 'Worksheet 1', 'type': 'pdf', 'file': {'url': 'r2/x.pdf'}, 'text': '', 'quiz': null, 'isPreview': false});
  });

  test('link and field rules match the API', () {
    expect(CourseLesson.validateLink('https://www.youtube.com/watch?v=dQw4w9WgXcQ'), isNull);
    expect(CourseLesson.validateLink('https://youtu.be/dQw4w9WgXcQ'), isNull);
    expect(CourseLesson.validateLink('https://vimeo.com/76979871'), isNull);
    expect(CourseLesson.validateLink('http://youtube.com/x'), isNotNull);
    expect(CourseLesson.validateLink('https://example.com/a'), isNotNull);

    final c = CourseContent.fromJson(_course);
    expect(c.validate(), isNull);
    c.accessDays = 0;
    expect(c.validate(), contains('1-3650'));
    c.accessDays = 30;
    c.outcomes.addAll(List.filled(11, 'x'));
    expect(c.validate(), 'Add up to 10 learning outcomes.');
    c.outcomes.clear();
    c.certificate['watermarkText'] = 'w' * 41;
    expect(c.validate(), contains('40'));
    c.certificate['watermarkText'] = null;
    c.sections.single.lessons.add(CourseLesson(title: 'No video'));
    expect(c.validate(), contains('upload the video or paste a YouTube/Vimeo link'));
    expect(CourseBuilderController.validateAccessDays('3651'), isNotNull);
    expect(CourseBuilderController.validateAccessDays('365'), isNull);
  });

  test('controller edits locally and saves one PUT', () async {
    final client = _Client();
    final ctrl = CourseBuilderController(repository: SellerCourseRepository(client: client), storeId: 's1', productId: 'p1');
    await ctrl.load();
    expect(ctrl.dirty.value, isFalse);
    ctrl.addSection('Week 2');
    ctrl.putLesson(1, CourseLesson(title: 'Intro', videoUrl: 'https://youtu.be/dQw4w9WgXcQ', isPreview: true));
    ctrl.moveSection(1, -1);
    ctrl.setAccessDays(90);
    ctrl.setOutcomes(['Read faster', '  ', 'Spell better']);
    expect(ctrl.dirty.value, isTrue);
    expect(await ctrl.save(), isTrue);
    final sections = client.put_['sections'] as List;
    expect(sections.first['title'], 'Week 2');
    expect(sections.first['lessons'].single, {'title': 'Intro', 'type': 'video', 'videoUrl': 'https://youtu.be/dQw4w9WgXcQ', 'isPreview': true});
    expect(client.put_['accessDays'], 90);
    expect(client.put_['outcomes'], ['Read faster', 'Spell better']);
    expect(ctrl.dirty.value, isFalse);
  });
}
