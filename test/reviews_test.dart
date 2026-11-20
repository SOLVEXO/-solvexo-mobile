import 'package:book_store_app/app/data/models/rating/review_model.dart';
import 'package:book_store_app/app/data/repositories/rating_repository.dart';
import 'package:book_store_app/app/modules/my_reviews/my_reviews_view.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;

// Live (test buyer, 2026-11-20; review deleted right after, my-reviewed-ids back to []):
// POST /api/rating/add-review {productId, rating:5, comment, usedFor:"home"} -> 201
//   {"success":true,"message":"Review added","data":{"rating":5,"media":[],"isVerifiedPurchase":true,"usedFor":"home",..}}
// GET /api/rating/my-reviews -> {"reviews":[{"reviewId":"6afff059d1f43443b864e9c9","product":{"productId":"6ae33f4c3da5d8d7d7033bd4",
//   "name":"Basic Computer Skills Course","image":".."},"rating":5,"comments":[{"text":"TEST review - will be deleted"}],
//   "media":[],"isVerifiedPurchase":true,"sellerReply":null}]}
// DELETE /api/rating/6afff059d1f43443b864e9c9 -> 200 "Review deleted"
const _live = {
  'reviewId': '6afff059d1f43443b864e9c9',
  'product': {'productId': '6ae33f4c3da5d8d7d7033bd4', 'name': 'Basic Computer Skills Course', 'image': null},
  'rating': 5,
  'comments': [{'text': 'TEST review - will be deleted', 'createdAt': '2026-11-20T07:01:45.871Z'}],
  'media': [],
  'isVerifiedPurchase': true,
  'sellerReply': null,
};

class _Client extends BaseClient {
  Map? sent;
  @override
  Future<Response> post(String url, {dynamic data, Map<String, dynamic>? queryParameters, bool requiresAuth = true, Map<String, dynamic>? headers}) async {
    sent = data as Map;
    return Response(requestOptions: RequestOptions(path: url), statusCode: 201, data: {'success': true});
  }
}

class _Repo extends RatingRepository {
  _Repo(this.result);
  final Object result;
  @override
  Future<List<ReviewModel>> fetchMyReviews({int page = 1}) async => result is List<ReviewModel> ? result as List<ReviewModel> : throw result;
}

Widget _app(Widget w) => GetMaterialApp(home: Scaffold(body: w));

void main() {
  test('add-review sends usedFor + media (AddReviewDto)', () async {
    final c = _Client();
    final r = await RatingRepository(client: c).addReview(productId: 'p', rating: 5, usedFor: 'classroom', media: ['https://x/1.jpg']);
    expect(r.success, isTrue);
    expect(c.sent, containsPair('usedFor', 'classroom'));
    expect(c.sent!['media'], ['https://x/1.jpg']);
    expect(ReviewRules.usedFor, ['home', 'classroom', 'school']);
    expect(ReviewRules.maxPhotos, 4);
  });

  testWidgets('my reviews: list, empty, error + retry', (t) async {
    await t.pumpWidget(_app(MyReviewsView(repo: _Repo([ReviewModel.fromJson(_live)]))));
    await t.pumpAndSettle();
    expect(find.text('Basic Computer Skills Course'), findsOneWidget);
    expect(find.text('TEST review - will be deleted'), findsOneWidget);
    await t.pumpWidget(_app(MyReviewsView(key: const Key('e'), repo: _Repo(<ReviewModel>[]))));
    await t.pumpAndSettle();
    expect(find.text('No reviews yet'), findsOneWidget);
    await t.pumpWidget(_app(MyReviewsView(key: const Key('f'), repo: _Repo(Exception('x')))));
    await t.pumpAndSettle();
    expect(find.text('Could not load your reviews.'), findsOneWidget);
  });

  testWidgets('report sheet needs a reason', (t) async {
    await t.pumpWidget(_app(ReportReviewSheet(review: ReviewModel.fromJson(_live), repo: _Repo(const <ReviewModel>[]))));
    await t.tap(find.byKey(const Key('reportSend')));
    await t.pump();
    expect(find.text('Choose a reason.'), findsOneWidget);
  });
}
