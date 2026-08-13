import 'package:book_store_app/app/data/repositories/seller_repository.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:get/get.dart';

/// Backend blocks product creation until the owning store is `active`
/// (`ProductsService.createProduct`/`createDigitalProduct` check
/// `store.status !== 'active'` — see `StoreService.createStore`, which
/// starts every new store `pending`). Checked here first so a seller with
/// an unverified store gets sent straight to verification instead of
/// filling out a whole product form only to hit a 400 on submit.
Future<void> openAddProductOrRequireVerification() async {
  final storeId = await AppPreferences.getStoreId();
  if (storeId == null || storeId.isEmpty) {
    Get.toNamed(Routes.addSellerProduct);
    return;
  }

  final store = await SellerRepository().getStoreById(storeId);
  if (store != null && store.status != 'active') {
    ToastUtil.showToast(
      'Complete business verification before adding products.',
    );
    Get.toNamed(Routes.storeVerification, arguments: storeId);
    return;
  }

  Get.toNamed(Routes.addSellerProduct);
}
