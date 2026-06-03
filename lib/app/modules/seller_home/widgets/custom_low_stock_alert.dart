import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/seller_home/controllers/seller_home_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomLowStockAlert extends StatelessWidget {
  CustomLowStockAlert({super.key});
  final SellerHomeController controller = Get.find();
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.yellowBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.yellow.withOpacity(0.4)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('⚠️', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text:
                          '${controller.lowStockItems.length} items low on stock',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.amberDark,
                    ),
                    const SizedBox(height: 4),
                    CustomText(
                      text: controller.lowStockItems.join(', '),
                      fontSize: 13,
                      color: AppColors.amberDark,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
