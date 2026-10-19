import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pokakbilling/core/api/api_constants.dart';
import 'package:pokakbilling/core/api/dio_client.dart';
import 'package:pokakbilling/models/call_activity/dashboard_model.dart';
import 'package:pokakbilling/models/call_activity/call_recording_model.dart';
import 'package:pokakbilling/models/call_activity/call_log_model.dart';
import 'package:pokakbilling/models/call_activity/call_lead_model.dart';
import 'package:pokakbilling/models/call_activity/call_details_model.dart';
import 'package:pokakbilling/models/call_activity/twilio_token_model.dart';

class CallActivityService {
  // ===========================
  // GET DASHBOARD
  // ===========================
  static Future<CallActivityDashboardModel> getDashboard({
    String? period,
    String? status,
    String? stage,
  }) async {
    final dio = await DioClient().getAuthorizedDio();

    final response = await dio.get(
      ApiConstants.callActivityDashboardEndpoint,
      queryParameters: {
        if (period != null && period.isNotEmpty) 'period': period,
        if (status != null && status.isNotEmpty) 'status': status,
        if (stage != null && stage.isNotEmpty) 'stage': stage,
      },
    );

    if (response.statusCode == 200) {
      return CallActivityDashboardModel.fromJson(response.data);
    }

    throw Exception('Failed to load call activity dashboard');
  }

  // ===========================
  // GET TODAY'S TASKS (+ overdue)
  // ===========================
  static Future<TodayTasksResponseModel> getTodayTasks() async {
    final dio = await DioClient().getAuthorizedDio();

    debugPrint(
        '[getTodayTasks] GET ${ApiConstants.callActivityTodayTasksEndpoint}');

    try {
      final response = await dio.get(
        ApiConstants.callActivityTodayTasksEndpoint,
      );

      debugPrint('[getTodayTasks] status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return TodayTasksResponseModel.fromJson(response.data);
      }

      throw Exception('Failed to load today\'s tasks');
    } on DioException catch (e) {
      debugPrint('[getTodayTasks] DioException: ${e.type} '
          '${e.response?.statusCode} ${e.response?.data} — ${e.message} — error: ${e.error}');
      rethrow;
    }
  }

