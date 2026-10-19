import 'package:dio/dio.dart';
import 'package:pokakbilling/core/api/api_constants.dart';
import 'package:pokakbilling/models/data-models/setup/category_model.dart';

class CategoryServices {
  static Future<String?> createCategory(
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
        ApiConstants.categoryEndpoint,
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

  static Future<List<CategoryModel>> getAllCategories() async {
    final dio = Dio();

    final response = await dio.get(
      ApiConstants.categoryEndpoint,
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = response.data;
      List<dynamic> customerJson = jsonData["Data"];

      if (jsonData["Status"] == "1") {
        List<CategoryModel> categoryList =
            customerJson.map((json) => CategoryModel.fromJson(json)).toList();

        return categoryList;
      } else {
        throw Exception('Error: ${jsonData["message"]}');
      }
    } else {
      throw Exception('Failed to load Category');
    }
  }

  static Future<String?> deleteCategory(int categoryId) async {
    try {
      final dio = Dio();

      final response = await dio.delete(
        ApiConstants.categoryByIdEndpoint(categoryId),
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

  static Future<List<CategoryModel>> getCategoryById(int categoryId) async {
    final dio = Dio();

    final response = await dio.get(
      ApiConstants.categoryByIdEndpoint(categoryId),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = response.data;
      List<dynamic> categoryJson = jsonData["Data"];

      if (jsonData["Status"] == "1") {
        List<CategoryModel> categoryList =
            categoryJson.map((json) => CategoryModel.fromJson(json)).toList();

        return categoryList;
      } else {
        throw Exception('Error: ${jsonData["message"]}');
      }
    } else {
      throw Exception('Failed to load Categories');
    }
  }

  static Future<String?> editCategory(
    int categoryId,
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
        ApiConstants.categoryByIdEndpoint(categoryId),
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
