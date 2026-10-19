import 'package:dio/dio.dart';
import 'package:pokakbilling/core/api/api_constants.dart';
import 'package:pokakbilling/core/api/dio_client.dart';
import 'package:pokakbilling/models/data-models/receipt_model.dart';

class ReceiptServices {
  static Future<List<InvoiceModel>> getInvoice() async {
    final dio = await DioClient().getAuthorizedDio();

    final response = await dio.get(
      ApiConstants.invoiceEndpoint,
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = response.data;
      List<dynamic> invoiceJson = jsonData["data"];

      if (jsonData["status"] == "1") {
        List<InvoiceModel> invoiceList =
            invoiceJson.map((json) => InvoiceModel.fromJson(json)).toList();

        return invoiceList;
      } else {
        throw Exception('Error: ${jsonData["message"]}');
      }
    } else {
      throw Exception('Failed to load Invoice');
    }
  }

  static Future<int?> createReceipt(
    String receiptNumber,
    String receiptDate,
    int clientId,
    int invoiceId,
    int termsId,
    String remark,
  ) async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      var data = {
        'receipt_number': receiptNumber,
        'receipt_date': receiptDate,
        'client': clientId,
        'invoice': invoiceId,
        'termsandconditions': termsId,
        'remark': remark,
      };

      final response = await dio.post(ApiConstants.receiptEndpoint, data: data);

      if (response.statusCode == 201) {
        print("---------- success");
        final data = response.data;
        final int receiptId = data['receipt_id'];

        return receiptId;
      } else {
        print("---------- failure");
        return 0;
      }
    } on DioException catch (e) {
      Map<String, dynamic>? errorData = e.response?.data;
      print("error ====> $errorData");

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

  static Future<List<ReceiptModel>> getAllReceipt() async {
    final dio = await DioClient().getAuthorizedDio();

    final response = await dio.get(
      ApiConstants.receiptEndpoint,
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = response.data;
      List<dynamic> receiptJson = jsonData["Data"];

      if (jsonData["Status"] == "1") {
        List<ReceiptModel> receiptList =
            receiptJson.map((json) => ReceiptModel.fromJson(json)).toList();

        return receiptList;
      } else {
        throw Exception('Error: ${jsonData["message"]}');
      }
    } else {
      throw Exception('Failed to load Receipt');
    }
  }

  static Future<List<SingleReceiptModel>> getReceiptById(
    int receiptId,
  ) async {
    final dio = await DioClient().getAuthorizedDio();

    final response = await dio.get(
      ApiConstants.receiptByIdEndpoint(receiptId),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = response.data;
      List<dynamic> receiptJson = jsonData["Data"];

      if (jsonData["Status"] == "1") {
        List<SingleReceiptModel> receiptList = receiptJson
            .map((json) => SingleReceiptModel.fromJson(json))
            .toList();

        return receiptList;
      } else {
        throw Exception('Error: ${jsonData["message"]}');
      }
    } else {
      throw Exception('Failed to load Receipt');
    }
  }

  static Future<String?> updateReceipt(
    int receiptId,
    String receiptNumber,
    String receiptDate,
    int clientId,
    int invoiceId,
    int termsId,
    String remark,
  ) async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      var data = {
        'receipt_number': receiptNumber,
        'receipt_date': receiptDate,
        'client': clientId,
        'invoice': invoiceId,
        'termsandconditions': termsId,
        'remark': remark,
      };

      final response = await dio.patch(
        ApiConstants.receiptByIdEndpoint(receiptId),
        data: data,
      );

      if (response.statusCode == 200) {
        print("---------- success");

        return null;
      } else {
        print("---------- failure");
        return "error";
      }
    } on DioException catch (e) {
      Map<String, dynamic>? errorData = e.response?.data;
      print("error ====> $errorData");

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
}
