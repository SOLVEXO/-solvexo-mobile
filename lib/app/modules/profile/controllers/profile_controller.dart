import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  final options = [
    {
      "title": "My Order",
      "subtitle": "Check the Order status and history",
      "icon": AppIcons.billsIcon,
      "ontap": Routes.myOrdersView,
    },
    {
      "title": "Payment",
      "subtitle": "Change Payment Option",
      "icon": AppIcons.duePayment,
      "ontap": Routes.paymentView,
    },
    {
      "title": "Address",
      "subtitle": "Delete, Update and add your address",
      "icon": AppIcons.locationIcon,
      "ontap": Routes.myOrdersView,
    },
    {
      "title": "Help Center",
      "subtitle": "Have a problem? you can contact us",
      "icon": AppIcons.phoneIcon,
      "ontap": Routes.myOrdersView,
    },
    {
      "title": "Logout",
      "subtitle": "You can login Again",
      "icon": AppIcons.logoutIcon,
      "ontap": Routes.authTabView,
    },
  ];
}
