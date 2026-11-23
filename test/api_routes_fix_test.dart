import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:flutter_test/flutter_test.dart';

// Found by the local end-to-end run (jami-branch API).
void main() {
  test('testimonials use GET /api/testimonials (was /store/public/testimonials -> 404)', () {
    expect(ApiConstants.publicTestimonials(limit: 6), endsWith('/api/testimonials?limit=6'));
  });
}
