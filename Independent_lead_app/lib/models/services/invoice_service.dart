import 'package:dio/dio.dart';
import 'package:pokakbilling/core/api/api_constants.dart';
import 'package:pokakbilling/core/api/dio_client.dart';
import 'package:pokakbilling/models/data-models/invoice-model/invoice-model.dart';

class InvoiceServices {
  // ================= CREATE =================
  static Future<String?> createInvoice(Map<String, dynamic> data) async {
    try {
      final dio = await DioClient().getAuthorizedDio();

      final response = await dio.post(
        ApiConstants.createInvoiceEndpoint,
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return null;
      } else {
        return response.data.toString();
      }
    } on DioException catch (e) {
      return e.response?.data.toString() ?? "Create failed";
    } catch (e) {
      return "Unexpected error: $e";
    }
  }

  // ================= EDIT =================
  static Future<String?> editInvoice(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final dio = await DioClient().getAuthorizedDio();

      final response = await dio.patch(
        ApiConstants.invoiceByIdEndpoint(id),
        data: data,
      );

      if (response.statusCode == 200) {
        return null;
      } else {
        return response.data.toString();
      }
    } on DioException catch (e) {
      return e.response?.data.toString() ?? "Edit failed";
    } catch (e) {
      return "Unexpected error: $e";
    }
  }

  // ================= GET INVOICES =================

  static Future<List<InvoiceModel>> getInvoices({
    String? status,
  }) async {
    try {
      final dio = await DioClient().getAuthorizedDio();

      String url = ApiConstants.getInvoiceEndpoint;

      /// ADD QUERY PARAM
      if (status != null && status.isNotEmpty) {
        url += "?status=$status";
      }

      final response = await dio.get(url);

      if (response.statusCode == 200) {
        List data = response.data;

        return data.map((e) => InvoiceModel.fromJson(e)).toList();
      } else {
        throw Exception("Failed to load invoices");
      }
    } catch (e) {
      throw Exception("GET ERROR: $e");
    }
  }

  // ================== GET BY ID ========================
  static Future<InvoiceModel?> getInvoiceById(int id) async {
    try {
      final dio = await DioClient().getAuthorizedDio();

      final response = await dio.get(ApiConstants.invoiceByIdEndpoint(id));

      if (response.statusCode == 200) {
        return InvoiceModel.fromJson(response.data);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // ================== EDIT ========================
  // static Future<String?> editInvoice(
  //   int id,
  //   Map<String, dynamic> data,
  // ) async {
  //   try {
  //     final dio = await DioClient().getAuthorizedDio();

  //     final response = await dio.patch(
  //       ApiConstants.invoiceByIdEndpoint(id),
  //       data: data,
  //     );

  //     if (response.statusCode == 200) {
  //       return null;
  //     } else {
  //       return response.data.toString();
  //     }
  //   } on DioException catch (e) {
  //     return e.response?.data.toString() ?? "Edit failed";
  //   } catch (e) {
  //     return "Unexpected error: $e";
  //   }
  // }

  // ================== DELETE ========================
  static Future<String?> deleteInvoice(int id) async {
    try {
      final dio = await DioClient().getAuthorizedDio();

      final response = await dio.delete(
        ApiConstants.deleteInvoiceEndpoint(id),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return null;
      } else {
        return response.data.toString();
      }
    } on DioException catch (e) {
      return e.response?.data.toString() ?? "Delete failed";
    } catch (e) {
      return "Unexpected error: $e";
    }
  }
}
