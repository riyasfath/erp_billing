import 'package:flutter/foundation.dart';

import 'package:ecommerce_app/core/api_exception.dart';
import 'package:ecommerce_app/core/view_status.dart';
import 'package:ecommerce_app/models/product_model.dart';
import 'package:ecommerce_app/service/product_service.dart';

/// ViewModel for the /api/products/ list, with "load more" pagination.
class ProductViewModel extends ChangeNotifier {
  final ProductService _productService;

  ProductViewModel({ProductService? productService})
      : _productService = productService ?? ProductService();

  ViewStatus status = ViewStatus.idle;
  String? error;
  List<ProductModel> products = [];

  String? _nextUrl;
  bool _isLoadingMore = false;

  bool get isLoading => status == ViewStatus.loading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _nextUrl != null;

  /// First page. Safe to call multiple times — screens typically call
  /// this once in initState.
  Future<void> fetchProducts() async {
    status = ViewStatus.loading;
    error = null;
    notifyListeners();

    try {
      final result = await _productService.getProducts();
      products = result.products;
      _nextUrl = result.nextUrl;
      status = ViewStatus.success;
    } on ApiException catch (e) {
      status = ViewStatus.error;
      error = e.message;
    } catch (_) {
      status = ViewStatus.error;
      error = 'Something went wrong. Please try again.';
    }

    notifyListeners();
  }

  /// Appends the next page onto [products]. No-ops if there's no next
  /// page or a load is already in flight.
  Future<void> loadMore() async {
    if (_nextUrl == null || _isLoadingMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final result = await _productService.getProducts(url: _nextUrl);
      products = [...products, ...result.products];
      _nextUrl = result.nextUrl;
    } on ApiException catch (e) {
      error = e.message;
    } catch (_) {
      error = 'Something went wrong loading more products.';
    }

    _isLoadingMore = false;
    notifyListeners();
  }
}