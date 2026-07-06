import 'package:book_store_app/app/components/buttons/app_button.dart';
import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_rating_bar.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/modules/myorders/controllers/reviews_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
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
          ? const Center(
              child: CustomText(
                text: 'This item could not be loaded.',
                fontSize: AppFontSize.small2,
                color: AppColors.gray600,
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30),
              child: Column(
                spacing: 20,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(width: 0.5, color: AppColors.lightGrey2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CommonImageView(
                          url: item.image ?? '',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: CustomText(
                        text: item.name,
                        fontSize: AppFontSize.small,
                        fontWeight: FontWeight.bold,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: CustomText(
                        text: "Qty ${item.quantity}",
                        fontSize: AppFontSize.small2,
                        color: AppColors.gray600,
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(top: 20),
                    child: Column(
                      spacing: 10,
                      children: [
                        CustomText(
                          text: "Rate this Product",
                          fontSize: AppFontSize.small,
                          fontWeight: FontWeight.bold,
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
                    padding: const EdgeInsets.only(top: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CustomText(
                          text: "Message (optional)",
                          fontWeight: FontWeight.w600,
                          fontSize: AppFontSize.small,
                        ),
                        const SizedBox(height: 8),
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
                    () => AppButton(
                      label: controller.isSubmitting.value ? "Submitting..." : "Submit",
                      onPressed: controller.canSubmit ? controller.submit : null,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
