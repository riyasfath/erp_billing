import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:pokakbilling/core/api/api_constants.dart';
import 'package:pokakbilling/core/api/dio_client.dart';
import 'package:pokakbilling/models/data-models/delivery-models/deliveryOrderItems_model.dart';
import 'package:pokakbilling/models/data-models/delivery-models/delivery_models.dart';
import 'package:pokakbilling/models/data-models/delivery-models/items_by_salesOrder.dart';
import 'package:pokakbilling/models/data-models/delivery-models/salesOrder_by_client_model.dart';

class DeliveryServices {
  static Future<List<SalesorderByClientModel>> getSalesOrderByClient(
    int clientId,
  ) async {
    final dio = await DioClient().getAuthorizedDio();

    final response = await dio.get(
      ApiConstants.salesOrderByClientIdEndPoint(clientId),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = response.data;
      List<dynamic> salesOrderJson = jsonData["data"];

      if (jsonData["status"] == "1") {
        List<SalesorderByClientModel> accountList = salesOrderJson
            .map((json) => SalesorderByClientModel.fromJson(json))
            .toList();

        return accountList;
      } else {
        throw Exception('Error: ${jsonData["message"]}');
      }
    } else {
      throw Exception('Failed to load Sales Orders');
    }
  }

  static Future<List<ItemsBySalesOrder>> getItemsBySalesOrder(
    int salesOrderId,
  ) async {
    final dio = await DioClient().getAuthorizedDio();

    final response = await dio.get(
      ApiConstants.itemsBySalesOrderIdEndPoint(salesOrderId),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = response.data;
      List<dynamic> itemJson = jsonData["data"];

      if (jsonData["status"] == "1") {
        List<ItemsBySalesOrder> itemList =
            itemJson.map((json) => ItemsBySalesOrder.fromJson(json)).toList();

        return itemList;
      } else {
        throw Exception('Error: ${jsonData["message"]}');
      }
    } else {
      throw Exception('Failed to load Items');
    }
  }

  static Future<int?> createDeliveryOrder(
    int customerId,
    String deliveryNumber,
    String deliveryDate,
    int salesOrderId,
    String deliveryLocation,
    String deliveryAddress,
    String contactPerson,
    String mobileNumber,
    int termsandConditionId,
    String time,
    String date,
    List<Map<String, dynamic>> items,
  ) async {
    try {
      final dio = await DioClient().getAuthorizedDio();

      var data = {
        'customer': customerId,
        'delivery_number': deliveryNumber,
        'delivery_date': deliveryDate,
        'sales_order': salesOrderId,
        "delivery_location": deliveryLocation,
        "delivery_address": deliveryAddress,
        "contact_person": contactPerson,
        "mobile_number": mobileNumber,
        "termsandconditions": termsandConditionId,
        "time": time,
        "date": date,
        "items": items,
      };

      print("Final Payload: ${jsonEncode(data)}");

      final response = await dio.post(
        ApiConstants.deliveryEndpoint,
        data: data,
      );

      if (response.statusCode == 201) {
        final data = response.data;
        final int deliveryId = data['delivery_number'];
        return deliveryId;
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

  static Future<List<DeliveryModel>> getAllDeliveryOrders() async {
    final dio = await DioClient().getAuthorizedDio();

    final response = await dio.get(
      ApiConstants.deliveryEndpoint,
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = response.data;
      List<dynamic> deliveryOrderJson = jsonData["data"];

      if (jsonData["status"] == "1") {
        List<DeliveryModel> deliveryOrderList = deliveryOrderJson
            .map((json) => DeliveryModel.fromJson(json))
            .toList();

        return deliveryOrderList;
      } else {
        throw Exception('Error: ${jsonData["message"]}');
      }
    } else {
      throw Exception('Failed to load Delivery Orders');
    }
  }

  static Future<List<DeliveryOrderItemsModel>> getDeliveryOrderById(
    int deliveryOrderId,
  ) async {
    final dio = await DioClient().getAuthorizedDio();

    final response = await dio.get(
      ApiConstants.deliveryByIdEndpoint(deliveryOrderId),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = response.data;
      List<dynamic> deliveryOrderJson = jsonData["data"];

      if (jsonData["status"] == "1") {
        List<DeliveryOrderItemsModel> deliveryOrderList = deliveryOrderJson
            .map((json) => DeliveryOrderItemsModel.fromJson(json))
            .toList();

        return deliveryOrderList;
      } else {
        throw Exception('Error: ${jsonData["message"]}');
      }
    } else {
      throw Exception('Failed to load Delivery Order');
    }
  }

  static Future<String?> deleteDeliveryOrder(int deliveryOrderId) async {
    try {
      final dio = await DioClient().getAuthorizedDio();

      final response = await dio.delete(
        ApiConstants.deliveryByIdEndpoint(deliveryOrderId),
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
