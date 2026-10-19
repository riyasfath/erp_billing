import 'package:dio/dio.dart';
import 'package:pokakbilling/core/api/api_constants.dart';
import 'package:pokakbilling/core/api/dio_client.dart';
import 'package:pokakbilling/models/staff_lead/staff_lead_model.dart';

class StaffLeadService {
  // ── Dashboard (tab + filters) ──────────────────────────────────────────────
  static Future<StaffLeadDashboard> dashboard({
    required LeadStage tab,
    int? courseId,
    String? name,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      final res = await dio.get(
        ApiConstants.academicDashboardStaffEndpoint,
        queryParameters: {
          'tab': tab.tabKey,
          if (courseId != null) 'course': courseId,
          if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
          if (startDate != null) 'start_date': leadApiDate(startDate),
          if (endDate != null) 'end_date': leadApiDate(endDate),
        },
      );
      return StaffLeadDashboard.fromJson(
          Map<String, dynamic>.from(res.data as Map));
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  // ── Courses (for filter + add lead) ────────────────────────────────────────
  static Future<List<StaffCourse>> courses() async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      final res = await dio.get(ApiConstants.internshipCourseEndpoint);
      final data = res.data;
      List raw = const [];
      if (data is List) {
        raw = data;
      } else if (data is Map<String, dynamic>) {
        for (final k in ['results', 'data', 'Data']) {
          if (data[k] is List) {
            raw = data[k] as List;
            break;
          }
        }
      }
      return raw
          .whereType<Map>()
          .map((e) => StaffCourse.fromJson(Map<String, dynamic>.from(e)))
          .where((c) => c.id != 0 && c.name.isNotEmpty)
          .toList();
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  // ── Create lead (lead_category is always "intern") ─────────────────────────
  /// Returns null on success, error text otherwise.
  static Future<String?> createLead({
    required String name,
    String phone = '',
    String email = '',
    int? courseId,
    String qualification = '',
    String addOn = '',
    DateTime? expectedStart,
    String leadStatus = 'new',
    String? priorityStatus, // hot | warm | cold | null
    DateTime? leadDate,
    String enquiry = '',
  }) async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      final res = await dio.post(
        ApiConstants.leadEndpoint,
        data: {
          'name': name,
          'lead_category': 'intern',
          if (phone.isNotEmpty) 'phone': phone,
          if (email.isNotEmpty) 'email': email,
          if (courseId != null) 'course': courseId,
          if (qualification.isNotEmpty) 'qualification': qualification,
          if (addOn.isNotEmpty) 'add_on_course_attended': addOn,
          if (expectedStart != null)
            'expected_starting_date': leadApiDate(expectedStart),
          'lead_status': leadStatus,
          'priority_status': priorityStatus,
          'lead_date': leadApiDate(leadDate ?? DateTime.now()),
          if (enquiry.isNotEmpty) 'enquiry': enquiry,
        },
      );
      if (res.statusCode == 200 || res.statusCode == 201) return null;
      return res.data?.toString() ?? 'Unexpected error';
    } on DioException catch (e) {
      return _extractError(e);
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  // ── Patch priority / lead status ───────────────────────────────────────────
  /// body example: {'priority_status': 'hot'} / {'priority_status': null}
  /// / {'lead_status': 'rnr'}. Returns null on success.
  static Future<String?> updateLead(int id, Map<String, dynamic> body) async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      final res = await dio.patch(ApiConstants.leadByIdEndpoint(id), data: body);
      if (res.statusCode == 200 || res.statusCode == 201) return null;
      return res.data?.toString() ?? 'Unexpected error';
    } on DioException catch (e) {
      return _extractError(e);
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  static String _extractError(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final errors = data['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final k = errors.keys.first;
        final v = errors[k];
        final msg = v is List && v.isNotEmpty ? v.first.toString() : '$v';
        return '$k: $msg';
      }
      for (final key in ['detail', 'message', 'error']) {
        if (data[key] is String && (data[key] as String).isNotEmpty) {
          return data[key] as String;
        }
      }
    }
    return e.message ?? 'Network error';
  }
}