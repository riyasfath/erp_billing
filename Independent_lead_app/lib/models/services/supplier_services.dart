import 'package:dio/dio.dart';
import 'package:pokakbilling/core/api/api_constants.dart';
import 'package:pokakbilling/core/api/dio_client.dart';
import 'package:pokakbilling/models/data-models/supplier_model.dart';

class SupplierServices {
  static Future<String?> createSupplier(
    String supplierType,
    String supplierNumber,
    String date,
    String firstName,
    String lastName,
    String companyName,
    String contactPerson,
    String contactPersonNumber,
    String state,
    String country,
    String address,
    String emailId,
    String phone,
    String mobile,
    String currency,
    int termsId,
  ) async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      var data = {
        'supplier_type': supplierType,
        'supplier_number': supplierNumber,
        'date': date,
        'first_name': firstName,
        'last_name': lastName,
        'company_name': companyName,
        'contact_person_name': contactPerson,
        'contact_person_number': contactPersonNumber,
        'state': state,
        'country': country,
        'address': address,
        'email': emailId,
        'phone': phone,
        'mobile': mobile,
        'currency': currency,
        'payment_terms': termsId,
      };

      final response =
          await dio.post(ApiConstants.supplierEndPoint, data: data);

      if (response.statusCode == 201) {
        return null;
      } else {
        return response.data.toString();
      }
    } on DioException catch (e) {
      Map<String, dynamic>? errorData = e.response?.data;

      if (errorData != null) {
        String? errorMessage = errorData.values.firstWhere(
          (value) => value is String,
          orElse: () => "Unknown error occurred",
        );
        return errorMessage;
      }
      return "Something went wrong. Please try again.";
    } catch (e) {
      return "Unexpected error: $e";
    }
  }

  static Future<List<SupplierModel>> getSuppliers() async {
    final dio = await DioClient().getAuthorizedDio();

    final response = await dio.get(
      ApiConstants.supplierEndPoint,
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = response.data;
      List<dynamic> supplierJson = jsonData["Data"];

      if (jsonData["Status"] == "1") {
        List<SupplierModel> supplierList =
            supplierJson.map((json) => SupplierModel.fromJson(json)).toList();

        return supplierList;
      } else {
        throw Exception('Error: ${jsonData["message"]}');
      }
    } else {
      throw Exception('Failed to load Suppliers');
    }
  }

  static Future<String?> deleteSupplier(int supplierId) async {
    try {
      final dio = await DioClient().getAuthorizedDio();

      final response =
          await dio.delete(ApiConstants.supplierByIdEndpoint(supplierId));

      if (response.statusCode == 204 || response.statusCode == 200) {
        return null;
      } else {
        return response.data.toString();
      }
    } on DioException catch (e) {
      Map<String, dynamic>? errorData = e.response?.data;

      if (errorData != null) {
        String? errorMessage = errorData.values.firstWhere(
          (value) => value is String,
          orElse: () => "Unknown error occurred",
        );
        return errorMessage;
      }
      return "Something went wrong. Please try again.";
    } catch (e) {
      return "Unexpected error: $e";
    }
  }

  static Future<List<SupplierDetailModel>> getSupplierById(
    int supplierId,
  ) async {
    final dio = await DioClient().getAuthorizedDio();

    final response =
        await dio.get(ApiConstants.supplierByIdEndpoint(supplierId));

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = response.data;
      List<dynamic> supplierJson = jsonData["Data"];

      if (jsonData["Status"] == "1") {
        List<SupplierDetailModel> supplierList = supplierJson
            .map((json) => SupplierDetailModel.fromJson(json))
            .toList();

        return supplierList;
      } else {
        throw Exception('Error: ${jsonData["message"]}');
      }
    } else {
      throw Exception('Failed to load Sales Order');
    }
  }

  static Future<String?> updateSupplier(
    int supplierId,
    String supplierType,
    String supplierNumber,
    String date,
    String firstName,
    String lastName,
    String companyName,
    String contactPerson,
    String contactPersonNumber,
    String state,
    String country,
    String address,
    String emailId,
    String phone,
    String mobile,
    String currency,
    int termsId,
  ) async {
    try {
      final dio = await DioClient().getAuthorizedDio();

      var data = {
        'supplier_type': supplierType,
        'supplier_number': supplierNumber,
        'date': date,
        'first_name': firstName,
        'last_name': lastName,
        'company_name': companyName,
        'contact_person_name': contactPerson,
        'contact_person_number': contactPersonNumber,
        'state': state,
        'country': country,
        'address': address,
        'email': emailId,
        'phone': phone,
        'mobile': mobile,
        'currency': currency,
        'payment_terms': termsId,
      };

      final response = await dio
          .patch(ApiConstants.supplierByIdEndpoint(supplierId), data: data);

      if (response.statusCode == 200) {
        return null;
      } else {
        return response.data.toString();
      }
    } on DioException catch (e) {
      Map<String, dynamic>? errorData = e.response?.data;

      if (errorData != null) {
        String? errorMessage = errorData.values.firstWhere(
          (value) => value is String,
          orElse: () => "Unknown error occurred",
        );
        return errorMessage;
      }
      return "Something went wrong. Please try again.";
    } catch (e) {
      return "Unexpected error: $e";
    }
  }
}
