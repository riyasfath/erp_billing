// lib/models/services/lead_services.dart
// UPDATED: handles paginated responses ({count,next,priority_summary,results}),
// sends/reads `priority`, supports query filters.

import 'package:dio/dio.dart';
import 'package:pokakbilling/core/api/api_constants.dart';
import 'package:pokakbilling/core/api/dio_client.dart';
import 'package:pokakbilling/models/data-models/lead_model.dart';

class LeadServices {
  static String _parseError(dynamic responseData, int? statusCode) {
    if (responseData == null) return 'Something went wrong. Please try again.';

    if (responseData is String) {
      if (responseData.trimLeft().startsWith('<!') ||
          responseData.trimLeft().startsWith('<html')) {
        if (statusCode == 500) {
          return 'Server error (500): A duplicate entry or database conflict occurred. '
              'Please try again or contact support.';
        }
        return 'Server returned an unexpected error (status $statusCode). Please try again.';
      }
      return responseData;
    }

    if (responseData is Map) {
      for (final key in ['detail', 'message', 'error', 'non_field_errors']) {
        final v = responseData[key];
        if (v != null) {
          if (v is List && v.isNotEmpty) return v.first.toString();
          if (v is String && v.isNotEmpty) return v;
        }
      }
      for (final value in responseData.values) {
        if (value is List && value.isNotEmpty) return value.first.toString();
        if (value is String && value.isNotEmpty) return value;
      }
      return responseData.toString();
    }

    return 'Something went wrong. Please try again.';
  }

  // ───────────────────────────────────────────────────────────────────────
  // Core: fetch every page of a list endpoint (plain list OR paginated map)
  // ───────────────────────────────────────────────────────────────────────
  static List<LeadModel> _toLeads(List raw) => raw
      .whereType<Map>()
      .map((e) => LeadModel.fromJson(Map<String, dynamic>.from(e)))
      .toList();

  static Future<LeadPage> _fetchAll(
    String url, {
    Map<String, dynamic>? query,
  }) async {
    final dio = await DioClient().getAuthorizedDio();
    final all = <LeadModel>[];
    PrioritySummary? summary;
    int count = 0;
    int page = 1;

    while (page <= 100) {
      final params = <String, dynamic>{...?query};
      if (page > 1) params['page'] = page;

      final res = await dio.get(
        url,
        queryParameters: params.isEmpty ? null : params,
      );
      if (res.statusCode != 200) {
        throw Exception('Failed to load leads. Status: ${res.statusCode}');
      }

      final data = res.data;
      if (data is List) {
        all.addAll(_toLeads(data));
        count = all.length;
        break;
      }
      if (data is Map) {
        final results = data['results'];
        if (results is! List) throw Exception('Unexpected response format');
        all.addAll(_toLeads(results));
        if (page == 1) {
          count = int.tryParse('${data['count']}') ?? results.length;
          final ps = data['priority_summary'];
          if (ps is Map) {
            summary = PrioritySummary.fromJson(Map<String, dynamic>.from(ps));
          }
        }
        if (data['next'] == null || results.isEmpty) break;
        page++;
        continue;
      }
      throw Exception('Unexpected response format');
    }

    return LeadPage(leads: all, summary: summary, count: count);
  }

