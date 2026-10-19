// lib/models/services/ai_generator_service.dart  (NEW)
// Implements the "AI Generator API - Frontend Integration Guide".

import 'package:dio/dio.dart';
import 'package:pokakbilling/core/api/api_constants.dart';
import 'package:pokakbilling/core/api/dio_client.dart';
import 'package:pokakbilling/models/data-models/ai_followup_model.dart';

class AiGeneratorService {
  static String errorMessage(Object e) {
    if (e is DioException) {
      final d = e.response?.data;
      if (d is Map) {
        for (final k in ['detail', 'message', 'error']) {
          final v = d[k];
          if (v is String && v.isNotEmpty) return v;
        }
        for (final v in d.values) {
          if (v is List && v.isNotEmpty) return v.first.toString();
          if (v is String && v.isNotEmpty) return v;
        }
      }
      if (d is String && d.isNotEmpty && !d.trimLeft().startsWith('<')) return d;
      final code = e.response?.statusCode;
      return code == null
          ? 'Network error. Please check your connection.'
          : 'Request failed ($code). Please try again.';
    }
    return e.toString().replaceFirst('Exception: ', '');
  }

  static List _asList(dynamic d) {
    if (d is List) return d;
    if (d is Map && d['results'] is List) return d['results'] as List;
    return const [];
  }

  /// GET /ai-followups/?channel=email|whatsapp  (follows pagination)
  static Future<List<AiFollowup>> list(String? channel) async {
    final dio = await DioClient().getAuthorizedDio();
    final out = <AiFollowup>[];
    int page = 1;
    while (page <= 50) {
      final q = <String, dynamic>{
        if (channel != null) 'channel': channel,
        if (page > 1) 'page': page,
      };
      final res = await dio.get(
        ApiConstants.aiFollowupsEndpoint,
        queryParameters: q.isEmpty ? null : q,
      );
      final rows = _asList(res.data);
      out.addAll(rows
          .whereType<Map>()
          .map((e) => AiFollowup.fromJson(Map<String, dynamic>.from(e))));
      final hasNext = res.data is Map && (res.data as Map)['next'] != null;
      if (!hasNext || rows.isEmpty) break;
      page++;
    }
    return out;
  }

  /// POST /ai-followups/generate/
  static Future<AiFollowup> generate({
    required int leadId,
    required String channel,
    String? tone,
    String? length,
    String? language,
    String? purpose,
    String? additionalContext,
  }) async {
    final dio = await DioClient().getAuthorizedDio();
    final body = <String, dynamic>{
      'lead_id': leadId,
      'channel': channel,
      if (tone != null) 'tone': tone,
      if (length != null) 'length': length,
      if (language != null) 'language': language,
      if (purpose != null) 'purpose': purpose,
      if (additionalContext != null && additionalContext.trim().isNotEmpty)
        'additional_context': additionalContext.trim(),
    };
    final res = await dio.post(ApiConstants.aiFollowupGenerateEndpoint, data: body);
    if (res.data is! Map) throw Exception('Unexpected response format');
    return AiFollowup.fromGenerate(
      Map<String, dynamic>.from(res.data as Map),
      leadId: leadId,
      channel: channel,
      tone: tone,
      length: length,
      language: language,
      purpose: purpose,
    );
  }

  /// PATCH /ai-followups/{id}/update_message/
  static Future<void> updateMessage(int id, String message) async {
    final dio = await DioClient().getAuthorizedDio();
    await dio.patch(
      ApiConstants.aiFollowupUpdateMessageEndpoint(id),
      data: {'message': message},
    );
  }

  /// POST /ai-followups/{id}/send_action/
  /// email → backend sends via SMTP; whatsapp → backend only marks SENT.
  static Future<void> sendAction(int id) async {
    final dio = await DioClient().getAuthorizedDio();
    await dio.post(ApiConstants.aiFollowupSendActionEndpoint(id), data: {});
  }

  /// DELETE /ai-followups/{id}/
  static Future<void> delete(int id) async {
    final dio = await DioClient().getAuthorizedDio();
    await dio.delete(ApiConstants.aiFollowupByIdEndpoint(id));
  }

  /// Client-side helper: https://api.whatsapp.com/send?phone=..&text=..
  /// 10-digit numbers get the India code (91) prefixed.
  static Uri whatsappUri(String phone, String message) {
    var digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length == 10) digits = '91$digits';
    return Uri.https('api.whatsapp.com', '/send', {
      'phone': digits,
      'text': message,
    });
  }
}