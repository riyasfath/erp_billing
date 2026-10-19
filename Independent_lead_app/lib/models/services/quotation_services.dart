import 'package:pokakbilling/core/api/api_constants.dart';
import 'package:pokakbilling/core/api/dio_client.dart';
import 'package:pokakbilling/models/data-models/createQuotation_response.dart';
import 'package:pokakbilling/models/data-models/quotations-models/quotation_model.dart';

class QuotationServices {
  // ================================
  // CREATE QUOTATION
  // ================================
  static Future<CreateQuotationResponse?> createQuotation(
      String quotationNumber,
      String date,
      int? clientId,
      String? projectName,
      String? companyLocation,
      String? companyAddress,
      List<Map<String, dynamic>> items,
      dynamic contract,
      {int? terms}) async {
    try {
      final dio = await DioClient().getAuthorizedDio();

      final data = {
        "quotation_number": quotationNumber,
        "date": date,
        "client": clientId,
        "project_name": projectName,
        "company_location": companyLocation,
        "company_address": companyAddress,
        "items": items,
        "contract": contract,
        "terms_and_conditions": terms,
      };

      final response = await dio.post(
        ApiConstants.quotationEndPoint,
        data: data,
      );

      if (response.statusCode == 201) {
        final resData = response.data;

        return CreateQuotationResponse(
          quotationId: resData["id"],
          grandTotal: double.parse(resData["grand_total"]),
        );
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  // ================================
  // GET ALL QUOTATIONS
  // ================================
  static Future<List<QuotationModel>> getAllQuotations() async {
    final dio = await DioClient().getAuthorizedDio();

    final response = await dio.get(ApiConstants.quotationEndPoint);

    if (response.statusCode == 200) {
      List<dynamic> data = response.data;

      return data.map((json) => QuotationModel.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load quotations");
    }
  }

  // ================================
  // GET QUOTATION BY ID
  // ================================
  static Future<QuotationModel?> getQuotationById(int quotationId) async {
    final dio = await DioClient().getAuthorizedDio();

    final response = await dio.get(
      ApiConstants.quotationByIdEndPoint(quotationId),
    );

    if (response.statusCode == 200) {
      return QuotationModel.fromJson(response.data);
    } else {
      return null;
    }
  }

  // ================================
  // EDIT QUOTATION
  // ================================
  static Future<String?> editQuotation(
      int quotationId,
      String quotationNumber,
      String date,
      int? clientId,
      String? projectName,
      String? companyLocation,
      String? companyAddress,
      List<Map<String, dynamic>> items,
      dynamic contract,
      {int? terms}) async {
    try {
      final dio = await DioClient().getAuthorizedDio();

      final data = {
        "quotation_number": quotationNumber,
        "date": date,
        "client": clientId,
        "project_name": projectName,
        "company_location": companyLocation,
        "company_address": companyAddress,
        "items": items,
        "contract": contract,
        "terms_and_conditions": terms,
      };

      final response = await dio.patch(
        ApiConstants.quotationByIdEndPoint(quotationId),
        data: data,
      );

      if (response.statusCode == 200) {
        return null;
      } else {
        return "Failed to update quotation";
      }
    } catch (e) {
      return "Error updating quotation";
    }
  }

  // ================================
  // DELETE QUOTATION
  // ================================
  static Future<String?> deleteQuotation(int quotationId) async {
    try {
      final dio = await DioClient().getAuthorizedDio();

      final response = await dio.delete(
        ApiConstants.quotationByIdEndPoint(quotationId),
      );

      if (response.statusCode == 204 || response.statusCode == 200) {
        return null;
      } else {
        return "Failed to delete quotation";
      }
    } catch (e) {
      return "Error deleting quotation";
    }
  }

  // ================================
  // UPDATE SINGLE PRODUCT
  // ================================
  static Future<String?> updateQuotationProduct(
    int quotationId,
    int productId,
    Map<String, dynamic> updatedData,
  ) async {
    try {
      final dio = await DioClient().getAuthorizedDio();

      final response = await dio.patch(
        ApiConstants.quotationByIdAndProductEndPoint(quotationId, productId),
        data: updatedData,
      );

      if (response.statusCode == 200) {
        return null;
      } else {
        return "Failed to update product";
      }
    } catch (e) {
      return "Error updating product";
    }
  }

  // ================================
  // DELETE SINGLE PRODUCT
  // ================================
  static Future<String?> deleteQuotationItem(
    int quotationId,
    int productId,
  ) async {
    try {
      final dio = await DioClient().getAuthorizedDio();

      final response = await dio.delete(
        ApiConstants.deleteQuotationProductEndPoint(quotationId, productId),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return null;
      } else {
        return "Failed to delete product";
      }
    } catch (e) {
      return "Error deleting product";
    }
  }
}
