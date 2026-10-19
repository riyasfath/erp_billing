import 'package:dio/dio.dart';
import 'package:pokakbilling/core/api/api_constants.dart';
import 'package:pokakbilling/core/api/dio_client.dart';
import 'package:pokakbilling/models/data-models/lead_model.dart';

class LeadServices {
  // Sentinel value the ViewModel checks for to show a clean "no permission"
  // popup instead of dumping the raw backend error string.
  static const String kNoPermissionError = 'NO_PERMISSION';

  // This backend returns 400 (not just 401/403) when a staff user lacks
  // permission for an action.
  static bool _isPermissionStatus(int? statusCode) {
    return statusCode == 400 || statusCode == 401 || statusCode == 403;
  }

  // ── Shared request-body builder (used by create + edit) ──────────────────
  static Map<String, dynamic> _buildLeadBody({
    required String name,
    required String companyName,
    required String emailId,
    required String phoneNumber,
    required String notes,
    required String leadStatus,
    required String enquiry,
    int? leadSource,
    int? location,
    String? date,
    String? leadCategory,
    String? otherCategoryDetail,
    int? course,
    int? salesperson,
    String? reasonNote,
    String? otherNote,
  }) {
    final data = <String, dynamic>{
      'name': name,
      'company': companyName,
      'email': emailId,
      'phone': phoneNumber,
      'notes': notes,
      'lead_status': leadStatus,
      'enquiry': enquiry,
    };

    if (leadSource != null) data['lead_source'] = leadSource;
    if (location != null) data['location'] = location;
    if (date != null && date.trim().isNotEmpty) data['lead_date'] = date;
    if (salesperson != null) data['salesperson'] = salesperson;

    // ── Category ──
    if (leadCategory != null && leadCategory.trim().isNotEmpty) {
      data['lead_category'] = leadCategory;
    }
    // ── Other category detail: only when category == 'other' ──
    if (leadCategory == 'other' &&
        otherCategoryDetail != null &&
        otherCategoryDetail.trim().isNotEmpty) {
      data['other_category_detail'] = otherCategoryDetail.trim();
    }
    // ── Course: only when category == 'intern' ──
    if (leadCategory == 'intern' && course != null) {
      data['course'] = course;
    }

    // ── Status-specific notes ──
    // lead_status == 'lost'  → reason_note
    if (leadStatus == 'lost' &&
        reasonNote != null &&
        reasonNote.trim().isNotEmpty) {
      data['reason_note'] = reasonNote.trim();
    }
    // lead_status == 'other' → other_note
    if (leadStatus == 'other' &&
        otherNote != null &&
        otherNote.trim().isNotEmpty) {
      data['other_note'] = otherNote.trim();
    }

    return data;
  }

