import 'package:book_store_app/app/components/custom_refresh_wrapper.dart';
import 'package:book_store_app/app/modules/seller_stores/controllers/seller_stores_controller.dart';
import 'package:book_store_app/app/modules/seller_stores/widgets/stores_hero_header.dart';
import 'package:book_store_app/app/modules/seller_stores/widgets/stores_list.dart';
import 'package:book_store_app/app/modules/seller_stores/widgets/stores_section_header.dart';
import 'package:book_store_app/app/modules/seller_stores/widgets/stores_shimmer.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerStoresView extends StatelessWidget {
  SellerStoresView({super.key});

  final SellerStoresController controller = Get.put(SellerStoresController());

  @override
  Widget build(BuildContext context) {
    // One store per seller (backend 5adba44: a second create-store -> 409
    // "You already have a store — each seller account can run one store").
    // This picker only lists legacy stores; there is no "Create New Store".
    return Scaffold(
      backgroundColor: AppColors.textfldFillColor,
      body: Obx(() {
        if (controller.isLoading.value) return const StoresShimmer();
        return CustomRefreshWrapper(
          onRefresh: controller.refreshStores,
          child: SingleChildScrollView(
            child: Column(
              children: [
                StoresHeroHeader(controller: controller),
                Transform.translate(
                  offset: const Offset(0, -24),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.textfldFillColor,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        StoresSectionHeader(controller: controller),
                        const SizedBox(height: 12),
                        StoresList(controller: controller),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
