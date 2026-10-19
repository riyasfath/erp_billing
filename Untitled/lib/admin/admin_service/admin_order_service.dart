import '../admin_api_client.dart';
import '../admin_endpoints.dart';
import '../admin_model/admin_order_model.dart';

class AdminOrderService {
  final AdminApiClient _apiClient;

  AdminOrderService({AdminApiClient? apiClient}) : _apiClient = apiClient ?? AdminApiClient();

  Future<({List<AdminOrderModel> orders, String? nextUrl})> getOrders(String url) async {
    final data = await _apiClient.get(url);
    final results = (data['results'] as List? ?? []).map((e) => AdminOrderModel.fromJson(e as Map<String, dynamic>)).toList();
    return (orders: results, nextUrl: data['next']?.toString());
  }

  Future<AdminOrderModel> getDetail(int id) async {
    final data = await _apiClient.get(AdminEndpoints.orderDetail(id));
    return AdminOrderModel.fromJson(data);
  }

  /// Confirmed shape: {status, payment_status, transaction_id} — any
  /// subset. status must be one of the API's own `_status_options`
  /// (confirmed, processing, shipped, delivered, cancelled, refunded).
  Future<void> updateOrder(int id, {String? status, String? paymentStatus, String? transactionId}) async {
    await _apiClient.patchJson(AdminEndpoints.orderUpdate(id), {
      if (status != null) 'status': status,
      if (paymentStatus != null) 'payment_status': paymentStatus,
      if (transactionId != null) 'transaction_id': transactionId,
    });
  }
}