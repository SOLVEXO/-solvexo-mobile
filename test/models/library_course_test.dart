import 'package:book_store_app/app/modules/library/models/library_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LibraryCourse.fromJson', () {
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
