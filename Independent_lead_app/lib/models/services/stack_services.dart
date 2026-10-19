import 'package:dio/dio.dart';
import 'package:pokakbilling/core/api/api_constants.dart';
import 'package:pokakbilling/core/api/dio_client.dart';
import 'package:pokakbilling/models/data-models/stack_model.dart';

class StackServices {
  static Future<String?> createStack(
    String stackName,
  ) async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      var data = {
        'name': stackName,
      };

      final response = await dio.post(
        ApiConstants.stackEndpoint,
        data: data,
      );

      if (response.statusCode == 201) {
        return null;
      } else {
        return 'Error: ${response.data}';
      }
    } on DioException catch (e) {
      if (e.response != null) {
        try {
          final errors = e.response?.data['Errors'];
          if (errors != null && errors.containsKey('unit')) {
            return errors['unit'][0];
          }
        } catch (_) {
          return 'Validation failed.';
        }
      }
      return 'Request failed: ${e.message}';
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  static Future<List<StackModel>> getAllStack() async {
    final dio = await DioClient().getAuthorizedDio();

    final response = await dio.get(
      ApiConstants.stackEndpoint,
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = response.data;
      List<dynamic> stackJson = jsonData["data"];

      if (jsonData["status"] == "1") {
        List<StackModel> stackList =
            stackJson.map((json) => StackModel.fromJson(json)).toList();

        return stackList;
      } else {
        throw Exception('Error: ${jsonData["message"]}');
      }
    } else {
      throw Exception('Failed to load Stack');
    }
  }

  static Future<String?> deleteStack(int stackId) async {
    try {
      final dio = await DioClient().getAuthorizedDio();

      final response = await dio.delete(
        ApiConstants.stackByIdEndpoint(stackId),
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

  static Future<String?> updateStack(int stackId, String newName) async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      var data = {
        'name': newName,
      };

      final response = await dio.patch(
        ApiConstants.stackByIdEndpoint(stackId),
        data: data,
      );

      if (response.statusCode == 200) {
        return null;
      } else {
        return 'Error: ${response.data}';
      }
    } on DioException catch (e) {
      return e.response?.data.toString() ?? 'Request failed: ${e.message}';
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }
}
