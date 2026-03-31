import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:get/get.dart';

class SettingsController extends GetxController {
  List settings = [
    {
      "title": "Change Password",
      "icon": AppIcons.changePassword,
      "ontap": () => Get.toNamed(Routes.CHANGE_PASSWORD),
    },
    {
      "title": "Privacy Policy",
      "icon": AppIcons.privacy,
      "ontap": () => Get.toNamed(Routes.PRIVACY_POLICY),
    },
    {
      "title": "About App",
      "icon": AppIcons.aboutIcon,
      "ontap": () => Get.toNamed(Routes.ABOUT),
    },
  ];
}
