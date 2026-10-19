import 'package:dio/dio.dart';
import 'package:pokakbilling/core/api/api_constants.dart';
import 'package:pokakbilling/core/api/dio_client.dart';
import 'package:pokakbilling/models/academy_models/academy_hr_model.dart';

class AcademyHrService {
  // ── helpers ────────────────────────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> _rawList(String url) async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      final res = await dio.get(url);
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
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  // ── Counsellors (derived from admissions + registrations) ─────────────────
  static Future<List<AcadCounsellor>> counsellors() async {
    final results = await Future.wait([
      _rawList(ApiConstants.academyAdmissionsEndpoint),
      _rawList(ApiConstants.academyRegistrationsEndpoint),
    ]);
    final map = <int, String>{};
    for (final list in results) {
      for (final j in list) {
        final c = j['counsellor'];
        if (c is Map && c['id'] != null) {
          final id = int.tryParse('${c['id']}');
          final name = (c['name'] ?? '').toString();
          if (id != null && name.isNotEmpty) map[id] = name;
        }
      }
    }
    final out = map.entries
        .map((e) => AcadCounsellor(id: e.key, name: e.value))
        .toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return out;
  }

  // ── Conversion report ──────────────────────────────────────────────────────
  static Future<AcadConversion> conversion({
    required int counsellorId,
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      final res = await dio.get(
        ApiConstants.academyCounsellorConversionEndpoint(counsellorId),
        queryParameters: {
          'start_date': acadApiDate(start),
          'end_date': acadApiDate(end),
        },
      );
      return AcadConversion.fromJson(
          Map<String, dynamic>.from(res.data as Map));
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  // ── Proceed to HR (returns null on success, error text otherwise) ─────────
  static Future<String?> proceedToHr({
    required int counsellorId,
    required DateTime start,
    required DateTime end,
    required String periodLabel,
    required String remarks,
  }) async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      final res = await dio.post(
        ApiConstants.academyProceedToHrEndpoint(counsellorId),
        data: {
          'start_date': acadApiDate(start),
          'end_date': acadApiDate(end),
          'period_label': periodLabel,
          'remarks': remarks,
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

  // ── HR submissions ─────────────────────────────────────────────────────────
  static Future<List<AcadSubmission>> submissions() async =>
      (await _rawList(ApiConstants.academyHrSubmissionsEndpoint))
          .map(AcadSubmission.fromJson)
          .toList();

  static Future<AcadSubmissionDetail> submissionDetail(int id) async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      final res =
          await dio.get(ApiConstants.academyHrSubmissionByIdEndpoint(id));
      return AcadSubmissionDetail.fromJson(
          Map<String, dynamic>.from(res.data as Map));
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  /// action: 'approved' | 'rejected'. Returns null on success.
  static Future<String?> review({
    required int id,
    required String action,
    required String remarks,
  }) async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      final res = await dio.post(
        ApiConstants.academyHrActionEndpoint(id),
        data: {'action': action, 'remarks': remarks},
      );
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