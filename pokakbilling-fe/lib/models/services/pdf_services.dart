import 'package:pokakbilling/core/api/api_constants.dart';
import 'package:pokakbilling/core/api/dio_client.dart';
import 'package:pokakbilling/models/data-models/delivery-models/delivery_pdf_model.dart';
import 'package:pokakbilling/models/data-models/purchase-order-models/purchase_order_items_model.dart';
import 'package:pokakbilling/models/data-models/quotations-models/pdf_model.dart';
import 'package:pokakbilling/models/data-models/receipt/receipt_pdf_model.dart';
import 'package:pokakbilling/models/data-models/sales-order-models/salesorder_pdf_model.dart';

class PdfServices {
  static Future<List<QuotationPdfModel>> getQuotationPdf(
      int quotationPdfId) async {
    final dio = await DioClient().getAuthorizedDio();

    final response = await dio.get(
      ApiConstants.getQuotationPdfEndpoint(quotationPdfId),
    );

    if (response.statusCode == 200) {
      final jsonData = response.data as Map<String, dynamic>;
      final data = jsonData["data"] as List<dynamic>?;

      if (jsonData["status"] == "1" && data != null) {
        return data.map((e) => QuotationPdfModel.fromJson(e)).toList();
      } else {
        throw Exception("Error: ${jsonData['message']}");
      }
    } else {
      throw Exception("Failed to load quotation PDF");
    }
  }

  static Future<List<SalesOrderPdfModel>> getSalesorderPdf(
      int salesorderPdfId) async {
    final dio = await DioClient().getAuthorizedDio();

    final response = await dio.get(
      ApiConstants.getSalesorderPdfEndpoint(salesorderPdfId),
    );

    if (response.statusCode == 200) {
      final jsonData = response.data as Map<String, dynamic>;
      final data = jsonData["data"] as List<dynamic>?;

      if (jsonData["status"] == "1" && data != null) {
        return data.map((e) => SalesOrderPdfModel.fromJson(e)).toList();
      } else {
        throw Exception("Error: ${jsonData['message']}");
      }
    } else {
      throw Exception("Failed to load sales order PDF");
    }
  }

  static Future<List<PurchaseOrderItemsModel>> getPurchaseOrderPdf(
      int purchaseOrderId) async {
    final dio = await DioClient().getAuthorizedDio();

    final response = await dio.get(
      ApiConstants.purchaseOrderByIdEndpoint(purchaseOrderId),
    );

    if (response.statusCode == 200) {
      final jsonData = response.data as Map<String, dynamic>;
      final data = jsonData["data"] as List<dynamic>?;

      if (jsonData["status"] == "1" && data != null) {
        return data.map((e) => PurchaseOrderItemsModel.fromJson(e)).toList();
      } else {
        throw Exception("Error: ${jsonData['message']}");
      }
    } else {
      throw Exception("Failed to load purchase order PDF");
    }
  }

  // static Future<List<MaterialReceiveItemModel>> getMaterialReceivePdf(
  //     int mrId) async {
  //   final dio = await DioClient().getAuthorizedDio();

  //   final response =
  //       await dio.get(ApiConstants.materialReceiveByIdEndpoint(mrId));

  //   if (response.statusCode == 200) {
  //     final jsonData = response.data as Map<String, dynamic>;
  //     final data = jsonData["data"] as List<dynamic>?;

  //     if (jsonData["status"] == "1" && data != null) {
  //       return data.map((e) => MaterialReceiveItemModel.fromJson(e)).toList();
  //     } else {
  //       throw Exception("Error: ${jsonData['message']}");
  //     }
  //   } else {
  //     throw Exception("Failed to load material receive PDF");
  //   }
  // }

  static Future<List<DeliveryPdfModel>> getDeliveryPdf(
      int deliveryOrderId) async {
    final dio = await DioClient().getAuthorizedDio();

    final response = await dio.get(
      ApiConstants.getdeliveryPdfEndpoint(deliveryOrderId),
    );

    if (response.statusCode == 200) {
      final jsonData = response.data as Map<String, dynamic>;
      final data = jsonData["data"] as List<dynamic>?;

      if (jsonData["status"] == "1" && data != null) {
        return data.map((e) => DeliveryPdfModel.fromJson(e)).toList();
      } else {
        throw Exception("Error: ${jsonData['message']}");
      }
    } else {
      throw Exception("Failed to load delivery order PDF");
    }
  }

  static Future<List<ReceiptPdfModel>> getReceiptPdf(int receiptPdfId) async {
    final dio = await DioClient().getAuthorizedDio();

    final response = await dio.get(
      ApiConstants.getReceiptPdfEndpoint(receiptPdfId),
    );

    if (response.statusCode == 200) {
      final jsonData = response.data as Map<String, dynamic>;
      final data = jsonData["Data"] as List<dynamic>?;

      if (jsonData["Status"] == "1" && data != null) {
        return data.map((e) => ReceiptPdfModel.fromJson(e)).toList();
      } else {
        throw Exception("Error: \${jsonData['Message']}");
      }
    } else {
      throw Exception("Failed to load receipt PDF");
    }
  }
}
