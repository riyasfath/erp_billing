import 'package:ecommerce_app/core/api_client.dart';
import 'package:ecommerce_app/core/providers.dart';
import 'package:ecommerce_app/models/product_review_model.dart';

/// Network calls for /api/products/reviews/ (POST — add a review) and
/// /api/products/reviews/my/ (GET — the signed-in user's own reviews).
class ProductReviewService {
  final ApiClient _apiClient;

  ProductReviewService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<void> addReview({
    required int productId,
    required int rating,
    required String comment,
  }) async {
    await _apiClient.post(ApiEndpoints.addProductReview, {
      'product': productId,
      'rating': rating,
      'comment': comment,
    });
  }

  /// Plain array response (not paginated) — matches the shape used
  /// everywhere else in this API that doesn't return `results`/`count`.
  Future<List<MyProductReviewModel>> getMyReviews() async {
    final data = await _apiClient.get(ApiEndpoints.myProductReviews);
    final list = (data['data'] as List?) ?? (data['results'] as List?) ?? [];
    return list.map((e) => MyProductReviewModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}