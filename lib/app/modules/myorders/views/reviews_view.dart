import 'package:book_store_app/app/components/app_image_picker.dart';
import 'package:book_store_app/app/components/buyer_states.dart';
import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_rating_bar.dart';
import 'package:book_store_app/app/data/repositories/rating_repository.dart';
import 'package:book_store_app/app/modules/myorders/controllers/reviews_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Write a review (B7). Reached only from items with `canReview` (order
/// line items / product page). Fields follow AddReviewDto: rating 1-5,
/// comment <= 2000, usedFor home|classroom|school, up to 4 photos.
class ReviewsView extends StatelessWidget {
  ReviewsView({super.key});

  final ReviewsController controller = Get.put(ReviewsController());

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final item = c.item;
    final t = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text('Write a review'.tr)),
      body: item == null
          ? BuyerEmpty(icon: Icons.rate_review_outlined, title: 'This item could not be loaded.'.tr)
          : Obx(() => ListView(padding: const EdgeInsets.all(16), children: [
                Card(
                  child: ListTile(
                    leading: ClipRRect(borderRadius: BorderRadius.circular(6), child: CommonImageView(url: item.image ?? '', width: 50, height: 50, fit: BoxFit.cover)),
                    title: Text(item.name, maxLines: 2, overflow: TextOverflow.ellipsis),
                    subtitle: Text('${'Qty'.tr} ${item.quantity}'),
                  ),
                ),
                const SizedBox(height: 16),
                Text('${'Rate this product'.tr} *', style: t.textTheme.titleSmall),
                const SizedBox(height: 8),
                Center(child: CustomRatingBar(rating: c.rating.value, itemSize: 40, onRatingUpdate: (v) => c.rating.value = v)),
                const SizedBox(height: 16),
                Text('Where do you use it?'.tr, style: t.textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(spacing: 8, children: [
                  for (final u in ReviewRules.usedFor)
                    ChoiceChip(
                      key: Key('usedFor_$u'),
                      label: Text(ReviewRules.usedForLabel(u).tr),
                      selected: c.usedFor.value == u,
                      materialTapTargetSize: MaterialTapTargetSize.padded,
                      onSelected: (s) => c.usedFor.value = s ? u : null,
                    ),
                ]),
                const SizedBox(height: 16),
                TextField(
                  key: const Key('reviewComment'),
                  controller: c.commentController,
                  minLines: 3,
                  maxLines: 6,
                  maxLength: ReviewRules.commentMax,
                  decoration: InputDecoration(
                    labelText: 'Message (optional)'.tr,
                    hintText: 'What did you like or dislike about this product?'.tr,
                    border: const OutlineInputBorder(),
                  ),
                ),
                Text('${'Photos'.tr} (${c.photos.length}/${ReviewRules.maxPhotos})', style: t.textTheme.titleSmall),
                const SizedBox(height: 6),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  for (final p in c.photos)
                    Stack(children: [
                      ClipRRect(borderRadius: BorderRadius.circular(8), child: CachedNetworkImage(imageUrl: p, width: 72, height: 72, fit: BoxFit.cover)),
                      PositionedDirectional(
                        top: 0,
                        end: 0,
                        child: InkWell(onTap: () => c.photos.remove(p), child: const CircleAvatar(radius: 12, child: Icon(Icons.close, size: 14))),
                      ),
                    ]),
                  if (c.photos.length < ReviewRules.maxPhotos)
                    InkWell(
                      key: const Key('addReviewPhoto'),
                      onTap: c.uploading.value ? null : () => AppImagePicker.show(onPicked: c.addPhoto),
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(border: Border.all(color: t.colorScheme.outline), borderRadius: BorderRadius.circular(8)),
                        child: c.uploading.value ? const Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.add_a_photo_outlined),
                      ),
                    ),
                ]),
                const SizedBox(height: 20),
                if (c.rating.value == 0) Text('Choose a star rating to submit.'.tr, style: t.textTheme.bodySmall),
                FilledButton(
                  key: const Key('reviewSubmit'),
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                  onPressed: c.canSubmit ? c.submit : null,
                  child: c.isSubmitting.value
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text('Submit'.tr),
                ),
              ])),
    );
  }
}
