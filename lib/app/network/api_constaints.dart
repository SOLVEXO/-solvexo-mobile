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
  static String deleteAddress(String id) => "$apiPrefix/addresses/$id";
  static String getAddressById(String id) =>
      "$apiPrefix/addresses/get-address-by-id/$id";
  static String setDefaultAddress(String id) =>
      "$apiPrefix/addresses/$id/default";

  // ============ Order Endpoints ============
  static const String refunds = "$apiPrefix/refunds";
  static const String myRefunds = "$apiPrefix/refunds/my";
  static const String uploadRefundImages = '$apiPrefix/refunds/upload-images';
  static const String orders = "$apiPrefix/orders";
  static const String myOrders = "$apiPrefix/orders/my-orders";
  static String getOrderById(String id) => "$apiPrefix/orders/$id";
  static String updateOrderToPaid(String id) => "$apiPrefix/orders/$id/pay";
  static String cancelOrder(String id) => "$apiPrefix/orders/$id/cancel";

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

  // ============ Upload Endpoints ============
  static const String uploadFile = '$apiPrefix/upload/file';
  static const String uploadPrivateFile = '$apiPrefix/upload/private-file';
  // static String get cartSync => null;

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
