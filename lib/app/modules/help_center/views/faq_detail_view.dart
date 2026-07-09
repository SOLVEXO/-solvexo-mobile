import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/theme/base_typography.dart';
import 'package:book_store_app/core/widgets/buttons/base_buttons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/faq_model.dart';

class FAQDetailView extends StatelessWidget {
  const FAQDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final FaqModel faq = Get.arguments;

    return Scaffold(
      appBar: CustomAppBarTwo(title: "FAQ"),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: BaseSpacing.xxl - 2, vertical: BaseSpacing.xs),
        child: Column(
          spacing: BaseSpacing.lg,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              faq.question,
              style: BaseTypography.bodyMedium(color: AppColors.black).copyWith(fontWeight: FontWeight.w600),
            ),
            Text(faq.answer, style: BaseTypography.bodyMedium(color: AppColors.black)),
            Row(
              spacing: BaseSpacing.sm + 3,
              children: [
                // NOTE (incomplete feature): both "Was this helpful?" buttons
                // have no handler wired up — tapping does nothing. Not
                // implementing new feedback-submission logic here since
                // there's no endpoint/controller method for it anywhere in
                // this module; flagging rather than guessing.
                Expanded(
                  child: OutlineButton(
                    label: "Yes",
                    onPressed: () {},
                    icon: const Icon(Icons.thumb_up_alt_outlined, color: AppColors.primaryColor, size: 20),
                  ),
                ),
                Expanded(
                  child: OutlineButton(
                    label: "No",
                    onPressed: () {},
                    icon: const Icon(Icons.thumb_down_alt_outlined, color: AppColors.primaryColor, size: 20),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
