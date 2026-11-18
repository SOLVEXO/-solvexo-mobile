import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// Backend 5adba44: OTP_TTL_SECONDS = 5 * 60; plan lapse statuses
// expired | past_due | canceled.
void main() {
  test('OTP screen says 5 minutes', () {
    final src = File('lib/app/modules/otp/views/otp_view.dart').readAsStringSync();
    expect(src, contains('expires in 5 minutes'));
    expect(src, isNot(contains('10 minutes')));
  });

  test('expired plan is labelled Expired', () {
    final src = File('lib/app/modules/seller_platform_plans/widgets/platform_plan_widgets.dart').readAsStringSync();
    expect(src, contains("'expired' => 'Expired'"));
  });
}
