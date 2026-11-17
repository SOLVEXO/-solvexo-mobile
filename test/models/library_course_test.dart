import 'package:book_store_app/app/modules/library/models/library_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LibraryCourse.fromJson', () {
    test('live /api/courses/mine row (2026-11-17)', () {
      final c = LibraryCourse.fromJson({
        'productId': '6ae33f4c3da5d8d7d7033bd4',
        'name': 'Basic Computer Skills Course',
        'slug': 'basic-computer-skills-course',
        'image': 'https://res.cloudinary.com/x/w4scijrzabhc4tcvj0vi.jpg',
        'deliveryFormat': 'course',
        'lessons': 2,
        'completed': 2,
        'completedAt': '2026-10-30T07:54:17.693Z',
        'certificateCode': 'EDU-8C00AFD7',
        'percent': 100,
        'lastLessonId': 'b593bb5dbe14',
        'accessExpiresAt': '2026-11-29T07:41:22.733Z',
        'accessExpired': false,
        'isPublished': true,
      })!;
      expect(c.id, '6ae33f4c3da5d8d7d7033bd4');
      expect(c.title, 'Basic Computer Skills Course');
      expect(c.slug, 'basic-computer-skills-course');
      expect(c.image, isNotNull);
      expect(c.progress, 100);
      expect(c.lessonsTotal, 2);
      expect(c.lessonsDone, 2);
      expect(c.accessExpired, isFalse);
      expect(c.started, isTrue);
    });

    test('expired access is flagged', () {
      final c = LibraryCourse.fromJson({
        'productId': 'p1',
        'name': 'Old course',
        'percent': 10,
        'accessExpired': true,
      })!;
      expect(c.accessExpired, isTrue);
    });

    test('reads a flat row', () {
      final c = LibraryCourse.fromJson({
        '_id': 'c1',
        'title': 'Tajweed basics',
        'slug': 'tajweed-basics',
        'progress': 40,
        'completedLessons': ['a', 'b'],
        'totalLessons': 5,
      })!;
      expect(c.title, 'Tajweed basics');
      expect(c.progress, 40);
      expect(c.lessonsDone, 2);
      expect(c.started, isTrue);
    });

    test('reads nested product/course objects', () {
      final c = LibraryCourse.fromJson({
        'course': {'_id': 'c2', 'slug': 'maths-7'},
        'product': {
          'title': 'Class 7 Maths',
          'images': [
            {'url': 'https://img/x.png'}
          ],
        },
      })!;
      expect(c.id, 'c2');
      expect(c.title, 'Class 7 Maths');
      expect(c.image, 'https://img/x.png');
      expect(c.progress, isNull);
      expect(c.started, isFalse);
    });

    test('rows without id or title are skipped', () {
      expect(LibraryCourse.fromJson({'title': 'x'}), isNull);
      expect(LibraryCourse.fromJson('bad'), isNull);
    });

    test('unpublished course is flagged', () {
      final c = LibraryCourse.fromJson(
          {'_id': 'c3', 'title': 'Old', 'isPublished': false})!;
      expect(c.isPublished, isFalse);
    });
  });
}
