import 'package:book_store_app/utils/upload_rules.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('public uploads reject svg/html/js and archives', () {
    for (final f in ['a.svg', 'a.html', 'a.js', 'a.zip', 'a.epub', 'noext']) {
      expect(UploadRules.isAllowedPublic(f), isFalse, reason: f);
    }
    for (final f in ['a.JPG', 'b.mp4', 'c.pdf', 'd.docx', 'e.csv']) {
      expect(UploadRules.isAllowedPublic(f), isTrue, reason: f);
    }
  });

  test('private (sold) uploads add education formats but still reject html/js/exe', () {
    for (final f in ['a.epub', 'a.zip', 'a.pptx', 'a.numbers', 'a.mp3']) {
      expect(UploadRules.isAllowedPrivate(f), isTrue, reason: f);
    }
    for (final f in ['a.html', 'a.js', 'a.exe', 'a.apk']) {
      expect(UploadRules.isAllowedPrivate(f), isFalse, reason: f);
    }
  });

  test('content type follows the extension, never "image/<ext>"', () {
    expect(UploadRules.mimeFromExtension('x.pdf'), 'application/pdf');
    expect(UploadRules.mimeFromExtension('x.docx'), contains('wordprocessingml'));
    expect(UploadRules.mimeFromExtension('x.unknown'), 'application/octet-stream');
  });
}
