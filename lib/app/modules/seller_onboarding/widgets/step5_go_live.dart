import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/seller_onboarding/controllers/seller_onboarding_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Step5GoLive extends StatelessWidget {
  final SellerOnboardingController controller;

  const Step5GoLive({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimen.allPadding),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(AppDimen.allPadding),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius + 4),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                const Text('🎉', style: TextStyle(fontSize: 52)),
                const SizedBox(height: 16),
                const CustomText(
                  text: 'Your store is ready!',
                  fontSize: AppFontSize.veryLarge,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const CustomText(
                  text: 'Welcome to EduDeen. Your seller dashboard is set up and your tools are activated. Let\'s make your first sale.',
                  fontSize: AppFontSize.verySmall,
                  color: AppColors.grey,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _SetupSummary(controller: controller),
                const SizedBox(height: 24),
                const _SectionTitle(title: 'Recommended next steps'),
                const SizedBox(height: 14),
                _NextStepsRow(),
                const SizedBox(height: 20),
                _UpgradeNote(),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ── Setup summary card ────────────────────────────────────────────────────────

class _SetupSummary extends StatelessWidget {
  final SellerOnboardingController controller;
  const _SetupSummary({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CustomText(
              text: 'Your EduDeen Setup',
              fontSize: AppFontSize.verySmall,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
            const SizedBox(height: 12),
            _SummaryRow(
              emoji: '🏪',
              label: 'Store',
              value: controller.storeName.value.isEmpty
                  ? 'My EduDeen Store'
                  : controller.storeName.value,
            ),
            _SummaryRow(
              emoji: '👤',
              label: 'Seller type',
              value: controller.sellerTypeName.isEmpty
                  ? 'Not selected'
                  : controller.sellerTypeName,
            ),
            _SummaryRow(
              emoji: '📦',
              label: 'Products activated',
              value: controller.activatedProductsLabel,
            ),
            _SummaryRow(emoji: '💳', label: 'Plan', value: 'Starter — Free'),
            const _SummaryRow(emoji: '✨', label: 'AI Credits', value: '100 free credits included'),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;

  const _SummaryRow({
    required this.emoji,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            child: Text(emoji, style: const TextStyle(fontSize: 14)),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 100,
            child: CustomText(
              text: label,
              fontSize: AppFontSize.tiny,
              color: AppColors.grey,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: CustomText(
              text: value,
              fontSize: AppFontSize.tiny,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Next steps ────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: CustomText(
        text: title,
        fontSize: AppFontSize.verySmall,
        fontWeight: FontWeight.bold,
        color: AppColors.black,
      ),
    );
  }
}

class _NextStepsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(child: _NextStepCard(emoji: '➕', label: 'Add your first product')),
        SizedBox(width: 10),
        Expanded(child: _NextStepCard(emoji: '🏗️', label: 'Customise your store')),
        SizedBox(width: 10),
        Expanded(child: _NextStepCard(emoji: '🛍️', label: 'Browse the marketplace')),
      ],
    );
  }
}

class _NextStepCard extends StatelessWidget {
  final String emoji;
  final String label;

  const _NextStepCard({required this.emoji, required this.label});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius),
          border: Border.all(color: AppColors.lightGrey2),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            CustomText(
              text: label,
              fontSize: AppFontSize.tiny,
              fontWeight: FontWeight.w500,
              color: AppColors.black2,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Upgrade note ──────────────────────────────────────────────────────────────

class _UpgradeNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: const TextStyle(fontSize: 11, color: AppColors.grey),
        children: [
          const TextSpan(text: "You're on the free Starter plan. "),
          TextSpan(
            text: 'Upgrade anytime',
            style: const TextStyle(
              color: AppColors.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const TextSpan(
            text: ' to unlock unlimited products, AI Studio, POS, and custom domain.',
          ),
        ],
      ),
    );
  }
}
