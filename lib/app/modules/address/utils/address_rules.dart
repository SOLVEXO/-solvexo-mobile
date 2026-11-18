import 'package:get/get.dart';

/// Pakistani address rules, the same as backend 5adba44
/// (src/address/address.service.ts addressFieldError / pickAddressUpdate):
/// required phoneNumber, zipCode, city, addressLine1, state; every text
/// field at most 200 characters. A 400 carries `{message, errors: {field:
/// message}}`.
class AddressRules {
  AddressRules._();

  /// Exactly as the API accepts them (case-sensitive).
  static const provinces = [
    'Sindh',
    'Punjab',
    'Khyber Pakhtunkhwa',
    'Balochistan',
    'Islamabad Capital Territory',
    'Gilgit-Baltistan',
    'Azad Kashmir',
  ];

  static const maxLength = 200;

  /// 03XXXXXXXXX / +923XXXXXXXXX / 923XXXXXXXXX (spaces and dashes
  /// ignored) -> +923XXXXXXXXX, else null. Same as normalizePkPhone.
  static String? normalizePhone(String raw) {
    final s = raw.replaceAll(RegExp(r'[\s-]'), '');
    final m = RegExp(r'^(?:\+92|92|0)(3\d{9})$').firstMatch(s);
    return m == null ? null : '+92${m.group(1)}';
  }

  /// The province from the list that matches [raw] ignoring case and
  /// spacing (e.g. a map pick "punjab"), else null.
  static String? matchProvince(String raw) {
    final n = raw.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
    for (final p in provinces) {
      if (p.toLowerCase() == n) return p;
    }
    return null;
  }

  static String? _len(String v) => v.length > maxLength ? 'Use at most $maxLength characters.'.tr : null;

  static String? recipient(String v) => v.trim().isEmpty ? 'Recipient name is required'.tr : _len(v);

  static String? phone(String v) {
    if (v.trim().isEmpty) return 'Phone number is required'.tr;
    return normalizePhone(v.trim()) == null
        ? 'Enter a valid Pakistani mobile number (03XXXXXXXXX or +923XXXXXXXXX)'.tr
        : null;
  }

  static String? line1(String v) {
    if (v.trim().isEmpty) return 'Address is required'.tr;
    if (v.trim().length < 5) return 'Address must be at least 5 characters'.tr;
    return _len(v);
  }

  static String? line2(String v) => _len(v);

  static String? city(String v) {
    final t = v.trim();
    if (t.isEmpty) return 'City is required'.tr;
    if (t.length < 2 || !RegExp(r'^\p{L}[\p{L} ]*$', unicode: true).hasMatch(t)) {
      return 'City must be letters and spaces, at least 2 characters'.tr;
    }
    return _len(v);
  }

  static String? state(String v) {
    if (v.trim().isEmpty) return 'Select a province'.tr;
    return provinces.contains(v.trim()) ? null : 'Select a valid province'.tr;
  }

  static String? zip(String v) {
    if (v.trim().isEmpty) return 'Postal code is required'.tr;
    return RegExp(r'^\d{5}$').hasMatch(v.trim()) ? null : 'Postal code must be exactly 5 digits'.tr;
  }

  static String? country(String v) => _len(v);
}
