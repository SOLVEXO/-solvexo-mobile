import 'package:book_store_app/app/data/repositories/seller_repository.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:get/get.dart';

/// The API refuses product creation while the store is not `active` and
/// while the seller's platform plan has lapsed (docs §2.8). New stores are
/// active at once (verification is retired, docs §11); only legacy
/// `pending`/`rejected`/`suspended` stores are stopped here, with a plain
/// reason instead of a form that would end in a 400.
Future<void> openAddProductOrRequireVerification() async {
  final storeId = await AppPreferences.getStoreId();
  if (storeId == null || storeId.isEmpty) {
    Get.toNamed(Routes.addSellerProduct);
    return;
  }

  final store = await SellerRepository().getStoreById(storeId);
  if (store != null && store.status != 'active') {
    ToastUtil.showToast(
      store.status == 'pending'
          ? 'Your store is waiting for Edudeen approval.'
          : 'Your store is not active. Please contact Edudeen support.',
    );
    return;
  }

  Get.toNamed(Routes.addSellerProduct);
}