  // ===========================
  // GET CALL HISTORY
  // ===========================
  static Future<CallHistoryResponseModel> getCallHistory({
    int? page,
    String? search,
  }) async {
    final dio = await DioClient().getAuthorizedDio();

    final response = await dio.get(
      ApiConstants.callActivityHistoryEndpoint,
      queryParameters: {
        if (page != null) 'page': page,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );

    if (response.statusCode == 200) {
      return CallHistoryResponseModel.fromJson(response.data);
    }

    throw Exception('Failed to load call history');
  }

  // ===========================
  // GET FOLLOW-UPS
  // ===========================
  static Future<CallFollowUpResponseModel> getFollowUps({int? page}) async {
    final dio = await DioClient().getAuthorizedDio();

    final response = await dio.get(
      ApiConstants.callActivityFollowUpEndpoint,
      queryParameters: {
        if (page != null) 'page': page,
      },
    );

    if (response.statusCode == 200) {
      return CallFollowUpResponseModel.fromJson(response.data);
    }

    throw Exception('Failed to load call follow-ups');
  }

  // ===========================
  // GET PERFORMANCE SUMMARY
  // ===========================
  static Future<CallPerformanceSummaryModel> getPerformanceSummary({
    String? period,
    String? status,
    String? stage,
  }) async {
    final dio = await DioClient().getAuthorizedDio();

    final response = await dio.get(
      ApiConstants.callActivityPerformanceSummaryEndpoint,
      queryParameters: {
        if (period != null && period.isNotEmpty) 'period': period,
        if (status != null && status.isNotEmpty) 'status': status,
        if (stage != null && stage.isNotEmpty) 'stage': stage,
      },
    );

    if (response.statusCode == 200) {
      return CallPerformanceSummaryModel.fromJson(response.data);
    }

    throw Exception('Failed to load call performance summary');
  }

  // ===========================
  // GET CALL RECORDINGS
  // ===========================
  static Future<CallRecordingsResponseModel> getCallRecordings({
    int? page,
    String? search,
  }) async {
    final dio = await DioClient().getAuthorizedDio();

    final response = await dio.get(
      ApiConstants.callRecordingsEndpoint,
      queryParameters: {
        if (page != null) 'page': page,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );

    if (response.statusCode == 200) {
      return CallRecordingsResponseModel.fromJson(response.data);
    }

    throw Exception('Failed to load call recordings');
  }

  // ===========================
  // ADD CALL LOG (POST)
  // ===========================
  static Future<AddCallLogResponseModel> addCallLog(
    AddCallLogRequestModel payload,
  ) async {
    final dio = await DioClient().getAuthorizedDio();

    final response = await dio.post(
      ApiConstants.addCallLogEndpoint,
      data: payload.toJson(),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final result = AddCallLogResponseModel.fromJson(response.data);
      if (result.success) return result;
      throw Exception(
        result.message.isNotEmpty ? result.message : 'Failed to add call log',
      );
    }

    throw Exception('Failed to add call log');
  }

  // ===========================
  // GET LEADS FOR "START NEW CALL" PICKER
  // ===========================
  static Future<CallLeadListResponseModel> getCallableLeads({
    String? search,
  }) async {
    final dio = await DioClient().getAuthorizedDio();

    final response = await dio.get(
      ApiConstants.callActivityStartNewCallEndpoint,
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );

    if (response.statusCode == 200) {
      return CallLeadListResponseModel.fromJson(response.data);
    }

    throw Exception('Failed to load leads');
  }

  // ===========================
  // GET CALL DETAILS (by lead id)
  // ===========================
  static Future<CallDetailsModel> getCallDetails(int leadId) async {
    final dio = await DioClient().getAuthorizedDio();

    final response = await dio.get(
      ApiConstants.callActivityCallDetailsEndpoint(leadId),
    );

    if (response.statusCode == 200) {
      return CallDetailsModel.fromJson(response.data, fallbackLeadId: leadId);
    }

    throw Exception('Failed to load call details');
  }

  // ===========================
  // UPDATE CALL DETAILS (lead status / follow-up / notes)
  // ===========================
  //
  // Confirmed working payload (via Hoppscotch, 200 OK):
  // PATCH /call-activity/call-details/<lead_id>/
  // {
  //   "status": "failed",
  //   "notes": "Customer next week vilikkan paranju",
  //   "follow_up_date": "2026-07-15T10:00:00Z"   // full ISO-8601, not bare date
  // }
  // -> { "success": true, "message": "Call details updated successfully" }
  //
  // ✅ DEBUG: added full request/response logging (payload, status code,
  // raw body) — same pattern as getTwilioAccessToken() below — so the next
  // time this "silently doesn't work" in the app, the console will show
  // exactly what was sent and what came back, instead of us having to
  // guess blind.
  //
  // ✅ REMOVED: the previous `Options(headers: {'Connection': 'close'})`.
  // That header isn't reliably respected by Dio's IO HTTP adapter on real
  // devices/emulators (the underlying dart:io HttpClient manages
  // connection reuse itself), so it wasn't guaranteed to do anything —
  // and if your Authorization header ever stops being merged correctly by
  // a future Dio version, a per-call `Options(headers: ...)` block like
  // this is the first place that breaks silently. Removing it also lets
  // us rule it out as a cause.
  static Future<bool> updateCallDetails({
    required int leadId,
    String? leadStatus,
    String? followUpDate,
    String? notes,
  }) async {
    final dio = await DioClient().getAuthorizedDio();

    final payload = {
      if (leadStatus != null) 'status': leadStatus,
      if (followUpDate != null) 'follow_up_date': followUpDate,
      if (notes != null) 'notes': notes,
    };

    final url = ApiConstants.callActivityCallDetailsEndpoint(leadId);

    debugPrint('[updateCallDetails] PATCH $url');
    debugPrint('[updateCallDetails] payload: $payload');
    debugPrint(
        '[updateCallDetails] auth header present: ${dio.options.headers.containsKey('Authorization')}');

    try {
      final response = await dio.patch(
        url,
        data: payload,
      );

      debugPrint('[updateCallDetails] status: ${response.statusCode}');
      debugPrint('[updateCallDetails] response body: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        final data = response.data;
        if (data is Map && data.containsKey('success')) {
          return data['success'] == true;
        }
        return true;
      }

      return false;
    } on DioException catch (e) {
      debugPrint('[updateCallDetails] DioException: ${e.type} '
          '${e.response?.statusCode} ${e.response?.data} — ${e.message} — error: ${e.error}');
      return false;
    }
  }

  // ===========================
  // ✅ GET TWILIO ACCESS TOKEN (for in-app calling via Twilio Voice SDK)
  // Returns TwilioTokenModel { token, identity } — NOT a plain String.
  // ===========================
  static Future<TwilioTokenModel> getTwilioAccessToken() async {
    final dio = await DioClient().getAuthorizedDio();

    try {
      final response = await dio.get(
        ApiConstants.callActivityTwilioTokenEndpoint,
      );

      debugPrint(
          'Twilio token endpoint: ${ApiConstants.callActivityTwilioTokenEndpoint}');
      debugPrint('Twilio token status code: ${response.statusCode}');
      debugPrint('Twilio token response body: ${response.data}');

      if (response.statusCode == 200) {
        final model = TwilioTokenModel.fromJson(
          response.data as Map<String, dynamic>,
        );

        if (!model.isValid) {
          throw Exception(
            'Twilio token or identity missing in response: ${response.data}',
          );
        }

        return model;
      }

      throw Exception(
        'Failed to fetch Twilio access token — status ${response.statusCode}, body: ${response.data}',
      );
    } on DioException catch (e) {
      debugPrint('Twilio token DioException: ${e.response?.statusCode} '
          '${e.response?.data} (${e.type})');
      throw Exception(
        'Failed to fetch Twilio access token — ${e.response?.statusCode ?? e.type}: '
        '${e.response?.data ?? e.message}',
      );
    }
  }
}
