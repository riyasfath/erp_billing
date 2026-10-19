import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:pokakbilling/core/api/api_constants.dart';
import 'package:pokakbilling/core/api/dio_client.dart';
import 'package:pokakbilling/models/data-models/createQuotation_response.dart';
import 'package:pokakbilling/models/data-models/quotations-models/quotationItems_model.dart';
import 'package:pokakbilling/models/data-models/quotations-models/quotation_model.dart';

class QuotationServices {
  static Future<CreateQuotationResponse?> createQuotation(
    String quotationNumber,
    String quotationDate,
    int clientId,
    int termsId,
    deliveryAddress,
    deliveryLocation,
    String projectName,
    List<Map<String, dynamic>> items,
    Map<String, dynamic> contract,
  ) async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      var data = {
        "quotation_number": quotationNumber,
        'client': clientId,
        'quotation_date': quotationDate,
        "delivery_address": deliveryAddress,
        "delivery_location": deliveryLocation,
        "termsandconditions": termsId,
        "project_name": projectName,
        "items": items,
        "contract": contract,
      };

      print("Final Payload: ${jsonEncode(data)}");

      final response = await dio.post(
        ApiConstants.quotationEndPoint,
        data: data,
      );

      if (response.statusCode == 201) {
        final data = response.data;

        final int quotationId = data['quotation_id'];
        final double grandTotal = double.parse(data['grand_total']);

        return CreateQuotationResponse(
          quotationId: quotationId,
          grandTotal: grandTotal,
        );
      } else {
        return null;
      }
    } on DioException catch (e) {
      Map<String, dynamic>? errorData = e.response?.data;

      if (errorData != null) {
        errorData.values.firstWhere(
          (value) => value is String,
          orElse: () => "Unknown error occurred",
        );
        return null;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<List<QuotationModel>> getAllQuotations() async {
    final dio = await DioClient().getAuthorizedDio();

    final response = await dio.get(
      ApiConstants.quotationEndPoint,
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = response.data;
      List<dynamic> quotationJson = jsonData["data"];

      if (jsonData["status"] == "1") {
        List<QuotationModel> quotationList =
            quotationJson.map((json) => QuotationModel.fromJson(json)).toList();

        return quotationList;
      } else {
        throw Exception('Error: ${jsonData["message"]}');
      }
    } else {
      throw Exception('Failed to load Quotations');
    }
  }

  static Future<String?> deleteQuotation(int quotationId) async {
    try {
      final dio = await DioClient().getAuthorizedDio();

      final response = await dio.delete(
        ApiConstants.quotationByIdEndPoint(quotationId),
      );

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

  static Future<List<QuotationitemsModel>> getQuotationById(
    int quotationId,
  ) async {
    final dio = await DioClient().getAuthorizedDio();

    final response = await dio.get(
      ApiConstants.quotationByIdEndPoint(quotationId),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = response.data;
      List<dynamic> quotationJson = jsonData["quotation"];

      if (jsonData["status"] == "1") {
        List<QuotationitemsModel> quotationList = quotationJson
            .map((json) => QuotationitemsModel.fromJson(json))
            .toList();

        return quotationList;
      } else {
        throw Exception('Error: ${jsonData["message"]}');
      }
    } else {
      throw Exception('Failed to load Quotation');
    }
  }

  static Future<String?> editQuotation(
    int quotationId,
    String quotationNumber,
    String quotationDate,
    int clientId,
    int termsId,
    deliveryAddress,
    deliveryLocation,
    int contractId,
    String projectName,
    List<Map<String, dynamic>> items,
  ) async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      var data = {
        "quotation_number": quotationNumber,
        'client': clientId,
        'quotation_date': quotationDate,
        "delivery_address": deliveryAddress,
        "delivery_location": deliveryLocation,
        "termsandconditions": termsId,
        "contract": contractId,
        "project_name": projectName,
        "items": items,
      };

      print("Final Payload: ${jsonEncode(data)}");

      final response = await dio.patch(
        ApiConstants.quotationByIdEndPoint(quotationId),
        data: data,
      );

      if (response.statusCode == 200) {
        print("============ success =========");
        return null;
      } else {
        print("=========== failure =========");
        return "error";
      }
    } on DioException catch (e) {
      Map<String, dynamic>? errorData = e.response?.data;

      if (errorData != null) {
        errorData.values.firstWhere(
          (value) => value is String,
          orElse: () => "Unknown error occurred",
        );
        return null;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<String?> updateQuotationProduct(
    int quotationId,
    int productId,
    Map<String, dynamic> updatedProductData,
  ) async {
    try {
      print("------------------- updateProduct api called --------");
      final dio = Dio();
      print("updatedProductData $updatedProductData");
      var data = updatedProductData;

      print("📦 Sending PATCH Request...");
      print("Final Payload: ${jsonEncode(data)}");

      final response = await dio.patch(
        ApiConstants.quotationByIdAndProductEndPoint(quotationId, productId),
        data: data,
      );

      print("📥 Status Code: ${response.statusCode}");
      print("📥 Response Data: ${response.data}");

      if (response.statusCode == 200) {
        return null;
      } else {
        return response.data?.toString() ?? "Unexpected server response.";
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorData = e.response?.data;
        if (errorData is Map<String, dynamic>) {
          String? errorMessage = errorData["message"] ??
              errorData["error"] ??
              errorData.values.firstWhere(
                (value) => value is String,
                orElse: () => "Unknown error occurred",
              );

          return errorMessage;
        }
        return e.response?.statusMessage ?? "Unknown error occurred.";
      }
      return "Network error: ${e.message}";
    } catch (e) {
      return "Unexpected error: $e";
    }
  }

  static Future<String?> deleteSingleQuotationProduct(
    int quotationId,
    int productId,
  ) async {
    try {
      final dio = Dio();

      final response = await dio.delete(
        ApiConstants.deleteQuotationProductEndPoint(quotationId, productId),
      );

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

  static Future<String?> deleteQuotationItems(
      int quotationId, int productTabId) async {
    try {
      final dio = await DioClient().getAuthorizedDio();

      final response = await dio.delete(
        ApiConstants.deleteQuotationItemsEndPoint(quotationId, productTabId),
      );

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
