import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/pos_home/controllers/pos_home_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:flutter/material.dart';

class PosSearchBar extends StatelessWidget {
  final PosHomeController c;
  const PosSearchBar({super.key, required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: [
          Expanded(
            child: CustomTextField(
              controller: c.searchController,
              onChanged: c.onSearchChanged,
              hintText: 'Search products or SKU...',
              fillColor: AppColors.textfldFillColor,
              isborder: true,
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 46,
              height: 46,
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryColor.withOpacity(0.25),
                ),
              ),
              child: SvgIcon(
                assetName: AppIcons.barcodeIcon,
                color: AppColors.primaryColor,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
