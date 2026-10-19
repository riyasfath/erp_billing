import 'package:dio/dio.dart';
import 'package:pokakbilling/core/api/api_constants.dart';
import 'package:pokakbilling/core/api/dio_client.dart';
import 'package:pokakbilling/models/data-models/lead_model.dart';

class AdminLeadServices {
  // ── Endpoints ─────────────────────────────────────────────────────────────
  static String get _adminLeadBase => '${ApiConstants.serverUrl}/leads/admin/';
  static String _adminLeadById(int id) =>
      '${ApiConstants.serverUrl}/leads/admin/$id/';

  // ── GET all leads (admin) ─────────────────────────────────────────────────
  static Future<List<LeadModel>> getAdminLeads() async {
    final dio = await DioClient().getAuthorizedDio();
    final response = await dio.get(_adminLeadBase);

    if (response.statusCode == 200) {
      final dynamic raw = response.data;
      List<dynamic> leadJson = [];

      if (raw is Map<String, dynamic>) {
        if (raw['status'] == '1' || raw['status'] == 1) {
          leadJson = raw['data'] ?? [];
        } else if (raw.containsKey('data')) {
          leadJson = raw['data'] ?? [];
        }
      } else if (raw is List) {
        leadJson = raw;
      }

      return leadJson
          .map((e) => LeadModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception(
        'Failed to load admin leads. Status: ${response.statusCode}');
  }

  // ── CREATE lead (admin) ───────────────────────────────────────────────────
  static Future<String?> createAdminLead({
    required String name,
    required String company,
    required String email,
    required String phone,
    required String notes,
    required String leadStatus,
    int? leadSource,
    String? enquiry,
    String? projectRequirement,
    String? address,
    int? location,
    int? salesperson,
  }) async {
    try {
      final dio = await DioClient().getAuthorizedDio();

      final Map<String, dynamic> data = {
        'name': name,
        'company': company,
        'email': email,
        'phone': phone,
        'notes': notes,
        'lead_status': leadStatus,
        'enquiry': enquiry ?? '',
      };

      // Only add optional fields when they have a value
      if (projectRequirement != null && projectRequirement.isNotEmpty) {
        data['project_requirement'] = projectRequirement;
      }
      if (address != null && address.isNotEmpty) data['address'] = address;
      if (leadSource != null) data['lead_source'] = leadSource;
      if (location != null) data['location'] = location;
      if (salesperson != null) data['salesperson'] = salesperson;

      final response = await dio.post(_adminLeadBase, data: data);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return null; // success
      }
      return _extractError(response.data);
    } on DioException catch (e) {
      return _extractDioError(e);
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  // ── EDIT / PATCH lead (admin) ─────────────────────────────────────────────
  static Future<String?> editAdminLead({
    required int leadId,
    String? name,
    String? company,
    String? email,
    String? phone,
    String? notes,
    String? leadStatus,
    int? leadSource,
    String? enquiry,
    int? location,
    int? salesperson,
  }) async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      final Map<String, dynamic> data = {};

      if (name != null) data['name'] = name;
      if (company != null) data['company'] = company;
      if (email != null) data['email'] = email;
      if (phone != null) data['phone'] = phone;
      if (notes != null) data['notes'] = notes;
      if (leadStatus != null) data['lead_status'] = leadStatus;
      if (enquiry != null) data['enquiry'] = enquiry;
      if (leadSource != null) data['lead_source'] = leadSource;
      if (location != null) data['location'] = location;
      if (salesperson != null) data['salesperson'] = salesperson;

      final response = await dio.patch(_adminLeadById(leadId), data: data);
      if (response.statusCode == 200) return null;
      return _extractError(response.data);
    } on DioException catch (e) {
      return _extractDioError(e);
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  // ── DELETE lead (admin) ───────────────────────────────────────────────────
  static Future<String?> deleteAdminLead(int leadId) async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      final response = await dio.delete(_adminLeadById(leadId));
      if (response.statusCode == 200 || response.statusCode == 204) return null;
      return _extractError(response.data);
    } on DioException catch (e) {
      return _extractDioError(e);
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  // ── ASSIGN salesperson (admin) ────────────────────────────────────────────
  static Future<String?> assignSalesperson({
    required int leadId,
    required int salespersonId,
  }) async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      final response = await dio.patch(
        _adminLeadById(leadId),
        data: {'salesperson': salespersonId},
      );
      if (response.statusCode == 200) return null;
      return _extractError(response.data);
    } on DioException catch (e) {
      return _extractDioError(e);
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  // ── Error helpers ─────────────────────────────────────────────────────────
  static String _extractError(dynamic data) {
    if (data == null) return 'Unknown error';
    if (data is Map<String, dynamic>) {
      // Try common error keys from DRF
      for (final key in ['detail', 'message', 'error', 'non_field_errors']) {
        if (data.containsKey(key)) return data[key].toString();
      }
      // Return first field error
      final firstEntry = data.entries.first;
      final val = firstEntry.value;
      if (val is List) return '${firstEntry.key}: ${val.first}';
      return '${firstEntry.key}: $val';
    }
    return data.toString();
  }

  static String _extractDioError(DioException e) {
    final data = e.response?.data;
    if (data != null) return _extractError(data);
    return e.message ?? 'Request failed';
  }
}