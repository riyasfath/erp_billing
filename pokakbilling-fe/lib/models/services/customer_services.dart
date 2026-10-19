import 'package:dio/dio.dart';
import 'package:pokakbilling/core/api/api_constants.dart';
import 'package:pokakbilling/models/data-models/customer_model.dart';

class CustomerServices {
  // ---------------------------------------------------------------------------
  // CREATE
  // ---------------------------------------------------------------------------
  static Future<String?> createCustomer({
    required String moduleType,
    required String firstName,
    required String lastName,
    required String companyName,
    required String country,
    required String state,
    required String address,
    required String email,
    required String phone,
    required String mobile,
    required int salesPersonId,
    required String gstNumber,
    int? leadId, // only when moduleType == 'lead'
  }) async {
    try {
      final dio = Dio();
      final data = <String, dynamic>{
        'module_type': moduleType,
        'first_name': firstName,
        'last_name': lastName,
        'company_name': companyName.isEmpty ? null : companyName,
        'country': country,
        'state': state,
        'address': address.isEmpty ? null : address,
        'email': email,
        'phone': phone,
        'mobile': mobile,
        'salesperson_id': salesPersonId,
        'gst_number': gstNumber.isEmpty ? null : gstNumber,
      };

      if (moduleType == 'lead' && leadId != null) {
        data['lead'] = leadId;
      }

      final response =
          await dio.post(ApiConstants.createCustomerEndpoint, data: data);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return null;
      } else {
        return response.data?.toString() ?? "Failed to create customer.";
      }
    } on DioException catch (e) {
      return _extractErrorMessage(e);
    } catch (e) {
      return "Unexpected error: $e";
    }
  }

  // ---------------------------------------------------------------------------
  // GET ALL
  // ---------------------------------------------------------------------------
  static Future<List<CustomerModel>> getCustomers() async {
    final dio = Dio();
    final response = await dio.get(ApiConstants.getCustomerEndpoint);

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = response.data;
      List<dynamic> customerJson = jsonData["Data"];

      if (jsonData["Status"] == "1") {
        return customerJson
            .map((json) => CustomerModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Error: ${jsonData["message"]}');
      }
    } else {
      throw Exception('Failed to load Customers');
    }
  }

  // ---------------------------------------------------------------------------
  // GET BY ID
  // ---------------------------------------------------------------------------
  static Future<List<CustomerModel>> getCustomerById(int customerId) async {
    final dio = Dio();
    final response = await dio.get(
      ApiConstants.customerByIdEndpoint(customerId),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = response.data;
      List<dynamic> customerJson = jsonData["Data"];

      if (jsonData["Status"] == "1") {
        return customerJson
            .map((json) => CustomerModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Error: ${jsonData["message"]}');
      }
    } else {
      throw Exception('Failed to load Customers');
    }
  }

  // ---------------------------------------------------------------------------
  // DELETE
  // ---------------------------------------------------------------------------
  static Future<String?> deleteCustomer(int customerId) async {
    try {
      final dio = Dio();
      dio.options.validateStatus = (status) => true;

      final response = await dio.delete(
        ApiConstants.customerByIdEndpoint(customerId),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return null;
      }

      final rawData = response.data?.toString() ?? '';

      if (_isHtmlResponse(rawData)) {
        return _extractMessageFromHtml(rawData);
      }

      if (response.data is Map) {
        return _extractFromMap(response.data as Map);
      }

      return rawData.isNotEmpty ? rawData : "Cannot delete this customer.";
    } on DioException catch (e) {
      return _extractErrorMessage(e);
    } catch (e) {
      return "Unexpected error: $e";
    }
  }

  // ---------------------------------------------------------------------------
  // EDIT
  // ---------------------------------------------------------------------------
  static Future<String?> editCustomer({
    required int customerId,
    required String moduleType,
    required String firstName,
    required String lastName,
    required String companyName,
    required String country,
    required String state,
    required String address,
    required String email,
    required String phone,
    required String mobile,
    required int salesPersonId,
    required String gstNumber,
    int? leadId,
  }) async {
    try {
      final dio = Dio();
      final data = <String, dynamic>{
        'module_type': moduleType,
        'first_name': firstName,
        'last_name': lastName,
        'company_name': companyName.isEmpty ? null : companyName,
        'country': country,
        'state': state,
        'address': address.isEmpty ? null : address,
        'email': email,
        'phone': phone,
        'mobile': mobile,
        'salesperson_id': salesPersonId,
        'gst_number': gstNumber.isEmpty ? null : gstNumber,
      };

      if (moduleType == 'lead' && leadId != null) {
        data['lead'] = leadId;
      }

      final response = await dio.patch(
        ApiConstants.customerByIdEndpoint(customerId),
        data: data,
      );

      if (response.statusCode == 200) {
        return null;
      } else {
        return response.data?.toString() ?? "Edit failed.";
      }
    } on DioException catch (e) {
      return _extractErrorMessage(e);
    } catch (e) {
      return "Unexpected error: $e";
    }
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------
  static bool _isHtmlResponse(String body) {
    final lower = body.toLowerCase().trim();
    return lower.startsWith('<!doctype') ||
        lower.startsWith('<html') ||
        lower.contains('<title>protectederror') ||
        lower.contains('protectederror');
  }

  static String _extractMessageFromHtml(String html) {
    final pTagRegex = RegExp(r'<p[^>]*>(.*?)<\/p>', dotAll: true);
    final matches = pTagRegex.allMatches(html);

    for (final match in matches) {
      final text = match
          .group(1)
          ?.replaceAll(RegExp(r'<[^>]+>'), '')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();

      if (text != null && text.length > 10 && !text.contains('{')) {
        if (text.toLowerCase().contains('quotation') ||
            text.toLowerCase().contains('invoice') ||
            text.toLowerCase().contains('order') ||
            text.toLowerCase().contains('protected')) {
          return 'Cannot delete: this customer is linked to a quotation or invoice. Please remove those records first.';
        }
        return 'Cannot delete: this customer is linked to existing records. Please remove them first.';
      }
    }
    return 'Cannot delete: this customer is linked to existing records. Please remove them first.';
  }

  static String _extractErrorMessage(DioException e) {
    final data = e.response?.data;
    if (data == null) return "Something went wrong. Please try again.";
    if (data is String) {
      if (_isHtmlResponse(data)) return _extractMessageFromHtml(data);
      return data.isNotEmpty ? data : "Something went wrong.";
    }
    if (data is Map) return _extractFromMap(data);
    if (data is List && data.isNotEmpty) return data.first.toString();
    return "Something went wrong. Please try again.";
  }

  static String _extractFromMap(Map data) {
    if (data.containsKey('detail')) return data['detail'].toString();
    if (data.containsKey('message')) return data['message'].toString();
    if (data.containsKey('error')) return data['error'].toString();
    for (final value in data.values) {
      if (value is String && value.isNotEmpty) return value;
      if (value is List && value.isNotEmpty) return value.first.toString();
    }
    return data.toString();
  }
}