  static Future<String?> createLead(
    String name,
    String companyName,
    String emailId,
    String phoneNumber,
    String notes,
    String leadStatus,
    int? leadSource,
    String enquiry, {
    int? location,
    String? date,
    String? leadCategory,
    String? otherCategoryDetail,
    int? course,
    int? salesperson,
    String? reasonNote,
    String? otherNote,
  }) async {
    try {
      final dio = await DioClient().getAuthorizedDio();

      final data = _buildLeadBody(
        name: name,
        companyName: companyName,
        emailId: emailId,
        phoneNumber: phoneNumber,
        notes: notes,
        leadStatus: leadStatus,
        enquiry: enquiry,
        leadSource: leadSource,
        location: location,
        date: date,
        leadCategory: leadCategory,
        otherCategoryDetail: otherCategoryDetail,
        course: course,
        salesperson: salesperson,
        reasonNote: reasonNote,
        otherNote: otherNote,
      );

      final response = await dio.post(ApiConstants.leadEndpoint, data: data);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return null;
      } else if (_isPermissionStatus(response.statusCode)) {
        return kNoPermissionError;
      } else {
        return 'Something went wrong. Please try again.';
      }
    } on DioException catch (e) {
      // ── Permission check FIRST, before any generic error parsing ──
      if (_isPermissionStatus(e.response?.statusCode)) {
        return kNoPermissionError;
      }
      if (e.response != null) {
        try {
          final errors = e.response?.data['Errors'];
          if (errors != null && errors.containsKey('unit')) {
            return errors['unit'][0];
          }
        } catch (_) {
          return 'Validation failed.';
        }
      }
      return 'Something went wrong. Please try again.';
    } catch (e) {
      return 'Something went wrong. Please try again.';
    }
  }

  // Get all leads
  static Future<List<LeadModel>> getLeads({bool staffOnly = false}) async {
    final dio = await DioClient().getAuthorizedDio();
    final endpoint = staffOnly
        ? '${ApiConstants.leadEndpoint}staff/'
        : ApiConstants.leadEndpoint;

    final response = await dio.get(endpoint);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = response.data is Map
          ? response.data as Map<String, dynamic>
          : {'status': '0', 'data': []};
      final List<dynamic> leadJson = jsonData['data'] ?? [];

      if (jsonData['status'] == '1' || jsonData['status'] == 1) {
        final List<LeadModel> leadList = leadJson
            .map((json) => LeadModel.fromJson(json as Map<String, dynamic>))
            .toList();
        return leadList;
      } else {
        if (response.data is List) {
          return (response.data as List)
              .map((e) => LeadModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        throw Exception(
            'Error: ${jsonData['message'] ?? 'Failed to load leads'}');
      }
    } else {
      throw Exception('Failed to load Leads. Status: ${response.statusCode}');
    }
  }

  // Delete lead by id
  static Future<String?> deleteLead(int leadId) async {
    try {
      final dio = await DioClient().getAuthorizedDio();

      final response = await dio.delete(
        ApiConstants.leadByIdEndpoint(leadId),
      );

      if (response.statusCode == 200) {
        return null;
      } else if (_isPermissionStatus(response.statusCode)) {
        return kNoPermissionError;
      } else {
        return 'Something went wrong. Please try again.';
      }
    } on DioException catch (e) {
      if (_isPermissionStatus(e.response?.statusCode)) {
        return kNoPermissionError;
      }
      Map<String, dynamic>? errorData = e.response?.data;
      if (errorData != null) {
        String? errorMessage = errorData.values.firstWhere(
          (value) => value is String,
          orElse: () => "Unknown error occurred",
        ) as String?;
        return errorMessage;
      }
      return "Something went wrong. Please try again.";
    } catch (e) {
      return "Something went wrong. Please try again.";
    }
  }

  // Get lead by id
  static Future<LeadModel> getLeadById(int leadId) async {
    final dio = await DioClient().getAuthorizedDio();

    final response = await dio.get(ApiConstants.leadByIdEndpoint(leadId));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = response.data;
      if (jsonData['status'] == '1' || jsonData['status'] == 1) {
        final List<dynamic> leadJson = jsonData['data'] ?? [];
        if (leadJson.isNotEmpty) {
          return LeadModel.fromJson(leadJson.first as Map<String, dynamic>);
        }
        throw Exception('Lead not found');
      } else if (response.data is Map) {
        return LeadModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to load Lead');
      }
    } else {
      throw Exception('Failed to load Lead');
    }
  }

  static Future<String?> editLead(
    int leadId,
    String name,
    String companyName,
    String emailId,
    String phoneNumber,
    String notes,
    String leadStatus,
    int? leadSource,
    String enquiry, {
    int? location,
    String? date,
    String? leadCategory,
    String? otherCategoryDetail,
    int? course,
    int? salesperson,
    String? reasonNote,
    String? otherNote,
  }) async {
    try {
      final dio = await DioClient().getAuthorizedDio();

      final data = _buildLeadBody(
        name: name,
        companyName: companyName,
        emailId: emailId,
        phoneNumber: phoneNumber,
        notes: notes,
        leadStatus: leadStatus,
        enquiry: enquiry,
        leadSource: leadSource,
        location: location,
        date: date,
        leadCategory: leadCategory,
        otherCategoryDetail: otherCategoryDetail,
        course: course,
        salesperson: salesperson,
        reasonNote: reasonNote,
        otherNote: otherNote,
      );

      final response =
          await dio.patch(ApiConstants.leadByIdEndpoint(leadId), data: data);

      if (response.statusCode == 200) {
        return null;
      } else if (_isPermissionStatus(response.statusCode)) {
        return kNoPermissionError;
      } else {
        return 'Something went wrong. Please try again.';
      }
    } on DioException catch (e) {
      // ── Permission check FIRST, before any generic error parsing ──
      if (_isPermissionStatus(e.response?.statusCode)) {
        return kNoPermissionError;
      }
      final d = e.response?.data;
      if (d is Map<String, dynamic>) {
        final msg = d.values.firstWhere(
          (v) => v is String,
          orElse: () => "Something went wrong. Please try again.",
        );
        return msg as String;
      }
      return "Something went wrong. Please try again.";
    } catch (e) {
      return "Something went wrong. Please try again.";
    }
  }

  static Future<String?> createFollowup({
    required int leadId,
    required String title,
    required String date,
    required String time,
    required String status,
    required String type,
    required String notes,
  }) async {
    try {
      final dio = await DioClient().getAuthorizedDio();

      final data = <String, dynamic>{
        'lead': leadId,
        'title': title,
        'date': date,
        'time': time,
        'status': status,
        'type': type,
        'notes': notes,
      };

      final response =
          await dio.post(ApiConstants.followupsEndpoint, data: data);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return null;
      } else if (_isPermissionStatus(response.statusCode)) {
        return kNoPermissionError;
      } else {
        return 'Failed to create follow-up. Please try again.';
      }
    } on DioException catch (e) {
      if (_isPermissionStatus(e.response?.statusCode)) {
        return kNoPermissionError;
      }
      if (e.response != null) {
        try {
          final d = e.response?.data;
          if (d is Map && d.containsKey('detail')) {
            return d['detail'].toString();
          }
          return 'Failed to create follow-up. Please try again.';
        } catch (_) {
          return 'Failed to create follow-up. Please try again.';
        }
      }
      return 'Failed to create follow-up. Please try again.';
    } catch (e) {
      return 'Failed to create follow-up. Please try again.';
    }
  }

  static Future<List<LeadModel>> searchLeadsByName(String name) async {
    final dio = await DioClient().getAuthorizedDio();

    final response = await dio.get(ApiConstants.searchLeadByNameEndpoint(name));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = response.data;
      final List<dynamic> leadJson = jsonData['data'] ?? [];
      if (jsonData['status'] == '1' || jsonData['status'] == 1) {
        final List<LeadModel> leadList = leadJson
            .map((json) => LeadModel.fromJson(json as Map<String, dynamic>))
            .toList();
        return leadList;
      } else {
        throw Exception('Error: ${jsonData['message']}');
      }
    } else {
      throw Exception('Failed to search leads');
    }
  }

  static Future<List<LeadModel>> searchLeadsByDate({
    required String fromDate,
    required String toDate,
  }) async {
    final dio = await DioClient().getAuthorizedDio();

    final response = await dio
        .get(ApiConstants.searchLeadByDate(fromDate: fromDate, toDate: toDate));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = response.data;
      final List<dynamic> leadJson = jsonData['data'] ?? [];
      if (jsonData['status'] == '1' || jsonData['status'] == 1) {
        final List<LeadModel> leadList = leadJson
            .map((json) => LeadModel.fromJson(json as Map<String, dynamic>))
            .toList();
        return leadList;
      } else {
        throw Exception('Error: ${jsonData['message']}');
      }
    } else {
      throw Exception('Failed to search leads by date');
    }
  }
}