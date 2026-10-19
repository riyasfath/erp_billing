import '../admin_api_client.dart';
import '../admin_endpoints.dart';
import '../admin_model/admin_support_model.dart';

class AdminSupportService {
  final AdminApiClient _apiClient;

  AdminSupportService({AdminApiClient? apiClient}) : _apiClient = apiClient ?? AdminApiClient();

  Future<AdminSupportStatsModel> getStats() async {
    final data = await _apiClient.get(AdminEndpoints.supportStats);
    return AdminSupportStatsModel.fromJson(data);
  }

  /// Plain array response (not paginated), matching the sample given.
  Future<List<AdminSupportTicketModel>> getTickets() async {
    final data = await _apiClient.get(AdminEndpoints.supportTickets);
    final list = (data['data'] as List?) ?? (data['results'] as List?) ?? [];
    return list.map((e) => AdminSupportTicketModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<AdminSupportTicketModel> getDetail(int id) async {
    final data = await _apiClient.get(AdminEndpoints.supportTicketDetail(id));
    return AdminSupportTicketModel.fromJson(data);
  }

  /// Body shape wasn't shown explicitly in the sample (only the
  /// resulting response was) — {"status": "..."} matches the pattern
  /// used everywhere else in this API. Confirm if the server rejects it.
  Future<AdminSupportTicketModel> updateStatus(int id, String status) async {
    final data = await _apiClient.patchJson(AdminEndpoints.supportTicketDetail(id), {'status': status});
    return AdminSupportTicketModel.fromJson(data);
  }
}