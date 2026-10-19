import 'package:ecommerce_app/admin/admin_api_client.dart';
import 'package:ecommerce_app/admin/admin_model/admin_stats_model.dart';
import 'package:ecommerce_app/admin/admin_service/admin_dashboard_service.dart';
import 'package:flutter/foundation.dart';


class AdminDashboardViewModel extends ChangeNotifier {
  final AdminDashboardService _service;

  AdminDashboardViewModel({AdminDashboardService? service}) : _service = service ?? AdminDashboardService();

  bool isLoading = false;
  String? error;
  DashboardStatsModel? stats;

  Future<void> fetchStats() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      stats = await _service.getStats();
      isLoading = false;
    } on AdminApiException catch (e) {
      isLoading = false;
      error = e.message;
    } catch (_) {
      isLoading = false;
      error = 'Could not load dashboard stats.';
    }
    notifyListeners();
  }
}