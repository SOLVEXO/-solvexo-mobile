import 'package:book_store_app/app/modules/certificate/controllers/certificate_controller.dart';
import 'package:get/get.dart';

class CertificateBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut<CertificateController>(() => CertificateController());
}

class CertificateDetailsBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut<CertificateDetailsController>(() => CertificateDetailsController());
}
