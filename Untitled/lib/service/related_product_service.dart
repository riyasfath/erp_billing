import 'package:ecommerce_app/core/api_client.dart';
import 'package:ecommerce_app/core/providers.dart';
import 'package:ecommerce_app/models/product_model.dart';

/// Network call for GET /api/products/{id}/related/ — used for the
/// "Similar Products" section at the bottom of the product detail page.
class RelatedProductsService {
  final ApiClient _apiClient;

  RelatedProductsService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<List<ProductModel>> getRelated(String productId) async {
    final data = await _apiClient.get(ApiEndpoints.relatedProducts(productId));
    final dynamic rawList = data['data'] ?? data['results'];
    if (rawList is! List) return [];

    final products = <ProductModel>[];
    for (final entry in rawList) {
      if (entry is Map<String, dynamic>) {
        try {
          products.add(ProductModel.fromJson(entry));
        } catch (_) {
          // Skip a single malformed entry rather than failing the
          // whole list over one bad item.
        }
      }
    }
    return products;
  }
}