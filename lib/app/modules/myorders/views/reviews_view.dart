import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_rating_bar.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/modules/myorders/controllers/reviews_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/theme/base_typography.dart';
import 'package:book_store_app/core/widgets/buttons/base_buttons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReviewsView extends StatelessWidget {
  ReviewsView({super.key});

  final ReviewsController controller = Get.put(ReviewsController());

  @override
  Widget build(BuildContext context) {
    final item = controller.item;

    return Scaffold(
      appBar: CustomAppBarTwo(title: "Write a review"),
      body: item == null
          ? Center(
              child: Text(
                'This item could not be loaded.',
                style: BaseTypography.bodySmall(color: AppColors.gray600),
              ),
            )
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: BaseSpacing.xl, vertical: BaseSpacing.xxl - 2),
              child: Column(
                spacing: BaseSpacing.lg,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(width: 0.5, color: AppColors.lightGrey2),
                      borderRadius: BorderRadius.circular(BaseRadius.lg),
                    ),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(BaseRadius.sm),
                        child: CommonImageView(url: item.image ?? '', width: 50, height: 50, fit: BoxFit.cover),
                      ),
                      title: Text(
                        item.name,
                        style: BaseTypography.bodyMedium(color: AppColors.black).copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text("Qty ${item.quantity}", style: BaseTypography.bodySmall(color: AppColors.gray600)),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(top: BaseSpacing.xl),
                    child: Column(
                      spacing: BaseSpacing.sm,
                      children: [
                        Text(
                          "Rate this Product",
                          style: BaseTypography.bodyMedium(color: AppColors.black).copyWith(fontWeight: FontWeight.bold),
                        ),
                        Obx(
                          () => CustomRatingBar(
                            rating: controller.rating.value,
                            itemSize: 35,
                            onRatingUpdate: (value) => controller.rating.value = value,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: BaseSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Message (optional)",
                          style: BaseTypography.bodyMedium(color: AppColors.black).copyWith(fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: BaseSpacing.xs),
                        CustomTextField(
                          controller: controller.commentController,
                          hintText: "What did you like or dislike about this product?",
                          maxLines: 4,
                          isborder: true,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Obx(
                    () => PrimaryButton(
                      label: controller.isSubmitting.value ? "Submitting..." : "Submit",
                      isLoading: controller.isSubmitting.value,
                      onPressed: controller.canSubmit ? controller.submit : null,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
