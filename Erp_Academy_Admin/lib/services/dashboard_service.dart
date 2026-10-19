import '../core/network/api_endpoints.dart';
import '../core/network/api_exception.dart';
import '../core/network/dio_client.dart';
import '../models/dashboard_model.dart';

class DashboardService {
  DashboardService([DioClient? client]) : _client = client ?? DioClient.shared;

  final DioClient _client;

  /// GET /internship/dashboard/academic/
  Future<AcademicDashboard> getAcademicDashboard() async {
    final res = await _client.get<dynamic>(ApiEndpoints.academicDashboard);
    final data = res.data;
    if (data is! Map) {
      throw const ApiException('Invalid dashboard response from server.');
    }
    return AcademicDashboard.fromJson(Map<String, dynamic>.from(data));
  }
}