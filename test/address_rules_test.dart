import 'package:book_store_app/app/modules/address/utils/address_rules.dart';
import 'package:flutter_test/flutter_test.dart';

// Same rules as backend 5adba44 address.service.ts. Live 400 for
// {phoneNumber:"12345", addressLine1:"abc", city:"Karachi.", state:"sindh",
//  zipCode:"123456"} returned errors for exactly these five fields.
void main() {
  test('phone: PK mobile in any of the three forms', () {
    expect(AddressRules.normalizePhone('0300-1234567'), '+923001234567');
    expect(AddressRules.normalizePhone('+92 300 1234567'), '+923001234567');
    expect(AddressRules.normalizePhone('923001234567'), '+923001234567');
    expect(AddressRules.normalizePhone('12345'), isNull);
    expect(AddressRules.normalizePhone('0421234567'), isNull, reason: 'landline');
    expect(AddressRules.phone('12345'), isNotNull);
  });

  test('the live failing body fails here too, field by field', () {
    expect(AddressRules.line1('abc'), isNotNull);
    expect(AddressRules.city('Karachi.'), isNotNull);
    expect(AddressRules.state('sindh'), isNotNull, reason: 'case-sensitive');
    expect(AddressRules.zip('123456'), isNotNull);
  });

  test('valid values pass', () {
    expect(AddressRules.line1('House 1, Street 2'), isNull);
    expect(AddressRules.city('Karachi'), isNull);
    expect(AddressRules.city('ڈیرہ غازی خان'), isNull, reason: 'letters in any script');
    expect(AddressRules.state('Sindh'), isNull);
    expect(AddressRules.zip('75500'), isNull);
    expect(AddressRules.phone('03001234567'), isNull);
  });

  test('map picks map onto the exact province names', () {
    expect(AddressRules.matchProvince('punjab'), 'Punjab');
    expect(AddressRules.matchProvince(' khyber  pakhtunkhwa '), 'Khyber Pakhtunkhwa');
    expect(AddressRules.matchProvince('Lahore'), isNull);
  });
}
