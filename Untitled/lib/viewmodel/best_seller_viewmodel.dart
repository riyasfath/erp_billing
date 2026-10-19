import 'package:flutter/foundation.dart';

import 'package:ecommerce_app/core/api_exception.dart';
import 'package:ecommerce_app/core/view_status.dart';
import 'package:ecommerce_app/models/product_model.dart';
import 'package:ecommerce_app/service/product_service.dart';

/// ViewModel for the "Best Seller Deals" section — GET
/// /api/products/bestseller/. Separate from ProductViewModel (which
/// handles the paginated /api/products/ list) since this endpoint has
/// no pagination and a different data shape at the HTTP level.
class BestSellerViewModel extends ChangeNotifier {
  final ProductService _productService;

  BestSellerViewModel({ProductService? productService})
      : _productService = productService ?? ProductService();

  ViewStatus status = ViewStatus.idle;
  String? error;
  List<ProductModel> products = [];

  bool get isLoading => status == ViewStatus.loading;

  Future<void> fetchBestSellers() async {
    status = ViewStatus.loading;
    error = null;
    notifyListeners();

    try {
      products = await _productService.getBestSellers();
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
}