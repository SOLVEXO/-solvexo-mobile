import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:get/get.dart';

class NotificationController extends GetxController {
  List notificationsAbout = [
    {"icon": AppIcons.duePayment, "notification": "Payment is due"},
    {"icon": AppIcons.truckIcon, "notification": "Your order is on the way"},
    {
      "icon": AppIcons.saleIcon,
      "notification": "Deals and products we think you like",
    },
    {"icon": AppIcons.shoppingBag, "notification": "When you make a purchase"},
  ];
}
