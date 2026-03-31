import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize SharedPreferences

  final prefs = await SharedPreferences.getInstance();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return GetMaterialApp(
          theme: AppTheme.lightTheme,
          debugShowCheckedModeBanner: false,
          title: "Book Store",
          initialRoute: AppPages.initialRoute,
          getPages: AppPages.routes,
        );
      },
    );
  }
}
