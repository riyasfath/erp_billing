import 'package:flutter/foundation.dart';

import 'package:ecommerce_app/core/api_exception.dart';
import 'package:ecommerce_app/models/product_review_model.dart';
import 'package:ecommerce_app/service/product_review_service.dart';

class ProductReviewViewModel extends ChangeNotifier {
  final ProductReviewService _service;

  ProductReviewViewModel({ProductReviewService? service}) : _service = service ?? ProductReviewService();

  bool isSubmitting = false;
  String? submitError;

  bool isLoadingMyReviews = false;
  List<MyProductReviewModel> myReviews = [];

  Future<bool> submitReview({
    required String productId,
    required int rating,
    required String comment,
  }) async {
    final idInt = int.tryParse(productId);
    if (idInt == null) {
      submitError = 'Something went wrong with this product.';
      notifyListeners();
      return false;
    }

    isSubmitting = true;
    submitError = null;
    notifyListeners();

    bool success = false;
    try {
      await _service.addReview(productId: idInt, rating: rating, comment: comment);
      success = true;
    } on ApiException catch (e) {
      submitError = e.message;
    } catch (_) {
      submitError = 'Could not submit your review. Please try again.';
    }
    isSubmitting = false;
    notifyListeners();
    return success;
  }

  Future<void> fetchMyReviews() async {
    isLoadingMyReviews = true;
    notifyListeners();
    try {
      myReviews = await _service.getMyReviews();
    } catch (_) {
      // Silent — used opportunistically to pre-fill "already reviewed"
      // state; not worth an error banner if it fails to load.
    }
    isLoadingMyReviews = false;
    notifyListeners();
  }

  /// Has the signed-in user already reviewed this product? Returns
  /// that review if so (null if not, or if myReviews hasn't loaded /
  /// the API didn't include a matchable product id).
  MyProductReviewModel? existingReviewFor(String productId) {
    final idInt = int.tryParse(productId);
    if (idInt == null) return null;
    for (final review in myReviews) {
      if (review.productId == idInt) return review;
    }
    return null;
  }
}