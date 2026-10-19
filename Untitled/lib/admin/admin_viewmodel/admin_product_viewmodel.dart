import 'package:ecommerce_app/admin/admin_api_client.dart';
import 'package:ecommerce_app/admin/admin_endpoints.dart';
import 'package:ecommerce_app/admin/admin_model/admin_product_model.dart';
import 'package:ecommerce_app/admin/admin_service/admin_product_service.dart';
import 'package:flutter/foundation.dart';


class AdminProductViewModel extends ChangeNotifier {
  final AdminProductService _service;

  AdminProductViewModel({AdminProductService? service}) : _service = service ?? AdminProductService();

  bool isLoading = false;
  bool isLoadingMore = false;
  String? error;
  List<AdminProductModel> products = [];
  String? _nextUrl;
  bool get hasMore => _nextUrl != null;

  final Set<int> _busyIds = {};
  bool isBusy(int id) => _busyIds.contains(id);

  Future<void> fetchProducts() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final result = await _service.getProducts(AdminEndpoints.products);
      products = result.products;
      _nextUrl = result.nextUrl;
      isLoading = false;
    } on AdminApiException catch (e) {
      isLoading = false;
      error = e.message;
    } catch (_) {
      isLoading = false;
      error = 'Could not load products.';
    }
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_nextUrl == null || isLoadingMore) return;
    isLoadingMore = true;
    notifyListeners();

    try {
      final result = await _service.getProducts(_nextUrl!);
      products = [...products, ...result.products];
      _nextUrl = result.nextUrl;
    } catch (_) {
      // silent — the Load More button just stays tappable to retry
    }
    isLoadingMore = false;
    notifyListeners();
  }

  Future<bool> toggleFeatured(AdminProductModel product) async {
    _busyIds.add(product.id);
    notifyListeners();
    bool success = false;

    try {
      final newValue = await _service.toggleFeatured(product.id);
      final index = products.indexWhere((p) => p.id == product.id);
      if (index != -1) products[index] = products[index].copyWith(isFeatured: newValue);
      success = true;
    } catch (_) {
      error = 'Could not update featured status.';
    }

    _busyIds.remove(product.id);
    notifyListeners();
    return success;
  }

  Future<bool> changeStatus(AdminProductModel product, String newStatus) async {
    _busyIds.add(product.id);
    notifyListeners();
    bool success = false;

    try {
      await _service.changeStatus(product.id, newStatus);
      final index = products.indexWhere((p) => p.id == product.id);
      if (index != -1) products[index] = products[index].copyWith(status: newStatus);
      success = true;
    } catch (_) {
      error = 'Could not update status.';
    }

    _busyIds.remove(product.id);
    notifyListeners();
    return success;
  }

  Future<bool> deleteProduct(AdminProductModel product) async {
    _busyIds.add(product.id);
    notifyListeners();
    bool success = false;

    try {
      await _service.deleteProduct(product.id);
      products = products.where((p) => p.id != product.id).toList();
      success = true;
    } catch (_) {
      error = 'Could not delete this product.';
    }

    _busyIds.remove(product.id);
    notifyListeners();
    return success;
  }
}