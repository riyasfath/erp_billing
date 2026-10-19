// lib/models/services/staff_dashboard_service.dart  (NEW)

import 'package:dio/dio.dart';
import 'package:pokakbilling/core/api/api_constants.dart';
import 'package:pokakbilling/core/api/dio_client.dart';
import 'package:pokakbilling/models/data-models/staff_dashboard_model.dart';

class StaffDashboardService {
  static String _msg(DioException e) {
    final d = e.response?.data;
    if (d is Map) {
      for (final k in ['detail', 'message', 'error']) {
        if (d[k] is String && (d[k] as String).isNotEmpty) return d[k];
      }
    }
    if (e.response?.statusCode == 401) return 'Session expired. Please login again.';
    return 'Could not load dashboard (${e.response?.statusCode ?? 'network error'}).';
  }

  /// GET /staff/dashboard/
  /// - [startDate]/[endDate] (yyyy-MM-dd) override [filterType]
  /// - [filterType]: day | week | month
  static Future<StaffDashboard> fetch({
    String? search,
    String? filterType,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      final q = <String, dynamic>{};
      if (search != null && search.trim().isNotEmpty) q['search'] = search.trim();
      if (startDate != null && startDate.isNotEmpty) {
        q['start_date'] = startDate;
        if (endDate != null && endDate.isNotEmpty) q['end_date'] = endDate;
      } else if (filterType != null && filterType.isNotEmpty) {
        q['filter_type'] = filterType;
      }

      final res = await dio.get(
        ApiConstants.staffDashboardEndpoint,
        queryParameters: q.isEmpty ? null : q,
      );

      if (res.data is Map) {
        return StaffDashboard.fromJson(Map<String, dynamic>.from(res.data as Map));
      }
      throw Exception('Unexpected response format');
    } on DioException catch (e) {
      throw Exception(_msg(e));
    }
  }
}