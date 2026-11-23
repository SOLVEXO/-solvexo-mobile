import 'package:book_store_app/app/components/buyer_states.dart';
import 'package:book_store_app/app/data/models/rating/review_model.dart';
import 'package:book_store_app/app/data/repositories/rating_repository.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// My reviews (/account/reviews, B7): GET /api/rating/my-reviews, delete.
class MyReviewsView extends StatefulWidget {
  const MyReviewsView({super.key, this.repo});
  final RatingRepository? repo;

  @override
  State<MyReviewsView> createState() => _MyReviewsViewState();
}

class _MyReviewsViewState extends State<MyReviewsView> {
  late final RatingRepository _repo = widget.repo ?? RatingRepository();
  List<ReviewModel>? _items;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _items = null;
      _failed = false;
    });
    try {
      final r = await _repo.fetchMyReviews();
      if (mounted) setState(() => _items = r);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  Future<void> _delete(ReviewModel r) async {
    final ok = await Get.dialog<bool>(AlertDialog(
      title: Text('Delete this review?'.tr),
      actions: [
        TextButton(onPressed: () => Get.back(result: false), child: Text('Cancel'.tr)),
        FilledButton(onPressed: () => Get.back(result: true), child: Text('Delete'.tr)),
      ],
    ));
    if (ok != true) return;
    if (await _repo.deleteReview(r.reviewId)) {
      setState(() => _items?.removeWhere((x) => x.reviewId == r.reviewId));
      ToastUtil.showToast('Review deleted'.tr);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    Widget body;
    if (_failed) {
      body = BuyerError(message: 'Could not load your reviews.'.tr, onRetry: _load);
    } else if (_items == null) {
      body = const BuyerSkeleton(rows: 3);
    } else if (_items!.isEmpty) {
      body = BuyerEmpty(icon: Icons.rate_review_outlined, title: 'No reviews yet'.tr, body: 'You can review items from your orders after they arrive.'.tr);
    } else {
      body = RefreshIndicator(
        onRefresh: _load,
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: _items!.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final r = _items![i];
            return Card(
              key: Key('myReview_${r.reviewId}'),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    if ((r.product?.image ?? '').isNotEmpty)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(end: 10),
                        child: CachedNetworkImage(imageUrl: r.product!.image!, width: 44, memCacheWidth: 132, height: 44, fit: BoxFit.cover),
                      ),
                    Expanded(child: Text(r.product?.name ?? '', style: t.textTheme.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis)),
                    IconButton(
                      tooltip: 'Delete'.tr,
                      style: IconButton.styleFrom(minimumSize: const Size(44, 44)),
                      onPressed: () => _delete(r),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ]),
                  if (r.rating != null)
                    Row(children: [for (var k = 1; k <= 5; k++) Icon(k <= r.rating!.round() ? Icons.star_rounded : Icons.star_border_rounded, size: 18, color: Colors.amber)]),
                  if (r.commentText.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 6), child: Text(r.commentText)),
                  if (r.usedFor != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text('${'Used'.tr}: ${ReviewRules.usedForLabel(r.usedFor!).tr}', key: Key('myReviewUsedFor_${r.reviewId}'), style: t.textTheme.bodySmall),
                    ),
                  if (r.media.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Wrap(spacing: 6, runSpacing: 6, key: Key('myReviewPhotos_${r.reviewId}'), children: [
                        for (final url in r.media.take(ReviewRules.maxPhotos))
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: CachedNetworkImage(imageUrl: url, width: 56, height: 56, memCacheWidth: 168, fit: BoxFit.cover,
                                errorWidget: (_, __, ___) => const SizedBox(width: 56, height: 56, child: Icon(Icons.broken_image_outlined))),
                          ),
                      ]),
                    ),
                  if (r.sellerReply != null)
                    Padding(padding: const EdgeInsets.only(top: 6), child: Text('${'Seller response'.tr}: ${r.sellerReply!.text}', style: t.textTheme.bodySmall)),
                ]),
              ),
            );
          },
        ),
      );
    }
    return Scaffold(appBar: AppBar(title: Text('My reviews'.tr)), body: body);
  }
}

/// Report a review (buyer): POST /api/rating/:reviewId/report-by-buyer
/// (backend fix #6). Goes to the Edudeen moderation queue.
class ReportReviewSheet extends StatefulWidget {
  const ReportReviewSheet({super.key, required this.review, this.repo});
  final ReviewModel review;
  final RatingRepository? repo;

  static Future<void> open(ReviewModel r) =>
      Get.bottomSheet(ReportReviewSheet(review: r), isScrollControlled: true, backgroundColor: Get.theme.colorScheme.surface);

  @override
  State<ReportReviewSheet> createState() => _ReportReviewSheetState();
}

class _ReportReviewSheetState extends State<ReportReviewSheet> {
  late final RatingRepository _repo = widget.repo ?? RatingRepository();
  final _details = TextEditingController();
  String? _reason;
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _details.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_reason == null) return setState(() => _error = 'Choose a reason.'.tr);
    if (_reason == 'other' && _details.text.trim().length < ReportReasons.otherMin) {
      return setState(() => _error = 'Please tell us more (at least 5 characters).'.tr);
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final r = await _repo.reportReview(reviewId: widget.review.reviewId, reasonCode: _reason!, text: _details.text);
    if (!mounted) return;
    setState(() => _busy = false);
    if (r.ok) {
      Get.back();
      ToastUtil.showToast('Thanks. Our team will check this review.'.tr);
    } else if (r.alreadyReported) {
      Get.back();
      ToastUtil.showToast('You already reported this review.'.tr);
    } else {
      setState(() => _error = r.message ?? 'Could not send your report. Please try again.'.tr);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('Report this review'.tr, style: Theme.of(context).textTheme.titleMedium),
          RadioGroup<String>(
            groupValue: _reason,
            onChanged: (v) => setState(() => _reason = v),
            child: Column(children: [
              for (final code in ReportReasons.codes)
                RadioListTile<String>(key: Key('reportReason_$code'), value: code, title: Text(ReportReasons.label(code).tr), contentPadding: EdgeInsets.zero),
            ]),
          ),
          TextField(controller: _details, maxLength: ReportReasons.textMax, maxLines: 3, decoration: InputDecoration(labelText: 'Details (optional)'.tr, border: const OutlineInputBorder())),
          if (_error != null) Text(_error!, key: const Key('reportError'), style: TextStyle(color: Theme.of(context).colorScheme.error)),
          const SizedBox(height: 8),
          FilledButton(
            key: const Key('reportSend'),
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            onPressed: _busy ? null : _send,
            child: Text('Send report'.tr),
          ),
        ]),
      ),
    );
  }
}
