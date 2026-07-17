import 'package:book_store_app/app/modules/ai_studio/controllers/listing_writer_controller.dart';
import 'package:get/get.dart';

class ListingWriterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ListingWriterController>(() => ListingWriterController());
  }
}
