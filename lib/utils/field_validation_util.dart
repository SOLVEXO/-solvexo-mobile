import 'package:get/get.dart';

class FieldValidationUtil {
  static String? passwordValidateStrong(String value) {
    //RegExp regex = RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{6,}$');
    RegExp regex = RegExp(
      r'^(?=.*?[A-Z])(?=.*?[0-9])(?=.*?[!@#\$&*~%();:/?,.[{}^|<>]).{8,}$',
    );

    if (value.isEmpty || value == "") {
      return "password_required".tr;
    }
    if (value.length < 8) {
      return "strong_password_validation".tr;
    }
    if (!regex.hasMatch(value)) {
      return "strong_password_validation".tr;
    } else {
      return null;
    }
  }

  static String? confirmPasswordValidate(String value, String confirmValue) {
    if (value.isEmpty || value == "") {
      return "${"confirm_password".tr} ${"field_cannot_be_empty".tr}";
    } else if (value.length < 8) {
      return "confirm_password_short".tr;
    } else if (value != confirmValue) {
      return "password_not_match".tr;
    } else {
      return null;
    }
  }

  static String? stringValidateWithDelete(val, {fieldName}) {
    if (val.isEmpty || val == '') {
      return '${fieldName ?? 'field'.tr} ${'cannot_be_empty'.tr}';
    }
    if (val.length < 3) {
      return '${fieldName ?? 'field'.tr}${'is_too_short'.tr}';
    }
    if (val != "lbl_delete_cap".tr) {
      return 'lbl_delete_validation'.tr;
    } else {
      return null;
    }
  }

  static String? emailValidate(String value) {
    var emailRegex = RegExp(
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
    );

    if (value.isEmpty || value == "") {
      return "${"email_address".tr} ${"field_cannot_be_empty".tr}";
    }
    if (!emailRegex.hasMatch(value)) {
      return "invalid_email_address".tr;
    } else {
      return null;
    }
  }

  static String? otpCodeValidator(String value) {
    if (value.isEmpty || value == "") {
      return "Verification code cannot be empty";
    }
    if (value.length < 4) {
      return "Verification code must be of 4 digits";
    } else {
      return null;
    }
  }

  static String? validateValue(String value, String fieldName) {
    value = value.trim();

    if (value.isEmpty || value == "") {
      return "${fieldName.tr} ${"field_cannot_be_empty".tr}";
    } else {
      return null;
    }
  }

  static String? couponValidation(String value, String fieldName) {
    value = value.trim();

    if (value.isEmpty) {
      return "${fieldName.tr} ${"Filed cannot be empty"}";
    } else if (value.length >= 8) {
      return "${fieldName.tr} ${"Your Point is max the limit"}";
    } else {
      return null;
    }
  }
}
