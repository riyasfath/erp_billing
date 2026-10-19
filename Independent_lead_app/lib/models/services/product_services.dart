import 'package:dio/dio.dart';
import 'package:pokakbilling/core/api/api_constants.dart';
import 'package:pokakbilling/core/api/dio_client.dart';
import 'package:pokakbilling/models/data-models/product_model.dart';

class ProductServices {
  //================== CREATE PRODUCT ========================
  static Future<String?> addProduct(
    String productName,
    String description,
    String unit,
    String unitPrice,
    String category,
    int stock,
    String sgst,
    String cgst,
  ) async {
    try {
      final dio = await DioClient().getAuthorizedDio();

      var data = {
        'name': productName,
        'description': description,
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
    } catch (e) {
      return "Unexpected error: $e";
    }
  }

  //================== GET ALL PRODUCT ========================
  static Future<List<ProductModel>> getProducts() async {
    final dio = await DioClient().getAuthorizedDio();

    final response = await dio.get(ApiConstants.getProductEndPoint);

    if (response.statusCode == 200) {
      List<dynamic> productJson = response.data;
      List<ProductModel> productList =
          productJson.map((json) => ProductModel.fromJson(json)).toList();

      return productList;
    } else {
      throw Exception('Failed to load Products');
    }
  }

  //================== DELETE PRODUCT ========================
  static Future<String?> deleteProduct(int productId) async {
    try {
      final dio = await DioClient().getAuthorizedDio();

      final response = await dio.delete(
        ApiConstants.productByIdEndPoint(productId),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
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

  //================== PRODUCT BY ID ========================
  static Future<List<ProductModel>> getProductById(int productId) async {
    final dio = await DioClient().getAuthorizedDio();

    final response = await dio.get(
      ApiConstants.productByIdEndPoint(productId),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = response.data;
      List<dynamic> productJson = jsonData["Data"];

      if (jsonData["Status"] == "1") {
        List<ProductModel> productList =
            productJson.map((json) => ProductModel.fromJson(json)).toList();

        return productList;
      } else {
        throw Exception('Error: ${jsonData["message"]}');
      }
    } else {
      throw Exception('Failed to load Product');
    }
  }

  //================== EDIT PRODUCT ========================
  static Future<String?> updateProduct(
    int productId,
    String productName,
    String description,
    String unit,
    String unitPrice,
    String category,
    int stock,
    String sgst,
    String cgst,
  ) async {
    try {
      final dio = await DioClient().getAuthorizedDio();

      var data = {
        'name': productName,
        'description': description,
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
    } catch (e) {
      return "Unexpected error: $e";
    }
  }
}
