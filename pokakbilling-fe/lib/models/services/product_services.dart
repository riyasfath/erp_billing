import 'package:dio/dio.dart';
import 'package:pokakbilling/core/api/api_constants.dart';
import 'package:pokakbilling/core/api/dio_client.dart';
import 'package:pokakbilling/models/data-models/product_model.dart';

class ProductServices {
  static Future<String?> addProduct(
    String productName,
    String productDescription,
    String unit,
    String unitPrice,
    int category,
    String stock,
    String sgst,
    String cgst,
  ) async {
    try {
      final dio = await DioClient().getAuthorizedDio();

      var data = {
        'name': productName,
        'product_description': productDescription,
        'unit': unit,
        'unit_price': unitPrice,
        'category': category,
        'stock': stock,
        'sgst': sgst,
        'cgst': cgst,
      };

      final response = await dio.post(
        ApiConstants.addProductEndPoint,
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

  static Future<List<ProductModel>> getProducts() async {
    final dio = await DioClient().getAuthorizedDio();

    final response = await dio.get(ApiConstants.getProductEndPoint);

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = response.data;
      List<dynamic> productJson = jsonData["Data"];

      if (jsonData["Status"] == "1") {
        return productJson.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        throw Exception('Error: ${jsonData["message"]}');
      }
    } else {
      throw Exception('Failed to load Products');
    }
  }

  static Future<String?> deleteProduct(int productId) async {
    try {
      final dio = await DioClient().getAuthorizedDio();

      final response = await dio.delete(
        ApiConstants.productByIdEndPoint(productId),
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

  // FIX: The API returns { "Status": "1", "Data": { ... } } — a single object,
  // NOT an array. We now handle BOTH shapes defensively so it never crashes.
  static Future<List<ProductModel>> getProductById(int productId) async {
    final dio = await DioClient().getAuthorizedDio();

    final response = await dio.get(
      ApiConstants.productByIdEndPoint(productId),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = response.data;

      if (jsonData["Status"] == "1") {
        final rawData = jsonData["Data"];

        // API may return a single object {} or an array [{}].
        // Normalise to List<ProductModel> either way.
        if (rawData is List) {
          // Array response → map directly
          return rawData
              .map(
                  (json) => ProductModel.fromJson(json as Map<String, dynamic>))
              .toList();
        } else if (rawData is Map<String, dynamic>) {
          // Single-object response → wrap in a list
          return [ProductModel.fromJson(rawData)];
        } else {
          throw Exception('Unexpected Data format in getProductById response');
        }
      } else {
        throw Exception('Error: ${jsonData["message"]}');
      }
    } else {
      throw Exception('Failed to load Product');
    }
  }

  static Future<String?> updateProduct(
    int productId,
    String productName,
    String productDescription,
    String unit,
    String unitPrice,
    int category,
    String stock,
    String sgst,
    String cgst,
  ) async {
    try {
      final dio = await DioClient().getAuthorizedDio();

      var data = {
        'name': productName,
        'product_description': productDescription,
        'unit': unit,
        'unit_price': unitPrice,
        'category': category,
        'stock': stock,
        'sgst': sgst,
        'cgst': cgst,
      };

      final response = await dio.put(
        ApiConstants.productByIdEndPoint(productId),
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
