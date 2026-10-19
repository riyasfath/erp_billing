import 'package:dio/dio.dart';
import 'package:pokakbilling/core/api/api_constants.dart';
import 'package:pokakbilling/core/api/dio_client.dart';
import 'package:pokakbilling/models/academy_models/academy_model.dart';

class AcademyService {
  // ── GET list (handles plain list or {results/data/Data: []}) ──────────────
  static Future<List<Map<String, dynamic>>> _list(String url) async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      final response = await dio.get(url);

      final data = response.data;
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
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  static Future<List<AcadRegistration>> registrations() async =>
      (await _list(ApiConstants.academyRegistrationsEndpoint))
          .map(AcadRegistration.fromJson)
          .toList();

  static Future<List<AcadAdmission>> admissions() async =>
      (await _list(ApiConstants.academyAdmissionsEndpoint))
          .map(AcadAdmission.fromJson)
          .toList();

  static Future<List<AcadPayment>> payments() async =>
      (await _list(ApiConstants.academyPaymentsEndpoint))
          .map(AcadPayment.fromJson)
          .toList();

  static Future<AcadSummary> summary() async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      final response = await dio.get(ApiConstants.academySummaryEndpoint);
      final data = response.data;
      if (data is Map) {
        return AcadSummary.fromJson(Map<String, dynamic>.from(data));
      }
      return const AcadSummary();
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  // ── error helper (same style as InvoiceServices) ──────────────────────────
  static String _extractError(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      for (final key in ['detail', 'message', 'error']) {
        if (data[key] is String) return data[key] as String;
      }
      for (final val in data.values) {
        if (val is String && val.isNotEmpty) return val;
        if (val is List && val.isNotEmpty) return val.first.toString();
      }
    }
    return e.message ?? 'Network error';
  }
}