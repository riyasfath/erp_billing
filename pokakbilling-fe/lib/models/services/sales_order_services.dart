import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:pokakbilling/core/api/api_constants.dart';
import 'package:pokakbilling/core/api/dio_client.dart';
import 'package:pokakbilling/models/data-models/sales-order-models/salesOrderItems_model.dart';
import 'package:pokakbilling/models/data-models/sales-order-models/salesOrder_model.dart';

class SalesOrderServices {
  static Future<int?> createSalesOrder(
    String salesOrderNumber,
    String salesDate,
    int customerId,
    String purchaseOrderNumber,
    String terms,
    String deliveryLocation,
    String deliveryAddress,
    int termsandConditionId,
    String remarks,
    List<Map<String, dynamic>> items,
  ) async {
    try {
      final dio = await DioClient().getAuthorizedDio();

      var data = {
        'sales_order_number': salesOrderNumber,
        'customer': customerId,
        'sales_date': salesDate,
        'purchase_order_number': purchaseOrderNumber,
        'terms': terms,
        "delivery_location": deliveryLocation,
        "delivery_address": deliveryAddress,
        "termsandconditions": termsandConditionId,
        "remark": remarks,
        "items": items,
      };

      print("Final Payload: ${jsonEncode(data)}");

      final response = await dio.post(
        ApiConstants.salesOrderEndpoint,
        data: data,
      );

      if (response.statusCode == 201) {
        final data = response.data;
        final int salesOrderId = data['sales_order_id'];
        return salesOrderId;
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

  static Future<List<SalesOrderModel>> getAllSalesOrder() async {
    final dio = await DioClient().getAuthorizedDio();

    final response = await dio.get(
      ApiConstants.salesOrderEndpoint,
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = response.data;
      List<dynamic> salesOrderJson = jsonData["data"];

      if (jsonData["status"] == "1") {
        List<SalesOrderModel> salesOrderList = salesOrderJson
            .map((json) => SalesOrderModel.fromJson(json))
            .toList();

        return salesOrderList;
      } else {
        throw Exception('Error: ${jsonData["message"]}');
      }
    } else {
      throw Exception('Failed to load Sales Order');
    }
  }

  static Future<String?> deleteSalesOrder(int salesOrderId) async {
    try {
      final dio = await DioClient().getAuthorizedDio();

      final response = await dio.delete(
        ApiConstants.salesOrderByIdEndPoint(salesOrderId),
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

  static Future<List<SalesOrderitemsModel>> getSalesOrderById(
    int salesOrderId,
  ) async {
    final dio = await DioClient().getAuthorizedDio();

    final response = await dio.get(
      ApiConstants.salesOrderByIdEndPoint(salesOrderId),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = response.data;
      List<dynamic> salesOrderJson = jsonData["data"];

      if (jsonData["status"] == "1") {
        List<SalesOrderitemsModel> salesOrderList = salesOrderJson
            .map((json) => SalesOrderitemsModel.fromJson(json))
            .toList();

        return salesOrderList;
      } else {
        throw Exception('Error: ${jsonData["message"]}');
      }
    } else {
      throw Exception('Failed to load Sales Order');
    }
  }

  static Future<String?> editSalesOrder(
    int salesOrderId,
    String salesOrderNumber,
    String salesDate,
    int customerId,
    String purchaseOrderNumber,
    String deliveryLocation,
    String deliveryAddress,
    int termsandConditionId,
    String remarks,
    List<Map<String, dynamic>> items,
  ) async {
    try {
      final dio = await DioClient().getAuthorizedDio();

      var data = {
        'sales_order_number': salesOrderNumber,
        'customer': customerId,
        'sales_date': salesDate,
        'purchase_order_number': purchaseOrderNumber,
        "delivery_location": deliveryLocation,
        "delivery_address": deliveryAddress,
        "termsandconditions": termsandConditionId,
        "remark": remarks,
        "items": items,
      };

      print("Final Payload: ${jsonEncode(data)}");

      final response = await dio.patch(
        ApiConstants.salesOrderByIdEndPoint(salesOrderId),
        data: data,
      );

      if (response.statusCode == 200) {
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

  static Future<String?> deleteSalesOrderItems(
      int salesOrderId, int productTabId) async {
    try {
      final dio = await DioClient().getAuthorizedDio();

      final response = await dio.delete(
        ApiConstants.deleteSalesOrderItemsEndPoint(salesOrderId, productTabId),
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
