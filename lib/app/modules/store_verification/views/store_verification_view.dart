import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_refresh_wrapper.dart';
import 'package:book_store_app/app/modules/store_verification/controllers/store_verification_controller.dart';
import 'package:book_store_app/app/modules/store_verification/widgets/verification_bottom_bar.dart';
import 'package:book_store_app/app/modules/store_verification/widgets/verification_business_section.dart';
import 'package:book_store_app/app/modules/store_verification/widgets/verification_contact_section.dart';
import 'package:book_store_app/app/modules/store_verification/widgets/verification_documents_section.dart';
import 'package:book_store_app/app/modules/store_verification/widgets/verification_history_section.dart';
import 'package:book_store_app/app/modules/store_verification/widgets/verification_status_banner.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StoreVerificationView extends StatelessWidget {
  StoreVerificationView({super.key});

  final StoreVerificationController c = Get.put(StoreVerificationController());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: AppColors.background,
        appBar: const CustomAppBarTwo(title: 'Business Verification'),
        body: c.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : CustomRefreshWrapper(
                onRefresh: c.refreshData,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppDimen.allPadding,
                  ),
                  child: Column(
                    children: [
                      VerificationStatusBanner(c: c),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimen.allPadding,
                        ),
                        child: VerificationBusinessSection(c: c),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimen.allPadding,
                        ),
                        child: VerificationContactSection(c: c),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimen.allPadding,
                        ),
                        child: VerificationDocumentsSection(c: c),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimen.allPadding,
                        ),
                        child: VerificationHistorySection(c: c),
                      ),
                    ],
                  ),
                ),
              ),
        bottomNavigationBar: c.isLoading.value
            ? null
            : VerificationBottomBar(
                c: c,
                bottomInset: MediaQuery.of(context).padding.bottom,
              ),
      ),
    );
  }
}
