import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/seller_products/controllers/seller_products_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductsSearchBar extends StatelessWidget {
  ProductsSearchBar({super.key});
  final SellerProductsController controller = Get.find();
  @override
  Widget build(BuildContext context) {
    final textController = TextEditingController();
    return Padding(
      padding: const EdgeInsets.all(AppDimen.allPadding),
      child: CustomTextField(
        controller: textController,
        onChanged: controller.onSearch,
        hintText: 'Search products...',
        prefixIcon: SvgIcon(
          assetName: AppIcons.searchIcon,
          size: 22,
          color: AppColors.gray600,
        ),
        isborder: true,
        ispadding: true,
        suffixIcon: Obx(() {
          if (controller.searchQuery.value.isEmpty) {
            return const SizedBox(width: 12);
          }
          return GestureDetector(
            onTap: () {
              textController.clear();
              controller.clearSearch();
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Icon(
                Icons.close_rounded,
                size: 18,
                color: AppColors.lightGrey5,
              ),
            ),
          );
        }),
      ),
    );
  }
}


// import 'package:book_store_app/app/modules/seller_products/controllers/seller_products_controller.dart';
// import 'package:book_store_app/config/resources/app_colors.dart';
// import 'package:book_store_app/utils/app_font_size.dart';
// import 'package:book_store_app/utils/dimens.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';


// class ProductsSearchBar extends StatefulWidget {
//   final SellerProductsController controller;

//   const ProductsSearchBar({super.key, required this.controller});

//   @override
//   State<ProductsSearchBar> createState() => _ProductsSearchBarState();
// }

// class _ProductsSearchBarState extends State<ProductsSearchBar> {
//   final _textController = TextEditingController();

//   @override
//   void dispose() {
//     _textController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: AppColors.white,
//       padding: const EdgeInsets.fromLTRB(
//         AppDimen.allPadding,
//         10,
//         AppDimen.allPadding,
//         10,
//       ),
//       child: Container(
//         height: 44,
//         decoration: BoxDecoration(
//           color: AppColors.background,
//           borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius),
//           border: Border.all(color: AppColors.lightGrey2),
//         ),
//         child: Row(
//           children: [
//             const SizedBox(width: 12),
//             const Icon(
//               Icons.search_rounded,
//               size: AppDimen.iconSize,
//               color: AppColors.lightGrey5,
//             ),
//             const SizedBox(width: 8),
//             Expanded(
//               child: TextField(
                // controller: _textController,
                // onChanged: widget.controller.onSearch,
                // style: TextStyle(
                //   fontSize: AppFontSize.verySmall,
                //   color: AppColors.black,
                // ),
//                 decoration: InputDecoration(
                  // hintText: 'Search products...',
                  // hintStyle: TextStyle(
                  //   fontSize: AppFontSize.verySmall,
                  //   color: AppColors.lightGrey5,
                  // ),
//                   border: InputBorder.none,
//                   isDense: true,
//                   contentPadding: EdgeInsets.zero,
//                 ),
//               ),
//             ),
            // Obx(() {
            //   if (widget.controller.searchQuery.value.isEmpty) {
            //     return const SizedBox(width: 12);
            //   }
            //   return GestureDetector(
            //     onTap: () {
            //       _textController.clear();
            //       widget.controller.clearSearch();
            //     },
            //     child: const Padding(
            //       padding: EdgeInsets.symmetric(horizontal: 10),
            //       child: Icon(
            //         Icons.close_rounded,
            //         size: 18,
            //         color: AppColors.lightGrey5,
            //       ),
            //     ),
            //   );
            // }),
//           ],
//         ),
//       ),
//     );
//   }
// }
