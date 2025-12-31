// ignore_for_file: deprecated_member_use

import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:flutter/material.dart';

class AppGradient {
  static final blueGradient = LinearGradient(
    colors: [
      AppColors.primaryColor.withOpacity(0.8),
      AppColors.primaryColor.withOpacity(0.6),
    ],
  );
}
