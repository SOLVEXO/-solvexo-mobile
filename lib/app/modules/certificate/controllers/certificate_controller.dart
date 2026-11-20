import 'dart:typed_data';

import 'package:book_store_app/app/data/repositories/course_repository.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

/// Public certificate view (B2): GET /api/courses/certificates/:code.
/// Arguments: {code}. Also the target of the /certificates/:code deep link.
class CertificateController extends GetxController {
  CertificateController({CourseRepository? repository, String? code})
      : _repo = repository ?? CourseRepository(),
        _codeOverride = code;

  final CourseRepository _repo;
  final String? _codeOverride;
  String code = '';

  final RxBool isLoading = true.obs;
  final RxBool notFound = false.obs;
  final RxBool failed = false.obs;
  final RxBool sharing = false.obs;
  final Rx<CourseCertificate?> cert = Rx<CourseCertificate?>(null);

  @override
  void onInit() {
    super.onInit();
    final a = Get.arguments;
    code = _codeOverride ?? (a is Map ? '${a['code'] ?? ''}' : (a is String ? a : ''));
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    failed.value = false;
    notFound.value = false;
    try {
      cert.value = await _repo.certificate(code);
    } on DioException catch (e) {
      e.response?.statusCode == 404 ? notFound.value = true : failed.value = true;
    } catch (_) {
      failed.value = true;
    }
    isLoading.value = false;
  }

  static String dateText(DateTime? d) => d == null ? '' : DateFormat('d MMMM y').format(d);

  /// A4 landscape PDF, shared through the system sheet (save to Files etc.).
  Future<void> sharePdf() async {
    final c = cert.value;
    if (c == null || sharing.value) return;
    sharing.value = true;
    try {
      final bytes = await buildPdf(c);
      await SharePlus.instance.share(ShareParams(
        files: [XFile.fromData(bytes, name: 'certificate-${c.code}.pdf', mimeType: 'application/pdf')],
        subject: c.courseName,
      ));
    } catch (_) {
      ToastUtil.showToast('Could not create the PDF.'.tr);
    } finally {
      sharing.value = false;
    }
  }

  static Future<Uint8List?> _image(String? url) async {
    if (url == null) return null;
    try {
      final r = await Dio().get<List<int>>(url, options: Options(responseType: ResponseType.bytes));
      return Uint8List.fromList(r.data ?? const []);
    } catch (_) {
      return null; // a missing image never blocks the certificate
    }
  }

