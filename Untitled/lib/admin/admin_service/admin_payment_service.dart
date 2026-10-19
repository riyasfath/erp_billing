import '../admin_api_client.dart';
import '../admin_endpoints.dart';
import '../admin_model/admin_payment_model.dart';

class AdminPaymentService {
  final AdminApiClient _apiClient;

  AdminPaymentService({AdminApiClient? apiClient}) : _apiClient = apiClient ?? AdminApiClient();

  /// Plain array response (not paginated), matching the sample given.
  Future<List<AdminPaymentModel>> getPayments() async {
    final data = await _apiClient.get(AdminEndpoints.paymentsAll);
    final list = (data['data'] as List?) ?? (data['results'] as List?) ?? [];
    return list.map((e) => AdminPaymentModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}