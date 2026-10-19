
import 'package:ecommerce_app/admin/admin_api_client.dart';
import 'package:ecommerce_app/admin/admin_endpoints.dart';
import 'package:ecommerce_app/admin/admin_model/admin_stats_model.dart';

class AdminDashboardService {
  final AdminApiClient _apiClient;

  AdminDashboardService({AdminApiClient? apiClient}) : _apiClient = apiClient ?? AdminApiClient();

  Future<DashboardStatsModel> getStats() async {
    final data = await _apiClient.get(AdminEndpoints.dashboardStats);
    return DashboardStatsModel.fromJson(data);
  }
}