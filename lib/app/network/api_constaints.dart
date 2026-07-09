class ApiConstants {
  static const String baseUrl = "http://localhost:3002";
  // static const String baseUrl = "https://staging.solvexo.store";

  // static const String baseUrl = "http://192.168.1.113:3001";

  static const String apiPrefix = "$baseUrl/api";

  // Timeouts
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000;

  // OTP
  // static const String sendOtp = "$apiPrefix/auth/send";
  static const String verifyOtp = "$apiPrefix/auth/verifyOtp";
  static const String resendOtp = "$apiPrefix/auth/resend-otp";

  // ============ Auth Endpoints ============
  static const String register = "$apiPrefix/auth/register";
  static const String socialLogin = '$apiPrefix/auth/social-login';
  static const String login = "$apiPrefix/auth/login";
  static const String getMe = "$apiPrefix/auth/getprofile";
  static const String logout = "$apiPrefix/auth/logout";
  // static const String verifyEmail = "$apiPrefix/auth/verify-email";
  // static const String resendVerification =
  //     "$apiPrefix/auth/resend-verification";
  static const String forgotPassword = "$apiPrefix/auth/forgot-password";
  static const String resetPassword = "$apiPrefix/auth/reset-password";

  static const String faqs = '$apiPrefix/faqs';
  // OAuth endpoints
  static const String googleAuth = "$apiPrefix/auth/google";
  static const String facebookAuth = "$apiPrefix/auth/facebook";
  static const String appleAuth = "$apiPrefix/auth/apple";

  // ============ User Profile Endpoints ============
  static const String getUserProfile = "$apiPrefix/auth/getprofile";
  static const String editProfile = "$apiPrefix/auth/edit-profile";
  static const String updateUserProfile = "$apiPrefix/users/profile";
  static const String deleteUserAccount = "$apiPrefix/users/profile";
  static const String changePassword = "$apiPrefix/users/change-password";
  static const String banners = "$apiPrefix/banners";

  // ============ Category Endpoints ============
  static const String categories = "$apiPrefix/categories/category-tree";
  static const String addCategory = "$apiPrefix/categories/add-category";
  static String getCategoryTree(String id) =>
      "$apiPrefix/categories/category-tree?id=$id";
  static String getCategoryById(String id) =>
      "$apiPrefix/categories/category/$id";
  // static String updateCategory(String id) => "$apiPrefix/categories/$id";
  // static String deleteCategory(String id) => "$apiPrefix/categories/$id";

  // ============ Product Endpoints ============
  static const String products = "$apiPrefix/products";
  static const String featuredProducts = "$apiPrefix/products/featured";
  static String getProductById(String id) =>
      '$apiPrefix/products/getProductById/$id';
  static String getVariantById(String id) =>
      '$apiPrefix/products/getVariantById/$id';
  // ============ Product by Category Endpoint ============
  static String getProductsByCategory({
    String? categoryId,
    int page = 1,
    int limit = 10,
  }) {
    String url = '$apiPrefix/products/products-by-category';
    List<String> queryParams = [];

    if (categoryId != null && categoryId.isNotEmpty) {
      queryParams.add('id=$categoryId');
    }
    queryParams.add('page=$page');
    queryParams.add('limit=$limit');

    return '$url?${queryParams.join('&')}';
  }

  // ============ Address Endpoints ============
  static const String addAdresses = "$baseUrl/address/add-address";
  static const String getAdresses = "$baseUrl/address/getMyAddresses";
  static const String getDefaultAddress = "$baseUrl/address/getDefaultAddress";
  static const String updateAddress = "$baseUrl/address/update-address";
  static String deleteAddress(String id) => "$baseUrl/address/delete-address/$id";
  static String getAddressById(String id) =>
      "$baseUrl/address/get-address-by-id/$id";
  static String setDefaultAddress(String id) =>
      "$baseUrl/address/setDefaultAddress/$id";

  // ============ Order Endpoints ============
  static const String orders = "$apiPrefix/orders";
  static const String myOrders = "$apiPrefix/orders/my-orders";
  static String getOrderById(String id) => "$apiPrefix/orders/$id";
  static String updateOrderToPaid(String id) => "$apiPrefix/orders/$id/pay";
  static String cancelOrder(String id) => "$apiPrefix/orders/cancel/$id";
  static String returnRequest(String orderId) =>
      "$apiPrefix/orders/return-request/$orderId";

  // ============ Rating / Review Endpoints ============
  static const String addReview = "$apiPrefix/rating/add-review";
  static const String myReviews = "$apiPrefix/rating/my-reviews";
  static String editReview(String reviewId) => "$apiPrefix/rating/$reviewId";
  static String deleteReview(String reviewId) => "$apiPrefix/rating/$reviewId";
  static String productReviews(String productId) =>
      "$apiPrefix/rating/product/$productId";
  static String storeReviews(String storeId) =>
      "$apiPrefix/rating/store-reviews/$storeId";
  static String replyToReview(String reviewId) =>
      "$apiPrefix/rating/reply/$reviewId";
  static String editReviewReply(String reviewId) =>
      "$apiPrefix/rating/edit-reply/$reviewId";

  // Cart endpoints
  static const String getCart = '$apiPrefix/cart/get-cart';
  static const String clearCart = '$apiPrefix/cart/clear-cart';
  static const String cartCount = '$apiPrefix/cart/count';
  static const String addToCart = '$apiPrefix/cart/add-to-cart';
  static const String removeCartItem = '$apiPrefix/cart/remove-cart-item';
  static const String updateCartQuantity =
      '$apiPrefix/cart/update-cart-quantity';
  static const String clearWishList = '$apiPrefix/cart/clear-wishlist';
  static const String addToWishlist = '$apiPrefix/cart/add-to-wishlist';
  static const String getWishlist = '$apiPrefix/cart/get-wishlist';
  static const String getWishlistItem = '$apiPrefix/cart/get-wishlist-item';
  static const String removeFromWishlist =
      '$apiPrefix/cart/remove-from-wishlist';
  // ============ Checkout / Shipping Endpoints ============
  static const String createCheckout = "$apiPrefix/checkout/create-checkout";
  static const String addShippingInCheckout =
      "$apiPrefix/checkout/addShippingInCheckout";
  static const String codPayment = "$apiPrefix/payment/cod-payment";
  static const String getShippingZones = "$apiPrefix/checkout/getShippingZones";
  // ============ Seller / Store Endpoints ============
  static const String createStore = "$apiPrefix/store/create-store";
  static const String updateStore = "$apiPrefix/store/update-store";
  static const String myStores = "$apiPrefix/store/my-stores";
  static String getStoreById(String id) => "$apiPrefix/store/getStoreById/$id";

  // ============ Public Storefront Endpoints ============
  static String publicStoreBySlug(String slug) =>
      "$apiPrefix/store/public/$slug";
  static String publicStoreProducts(String storeId) =>
      "$apiPrefix/store/public/$storeId/products";
  static String publicStoreFilters(String storeId) =>
      "$apiPrefix/store/public/$storeId/filters";
  static String followStore(String storeId) =>
      "$apiPrefix/store/$storeId/follow";
  static String storeFollowStatus(String storeId) =>
      "$apiPrefix/store/$storeId/follow-status";

  // ============ Seller / Product Endpoints ============
  static const String addPhysicalProduct =
      "$apiPrefix/products/add-physical-product";
  static const String addDigitalProduct =
      "$apiPrefix/products/add-digital-product";
  static const String editProduct = "$apiPrefix/products/edit-product";
  static String getStoreInventory(String storeId) =>
      "$apiPrefix/inventory/getStoreInventory/$storeId";
  static String sellerOrders(String storeId) =>
      "$apiPrefix/orders/seller-orders/$storeId";
  static String markOrderPaid(String orderId) =>
      "$apiPrefix/orders/mark-paid/$orderId";
  static const String updateOrderStatus = "$apiPrefix/orders/update-status";

  // ============ POS Endpoints ============
  // All GET endpoints below intentionally return a bare path — query params
  // are passed via BaseClient's `queryParameters:` map by the repository, not
  // string-interpolated here, so values are always properly encoded.
  static const String posPinLogin = '$apiPrefix/pos/pin-login';

  // Employees
  static String posEmployees(String storeId) =>
      '$apiPrefix/pos/employees/$storeId';
  static const String posEmployeesCreate = '$apiPrefix/pos/employees';
  static String posEmployeeLegacy(String employeeId) =>
      '$apiPrefix/pos/employees/$employeeId';
  static String posEmployeeV2(String storeId, String employeeId) =>
      '$apiPrefix/pos/employees/$storeId/$employeeId';
  static String posEmployeeResetPin(String storeId, String employeeId) =>
      '$apiPrefix/pos/employees/$storeId/$employeeId/reset-pin';

  // Registers
  static String posRegisters(String storeId) =>
      '$apiPrefix/pos/registers/$storeId';
  static String posRegisterById(String storeId, String registerId) =>
      '$apiPrefix/pos/registers/$storeId/$registerId';

  // Shifts
  static String posShifts(String storeId) => '$apiPrefix/pos/shifts/$storeId';
  static String posShiftById(String storeId, String shiftId) =>
      '$apiPrefix/pos/shifts/$storeId/$shiftId';

  // Sessions
  static const String posSessionsOpen = '$apiPrefix/pos/sessions/open';
  static const String posSessionsClose = '$apiPrefix/pos/sessions/close';
  static const String posSessionsActive = '$apiPrefix/pos/sessions/active';
  static const String posSessionsHistory = '$apiPrefix/pos/sessions/history';
  static String posSessionCashAdjustment(String sessionId) =>
      '$apiPrefix/pos/sessions/$sessionId/cash-adjustment';
  static String posSessionReport(String sessionId) =>
      '$apiPrefix/pos/sessions/$sessionId/report';
  static String posSessionForceClose(String sessionId) =>
      '$apiPrefix/pos/sessions/$sessionId/force-close';

  // Products (POS browse / search / barcode)
  static String posProducts(String storeId) =>
      '$apiPrefix/pos/products/$storeId';
  static const String posProductsSearch = '$apiPrefix/pos/products/search';
  static String posProductBarcode(String storeId, String barcode) =>
      '$apiPrefix/pos/products/barcode/$storeId/$barcode';

  // Sales
  static const String posSales = '$apiPrefix/pos/sales';
  static const String posSalesHeld = '$apiPrefix/pos/sales/held';
  static String posSaleById(String saleId) => '$apiPrefix/pos/sales/$saleId';
  static String posSaleComplete(String saleId) =>
      '$apiPrefix/pos/sales/$saleId/complete';
  static String posSaleDiscard(String saleId) =>
      '$apiPrefix/pos/sales/$saleId/discard';
  static String posSaleRefund(String saleId) =>
      '$apiPrefix/pos/sales/$saleId/refund';
  static String posSaleVoid(String saleId) =>
      '$apiPrefix/pos/sales/$saleId/void';
  static String posSaleItems(String saleId) =>
      '$apiPrefix/pos/sales/$saleId/items';

  // Reports
  static const String posReportsDaily = '$apiPrefix/pos/reports/daily';
  static const String posReportsDailyExport =
      '$apiPrefix/pos/reports/daily/export';
  static const String posReportsRange = '$apiPrefix/pos/reports/range';
  static String posReportsRegister(String registerId) =>
      '$apiPrefix/pos/reports/register/$registerId';
  static String posReportsEmployee(String employeeId) =>
      '$apiPrefix/pos/reports/employee/$employeeId';

  // Settings
  static String posSettings(String storeId) =>
      '$apiPrefix/pos/settings/$storeId';

  // Audit logs
  static String posAuditLogs(String storeId) =>
      '$apiPrefix/pos/audit-logs/$storeId';

  // ============ Messaging Endpoints ============
  static const String startConversation = '$apiPrefix/messaging/conversations';
  static const String conversations = '$apiPrefix/messaging/conversations';
  static const String searchConversations =
      '$apiPrefix/messaging/conversations/search';
  static String conversationById(String id) =>
      '$apiPrefix/messaging/conversations/$id';
  static String archiveConversation(String id) =>
      '$apiPrefix/messaging/conversations/$id/archive';
  static String restoreConversation(String id) =>
      '$apiPrefix/messaging/conversations/$id/restore';
  static String pinConversation(String id) =>
      '$apiPrefix/messaging/conversations/$id/pin';
  static String muteConversation(String id) =>
      '$apiPrefix/messaging/conversations/$id/mute';
  static String deleteConversation(String id) =>
      '$apiPrefix/messaging/conversations/$id';
  static String conversationMessages(String convId) =>
      '$apiPrefix/messaging/conversations/$convId/messages';
  static String searchMessages(String convId) =>
      '$apiPrefix/messaging/conversations/$convId/messages/search';
  static String conversationAttachments(String convId) =>
      '$apiPrefix/messaging/conversations/$convId/attachments';
  static String editMessage(String id) => '$apiPrefix/messaging/messages/$id';
  static String deleteMessage(String id) => '$apiPrefix/messaging/messages/$id';
  static String markMessageSeen(String id) =>
      '$apiPrefix/messaging/messages/$id/seen';
  static const String blockUser = '$apiPrefix/messaging/block';
  static String unblockUser(String targetId) =>
      '$apiPrefix/messaging/block/$targetId';
  static const String reportTarget = '$apiPrefix/messaging/report';

  // ============ Upload Endpoints ============
  static const String uploadFile = '$apiPrefix/upload/file';
  static const String uploadPrivateFile = '$apiPrefix/upload/private-file';
  // static String get cartSync => null;

  // ============ Marketing (Coupons) Endpoints — seller ============
  static String coupons(String storeId) =>
      '$apiPrefix/marketing/$storeId/coupons';
  static String couponById(String storeId, String couponId) =>
      '$apiPrefix/marketing/$storeId/coupons/$couponId';

  // ============ Loyalty & Rewards Endpoints — seller ============
  static String loyaltyOverview(String storeId) =>
      '$apiPrefix/loyalty/$storeId/overview';
  static String loyaltyProgram(String storeId) =>
      '$apiPrefix/loyalty/$storeId/program';
  static String loyaltyEarningRules(String storeId) =>
      '$apiPrefix/loyalty/$storeId/earning-rules';
  static String loyaltyTiers(String storeId) =>
      '$apiPrefix/loyalty/$storeId/tiers';
  static String loyaltyMembers(String storeId) =>
      '$apiPrefix/loyalty/$storeId/members';
  static String loyaltyMemberTransactions(String storeId, String memberId) =>
      '$apiPrefix/loyalty/$storeId/members/$memberId/transactions';
  static String loyaltyAwardPoints(String storeId, String memberId) =>
      '$apiPrefix/loyalty/$storeId/members/$memberId/award';
  // Seller's own management list — includes inactive rewards.
  static String loyaltyRewardsManage(String storeId) =>
      '$apiPrefix/loyalty/$storeId/rewards/manage';
  static String loyaltyRewardById(String storeId, String rewardId) =>
      '$apiPrefix/loyalty/$storeId/rewards/$rewardId';

  // ============ Loyalty & Rewards Endpoints — buyer ============
  // Public catalog — active rewards only.
  static String loyaltyRewards(String storeId) =>
      '$apiPrefix/loyalty/$storeId/rewards';
  static String loyaltyMyBalance(String storeId) =>
      '$apiPrefix/loyalty/$storeId/my-balance';
  static String loyaltyRedeem(String storeId) =>
      '$apiPrefix/loyalty/$storeId/redeem';

  // ============ Subscription Plans Endpoints — seller ============
  static const String subscriptionPlans = '$apiPrefix/seller/subscription-plans';
  static String subscriptionPlanById(String id) =>
      '$apiPrefix/seller/subscription-plans/$id';
  static const String subscriptionsDashboard =
      '$apiPrefix/seller/subscriptions/dashboard';
  static const String subscriptionsList = '$apiPrefix/seller/subscriptions';
  static String subscriptionById(String id) =>
      '$apiPrefix/seller/subscriptions/$id';
  static String subscriptionPause(String id) =>
      '$apiPrefix/seller/subscriptions/$id/pause';
  static String subscriptionResume(String id) =>
      '$apiPrefix/seller/subscriptions/$id/resume';
  static String subscriptionCancel(String id, {bool atPeriodEnd = false}) =>
      '$apiPrefix/seller/subscriptions/$id/cancel?atPeriodEnd=$atPeriodEnd';

  // ============ Seller Analytics Endpoints ============
  // All GET, storeId/range/from/to passed as query params via BaseClient's
  // `queryParameters` (same convention as coupons/loyalty/subscriptions).
  static const String analyticsOverview = '$apiPrefix/seller/analytics/overview';
  static const String analyticsRevenueOverTime = '$apiPrefix/seller/analytics/revenue-over-time';
  static const String analyticsOrdersOverTime = '$apiPrefix/seller/analytics/orders-over-time';
  static const String analyticsTrafficSources = '$apiPrefix/seller/analytics/traffic-sources';
  static const String analyticsTopProducts = '$apiPrefix/seller/analytics/top-products';
  static const String analyticsCustomers = '$apiPrefix/seller/analytics/customers';
  static const String analyticsProductPerformance = '$apiPrefix/seller/analytics/products/performance';
  static const String analyticsInventoryInsights = '$apiPrefix/seller/analytics/inventory-insights';
  static const String analyticsPaymentMethods = '$apiPrefix/seller/analytics/payment-methods';
  static const String analyticsRevenueBreakdown = '$apiPrefix/seller/analytics/revenue-breakdown';
  static const String analyticsExport = '$apiPrefix/seller/analytics/export';

  // ============ Platform Subscription Endpoints (seller pays marketplace) ============
  // Distinct from the seller-sells-to-buyers `seller/subscription*` endpoints
  // above — this is the seller's OWN platform tier (Starter/Basic/Pro/Enterprise)
  // plus the separate POS add-on purchase.
  static const String platformTiers = '$apiPrefix/platform-subscriptions/tiers';
  static String platformMyPlan(String storeId) =>
      '$apiPrefix/platform-subscriptions/$storeId/my-plan';
  static String platformSubscribe(String storeId) =>
      '$apiPrefix/platform-subscriptions/$storeId/subscribe';
  static String platformChangeTier(String storeId) =>
      '$apiPrefix/platform-subscriptions/$storeId/change-tier';
  static String platformCancel(String storeId, {bool atPeriodEnd = false}) =>
      '$apiPrefix/platform-subscriptions/$storeId/cancel?atPeriodEnd=$atPeriodEnd';
  static String platformPosAddonSubscribe(String storeId) =>
      '$apiPrefix/platform-subscriptions/$storeId/pos-addon/subscribe';
  static String platformPosAddonCancel(String storeId) =>
      '$apiPrefix/platform-subscriptions/$storeId/pos-addon/cancel';

  // ============ Query Parameters Helper ============
  // For product filtering and search
  static String getProductsWithFilters({
    String? search,
    String? category,
    double? minPrice,
    double? maxPrice,
    String? brand,
    String? sort, // price_asc, price_desc, rating, newest
    int page = 1,
    int limit = 10,
  }) {
    String url = products;
    List<String> queryParams = [];

    if (search != null && search.isNotEmpty) {
      queryParams.add('search=$search');
    }
    if (category != null && category.isNotEmpty) {
      queryParams.add('category=$category');
    }
    if (minPrice != null) {
      queryParams.add('minPrice=$minPrice');
    }
    if (maxPrice != null) {
      queryParams.add('maxPrice=$maxPrice');
    }
    if (brand != null && brand.isNotEmpty) {
      queryParams.add('brand=$brand');
    }
    if (sort != null && sort.isNotEmpty) {
      queryParams.add('sort=$sort');
    }
    queryParams.add('page=$page');
    queryParams.add('limit=$limit');

    if (queryParams.isNotEmpty) {
      url += '?${queryParams.join('&')}';
    }

    return url;
  }
}
