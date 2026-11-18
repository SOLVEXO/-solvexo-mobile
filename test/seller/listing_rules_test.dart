import 'package:book_store_app/app/modules/seller/utils/publish_rules.dart';
import 'package:flutter_test/flutter_test.dart';

// Same limits as backend 5adba44; live 400s (drafts, 2026-11-18):
// "Title must be at least 10 characters ... (now 5)", "Description must be
// at least 20 characters (now 5)", "Shipping weight is required",
// "Shipping weight can't be more than 50 kg".
void main() {
  test('title: normalised like the server, then >= 10', () {
    expect(ListingRules.validateTitle('Short'), contains('(now 5)'));
    expect(ListingRules.validateTitle('   Grade   5  '), contains('(now 7)'), reason: 'spaces collapsed');
    expect(ListingRules.validateTitle('<b>Grade</b> 5'), isNotNull, reason: 'tags stripped');
    expect(ListingRules.validateTitle('Grade 5 English Workbook'), isNull);
    expect(ListingRules.validateTitle(''), isNotNull);
  });

  test('description: required, >= 20', () {
    expect(ListingRules.validateDescription(''), isNotNull);
    expect(ListingRules.validateDescription('short'), contains('(now 5)'));
    expect(ListingRules.validateDescription('A long enough description here.'), isNull);
  });

  test('weight: number [kg|g], 1 g to 50 kg', () {
    expect(ListingRules.validateWeight(''), 'Shipping weight is required.');
    expect(ListingRules.validateWeight('-1 kg'), contains('negative'));
    expect(ListingRules.validateWeight('heavy'), isNotNull);
    expect(ListingRules.validateWeight('0.5g'), contains('1 g'));
    expect(ListingRules.validateWeight('60 kg'), contains('50 kg'));
    for (final ok in ['0.5 kg', '500 g', '2', '50kg', '1 G']) {
      expect(ListingRules.validateWeight(ok), isNull, reason: ok);
    }
    expect(ListingRules.parseWeightKg('500 g'), 0.5);
  });
}
