class ApiConstants {
  // static const String baseUrl = "http://localhost:3001";
  static const String baseUrl = "https://api.edudeen.com";

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
  static String getProductById(String id) => "$apiPrefix/products/$id";
  static String updateProduct(String id) => "$apiPrefix/products/$id";
  static String deleteProduct(String id) => "$apiPrefix/products/$id";

  // ============ Address Endpoints ============
  static const String addresses = "$apiPrefix/addresses";
  static String getAddressById(String id) => "$apiPrefix/addresses/$id";
  static String updateAddress(String id) => "$apiPrefix/addresses/$id";
  static String deleteAddress(String id) => "$apiPrefix/addresses/$id";
  static String setDefaultAddress(String id) =>
      "$apiPrefix/addresses/$id/default";

  // ============ Order Endpoints ============
  static const String refunds = "$apiPrefix/refunds";
  static const String myRefunds = "$apiPrefix/refunds/my";
  static const String uploadRefundImages = '$apiPrefix/refunds/upload-images';
  static const String orders = "$apiPrefix/orders";
  static const String myOrders = "$apiPrefix/orders/myorders";
  static String getOrderById(String id) => "$apiPrefix/orders/$id";
  static String updateOrderToPaid(String id) => "$apiPrefix/orders/$id/pay";
  static String cancelOrder(String id) => "$apiPrefix/orders/$id/cancel";

  // Cart endpoints
  static const String cart = '$apiPrefix/cart';
  static const String cartCount = '$apiPrefix/cart/count';
  static const String cartItems = '$apiPrefix/cart/items';
  static const String cartValidate = '$apiPrefix/cart/validate';
  static const String cartSync = '$apiPrefix/cart/sync';

  // ============ Upload Endpoints ============
  // ✅ Upload
  static const String uploadImage = '$apiPrefix/upload/image';
  static const String uploadProductImages = "$apiPrefix/upload/products";
  static const String uploadCategoryImage = "$apiPrefix/upload/category";
  static const String uploadProfileImage = "$apiPrefix/upload/profile";

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
