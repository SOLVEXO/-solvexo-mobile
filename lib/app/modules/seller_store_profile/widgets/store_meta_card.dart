import 'package:book_store_app/app/modules/seller_store_profile/controllers/seller_store_profile_controller.dart';
import 'package:book_store_app/app/modules/seller_store_profile/widgets/store_info_row.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StoreMetaCard extends StatelessWidget {
  final SellerStoreProfileController c;
  const StoreMetaCard({super.key, required this.c});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimen.allPadding),
      child: Container(
        decoration: _cardDeco(),
        child: Obx(() {
          final s = c.store.value;
          return Column(children: [
            StoreInfoRow(
              icon: AppIcons.dashboardIcon,
              label: 'Category',
              value: s?.categoryId ?? '—',
            ),
            const Divider(height: 1, indent: 54, color: AppColors.lightGrey2),
            StoreInfoRow(
              icon: AppIcons.calenderIcon,
              label: 'Member Since',
              value: s != null
                  ? '${_monthName(s.createdAt.month)} ${s.createdAt.year}'
                  : '—',
            ),
            const Divider(height: 1, indent: 54, color: AppColors.lightGrey2),
            StoreInfoRow(
              icon: AppIcons.cartIcon,
              label: 'Store Status',
              value: s?.isActive == true ? 'Active & Verified' : 'Inactive',
            ),
          ]);
        }),
      ),
    );
  }

  String _monthName(int m) => const [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ][m];
}

BoxDecoration _cardDeco() => BoxDecoration(
  color: AppColors.white,
  borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius),
  boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
);
