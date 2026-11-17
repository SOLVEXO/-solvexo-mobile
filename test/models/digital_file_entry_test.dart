import 'package:book_store_app/app/modules/add_seller_product/controllers/add_seller_product_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('digital file payload carries the upload reference as `url` (what the API reads)', () {
    final e = DigitalFileEntry();
    e.publicId.value = 'private/digital-products/abc';
    e.fileName.value = 'worksheet.pdf';
    final json = e.toJson();
    expect(json['url'], 'private/digital-products/abc');
    expect(json['name'], 'worksheet.pdf');
  });
}
