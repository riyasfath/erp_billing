import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:pokakbilling/core/api/api_constants.dart';
import 'package:pokakbilling/core/api/dio_client.dart';
import 'package:pokakbilling/models/data-models/material_receive/material_receive_model.dart';
import 'package:pokakbilling/models/data-models/material_receive/mr_items_model.dart';

class MaterialReceiveService {
  static Future<int?> createMaterialReceive(
    String mrNumber,
    String mrDate,
    int supplierId,
    int purchaseOrderId,
    String grandTotal,
    String remarks,
    List<Map<String, dynamic>> items,
  ) async {
    try {
      final dio = await DioClient().getAuthorizedDio();

      var data = {
        'material_receive_number': mrNumber,
        'received_date': mrDate,
        'supplier': supplierId,
        'purchase_order': purchaseOrderId,
        "grand_total": grandTotal,
        "remark": remarks,
        "items": items,
      };

      print("Final Payload: ${jsonEncode(data)}");

      final response = await dio.post(
        ApiConstants.materialReceiveEndPoint,
        data: data,
      );

      if (response.statusCode == 201) {
        final int mrId = response.data["data"]["id"];
        return mrId;
      } else {
        return null;
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

  static Future<List<MaterialReceiveModel>> getAllMaterialReceive() async {
    final dio = await DioClient().getAuthorizedDio();

    final response = await dio.get(ApiConstants.materialReceiveEndPoint);

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = response.data;
      List<dynamic> materialReceiveJson = jsonData["data"];

      if (jsonData["status"] == "1") {
        List<MaterialReceiveModel> receiveList = materialReceiveJson
            .map((json) => MaterialReceiveModel.fromJson(json))
            .toList();

        return receiveList;
      } else {
        throw Exception('Error: ${jsonData["message"]}');
      }
    } else {
      throw Exception('Failed to load Material Receive');
    }
  }

  static Future<List<MaterialReceiveItemModel>> getMaterialReceiveById(
      int mrId) async {
    final dio = await DioClient().getAuthorizedDio();

    final response =
        await dio.get(ApiConstants.materialReceiveByIdEndpoint(mrId));

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = response.data;
      List<dynamic> mrJson = jsonData["data"];

      if (jsonData["status"] == "1") {
        List<MaterialReceiveItemModel> mrList = mrJson
            .map((json) => MaterialReceiveItemModel.fromJson(json))
            .toList();

        return mrList;
      } else {
        throw Exception("Error: ${jsonData["message"]}");
      }
    } else {
      throw Exception("Failed to load Material Receive by ID");
    }
  }

  static Future<bool> deleteMaterialReceive(int mrId) async {
    try {
      final dio = await DioClient().getAuthorizedDio();

      final response =
          await dio.delete(ApiConstants.materialReceiveByIdEndpoint(mrId));

      if (response.statusCode == 204) {
        print("Material Receive deleted successfully");
        return true;
      } else {
        print("Failed to delete Material Receive: ${response.statusCode}");
        return false;
      }
    } on DioException catch (e) {
      print("Dio error during deletion: ${e.response?.data}");
      return false;
    } catch (e) {
      print("General error during deletion: $e");
      return false;
    }
  }

  static Future<String?> editMaterialReceive(
    int mrId,
    String mrNumber,
    String mrDate,
    int supplierId,
    int purchaseOrderId,
    String grandTotal,
    String remarks,
    List<Map<String, dynamic>> items,
  ) async {
    try {
      final dio = await DioClient().getAuthorizedDio();

      var data = {
        'material_receive_number': mrNumber,
        'received_date': mrDate,
        'supplier': supplierId,
        'purchase_order': purchaseOrderId,
        "grand_total": grandTotal,
        "remark": remarks,
        "items": items,
      };

      print("Edit Payload: ${jsonEncode(data)}");

      final response = await dio.patch(
        ApiConstants.materialReceiveByIdEndpoint(mrId),
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        print("Material Receive updated successfully");
        return null;
      } else {
        print("Failed to update: ${response.statusCode}");
        return "Error";
      }
    } on DioException catch (e) {
      print("Edit error: ${e.response?.data}");
      return "Error";
    } catch (e) {
      print("Unexpected error: $e");
      return "Error";
    }
  }
}
