// import 'package:dio/dio.dart';
// import 'package:pokakbilling/core/api/api_constants.dart';
// import 'package:pokakbilling/core/api/dio_client.dart';
// import 'package:pokakbilling/models/data-models/customer_model.dart';

// class CustomerServices {
//   // ======================CREATE CUSTOMER==========================
//   static Future<String?> createCustomer(
//     int? customerTypeId, // ✅ int ID instead of String
//     String firstName,
//     String lastName,
//     String companyName,
//     String email,
//     String phoneNumber,
//     String mobileNumber,
//     String address,
//     String state,
//     String country,
//     int salesPersonId,
//     int? contractId,
//   ) async {
//     try {
//       final dio = await DioClient().getAuthorizedDio();

//       final data = <String, dynamic>{
//         'first_name': firstName,
//         'last_name': lastName,
//         'company_name': companyName,
//         'email': email,
//         'phone_number': phoneNumber,
//         'mobile_number': mobileNumber,
//         'address': address,
//         'state': state,
//         'country': country,
//         'salesperson': salesPersonId,
//       };

//       // ✅ Only include if selected — API expects int ID
//       if (customerTypeId != null) {
//         data['customer_type'] = customerTypeId;
//       }
//       if (contractId != null) {
//         data['contract'] = contractId;
//       }

//       print("CREATE CUSTOMER PAYLOAD => $data");

//       final response =
//           await dio.post(ApiConstants.createCustomerEndpoint, data: data);

//       if (response.statusCode == 201) {
//         return null;
//       } else {
//         return response.data.toString();
//       }
//     } on DioException catch (e) {
//       final errorData = e.response?.data;
//       if (errorData is Map<String, dynamic>) {
//         final msg = errorData.values.firstWhere(
//           (v) => v is String,
//           orElse: () => "Unknown error occurred",
//         );
//         return msg;
//       }
//       return "Something went wrong. Please try again.";
//     } catch (e) {
//       return "Unexpected error: $e";
//     }
//   }

//   // ================= GET ALL =================
//   static Future<List<CustomerModel>> getCustomers() async {
//     final dio = await DioClient().getAuthorizedDio();
//     final response = await dio.get(ApiConstants.getCustomerEndpoint);

//     if (response.statusCode == 200) {
//       List<dynamic> jsonList = response.data;
//       return jsonList.map((e) => CustomerModel.fromJson(e)).toList();
//     } else {
//       throw Exception("Failed to load customers");
//     }
//   }

//   // ==================CUSTOMER BY ID========================
//   static Future<CustomerModel> getCustomerById(int id) async {
//     final dio = await DioClient().getAuthorizedDio();
//     final response = await dio.get(ApiConstants.customerByIdEndpoint(id));

//     if (response.statusCode == 200) {
//       return CustomerModel.fromJson(response.data);
//     } else {
//       throw Exception("Failed to load customer");
//     }
//   }

//   // ========================DELETE=============================
//   static Future<String?> deleteCustomer(int customerId) async {
//     try {
//       final dio = await DioClient().getAuthorizedDio();

//       final response = await dio.delete(
//         ApiConstants.customerByIdEndpoint(customerId),
//       );

//       if (response.statusCode == 200 || response.statusCode == 204) {
//         return null;
//       } else {
//         return response.data.toString();
//       }
//     } on DioException catch (e) {
//       final errorData = e.response?.data;
//       if (errorData is Map<String, dynamic>) {
//         final msg = errorData.values.firstWhere(
//           (v) => v is String,
//           orElse: () => "Unknown error occurred",
//         );
//         return msg;
//       }
//       return "Something went wrong. Please try again.";
//     } catch (e) {
//       return "Unexpected error: $e";
//     }
//   }

