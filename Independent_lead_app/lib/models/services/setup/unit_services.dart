import 'package:dio/dio.dart';
import 'package:pokakbilling/core/api/api_constants.dart';
import 'package:pokakbilling/models/data-models/setup/unit_model.dart';

class UnitServices {
  static Future<String?> createUnit(
    String name,
    String description,
  ) async {
    try {
      final dio = Dio();
      var data = {
        'name': name,
        'description': description,
      };

      final response = await dio.post(
        ApiConstants.unitEndpoint,
        data: data,
      );

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

  static Future<List<UnitModel>> getAllUnits() async {
    final dio = Dio();

    final response = await dio.get(
      ApiConstants.unitEndpoint,
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = response.data;
      List<dynamic> unitJson = jsonData["Data"];

      if (jsonData["Status"] == "1") {
        List<UnitModel> unitList =
            unitJson.map((json) => UnitModel.fromJson(json)).toList();

        return unitList;
      } else {
        throw Exception('Error: ${jsonData["message"]}');
      }
    } else {
      throw Exception('Failed to load Units');
    }
  }

  static Future<String?> deleteUnit(int unitId) async {
    try {
      final dio = Dio();

      final response = await dio.delete(
        ApiConstants.unitByIdEndpoint(unitId),
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

  static Future<List<UnitModel>> getUnitById(int unitId) async {
    final dio = Dio();

    final response = await dio.get(
      ApiConstants.unitByIdEndpoint(unitId),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = response.data;
      List<dynamic> unitJson = jsonData["Data"];

      if (jsonData["Status"] == "1") {
        List<UnitModel> unitList =
            unitJson.map((json) => UnitModel.fromJson(json)).toList();

        return unitList;
      } else {
        throw Exception('Error: ${jsonData["message"]}');
      }
    } else {
      throw Exception('Failed to load unit');
    }
  }

  static Future<String?> editUnit(
    int unitId,
    String name,
    String description,
  ) async {
    try {
      final dio = Dio();
      var data = {
        'name': name,
        'description': description,
      };

      final response = await dio.patch(
        ApiConstants.unitByIdEndpoint(unitId),
        data: data,
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
