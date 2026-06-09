import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/pos_home/controllers/pos_home_controller.dart';
import 'package:book_store_app/app/modules/pos_home/widgets/pos_cart_bar.dart';
import 'package:book_store_app/app/modules/pos_home/widgets/pos_category_row.dart';
import 'package:book_store_app/app/modules/pos_home/widgets/pos_product_card.dart';
import 'package:book_store_app/app/modules/pos_home/widgets/pos_search_bar.dart';
import 'package:book_store_app/app/modules/pos/widgets/pos_app_bar.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PosHomeView extends StatelessWidget {
  final c = Get.put(PosHomeController());

  PosHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(children: [
        Column(children: [
          const PosAppBar(),
          PosSearchBar(c: c),
          const Divider(height: 1, color: AppColors.lightGrey2),
          PosCategoryRow(c: c),
          const Divider(height: 1, color: AppColors.lightGrey2),
          Expanded(child: _ProductGrid(c: c)),
        ]),

        Obx(() => AnimatedPositioned(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
          bottom: c.hasItems ? (bottomPad + 12) : -(100 + bottomPad),
          left: 16,
          right: 16,
          child: PosCartBar(c: c),
        )),
      ]),
    );
  }
}

class _ProductGrid extends StatelessWidget {
  final PosHomeController c;
  const _ProductGrid({required this.c});

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Obx(() {
      final products = c.filteredProducts;
      if (products.isEmpty) {
        return Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.search_off_rounded, size: 52, color: AppColors.lightGrey2),
            const SizedBox(height: 12),
            const CustomText(
              text: 'No products found',
              fontSize: AppFontSize.small2,
              fontWeight: FontWeight.w500,
              color: AppColors.iosGrey,
            ),
            const SizedBox(height: 4),
            const CustomText(
              text: 'Try a different search or category',
              fontSize: AppFontSize.tiny,
              color: AppColors.lightGrey,
            ),
          ]),
        );
      }
      return GridView.builder(
        padding: EdgeInsets.fromLTRB(12, 12, 12, c.hasItems ? (bottomPad + 88) : 12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.72,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: products.length,
        itemBuilder: (_, i) => PosProductCard(c: c, product: products[i]),
      );
    });
  }
}
