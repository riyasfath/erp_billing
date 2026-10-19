import 'package:ecommerce_app/core/api_client.dart';
import 'package:ecommerce_app/core/providers.dart';
import 'package:ecommerce_app/models/product_detail_model.dart';
import 'package:ecommerce_app/models/product_model.dart';

/// Network calls for GET /api/products/ (list) and GET /api/products/{id}/
/// (detail).
class ProductService {
  final ApiClient _apiClient;

  ProductService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Fetches one page. Pass [url] (from a previous result's `nextUrl`)
  /// to fetch a specific page; omit it for the first page.
  Future<ProductPageResult> getProducts({String? url}) async {
    final requestUrl = url ?? ApiEndpoints.productList;
    final data = await _apiClient.get(requestUrl);

    final List<dynamic> resultsJson = (data['results'] as List?) ?? [];
    final products = resultsJson
        .map((e) => ProductModel.fromApiJson(e as Map<String, dynamic>))
        .toList();

    final int count = data['count'] is int
        ? data['count'] as int
        : int.tryParse(data['count']?.toString() ?? '') ?? products.length;

    return ProductPageResult(
      products: products,
      nextUrl: data['next']?.toString(),
      count: count,
    );
  }

  Future<ProductDetailModel> getProductDetail(String id) async {
    final data = await _apiClient.get(ApiEndpoints.productDetail(id));
    return ProductDetailModel.fromApiJson(data);
  }

  /// GET /api/products/bestseller/ — returns a plain JSON array (no
  /// pagination wrapper), unlike getProducts(). ApiClient.get() already
  /// wraps a bare array as {'data': [...]}, so we read from there.
  Future<List<ProductModel>> getBestSellers() async {
    final data = await _apiClient.get(ApiEndpoints.bestSellerProducts);
    final List<dynamic> resultsJson = (data['data'] as List?) ?? [];
    return resultsJson
        .map((e) => ProductModel.fromApiJson(e as Map<String, dynamic>))
        .toList();
  }
}