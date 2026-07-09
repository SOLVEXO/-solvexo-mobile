import 'package:get/get.dart';
import '../modules/notifications/bindings/notifications_binding.dart';
import '../modules/notifications/views/notifications_view.dart';
import '../modules/add_seller_product/bindings/add_seller_product_binding.dart';
import '../modules/add_seller_product/views/add_seller_product_view.dart';
import '../modules/edit_seller_product/bindings/edit_seller_product_binding.dart';
import '../modules/edit_seller_product/views/edit_seller_product_view.dart';
import '../modules/seller_store_profile/bindings/seller_store_profile_binding.dart';
import '../modules/seller_store_profile/views/seller_store_profile_view.dart';
import '../modules/seller_payment_methods/bindings/seller_payment_methods_binding.dart';
import '../modules/seller_payment_methods/views/seller_payment_methods_view.dart';
import '../modules/seller_shipping/bindings/seller_shipping_binding.dart';
import '../modules/seller_shipping/views/seller_shipping_view.dart';
import '../modules/seller_notifications/bindings/seller_notifications_binding.dart';
import '../modules/seller_notifications/views/seller_notifications_view.dart';
import '../modules/seller_password_security/bindings/seller_password_security_binding.dart';
import '../modules/seller_password_security/views/seller_password_security_view.dart';
import '../modules/seller_two_factor/bindings/seller_two_factor_binding.dart';
import '../modules/seller_two_factor/views/seller_two_factor_view.dart';
import '../modules/seller_language/bindings/seller_language_binding.dart';
import '../modules/seller_language/views/seller_language_view.dart';
import '../modules/seller_ai_studio/bindings/seller_ai_studio_binding.dart';
import '../modules/seller_ai_studio/views/seller_ai_studio_view.dart';
import '../modules/seller_messages/bindings/seller_messages_binding.dart';
import '../modules/seller_messages/views/seller_messages_view.dart';
import '../modules/messaging/bindings/conversations_binding.dart';
import '../modules/messaging/bindings/chat_binding.dart';
import '../modules/messaging/views/conversations_view.dart';
import '../modules/messaging/views/chat_view.dart';
import '../modules/seller_onboarding/bindings/seller_onboarding_binding.dart';
import '../modules/seller_onboarding/views/seller_onboarding_view.dart';
import '../modules/seller_stores/bindings/seller_stores_binding.dart';
import '../modules/seller_stores/views/seller_stores_view.dart';
import '../modules/welcome/views/welcome_view.dart';
import '../modules/welcome/bindings/welcome_binding.dart';
import '../modules/pos/bindings/pos_binding.dart';
import '../modules/pos_orders/bindings/pos_orders_binding.dart';
import '../modules/pos_products/bindings/pos_products_binding.dart';
import '../modules/pos_settings/bindings/pos_settings_binding.dart';
import '../modules/pos/views/pos_main_view.dart';
import '../modules/pos_orders/views/pos_orders_view.dart';
import '../modules/pos_products/views/pos_products_view.dart';
import '../modules/pos_settings/views/pos_settings_view.dart';
import '../modules/pos_pin_login/bindings/pos_pin_login_binding.dart';
import '../modules/pos_pin_login/views/pos_pin_login_view.dart';
import '../modules/pos_open_register/bindings/pos_open_register_binding.dart';
import '../modules/pos_open_register/views/pos_open_register_view.dart';
import '../modules/pos_held_sales/bindings/pos_held_sales_binding.dart';
import '../modules/pos_held_sales/views/pos_held_sales_view.dart';
import '../modules/pos_daily_report/bindings/pos_daily_report_binding.dart';
import '../modules/pos_daily_report/views/pos_daily_report_view.dart';
import '../modules/seller_pos_management/bindings/seller_pos_management_binding.dart';
import '../modules/seller_pos_management/views/seller_pos_management_view.dart';
import '../modules/seller_analytics/bindings/seller_analytics_binding.dart';
import '../modules/seller_finance/bindings/seller_finance_binding.dart';
import '../modules/seller_finance/views/seller_finance_view.dart';
import '../modules/seller_coupons/bindings/seller_coupons_binding.dart';
import '../modules/seller_coupons/views/seller_coupons_view.dart';
import '../modules/seller_loyalty/bindings/seller_loyalty_binding.dart';
import '../modules/seller_loyalty/views/seller_loyalty_view.dart';
import '../modules/seller_subscriptions/bindings/seller_subscriptions_binding.dart';
import '../modules/seller_subscriptions/views/seller_subscriptions_view.dart';
import '../modules/loyalty_rewards/bindings/loyalty_rewards_binding.dart';
import '../modules/loyalty_rewards/views/loyalty_rewards_view.dart';
import '../modules/seller_edit_profile/bindings/seller_edit_profile_binding.dart';
import '../modules/seller_edit_profile/views/seller_edit_profile_view.dart';
import '../modules/seller/bindings/seller_binding.dart';
import '../modules/seller_orders/bindings/seller_order_detail_binding.dart';
import '../modules/seller_orders/bindings/seller_orders_binding.dart';
import '../modules/seller_orders/views/seller_order_detail_view.dart';
import '../modules/seller_products/bindings/seller_products_binding.dart';
import '../modules/seller_settings/bindings/seller_settings_binding.dart';
import '../modules/seller_analytics/views/seller_analytics_view.dart';
import '../modules/seller/views/seller_main_view.dart';
import '../modules/seller_orders/views/seller_orders_view.dart';
import '../modules/seller_products/views/seller_products_view.dart';
import '../modules/seller_settings/views/seller_settings_view.dart';
import '../modules/about/bindings/about_binding.dart';
import '../modules/about/views/about_view.dart';
import '../modules/address/bindings/address_binding.dart';
import '../modules/address/views/add_address_view.dart';
import '../modules/address/views/address_view.dart';
import '../modules/auth/auth_tabs_view.dart';
import '../modules/cart/bindings/cart_binding.dart';
import '../modules/cart/views/cart_view.dart';
import '../modules/category/bindings/category_binding.dart';
import '../modules/category/views/category_view.dart';
import '../modules/change_password/bindings/change_password_binding.dart';
import '../modules/change_password/views/change_password_view.dart';
import '../modules/ai_assistant_chat/bindings/ai_assistant_chat_binding.dart';
import '../modules/ai_assistant_chat/views/ai_assistant_chat_view.dart';
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
import '../modules/product_details/binding/product_detail_binding.dart';
import '../modules/product_details/views/product_details_view.dart';
import '../modules/seller_storefront/bindings/seller_storefront_binding.dart';
import '../modules/seller_storefront/views/seller_storefront_view.dart';
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
import '../modules/splash_screen/views/splash_screen_view.dart';
import '../modules/sub_category/binding/sub_category_binding.dart';
import '../modules/sub_category/views/sub_category_view.dart';
import '../modules/wishlist/bindings/wishlist_binding.dart';
import '../modules/wishlist/views/wishlist_view.dart';
import '../modules/pos_sale_detail/bindings/pos_sale_detail_binding.dart';
import '../modules/pos_sale_detail/views/pos_sale_detail_view.dart';
import '../modules/pos_session_report/bindings/pos_session_report_binding.dart';
import '../modules/pos_session_report/views/pos_session_report_view.dart';
import '../modules/pos_session_history/bindings/pos_session_history_binding.dart';
import '../modules/pos_session_history/views/pos_session_history_view.dart';
import '../modules/pos_audit_log/bindings/pos_audit_log_binding.dart';
import '../modules/pos_audit_log/views/pos_audit_log_view.dart';
import '../modules/pos_range_report/bindings/pos_range_report_binding.dart';
import '../modules/pos_range_report/views/pos_range_report_view.dart';
import '../middleware/auth_middleware.dart';

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
      name: Routes.welcome,
      page: () => const WelcomeView(),
      binding: WelcomeBinding(),
    ),
    GetPage(
      name: Routes.sellerStores,
      page: () => SellerStoresView(),
      binding: SellerStoresBinding(),
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
      page: () => CategoryView(),
      binding: CategoryBinding(),
    ),
    GetPage(
      name: Routes.subCategoryView,
      page: () => const SubCategoryView(),
      binding: SubCategoryBinding(),
    ),
    GetPage(
      name: Routes.productDetailsView,
      page: () => ProductDetailsView(),
      binding: ProductDetailBinding(),
    ),
    GetPage(
      name: Routes.sellerStorefront,
      page: () => SellerStorefrontView(),
      binding: SellerStorefrontBinding(),
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
      binding: AddressBinding(),
    ),
    GetPage(
      name: Routes.addAddressView,
      page: () => AddAddressView(),
      binding: AddressBinding(),
    ),
    GetPage(
      name: Routes.trackerView,
      page: () => TrackOrderView(),
      binding: OrderTrackerBinding(),
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
    GetPage(
      name: Routes.CHAT,
      page: () => const AiAssistantChatView(),
      binding: AiAssistantChatBinding(),
    ),
    GetPage(
      name: Routes.WISHLIST,
      page: () => const WishlistView(),
      binding: WishlistBinding(),
    ),
    GetPage(
      name: Routes.sellerOnboarding,
      page: () => SellerOnboardingView(),
      binding: SellerOnboardingBinding(),
    ),
    GetPage(
      name: Routes.sellerHome,
      page: () => SellerMainView(),
      binding: SellerBinding(),
    ),
    GetPage(
      name: Routes.posHome,
      page: () => PosMainView(),
      binding: PosBinding(),
      middlewares: [PosAccessMiddleware(requireActiveSession: true)],
    ),
    GetPage(
      name: Routes.sellerMessages,
      page: () => SellerMessagesView(),
      binding: SellerMessagesBinding(),
    ),
    GetPage(
      name: Routes.messagesView,
      page: () => ConversationsView(),
      binding: ConversationsBinding(),
    ),
    GetPage(
      name: Routes.chatView,
      page: () => ChatView(),
      binding: ChatBinding(),
    ),
    GetPage(
      name: Routes.sellerOrders,
      page: () => SellerOrdersView(),
      binding: SellerOrdersBinding(),
    ),
    GetPage(
      name: Routes.sellerOrderDetail,
      page: () => const SellerOrderDetailView(),
      binding: SellerOrderDetailBinding(),
    ),
    GetPage(
      name: Routes.addSellerProduct,
      page: () => AddSellerProductView(),
      binding: AddSellerProductBinding(),
    ),
    GetPage(
      name: Routes.editSellerProduct,
      page: () => EditSellerProductView(),
      binding: EditSellerProductBinding(),
    ),
    GetPage(
      name: Routes.sellerProducts,
      page: () => SellerProductsView(),
      binding: SellerProductsBinding(),
    ),
    GetPage(
      name: Routes.sellerAnalytics,
      page: () => SellerAnalyticsView(),
      binding: SellerAnalyticsBinding(),
    ),
    GetPage(
      name: Routes.sellerFinance,
      page: () => SellerFinanceView(),
      binding: SellerFinanceBinding(),
    ),
    GetPage(
      name: Routes.sellerCoupons,
      page: () => SellerCouponsView(),
      binding: SellerCouponsBinding(),
    ),
    GetPage(
      name: Routes.sellerLoyalty,
      page: () => SellerLoyaltyView(),
      binding: SellerLoyaltyBinding(),
    ),
    GetPage(
      name: Routes.sellerSubscriptionPlans,
      page: () => SellerSubscriptionsView(),
      binding: SellerSubscriptionsBinding(),
    ),
    GetPage(
      name: Routes.loyaltyRewards,
      page: () => LoyaltyRewardsView(),
      binding: LoyaltyRewardsBinding(),
    ),
    GetPage(
      name: Routes.sellerEditProfile,
      page: () => SellerEditProfileView(),
      binding: SellerEditProfileBinding(),
    ),
    GetPage(
      name: Routes.sellerAiStudio,
      page: () => SellerAiStudioView(),
      binding: SellerAiStudioBinding(),
    ),
    GetPage(
      name: Routes.sellerSettings,
      page: () => SellerSettingsView(),
      binding: SellerSettingsBinding(),
    ),
    GetPage(
      name: Routes.sellerStoreProfile,
      page: () => SellerStoreProfileView(),
      binding: SellerStoreProfileBinding(),
    ),
    GetPage(
      name: Routes.sellerPaymentMethods,
      page: () => SellerPaymentMethodsView(),
      binding: SellerPaymentMethodsBinding(),
    ),
    GetPage(
      name: Routes.sellerShipping,
      page: () => SellerShippingView(),
      binding: SellerShippingBinding(),
    ),
    GetPage(
      name: Routes.sellerNotifications,
      page: () => SellerNotificationsView(),
      binding: SellerNotificationsBinding(),
    ),
    GetPage(
      name: Routes.sellerPasswordSecurity,
      page: () => SellerPasswordSecurityView(),
      binding: SellerPasswordSecurityBinding(),
    ),
    GetPage(
      name: Routes.sellerTwoFactor,
      page: () => SellerTwoFactorView(),
      binding: SellerTwoFactorBinding(),
    ),
    GetPage(
      name: Routes.sellerLanguage,
      page: () => SellerLanguageView(),
      binding: SellerLanguageBinding(),
    ),
    GetPage(
      name: Routes.posOrders,
      page: () => PosOrdersView(),
      binding: PosOrdersBinding(),
      middlewares: [PosAccessMiddleware(requireActiveSession: true)],
    ),
    GetPage(
      name: Routes.posPinLogin,
      page: () => PosPinLoginView(),
      binding: PosPinLoginBinding(),
      middlewares: [PosAccessMiddleware()],
    ),
    GetPage(
      name: Routes.posOpenRegister,
      page: () => PosOpenRegisterView(),
      binding: PosOpenRegisterBinding(),
      middlewares: [PosAccessMiddleware()],
    ),
    GetPage(
      name: Routes.posHeldSales,
      page: () => PosHeldSalesView(),
      binding: PosHeldSalesBinding(),
      middlewares: [PosAccessMiddleware(requireActiveSession: true)],
    ),
    GetPage(
      name: Routes.posDailyReport,
      page: () => PosDailyReportView(),
      binding: PosDailyReportBinding(),
      middlewares: [PosAccessMiddleware(requireActiveSession: true)],
    ),
    GetPage(
      name: Routes.sellerPosManagement,
      page: () => SellerPosManagementView(),
      binding: SellerPosManagementBinding(),
    ),
    GetPage(
      name: Routes.posProducts,
      page: () => PosProductsView(),
      binding: PosProductsBinding(),
      middlewares: [PosAccessMiddleware(requireActiveSession: true)],
    ),
    GetPage(
      name: Routes.posSettings,
      page: () => PosSettingsView(),
      binding: PosSettingsBinding(),
      middlewares: [PosAccessMiddleware(requireActiveSession: true)],
    ),
    GetPage(
      name: Routes.posSaleDetail,
      page: () => PosSaleDetailView(),
      binding: PosSaleDetailBinding(),
      middlewares: [PosAccessMiddleware(requireActiveSession: true)],
    ),
    GetPage(
      name: Routes.posSessionReport,
      page: () => PosSessionReportView(),
      binding: PosSessionReportBinding(),
      middlewares: [PosAccessMiddleware(requireActiveSession: true)],
    ),
    GetPage(
      name: Routes.posSessionHistory,
      page: () => PosSessionHistoryView(),
      binding: PosSessionHistoryBinding(),
      middlewares: [PosAccessMiddleware(requireActiveSession: true)],
    ),
    GetPage(
      name: Routes.posAuditLog,
      page: () => PosAuditLogView(),
      binding: PosAuditLogBinding(),
      middlewares: [PosAccessMiddleware()],
    ),
    GetPage(
      name: Routes.posRangeReport,
      page: () => PosRangeReportView(),
      binding: PosRangeReportBinding(),
      middlewares: [PosAccessMiddleware()],
    ),
    GetPage(
      name: Routes.notifications,
      page: () => NotificationsView(),
      binding: NotificationsBinding(),
    ),
  ];
}
