import 'dart:io';

import 'package:ecommerce_app/admin/admin_api_client.dart';
import 'package:ecommerce_app/admin/admin_endpoints.dart';
import 'package:ecommerce_app/admin/admin_model/admin_product_model.dart';


class AdminProductService {
  final AdminApiClient _apiClient;

  AdminProductService({AdminApiClient? apiClient}) : _apiClient = apiClient ?? AdminApiClient();

  /// [url] is a full URL — either AdminEndpoints.products for page 1, or
  /// the exact "next" URL DRF returned for subsequent pages.
  Future<({List<AdminProductModel> products, String? nextUrl})> getProducts(String url) async {
    final data = await _apiClient.get(url);
    final results = (data['results'] as List? ?? []).map((e) => AdminProductModel.fromJson(e as Map<String, dynamic>)).toList();
    final next = data['next']?.toString();
    return (products: results, nextUrl: next);
  }

  Future<AdminProductModel> getDetail(int id) async {
    final data = await _apiClient.get(AdminEndpoints.productDetail(id));
    return AdminProductModel.fromJson(data);
  }

  /// Confirmed working shape: brand/category are plain text (e.g.
  /// "Nike" / "Men"), sizes/colors are comma-separated strings.
  Future<AdminProductModel> createProduct({
    required String name,
    required String description,
    required double price,
    required int stockQuantity,
    required String brand,
    required String category,
    required String productType,
    String? sizes,
    String? colors,
    List<File> images = const [],
  }) async {
    final data = await _apiClient.multipart(
      'POST',
      AdminEndpoints.products,
      fields: {
        'name': name,
        'description': description,
        'price': price.toString(),
        'stock_quantity': stockQuantity.toString(),
        'brand': brand,
        'category': category,
        'product_type': productType,
        if (sizes != null && sizes.isNotEmpty) 'sizes': sizes,
        if (colors != null && colors.isNotEmpty) 'colors': colors,
      },
      images: images,
    );
    return AdminProductModel.fromJson(data);
  }

  /// Full update (PUT) — confirmed working shape includes `status`.
  Future<AdminProductModel> updateProductFull({
    required int id,
    required String name,
    required String description,
    required double price,
    required int stockQuantity,
    required String brand,
    required String category,
    required String productType,
    required String status,
    List<File> images = const [],
  }) async {
    final data = await _apiClient.multipart(
      'PUT',
      AdminEndpoints.productDetail(id),
      fields: {
        'name': name,
        'description': description,
        'price': price.toString(),
        'stock_quantity': stockQuantity.toString(),
        'brand': brand,
        'category': category,
        'product_type': productType,
        'status': status,
      },
      images: images,
    );
    return AdminProductModel.fromJson(data);
  }

  Future<void> addSize(int id, String size) async {
    await _apiClient.postJson(AdminEndpoints.addSize(id), {'size': size});
  }

  Future<void> changeStatus(int id, String status) async {
    await _apiClient.postJson(AdminEndpoints.changeStatus(id), {'status': status});
  }

  Future<bool> toggleFeatured(int id) async {
    final data = await _apiClient.postJson(AdminEndpoints.toggleFeatured(id), {});
    return data['is_featured'] == true;
  }

  Future<void> uploadImages(int id, List<File> images) async {
    await _apiClient.multipart('POST', AdminEndpoints.uploadImages(id), images: images);
  }

  /// NOTE: unconfirmed exact request shape — see the comment on
  /// AdminEndpoints.deleteImage.
  Future<void> deleteImage(int productId, int imageId) async {
    await _apiClient.postJson(AdminEndpoints.deleteImage(productId), {'image_id': imageId});
  }

  Future<void> deleteProduct(int id) async {
    await _apiClient.delete(AdminEndpoints.productDetail(id));
  }
}