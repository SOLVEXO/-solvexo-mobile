import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/modules/add_seller_product/controllers/add_seller_product_controller.dart';
import 'package:book_store_app/app/modules/add_seller_product/widgets/add_product_bottom_bar.dart';
import 'package:book_store_app/app/modules/add_seller_product/widgets/add_product_details_form.dart';
import 'package:book_store_app/app/modules/add_seller_product/widgets/add_product_step_indicator.dart';
import 'package:book_store_app/app/modules/add_seller_product/widgets/add_product_type_grid.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddSellerProductView extends StatelessWidget {
  AddSellerProductView({super.key});

  final AddSellerProductController controller = Get.put(
    AddSellerProductController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBarTwo(title: "Add Product"),
      body: Column(
        children: [
          // _AppHeader(context: context, controller: controller),
          AddProductStepIndicator(controller: controller),
          const Divider(height: 1, color: AppColors.lightGrey2),
          Expanded(
            child: Obx(() {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.05, 0),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                ),
                child: controller.step.value == AddProductStep.type
                    ? AddProductTypeGrid(
                        key: const ValueKey('type'),
                        controller: controller,
                      )
                    : AddProductDetailsForm(
                        key: const ValueKey('details'),
                        controller: controller,
                      ),
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: AddProductBottomBar(controller: controller),
    );
  }
}

// class _AppHeader extends StatelessWidget {
//   final BuildContext context;
//   final AddSellerProductController controller;

//   const _AppHeader({required this.context, required this.controller});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(gradient: AppColors.appbarGradient),
//       padding: EdgeInsets.only(
//         top: MediaQuery.of(context).padding.top + 12,
//         left: 20,
//         right: 20,
//         bottom: 16,
//       ),
//       child: Row(
//         children: [
//           GestureDetector(
//             onTap: controller.goBack,
//             child: Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: AppColors.background.withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: const Icon(
//                 Icons.arrow_back_ios_new_rounded,
//                 color: AppColors.white,
//                 size: 18,
//               ),
//             ),
//           ),
//           const SizedBox(width: 14),
//           const Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 CustomText(
//                   text: 'My Shop',
//                   fontSize: AppFontSize.small2,
//                   color: AppColors.background,
//                   fontWeight: FontWeight.w400,
//                 ),
//                 SizedBox(height: 2),
//                 CustomText(
//                   text: 'Add Product',
//                   fontSize: AppFontSize.large,
//                   color: AppColors.white,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
