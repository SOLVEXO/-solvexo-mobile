import 'dart:convert';
import 'dart:io';

import 'package:book_store_app/app/data/repositories/course_repository.dart';
import 'package:book_store_app/app/modules/certificate/controllers/certificate_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

// Live public GET /api/courses/certificates/EDU-8C00AFD7 (2026-11-20).
final _cert = jsonDecode(File('test/fixtures/course_certificate.json').readAsStringSync())['data'] as Map<String, dynamic>;

class _Repo extends CourseRepository {
  Map<String, String>? sent;
  @override
  Future<({String? code, String? error})> saveCertificateDetails(String idOrSlug, Map<String, String> details) async {
    sent = details;
    return (code: 'EDU-NEW', error: null);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => Get.testMode = true);

  test('certificate fields and design config', () {
    final c = CourseCertificate.fromJson(_cert);
    expect(c.code, 'EDU-8C00AFD7');
    expect(c.learnerName, isNotEmpty);
    expect(c.courseName, 'Basic Computer Skills Course');
    expect(c.c('signatureTitle'), 'Course Instructor');
    expect(c.c('watermarkText'), isNull);
    expect(c.s('storeLogoUrl'), isNull, reason: 'empty string = no logo');
    expect(c.issuedAt, isNotNull);
  });

  test('A4 landscape PDF builds without network images', () async {
    final noImages = Map<String, dynamic>.from(_cert)
      ..['config'] = {...(_cert['config'] as Map), 'watermarkImageUrl': null, 'stampImageUrl': null, 'signatureImageUrl': null};
    final bytes = await CertificateController.buildPdf(CourseCertificate.fromJson(noImages));
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
  });

  test('details form: same limits as the API', () async {
    final repo = _Repo();
    final c = CertificateDetailsController(repository: repo, slug: 'basic');
    c.fullName.text = 'X';
    expect(c.validate(), isFalse);
    expect(c.errors['fullName'], isNotNull);
    c.fullName.text = 'Ali Khan';
    c.institute.text = 'x' * 121;
    expect(c.validate(), isFalse);
    c.institute.text = 'Deenway School';
    expect(c.validate(), isTrue);
    expect(c.values['country'], 'Pakistan');
  });
}