//   // ======================EDIT==========================
//   static Future<String?> editCustomer(
//     int? customerId,
//     int? customerTypeId, // ✅ int ID instead of String
//     String firstName,
//     String lastName,
//     String companyName,
//     String email,
//     String phoneNumber,
//     String mobileNumber,
//     String address,
//     String state,
//     String country,
//     int? salesPersonId,
//     int? contractId,
//   ) async {
//     try {
//       if (customerId == null) {
//         return "Invalid customer ID";
//       }
//       if (salesPersonId == null) {
//         return "Please select a sales person";
//       }

//       final dio = await DioClient().getAuthorizedDio();

//       final data = <String, dynamic>{
//         'first_name': firstName,
//         'last_name': lastName,
//         'company_name': companyName,
//         'email': email,
//         'phone_number': phoneNumber,
//         'mobile_number': mobileNumber,
//         'address': address,
//         'state': state,
//         'country': country,
//         'salesperson': salesPersonId,
//       };

//       // ✅ Only include if selected — API expects int ID
//       if (customerTypeId != null) {
//         data['customer_type'] = customerTypeId;
//       }
//       if (contractId != null) {
//         data['contract'] = contractId;
//       }

//       print("EDIT CUSTOMER PAYLOAD => $data");

//       final response = await dio.patch(
//         ApiConstants.customerByIdEndpoint(customerId),
//         data: data,
//       );

//       if (response.statusCode == 200) {
//         return null;
//       } else {
//         return response.data.toString();
//       }
//     } on DioException catch (e) {
//       print("-------------- edit error------");
//       print(e.response?.data);
//       return e.response?.data.toString() ??
//           "Something went wrong. Please try again.";
//     }
//   }
// }
import 'package:dio/dio.dart';
import 'package:pokakbilling/core/api/api_constants.dart';
import 'package:pokakbilling/core/api/dio_client.dart';
import 'package:pokakbilling/models/data-models/customer_model.dart';

class CustomerServices {
  // ─── Shared error extractor ───────────────────────────────────────────────
  //
  // Converts a DioException into a human-readable string.
  // Handles the 401 case explicitly so the UI never shows raw server JSON or
  // a confusing "login failed" message when the token is simply missing.
  static String _handleDioError(DioException e) {
    final status = e.response?.statusCode;
    final errorData = e.response?.data;

    // 401 — token missing, expired, or invalid
    if (status == 401) {
      return 'Session expired. Please log in again.';
    }

    // Other structured error responses
    if (errorData is Map<String, dynamic>) {
      // Try common Django REST Framework error keys
      for (final key in ['detail', 'message', 'error', 'non_field_errors']) {
        final val = errorData[key];
        if (val is String && val.isNotEmpty) return val;
        if (val is List && val.isNotEmpty) return val.first.toString();
      }
      // Fall back to the first string value in the map
      for (final val in errorData.values) {
        if (val is String && val.isNotEmpty) return val;
        if (val is List && val.isNotEmpty) return val.first.toString();
      }
      return errorData.toString();
    }

    if (errorData is String && errorData.isNotEmpty) return errorData;

    return 'Something went wrong. Please try again.';
  }

  // ======================CREATE CUSTOMER==========================
  static Future<String?> createCustomer(
    int? customerTypeId,
    String firstName,
    String lastName,
    String companyName,
    String email,
    String phoneNumber,
    String mobileNumber,
    String address,
    String state,
    String country,
    int salesPersonId,
    int? contractId,
  ) async {
    try {
      final dio = await DioClient().getAuthorizedDio();

      final data = <String, dynamic>{
        'first_name': firstName,
        'last_name': lastName,
        'company_name': companyName,
        'email': email,
        'phone_number': phoneNumber,
        'mobile_number': mobileNumber,
        'address': address,
        'state': state,
        'country': country,
        'salesperson': salesPersonId,
      };

      if (customerTypeId != null) data['customer_type'] = customerTypeId;
      if (contractId != null) data['contract'] = contractId;

      print('[CustomerServices] CREATE payload => $data');

      final response =
          await dio.post(ApiConstants.createCustomerEndpoint, data: data);

      print('[CustomerServices] CREATE status => ${response.statusCode}');

      if (response.statusCode == 201) return null;

      // Non-201 but not thrown as DioException (validateStatus: true)
      if (response.statusCode == 401) {
        return 'Session expired. Please log in again.';
      }

      final body = response.data;
      if (body is Map<String, dynamic>) {
        for (final key in ['detail', 'message', 'error', 'non_field_errors']) {
          final val = body[key];
          if (val is String && val.isNotEmpty) return val;
          if (val is List && val.isNotEmpty) return val.first.toString();
        }
      }
      return body?.toString() ?? 'Failed to create customer.';
    } on DioException catch (e) {
      print('[CustomerServices] CREATE DioException => ${e.response?.data}');
      return _handleDioError(e);
    } catch (e) {
      print('[CustomerServices] CREATE unexpected error => $e');
      return 'Unexpected error: $e';
    }
  }

