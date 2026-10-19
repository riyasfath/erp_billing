import 'package:dio/dio.dart';
import 'package:pokakbilling/core/api/api_constants.dart';
import 'package:pokakbilling/core/api/dio_client.dart';
import 'package:pokakbilling/models/data-models/marketing_model/category.dart';

class CategoryMarketingServices {
  // GET - Fetch all categories
  static Future<List<CategoryMarketing>> getCategories() async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      final response = await dio.get(ApiConstants.categoryListEndpoint);

      if (response.statusCode == 200) {
        List<dynamic> categoriesJson = response.data;
        return categoriesJson
            .map((json) => CategoryMarketing.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load categories');
      }
    } on DioException catch (e) {
      String? errorMsg = 'Unknown error';
      if (e.response?.data != null) {
        errorMsg = e.response!.data.toString();
      } else {
        errorMsg = e.message;
      }
      throw Exception(errorMsg);
    }
  }

  // POST - Create new category
  static Future<String?> createCategory(String name, int source) async {
    try {
      final dio = await DioClient().getAuthorizedDio();

      var data = {
        'name': name,
        'source': source,
      };

      final response = await dio.post(
        ApiConstants.categoryListEndpoint,
        data: data,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return null; // Success
      } else {
        return 'Error: ${response.data}';
      }
    } on DioException catch (e) {
      if (e.response != null) {
        try {
          final errors = e.response?.data['Errors'];
          if (errors != null && errors.containsKey('name')) {
            return errors['name'][0];
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

  // PUT/PATCH - Update category
  static Future<String?> updateCategory(
      int categoryId, String name, int source) async {
    try {
      final dio = await DioClient().getAuthorizedDio();

      var data = {
        'name': name,
        'source': source,
      };

      final response = await dio.patch(
        '${ApiConstants.categoryListEndpoint}$categoryId/',
        data: data,
      );

      if (response.statusCode == 200) {
        return null; // Success
      } else {
        return 'Error: ${response.data}';
      }
    } on DioException catch (e) {
      if (e.response != null) {
        try {
          final errors = e.response?.data['Errors'];
          if (errors != null && errors.containsKey('name')) {
            return errors['name'][0];
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

  // DELETE - Delete category
  static Future<String?> deleteCategory(int categoryId) async {
    try {
      final dio = await DioClient().getAuthorizedDio();

      final response = await dio.delete(
        '${ApiConstants.categoryListEndpoint}$categoryId/',
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return null; // Success
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
