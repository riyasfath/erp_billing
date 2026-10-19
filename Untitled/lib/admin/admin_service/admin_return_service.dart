import '../admin_api_client.dart';
import '../admin_endpoints.dart';
import '../admin_model/admin_return_model.dart';

class AdminReturnService {
  final AdminApiClient _apiClient;

  AdminReturnService({AdminApiClient? apiClient}) : _apiClient = apiClient ?? AdminApiClient();

  /// Plain array response (not paginated), matching the sample given.
  Future<List<AdminReturnModel>> getReturns() async {
    final data = await _apiClient.get(AdminEndpoints.returnsAll);
    final list = (data['data'] as List?) ?? (data['results'] as List?) ?? [];
    return list.map((e) => AdminReturnModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<AdminReturnModel> getDetail(int id) async {
    final data = await _apiClient.get(AdminEndpoints.returnDetail(id));
    return AdminReturnModel.fromJson(data);
  }

  /// action is one of: approve, schedule_pickup, mark_picked_up,
  /// quality_check_pass, initiate_refund, complete_refund,
  /// quality_check_fail. category/note only apply to quality_check_fail.
  Future<void> processReturn(int id, String action, {String? category, String? note}) async {
    await _apiClient.postJson(AdminEndpoints.returnProcess(id), {
      'action': action,
      if (category != null) 'category': category,
      if (note != null) 'note': note,
    });
  }
}