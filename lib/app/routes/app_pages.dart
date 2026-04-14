import 'package:book_store_app/app/modules/splash_screen/views/splash_screen_view.dart';
import 'package:get/get.dart';

import '../modules/about/bindings/about_binding.dart';
import '../modules/about/views/about_view.dart';
import '../modules/address/bindings/profile_address_binding.dart';
import '../modules/address/views/add_address_view.dart';
import '../modules/address/views/address_view.dart';
import '../modules/auth/auth_tabs_view.dart';
import '../modules/cart/bindings/cart_binding.dart';
import '../modules/cart/views/cart_view.dart';
import '../modules/category/bindings/category_binding.dart';
import '../modules/category/views/category_view.dart';
import '../modules/category/views/product_details_view.dart';
import '../modules/category/views/sub_category_view.dart';
import '../modules/change_password/bindings/change_password_binding.dart';
import '../modules/change_password/views/change_password_view.dart';
import '../modules/checkout/bindings/checkout_binding.dart';
import '../modules/checkout/views/checkout_view.dart';
import '../modules/edit_profile/bindings/edit_profile_binding.dart';
import '../modules/edit_profile/views/edit_profile_view.dart';
import '../modules/forget_password/bindings/forget_password_binding.dart';
import '../modules/forget_password/views/forget_password_view.dart';
import '../modules/help_center/bindings/faq_binding.dart';
import '../modules/help_center/views/faq_detail_view.dart';
import '../modules/help_center/views/faq_list_view.dart';
import '../modules/help_center/views/help_center_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/main_view.dart';
import '../modules/login/binding/login_binding.dart';
import '../modules/map_picker/bindings/mappicker_binding.dart';
import '../modules/map_picker/views/mappicker_view.dart';
import '../modules/myorders/bindings/profile_myorders_binding.dart';
import '../modules/myorders/views/my_orders_view.dart';
import '../modules/myorders/views/reviews_view.dart';
import '../modules/ordertracker/bindings/order_tracker_binding.dart';
import '../modules/ordertracker/views/tracker_order_view.dart';
import '../modules/otp/binding/otp_binding.dart';
import '../modules/otp/views/get_notified.dart';
import '../modules/otp/views/otp_view.dart';
import '../modules/payment/bindings/payment_binding.dart';
import '../modules/payment/views/authentication_view.dart';
import '../modules/payment/views/payment_success_view.dart';
import '../modules/payment/views/payment_view.dart';
import '../modules/privacy_policy/bindings/privacy_policy_binding.dart';
import '../modules/privacy_policy/views/privacy_policy_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/refund_request/bindings/refund_request_binding.dart';
import '../modules/refund_request/views/refund_request_view.dart';
import '../modules/reset_password/bindings/new_password_binding.dart';
import '../modules/reset_password/views/new_password_view.dart';
import '../modules/search/bindings/search_binding.dart';
import '../modules/search/views/search_view.dart';
import '../modules/settings/bindings/settings_binding.dart';
import '../modules/settings/views/settings_view.dart';
import '../modules/splash_screen/bindings/splash_screen_binding.dart';

part 'app_routes.dart';

class AppPages {
  static const initialRoute = Routes.splashScreen;

  static final routes = [
    GetPage(
      name: Routes.mainHome,
      page: () => MainView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.splashScreen,
      page: () => SplashView(),
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
    // GetPage(
    //   name: Routes.orderTrackingView,
    //   page: () => OrderTrackingView(),
    //   binding: ProfileMyordersBinding(),
    // ),
    GetPage(
      name: Routes.reviewsView,
      page: () => ReviewsView(),
      binding: ProfileMyordersBinding(),
    ),
    GetPage(
      name: Routes.addressView,
      page: () => AddressView(),
      binding: ProfileAddressBinding(),
    ),
    GetPage(
      name: Routes.addAddressView,
      page: () => AddAddressView(),
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
    GetPage(
      name: Routes.helpCenterView,
      page: () => HelpCenterView(),
      binding: FaqBinding(),
    ),
    GetPage(
      name: Routes.faqListView,
      page: () => FAQListView(),
      binding: FaqBinding(),
    ),
    GetPage(
      name: Routes.faqDetailView,
      page: () => FAQDetailView(),
      binding: FaqBinding(),
    ),
    GetPage(
      name: Routes.mapPickerView,
      page: () => MapPickerScreen(),
      binding: MappickerBinding(),
    ),
    GetPage(
      name: Routes.editProfileView,
      page: () => const EditProfileView(),
      binding: EditProfileBinding(),
    ),
    GetPage(
      name: Routes.forgetPasswordView,
      page: () => const ForgetPasswordView(),
      binding: ForgetPasswordBinding(),
    ),
    GetPage(
      name: Routes.newPasswordView,
      page: () => const NewPasswordView(),
      binding: NewPasswordBinding(),
    ),
    GetPage(
      name: Routes.SETTINGS,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: Routes.CHANGE_PASSWORD,
      page: () => ChangePasswordView(),
      binding: ChangePasswordBinding(),
    ),
    GetPage(
      name: Routes.PRIVACY_POLICY,
      page: () => const PrivacyPolicyView(),
      binding: PrivacyPolicyBinding(),
    ),
    GetPage(
      name: Routes.ABOUT,
      page: () => const AboutView(),
      binding: AboutBinding(),
    ),
  ];
}
