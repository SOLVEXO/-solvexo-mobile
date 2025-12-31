import 'package:book_store_app/app/modules/profile/modules/myorders/views/reviews_view.dart';
import 'package:get/get.dart';
import '../modules/auth/auth_tabs_view.dart';
import '../modules/auth/login/binding/login_binding.dart';
import '../modules/auth/otp/binding/otp_binding.dart';
import '../modules/auth/otp/views/get_notified.dart';
import '../modules/auth/otp/views/otp_view.dart';
import '../modules/auth/welcome/splash_screen.dart';
import '../modules/cart/bindings/cart_binding.dart';
import '../modules/cart/views/cart_view.dart';
import '../modules/category/bindings/category_binding.dart';
import '../modules/category/views/category_view.dart';
import '../modules/category/views/product_details_view.dart';
import '../modules/category/views/sub_category_view.dart';
import '../modules/checkout/bindings/checkout_binding.dart';
import '../modules/checkout/views/checkout_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/main_view.dart';
import '../modules/payment/bindings/payment_binding.dart';
import '../modules/payment/views/authentication_view.dart';
import '../modules/payment/views/payment_success_view.dart';
import '../modules/payment/views/payment_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/modules/address/bindings/profile_address_binding.dart';
import '../modules/profile/modules/address/views/profile_address_view.dart';
import '../modules/profile/modules/myorders/bindings/profile_myorders_binding.dart';
import '../modules/profile/modules/myorders/views/my_orders_view.dart';
import '../modules/profile/modules/myorders/views/order_tracking_view.dart';
import '../modules/profile/modules/ordertracker/bindings/order_tracker_binding.dart';
import '../modules/profile/modules/ordertracker/views/tracker_order_view.dart';
import '../modules/profile/modules/refund_request/bindings/refund_request_binding.dart';
import '../modules/profile/modules/refund_request/views/refund_request_view.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/search/bindings/search_binding.dart';
import '../modules/search/views/search_view.dart';
import '../modules/splash_screen/bindings/splash_screen_binding.dart';

part 'app_routes.dart';

class AppPages {
  static const initialRoute = Routes.mainHome;

  static final routes = [
    GetPage(
      name: Routes.mainHome,
      page: () => MainView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.splashScreen,
      page: () => SplashScreen(),
      binding: SplashScreenBinding(),
    ),
    GetPage(
      name: Routes.authTabView,
      page: () => AuthTabsView(),
      binding: LoginBinding(),
    ),
    GetPage(name: Routes.otpView, page: () => OtpView(), binding: OtpBinding()),
    GetPage(
      name: Routes.getNotified,
      page: () => GetNotified(),
      binding: OtpBinding(),
    ),
    // GetPage(name: Routes.signUpView, page: () => SignUpView()),
    // GetPage(name: Routes.loginView, page: () => LoginView()),
    GetPage(
      name: Routes.categoryView,
      page: () => const CategoryView(),
      binding: CategoryBinding(),
    ),
    GetPage(
      name: Routes.subCategoryView,
      page: () => const SubCategoryView(),
      binding: CategoryBinding(),
    ),
    GetPage(
      name: Routes.productDetailsView,
      page: () => ProductDetailsView(),
      binding: CategoryBinding(),
    ),
    GetPage(
      name: Routes.searchView,
      page: () => SearchView(),
      binding: SearchBinding(),
    ),
    GetPage(
      name: Routes.cartView,
      page: () => CartView(),
      binding: CartBinding(),
    ),
    GetPage(
      name: Routes.checkoutView,
      page: () => CheckoutView(),
      binding: CheckoutBinding(),
    ),
    GetPage(
      name: Routes.paymentView,
      page: () => PaymentView(),
      binding: PaymentBinding(),
    ),
    GetPage(
      name: Routes.authenticationView,
      page: () => AuthenticationView(),
      binding: PaymentBinding(),
    ),
    GetPage(
      name: Routes.paymentSuccessView,
      page: () => PaymentSuccessView(),
      binding: PaymentBinding(),
    ),
    GetPage(
      name: Routes.profileView,
      page: () => ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: Routes.myOrdersView,
      page: () => MyOrdersView(),
      binding: ProfileMyordersBinding(),
    ),
    GetPage(
      name: Routes.orderTrackingView,
      page: () => OrderTrackingView(),
      binding: ProfileMyordersBinding(),
    ),
    GetPage(
      name: Routes.reviewsView,
      page: () => ReviewsView(),
      binding: ProfileMyordersBinding(),
    ),
    GetPage(
      name: Routes.addressView,
      page: () => ProfileAddressView(),
      binding: ProfileAddressBinding(),
    ),
    GetPage(
      name: Routes.trackerView,
      page: () => TrackOrderView(),
      binding: ProfileOrdertrackerBinding(),
    ),
    GetPage(
      name: Routes.refundRequestView,
      page: () => RefundRequestView(),
      binding: RefundRequestBinding(),
    ),
  ];
}