  static Future<Uint8List> buildPdf(CourseCertificate c) async {
    final images = await Future.wait([
      _image(c.c('watermarkImageUrl')),
      _image(c.c('stampImageUrl')),
      _image(c.c('signatureImageUrl')),
      _image(c.s('storeLogoUrl')),
    ]);
    pw.ImageProvider? img(Uint8List? b) => b == null || b.isEmpty ? null : pw.MemoryImage(b);
    final watermark = img(images[0]), stamp = img(images[1]), signature = img(images[2]), logo = img(images[3]);
    final doc = pw.Document();
    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4.landscape,
      margin: const pw.EdgeInsets.all(28),
      build: (_) => pw.Container(
        decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.blueGrey800, width: 3)),
        padding: const pw.EdgeInsets.all(28),
        child: pw.Stack(children: [
          if (watermark != null) pw.Center(child: pw.Opacity(opacity: 0.08, child: pw.Image(watermark, width: 320))),
          if (c.c('watermarkText') != null)
            pw.Center(
              child: pw.Transform.rotate(
                angle: 0.35,
                child: pw.Text(c.c('watermarkText')!, style: pw.TextStyle(fontSize: 60, color: PdfColors.grey200)),
              ),
            ),
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
            if (logo != null) pw.Image(logo, height: 48),
            pw.SizedBox(height: 8),
            pw.Text('Certificate of Completion', style: pw.TextStyle(fontSize: 30, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 18),
            pw.Text('This certifies that', style: const pw.TextStyle(fontSize: 13)),
            pw.SizedBox(height: 6),
            pw.Text(c.learnerName, style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold)),
            if (c.s('guardianName') != null) pw.Text('Son/Daughter of ${c.s('guardianName')}', style: const pw.TextStyle(fontSize: 11)),
            if (c.s('institute') != null) pw.Text(c.s('institute')!, style: const pw.TextStyle(fontSize: 11)),
            pw.SizedBox(height: 12),
            pw.Text('has completed the course', style: const pw.TextStyle(fontSize: 13)),
            pw.SizedBox(height: 6),
            pw.Text(c.courseName, textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.Text('${c.s('storeName') ?? ''}  ·  ${dateText(c.issuedAt)}', style: const pw.TextStyle(fontSize: 11)),
            pw.Spacer(),
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
              pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                if (signature != null) pw.Image(signature, height: 40),
                pw.Text(c.c('signatureName') ?? c.s('instructorName') ?? '', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                if (c.c('signatureTitle') != null) pw.Text(c.c('signatureTitle')!, style: const pw.TextStyle(fontSize: 10)),
              ]),
              if (stamp != null) pw.Image(stamp, height: 70),
              pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
                pw.Text(c.c('issuerName') ?? c.s('storeName') ?? '', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text('Certificate ${c.code}', style: const pw.TextStyle(fontSize: 10)),
                pw.Text('Verify at edudeen.com/certificates/${c.code}', style: const pw.TextStyle(fontSize: 9)),
              ]),
            ]),
          ]),
        ]),
      ),
    ));
    return doc.save();
  }
}

/// Details form before the first certificate (POST .../certificate-details).
/// Limits from backend 5adba44 course.util.ts cleanCertificateDetails.
class CertificateDetailsController extends GetxController {
  CertificateDetailsController({CourseRepository? repository, String? slug})
      : _repo = repository ?? CourseRepository(),
        _slugOverride = slug;

  final CourseRepository _repo;
  final String? _slugOverride;
  String slug = '';

  final fullName = TextEditingController();
  final guardianName = TextEditingController();
  final institute = TextEditingController();
  final city = TextEditingController();
  final country = TextEditingController(text: 'Pakistan');
  final RxMap<String, String> errors = <String, String>{}.obs;
  final RxBool saving = false.obs;

  static const limits = {'fullName': 80, 'guardianName': 80, 'institute': 120, 'city': 60, 'country': 60};

  @override
  void onInit() {
    super.onInit();
    final a = Get.arguments;
    slug = _slugOverride ?? (a is Map ? '${a['slug'] ?? ''}' : '');
  }

  @override
  void onClose() {
    for (final c in [fullName, guardianName, institute, city, country]) {
      c.dispose();
    }
    super.onClose();
  }

  Map<String, String> get values => {
        'fullName': fullName.text.trim(),
        'guardianName': guardianName.text.trim(),
        'institute': institute.text.trim(),
        'city': city.text.trim(),
        'country': country.text.trim(),
      };

  bool validate() {
    final e = <String, String>{};
    final v = values;
    if (v['fullName']!.length < 2 || v['fullName']!.length > 80) e['fullName'] = 'Full name must be 2-80 characters'.tr;
    for (final k in limits.keys.where((k) => k != 'fullName')) {
      if (v[k]!.length > limits[k]!) e[k] = '${'Use at most'.tr} ${limits[k]} ${'characters'.tr}';
    }
    errors.assignAll(e);
    return e.isEmpty;
  }

  /// Returns the issued certificate code (or '' when only saved).
  Future<void> submit() async {
    if (!validate() || saving.value) return;
    saving.value = true;
    final r = await _repo.saveCertificateDetails(slug, values);
    saving.value = false;
    if (r.error != null) {
      ToastUtil.showToast(r.error!);
      return;
    }
    Get.back(result: r.code ?? '');
  }
}
