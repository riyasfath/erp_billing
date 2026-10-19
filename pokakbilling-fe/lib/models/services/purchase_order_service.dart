import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:pokakbilling/core/api/api_constants.dart';
import 'package:pokakbilling/core/api/dio_client.dart';
import 'package:pokakbilling/models/data-models/purchase-order-models/purchase_order_items_model.dart';
import 'package:pokakbilling/models/data-models/purchase-order-models/purchase_order_model.dart';

class PurchaseOrderService {
  static Future<int?> createPurchaseOrder(
    String purchaseOrderNumber,
    String purchaseOrderDate,
    int supplierId,
    String quotationNumber,
    String contactPersonName,
    String contactPersonNumber,
    double grandTotal,
    String remarks,
    int termsandConditionId,
    List<Map<String, dynamic>> items,
  ) async {
    try {
      final dio = await DioClient().getAuthorizedDio();

      var data = {
        'supplier': supplierId,
        'purchase_order_number': purchaseOrderNumber,
        'purchase_order_date': purchaseOrderDate,
        'contact_person_name': contactPersonName,
        'contact_person_number': contactPersonNumber,
        "quotation_number": quotationNumber,
        "grand_total": grandTotal,
        "terms_and_conditions": termsandConditionId,
        "remark": remarks,
        "items": items,
      };

      print("Final Payload: ${jsonEncode(data)}");

      final response = await dio.post(
        ApiConstants.purchaseOrderEndPoint,
        data: data,
      );

      if (response.statusCode == 201) {
        print("API is success");

        final responseData = response.data;
        final purchaseOrderId = responseData['data']?['id'];

        print("Created Purchase Order ID: $purchaseOrderId");
        return purchaseOrderId;
      } else {
        return 0;
      }
    } on DioException catch (e) {
      print("error $e");
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

  static Future<List<PurchaseOrderModel>> getAllPurchaseOrders() async {
    final dio = await DioClient().getAuthorizedDio();

    final response = await dio.get(
      ApiConstants.purchaseOrderEndPoint,
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = response.data;
      List<dynamic> purchaseOrderJson = jsonData["data"];

      if (jsonData["status"] == "1") {
        List<PurchaseOrderModel> deliveryOrderList = purchaseOrderJson
            .map((json) => PurchaseOrderModel.fromJson(json))
            .toList();

        return deliveryOrderList;
      } else {
        throw Exception('Error: ${jsonData["message"]}');
      }
    } else {
      throw Exception('Failed to load Purchase Orders');
    }
  }

  static Future<List<PurchaseOrderItemsModel>> getPurchaseOrderById(
    int purchaseOrderId,
  ) async {
    final dio = await DioClient().getAuthorizedDio();

    final response = await dio.get(
      ApiConstants.purchaseOrderByIdEndpoint(purchaseOrderId),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = response.data;
      List<dynamic> purchaseOrderJson = jsonData["data"];

      if (jsonData["status"] == "1") {
        List<PurchaseOrderItemsModel> purchaseOrderList = purchaseOrderJson
            .map((json) => PurchaseOrderItemsModel.fromJson(json))
            .toList();

        return purchaseOrderList;
      } else {
        throw Exception('Error: ${jsonData["message"]}');
      }
    } else {
      throw Exception('Failed to load Purchase Order');
    }
  }

  static Future<String?> deletePurchaseOrder(int purchaseOrderId) async {
    try {
      final dio = await DioClient().getAuthorizedDio();

      final response = await dio.delete(
        ApiConstants.purchaseOrderByIdEndpoint(purchaseOrderId),
      );

      if (response.statusCode == 204) {
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

  static Future<String?> editPurchaseOrder(
    int purchaseId,
    String purchaseOrderNumber,
    String purchaseOrderDate,
    int supplierId,
    String quotationNumber,
    String contactPersonName,
    String contactPersonNumber,
    double grandTotal,
    String remarks,
    int termsandConditionId,
    List<Map<String, dynamic>> items,
  ) async {
    try {
      final dio = await DioClient().getAuthorizedDio();

      var data = {
        'supplier': supplierId,
        'purchase_order_number': purchaseOrderNumber,
        'purchase_order_date': purchaseOrderDate,
        'contact_person_name': contactPersonName,
        'contact_person_number': contactPersonNumber,
        "quotation_number": quotationNumber,
        "grand_total": grandTotal,
        "terms_and_conditions": termsandConditionId,
        "remark": remarks,
        "items": items,
      };

      print("Final Payload: ${jsonEncode(data)}");

      final response = await dio.patch(
        ApiConstants.purchaseOrderByIdEndpoint(purchaseId),
        data: data,
      );

      if (response.statusCode == 200) {
        print("API is success");

        return null;
      } else {
        return "Error";
      }
    } on DioException catch (e) {
      print("error $e");
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
}
