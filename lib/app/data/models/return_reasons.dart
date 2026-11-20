import 'package:get/get.dart';

/// The ONE reason list for returns and refunds (docs §2.7; backend 5adba44
/// refund-evidence.util.ts REFUND_REASON_CODES). Labels are the server's.
const List<(String, String)> kReturnReasons = [
  ('damaged', 'Item arrived damaged'),
  ('missing_pages', 'Missing pages or parts'),
  ('printing_error', 'Printing error'),
  ('wrong_item', 'Wrong item received'),
  ('wrong_edition_or_class', 'Wrong edition or class'),
  ('not_as_described', 'Not as described'),
  ('digital_not_working', 'Digital file is not working'),
  ('other', 'Other'),
];

/// Codes stored by older versions: shown, never sent.
const Map<String, String> kLegacyReturnReasons = {
  'incomplete': 'Incomplete (missing parts or pages)',
  'cant_access_file': "Can't access the digital file",
};

String returnReasonLabel(String? code, [String? freeText]) {
  for (final r in kReturnReasons) {
    if (r.$1 == code) return r.$2.tr;
  }
  return kLegacyReturnReasons[code] ?? (freeText ?? '');
}

class ReturnRules {
  ReturnRules._();
  static const noteMin = 20, noteMax = 1000, maxPhotos = 4;

  static String? note(String v) {
    final n = v.trim().length;
    if (n < noteMin) return '${'Please describe the problem in at least'.tr} $noteMin ${'characters'.tr} ($n)';
    if (n > noteMax) return '${'Use at most'.tr} $noteMax ${'characters'.tr}';
    return null;
  }

  /// Digital items only allow the "digital file" and "other" reasons.
  static List<(String, String)> reasonsFor({required bool digital}) => digital
      ? kReturnReasons.where((r) => r.$1 == 'digital_not_working' || r.$1 == 'not_as_described' || r.$1 == 'other').toList()
      : kReturnReasons.where((r) => r.$1 != 'digital_not_working').toList();
}