  // ───────────────────────────────────────────────────────────────────────
  // CREATE
  // ───────────────────────────────────────────────────────────────────────
  static Future<String?> createLead({
    String? leadId,
    required String name,
    required String company,
    String? email,
    required String phone,
    String? location,
    String? enquiry,
    String? address,
    String? projectRequirements,
    String? additionalNotes,
    String? source,
    String status = 'NEW',
    String? priority, // HOT | WARM | COOL
    String? receivedDate,
    String? reason,
    int? assignedTo,
  }) async {
    try {
      final dio = await DioClient().getAuthorizedDio();

      final data = <String, dynamic>{
        'name': name,
        'company': company,
        'phone': phone,
        'status': status,
      };

      void put(String k, String? v) {
        if (v != null && v.isNotEmpty) data[k] = v;
      }

      put('lead_id', leadId);
      put('email', email);
      put('location', location);
      put('enquiry', enquiry);
      put('address', address);
      put('project_requirements', projectRequirements);
      put('additional_notes', additionalNotes);
      put('source', source);
      put('priority', priority);
      put('received_date', receivedDate);
      put('reason', reason);
      if (assignedTo != null) data['assigned_to'] = assignedTo;

      final response = await dio.post(ApiConstants.leadsEndpoint, data: data);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return null;
      }
      return _parseError(response.data, response.statusCode);
    } on DioException catch (e) {
      return _parseError(e.response?.data, e.response?.statusCode);
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  // ───────────────────────────────────────────────────────────────────────
  // READ
  // ───────────────────────────────────────────────────────────────────────

  /// All leads (every page). Optional server-side filters:
  /// search, status, source, priority, created_from, created_to, assigned_to
  static Future<List<LeadModel>> getLeads({Map<String, dynamic>? filters}) async {
    final page = await _fetchAll(ApiConstants.leadsEndpoint, query: filters);
    return page.leads;
  }

  /// Same as getLeads but also returns `priority_summary` from the API.
  static Future<LeadPage> getLeadsPage({Map<String, dynamic>? filters}) =>
      _fetchAll(ApiConstants.leadsEndpoint, query: filters);

  static Future<List<LeadModel>> getAssignedLeads() async {
    final page = await _fetchAll(ApiConstants.assignedLeadsEndpoint);
    return page.leads;
  }

  static Future<LeadModel> getLeadById(int leadId) async {
    final dio = await DioClient().getAuthorizedDio();
    final response = await dio.get(ApiConstants.leadByIdEndpoint(leadId));

    if (response.statusCode == 200) {
      return LeadModel.fromJson(Map<String, dynamic>.from(response.data as Map));
    }
    throw Exception('Failed to load Lead');
  }

  static Future<List<LeadModel>> searchLeadsByName(String name) async {
    final page =
        await _fetchAll(ApiConstants.leadsEndpoint, query: {'search': name});
    return page.leads;
  }

  // ───────────────────────────────────────────────────────────────────────
  // UPDATE
  // ───────────────────────────────────────────────────────────────────────
  static Future<String?> editLead({
    required int leadId,
    String? name,
    String? company,
    String? email,
    String? phone,
    String? location,
    String? enquiry,
    String? address,
    String? projectRequirements,
    String? additionalNotes,
    String? source,
    String? status,
    String? priority,
    String? receivedDate,
    String? reason,
    int? assignedTo,
  }) async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      final data = <String, dynamic>{};

      if (name != null) data['name'] = name;
      if (company != null) data['company'] = company;
      if (email != null) data['email'] = email;
      if (phone != null) data['phone'] = phone;
      if (location != null) data['location'] = location;
      if (enquiry != null) data['enquiry'] = enquiry;
      if (address != null) data['address'] = address;
      if (projectRequirements != null) {
        data['project_requirements'] = projectRequirements;
      }
      if (additionalNotes != null) data['additional_notes'] = additionalNotes;
      if (status != null) data['status'] = status;
      if (priority != null) data['priority'] = priority;
      if (receivedDate != null) data['received_date'] = receivedDate;
      if (reason != null) data['reason'] = reason;
      if (source != null) data['source'] = source;
      if (assignedTo != null) data['assigned_to'] = assignedTo;

      final response = await dio.patch(
        ApiConstants.leadByIdEndpoint(leadId),
        data: data,
      );

      if (response.statusCode == 200) return null;
      return _parseError(response.data, response.statusCode);
    } on DioException catch (e) {
      return _parseError(e.response?.data, e.response?.statusCode);
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  // ───────────────────────────────────────────────────────────────────────
  // DELETE
  // ───────────────────────────────────────────────────────────────────────
  static Future<String?> deleteLead(int leadId) async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      final response = await dio.delete(ApiConstants.leadByIdEndpoint(leadId));

      if (response.statusCode == 200 || response.statusCode == 204) return null;
      return _parseError(response.data, response.statusCode);
    } on DioException catch (e) {
      return _parseError(e.response?.data, e.response?.statusCode);
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  // ───────────────────────────────────────────────────────────────────────
  // Schedule call task (Communication → Call)
  // ───────────────────────────────────────────────────────────────────────
  static Future<String?> scheduleCall(int leadId) async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      final response = await dio.post(
        ApiConstants.callActivityScheduleTaskEndpoint,
        data: {'lead_id': leadId},
      );

      if (response.statusCode == 200 || response.statusCode == 201) return null;
      return _parseError(response.data, response.statusCode);
    } on DioException catch (e) {
      return _parseError(e.response?.data, e.response?.statusCode);
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }
}