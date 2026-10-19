import 'package:ecommerce_app/core/api_client.dart';
import 'package:ecommerce_app/core/providers.dart';
import 'package:ecommerce_app/models/catgeroy_api_model.dart';

/// Network call for /api/products/categories/. Response is a plain JSON
/// array (like bestseller) — ApiClient.get() wraps that as {'data': [...]}.
class CategoryService {
  final ApiClient _apiClient;

  CategoryService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<List<CategoryApiModel>> getCategories() async {
    final data = await _apiClient.get(ApiEndpoints.categories);
    final List<dynamic> resultsJson = (data['data'] as List?) ?? [];
    return resultsJson
        .map((e) => CategoryApiModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}