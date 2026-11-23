/// Product publish fields the API requires (docs Part B 1, 4, 6.3):
/// `coverStyle` (book | flat) to go live, and `classFrom/classTo` to publish
/// a digital product.
///
/// Class slugs verified against the live API on 2026-11-17: the public
/// `products-by-category?class=` filter recognises exactly these (unknown
/// slugs are ignored), and stored products use them in `classFrom/classTo`.
/// Order = nursery → class-12 → O/A level → university (docs 5.3).
class ClassLevel {
  const ClassLevel(this.slug, this.label);
  final String slug;
  final String label;
}

const List<ClassLevel> kClassLevels = [
  ClassLevel('nursery', 'Nursery'),
  ClassLevel('kg', 'KG'),
  ClassLevel('prep', 'Prep'),
  ClassLevel('class-1', 'Class 1'),
  ClassLevel('class-2', 'Class 2'),
  ClassLevel('class-3', 'Class 3'),
  ClassLevel('class-4', 'Class 4'),
  ClassLevel('class-5', 'Class 5'),
  ClassLevel('class-6', 'Class 6'),
  ClassLevel('class-7', 'Class 7'),
  ClassLevel('class-8', 'Class 8'),
  ClassLevel('class-9', 'Class 9'),
  ClassLevel('class-10', 'Class 10'),
  ClassLevel('class-11', 'Class 11'),
  ClassLevel('class-12', 'Class 12'),
  ClassLevel('o-level', 'O Level'),
  ClassLevel('a-level', 'A Level'),
  ClassLevel('university', 'University'),
];

/// Product card style shown to buyers (`Product.coverStyle`).
const List<ClassLevel> kCoverStyles = [
  ClassLevel('book', 'Book cover'),
  ClassLevel('flat', 'Flat'),
];

class PublishRules {
  PublishRules._();

  static int classIndex(String? slug) =>
      kClassLevels.indexWhere((c) => c.slug == slug);

  static String classLabel(String? slug) {
    final i = classIndex(slug);
    return i < 0 ? (slug ?? '') : kClassLevels[i].label;
  }

  /// Known slug or null (legacy/unknown values are not re-sent).
  static String? knownClass(String? slug) => classIndex(slug) < 0 ? null : slug;

  static String? knownCoverStyle(String? v) =>
      kCoverStyles.any((c) => c.slug == v) ? v : null;

  /// Class range on its own: both or neither, and in order.
  /// Mirrors the API's "classFrom cannot be after classTo" (400).
  static String? classRangeError(String? from, String? to) {
    if (from == null && to == null) return null;
    if (from == null || to == null) return 'Pick both "From" and "To" classes.';
    if (classIndex(from) > classIndex(to)) {
      return '"From" class cannot be after "To" class.';
    }
    return null;
  }

  /// Same text as the server's 400 (products.service.ts
  /// FREE_SAMPLE_REQUIRED_MESSAGE).
  static const freeSampleRequired =
      'Add a free sample file before publishing a digital product. You can save it as a draft without one.';

  /// First problem that blocks saving with [status]
  /// ('active' | 'scheduled' | 'draft'), or null when OK.
  /// Drafts only need a valid range when one is given.
  static String? validate({
    required String status,
    required bool isDigital,
    required String? coverStyle,
    required String? classFrom,
    required String? classTo,
    bool hasSample = false,
  }) {
    final range = classRangeError(classFrom, classTo);
    if (range != null) return range;
    if (status == 'draft') return null;
    if (coverStyle == null) {
      return 'Choose a product card style (Book cover or Flat) to go live.';
    }
    if (isDigital && (classFrom == null || classTo == null)) {
      return 'Choose the class range to publish a digital product.';
    }
    // Checklist #3, docs Part B 2.9: a free sample is required to publish
    // digital (stored as `digital.sampleFile`). The server enforces the same
    // rule since backend fix #4 (jami-branch) with this exact message, so the
    // seller reads one text whether the app or the server catches it; a
    // server 400 is shown by DioExceptionHandler.
    if (isDigital && !hasSample) return freeSampleRequired;
    return null;
  }
}

/// Listing text and weight rules the API enforces on create, drafts
/// included (backend 5adba44):
/// - title: tags stripped, spaces collapsed, then >= 10 characters
///   (product-quality.util.ts normalizeTitle / assertTitleRule)
/// - description: required, >= 20 characters (price-rules.util.ts
///   assertDescriptionRule)
/// - physical variant shippingWeight: required, `"<number> [kg|g]"`, 1 g to
///   50 kg (price-rules.util.ts parseWeightKg / cleanShippingWeight).
class ListingRules {
  ListingRules._();

  static const minTitle = 10;
  static const minDescription = 20;
  static const minWeightKg = 0.001;
  static const maxWeightKg = 50.0;

  static String normalizeTitle(String raw) =>
      raw.replaceAll(RegExp(r'<[^>]*>'), ' ').replaceAll(RegExp('[<>]'), '').replaceAll(RegExp(r'\s+'), ' ').trim();

  static String? validateTitle(String raw) {
    final len = normalizeTitle(raw).length;
    if (len == 0) return 'Add a product name.';
    if (len < minTitle) return 'Use at least $minTitle characters so buyers know what it is (now $len).';
    return null;
  }

  static String? validateDescription(String raw) {
    final len = raw.trim().length;
    if (len == 0) return 'Add a description.';
    if (len < minDescription) return 'Use at least $minDescription characters (now $len).';
    return null;
  }

  /// kg, or null when the text is not `"<number> [kg|g]"`.
  static double? parseWeightKg(String raw) {
    final m = RegExp(r'^\s*(\d+(?:\.\d+)?)\s*(kg|g)?\s*$', caseSensitive: false).firstMatch(raw);
    if (m == null) return null;
    final n = double.parse(m.group(1)!);
    return (m.group(2) ?? 'kg').toLowerCase() == 'g' ? n / 1000 : n;
  }

  static String? validateWeight(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return 'Shipping weight is required.';
    if (RegExp(r'^\s*-\s*\d').hasMatch(t)) return "Shipping weight can't be negative.";
    final kg = parseWeightKg(t);
    if (kg == null) return 'Use a number, e.g. 0.5 kg or 500 g.';
    if (kg < minWeightKg - 1e-12) return 'Minimum weight is 1 g.';
    if (kg > maxWeightKg) return "Shipping weight can't be more than 50 kg.";
    return null;
  }
}
