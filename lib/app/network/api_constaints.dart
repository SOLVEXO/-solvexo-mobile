class ApiConstants {
  // Base URL
  static const String baseUrl = "https://smartvanride.com";
  static const String webSocket = "https://smartvanride.com";

  // static const String baseUrl = "http://192.168.20.127:3002";
  // static const String webSocket = "http://192.168.20.127:3002";

  // Auth Endpoints
  static const String registerUser = "$baseUrl/auth/registeruser";
  static const String login = "$baseUrl/auth/login";
  static const String verifyOtp = "$baseUrl/auth/verifyOtp";
  static const String resendOtp = "$baseUrl/auth/resend-otp";
  static const String forgotPassword = "$baseUrl/auth/forgot-password";
  static const String resetPassword = "$baseUrl/auth/reset-password";
  static const String resendOtpResetPassword =
      "$baseUrl/auth/resend-otp-reset-password";
  static const String socialLogin = "$baseUrl/auth/social-login";

  // Profile
  static const String getProfile = "$baseUrl/auth/getprofile";

  // Van
  static const String addVan = "$baseUrl/van/addVan";
  static const String getVans = "$baseUrl/van/getVans";
  static const String editVan = "$baseUrl/van/update-van";
  static const String getVanById = "$baseUrl/van/getVanById";

  // Kid
  static const String addKid = "$baseUrl/Kid/addKid";
  static const String getKids = "$baseUrl/Kid/getKids";

  // School
  static const String getAllSchools = "$baseUrl/Admin/getAllSchools";

  // Reports / Alerts
  static const String getFaq = "$baseUrl/report/getFaq";
  static const String reportIssues = "$baseUrl/report/issue-types";
  static const String reportIssuesDriver = "$baseUrl/report/issue-types-Driver";
  static const String addReport = "$baseUrl/report/addReport";
  static const String addReportByDriver = "$baseUrl/report/addReportByDriver";
  static const String allAlerts = "$baseUrl/notification/getAlerts";
  static const String issuesForDelete = "$baseUrl/auth/issuesForDelete";

  // Auth / User Settings
  static const String uploadImage = "$baseUrl/upload/image";
  static const String logout = "$baseUrl/auth/logout";
  static const String deleteAccount = "$baseUrl/auth/delete-account";
  static const String changePassword = "$baseUrl/auth/change-password";
  static const String editProfile = "$baseUrl/van/update-profile";

  // Trips
  static const String startTrip = "$baseUrl/trips/startTrip";
  static const String pickStudent = "$baseUrl/trips/pickStudent";
  static const String endTrip = "$baseUrl/trips/endTrip";
  static const String getLocation = "$baseUrl/trips/getLocation";
  static const String getKidsByDriver = "$baseUrl/van/getKidsByDriver";
  static const String getActiveTrips = "$baseUrl/kid/getActiveTripDetails";
  static const String getTripHistory = "$baseUrl/kid/getTripHistory";

  static const String deleteVanByDriver = "$baseUrl/van/deleteVanByDriver";
  static const String getVehicleType = "$baseUrl/van/getVehicleType ";
}