  // ================= GET ALL =================
  static Future<List<CustomerModel>> getCustomers() async {
    final dio = await DioClient().getAuthorizedDio();
    final response = await dio.get(ApiConstants.getCustomerEndpoint);

    if (response.statusCode == 200) {
      final jsonList = response.data as List<dynamic>;
      return jsonList.map((e) => CustomerModel.fromJson(e)).toList();
    }
    throw Exception('Failed to load customers (${response.statusCode})');
  }

  // ==================CUSTOMER BY ID========================
  static Future<CustomerModel> getCustomerById(int id) async {
    final dio = await DioClient().getAuthorizedDio();
    final response = await dio.get(ApiConstants.customerByIdEndpoint(id));

    if (response.statusCode == 200) {
      return CustomerModel.fromJson(response.data);
    }
    throw Exception('Failed to load customer (${response.statusCode})');
  }

  // ========================DELETE=============================
  static Future<String?> deleteCustomer(int customerId) async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      final response =
          await dio.delete(ApiConstants.customerByIdEndpoint(customerId));

      if (response.statusCode == 200 || response.statusCode == 204) return null;
      if (response.statusCode == 401) {
        return 'Session expired. Please log in again.';
      }
      return response.data?.toString() ?? 'Failed to delete customer.';
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  // ======================EDIT==========================
  static Future<String?> editCustomer(
    int? customerId,
    int? customerTypeId,
    String firstName,
    String lastName,
    String companyName,
    String email,
    String phoneNumber,
    String mobileNumber,
    String address,
    String state,
    String country,
    int? salesPersonId,
    int? contractId,
  ) async {
    try {
      if (customerId == null) return 'Invalid customer ID';
      if (salesPersonId == null) return 'Please select a sales person';

      final dio = await DioClient().getAuthorizedDio();

      final data = <String, dynamic>{
        'first_name': firstName,
        'last_name': lastName,
        'company_name': companyName,
        'email': email,
        'phone_number': phoneNumber,
        'mobile_number': mobileNumber,
        'address': address,
        'state': state,
        'country': country,
        'salesperson': salesPersonId,
      };

      if (customerTypeId != null) data['customer_type'] = customerTypeId;
      if (contractId != null) data['contract'] = contractId;

      print('[CustomerServices] EDIT payload => $data');

      final response = await dio.patch(
        ApiConstants.customerByIdEndpoint(customerId),
        data: data,
      );

      print('[CustomerServices] EDIT status => ${response.statusCode}');

      if (response.statusCode == 200) return null;

      if (response.statusCode == 401) {
        return 'Session expired. Please log in again.';
      }

      final body = response.data;
      if (body is Map<String, dynamic>) {
        for (final key in ['detail', 'message', 'error', 'non_field_errors']) {
          final val = body[key];
          if (val is String && val.isNotEmpty) return val;
          if (val is List && val.isNotEmpty) return val.first.toString();
        }
      }
      return body?.toString() ?? 'Failed to update customer.';
    } on DioException catch (e) {
      print('[CustomerServices] EDIT DioException => ${e.response?.data}');
      return _handleDioError(e);
    } catch (e) {
      print('[CustomerServices] EDIT unexpected error => $e');
      return 'Unexpected error: $e';
    }
  }
}
