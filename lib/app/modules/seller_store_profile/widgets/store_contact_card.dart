import 'package:book_store_app/app/modules/seller_store_profile/controllers/seller_store_profile_controller.dart';
import 'package:book_store_app/app/modules/seller_store_profile/widgets/store_info_row.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StoreContactCard extends StatelessWidget {
  final SellerStoreProfileController c;
  const StoreContactCard({super.key, required this.c});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimen.allPadding),
      child: Container(
        decoration: _cardDeco(),
        child: Obx(() {
          final email = c.store.value?.sellerEmail ?? '';
          return Column(children: [
            StoreInfoRow(
              icon: AppIcons.emailIcon,
              label: 'Email',
              value: email.isEmpty ? '—' : email,
            ),
            const Divider(height: 1, indent: 54, color: AppColors.lightGrey2),
            const StoreInfoRow(
              icon: AppIcons.phoneIcon,
              label: 'Phone',
              value: '—',
            ),
          ]);
        }),
      ),
    );
  }
}

BoxDecoration _cardDeco() => BoxDecoration(
  color: AppColors.white,
  borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius),
  boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
);
