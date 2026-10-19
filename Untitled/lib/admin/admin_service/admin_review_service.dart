import '../admin_api_client.dart';
import '../admin_endpoints.dart';

class AdminReviewService {
  final AdminApiClient _apiClient;

  AdminReviewService({AdminApiClient? apiClient}) : _apiClient = apiClient ?? AdminApiClient();

  Future<void> approveReview(int reviewId) async {
    await _apiClient.postJson(AdminEndpoints.reviewUpdateStatus(reviewId), {'status': 'approved'});
  }

  Future<void> rejectReview(int reviewId, String reason) async {
    await _apiClient.postJson(AdminEndpoints.reviewUpdateStatus(reviewId), {'status': 'rejected', 'reason': reason});
  }

  Future<void> replyToReview(int reviewId, String reply) async {
    await _apiClient.postJson(AdminEndpoints.reviewReply(reviewId), {'reply': reply});
  }
}