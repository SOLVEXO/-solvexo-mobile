import 'package:book_store_app/app/components/buyer_states.dart';
import 'package:book_store_app/app/data/repositories/course_repository.dart';
import 'package:book_store_app/app/modules/certificate/controllers/certificate_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Certificate (public verify view) - A4 landscape preview + PDF share.
class CertificateView extends GetView<CertificateController> {
  const CertificateView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Certificate'.tr)),
      body: Obx(() {
        if (controller.isLoading.value) return const BuyerSkeleton(rows: 2, rowHeight: 200);
        if (controller.notFound.value) {
          return BuyerEmpty(icon: Icons.gpp_bad_outlined, title: 'No certificate with that code'.tr, body: controller.code);
        }
        if (controller.failed.value || controller.cert.value == null) {
          return BuyerError(message: 'Could not load the certificate.'.tr, onRetry: controller.load);
        }
        final c = controller.cert.value!;
        return ListView(padding: const EdgeInsets.all(16), children: [
          Row(children: [
            Icon(Icons.verified_rounded, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(child: Text('${'Verified certificate'.tr} · ${c.code}', key: const Key('certVerified'))),
          ]),
          const SizedBox(height: 12),
          _CertificateCanvas(cert: c),
          const SizedBox(height: 16),
          FilledButton.icon(
            key: const Key('certPdf'),
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            onPressed: controller.sharing.value ? null : controller.sharePdf,
            icon: controller.sharing.value
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.picture_as_pdf_outlined),
            label: Text('Save or share as PDF'.tr),
          ),
        ]);
      }),
    );
  }
}

/// On-screen copy of the PDF layout. Always LTR (a printed document).
class _CertificateCanvas extends StatelessWidget {
  const _CertificateCanvas({required this.cert});
  final CourseCertificate cert;

  Widget _img(String? url, double h) =>
      url == null ? SizedBox(height: h) : CachedNetworkImage(imageUrl: url, height: h, fit: BoxFit.contain, errorWidget: (_, __, ___) => SizedBox(height: h));

  @override
  Widget build(BuildContext context) {
    final c = cert;
    const dark = Color(0xFF263238);
    TextStyle s(double size, {bool bold = false}) => TextStyle(fontSize: size, color: dark, fontWeight: bold ? FontWeight.w700 : FontWeight.w400);
    return Directionality(
      textDirection: TextDirection.ltr,
      child: AspectRatio(
        aspectRatio: 297 / 210,
        child: Container(
          key: const Key('certCanvas'),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: dark, width: 2)),
          child: FittedBox(
            child: SizedBox(
              width: 842,
              height: 595,
              child: Stack(children: [
                if (c.c('watermarkImageUrl') != null)
                  Center(child: Opacity(opacity: 0.08, child: _img(c.c('watermarkImageUrl'), 320))),
                if (c.c('watermarkText') != null)
                  Center(child: Transform.rotate(angle: -0.35, child: Text(c.c('watermarkText')!, style: const TextStyle(fontSize: 60, color: Color(0x14000000))))),
                Padding(
                  padding: const EdgeInsets.all(36),
                  child: Column(children: [
                    if (c.s('storeLogoUrl') != null) _img(c.s('storeLogoUrl'), 48),
                    const SizedBox(height: 8),
                    Text('Certificate of Completion', style: s(34, bold: true)),
                    const SizedBox(height: 18),
                    Text('This certifies that', style: s(15)),
                    const SizedBox(height: 6),
                    Text(c.learnerName, style: s(30, bold: true)),
                    if (c.s('guardianName') != null) Text('Son/Daughter of ${c.s('guardianName')}', style: s(13)),
                    if (c.s('institute') != null) Text(c.s('institute')!, style: s(13)),
                    const SizedBox(height: 12),
                    Text('has completed the course', style: s(15)),
                    const SizedBox(height: 6),
                    Text(c.courseName, textAlign: TextAlign.center, style: s(22, bold: true)),
                    Text('${c.s('storeName') ?? ''}  ·  ${CertificateController.dateText(c.issuedAt)}', style: s(13)),
                    const Spacer(),
                    Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                          _img(c.c('signatureImageUrl'), 40),
                          Text(c.c('signatureName') ?? c.s('instructorName') ?? '', style: s(14, bold: true)),
                          if (c.c('signatureTitle') != null) Text(c.c('signatureTitle')!, style: s(12)),
                        ]),
                      ),
                      _img(c.c('stampImageUrl'), 80),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.end, mainAxisSize: MainAxisSize.min, children: [
                          Text(c.c('issuerName') ?? c.s('storeName') ?? '', style: s(14, bold: true)),
                          Text('Certificate ${c.code}', style: s(12)),
                        ]),
                      ),
                    ]),
                  ]),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

/// Details form (needed once, before the first certificate).
class CertificateDetailsView extends GetView<CertificateDetailsController> {
  const CertificateDetailsView({super.key});

  Widget _field(TextEditingController c, String key, String label, {bool required = false}) => Obx(() => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(
          key: Key('cert_$key'),
          controller: c,
          maxLength: CertificateDetailsController.limits[key],
          onChanged: (_) => controller.errors.remove(key),
          decoration: InputDecoration(
            labelText: required ? '$label *' : label,
            errorText: controller.errors[key],
            border: const OutlineInputBorder(),
          ),
        ),
      ));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Certificate details'.tr)),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Text('These details are printed on your certificate and cannot be changed after it is issued.'.tr),
        const SizedBox(height: 16),
        _field(controller.fullName, 'fullName', 'Full name'.tr, required: true),
        _field(controller.guardianName, 'guardianName', 'Parent / guardian name'.tr),
        _field(controller.institute, 'institute', 'School / institute'.tr),
        _field(controller.city, 'city', 'City'.tr),
        _field(controller.country, 'country', 'Country'.tr),
        Obx(() => FilledButton(
              key: const Key('certSubmit'),
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              onPressed: controller.saving.value ? null : controller.submit,
              child: controller.saving.value
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text('Save'.tr),
            )),
      ]),
    );
  }
}
