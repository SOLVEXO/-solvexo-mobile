// import 'package:get/get.dart';
// import '../models/product_model.dart';

// class ProductDetailController extends GetxController {
//   late final ProductModel product;

//   RxInt selectedImage = 0.obs;
//   RxInt selectedVariant = 0.obs;
//   RxInt quantity = 1.obs;

//   RxBool showDescription = true.obs;
//   RxBool showMeasurements = false.obs;
//   RxBool showReviews = false.obs;

//   @override
//   void onInit() {
//     final args = Get.arguments;

//     if (args == null || args is! ProductModel) {
//       Get.back();
//       Get.snackbar(
//         "Error",
//         "Product data not found",
//         snackPosition: SnackPosition.BOTTOM,
//       );
//       return;
//     }

//     product = args;
//     super.onInit();
//   }

//   void selectVariant(int index) => selectedVariant.value = index;

//   void incrementQty() => quantity.value++;
//   void decrementQty() {
//     if (quantity.value > 1) quantity.value--;
//   }
// }
