import 'package:flutter/foundation.dart';

import 'package:ecommerce_app/core/api_exception.dart';
import 'package:ecommerce_app/core/view_status.dart';
import 'package:ecommerce_app/models/product_detail_model.dart';
import 'package:ecommerce_app/service/product_service.dart';

/// ViewModel for a single product's detail page.
class ProductDetailViewModel extends ChangeNotifier {
  final ProductService _productService;

  ProductDetailViewModel({ProductService? productService})
      : _productService = productService ?? ProductService();

  ViewStatus status = ViewStatus.idle;
  String? error;
  ProductDetailModel? detail;

  bool get isLoading => status == ViewStatus.loading;

  Future<void> fetchDetail(String id) async {
    status = ViewStatus.loading;
    error = null;
    detail = null;
    notifyListeners();

    try {
      detail = await _productService.getProductDetail(id);
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

  void reset() {
    status = ViewStatus.idle;
    error = null;
    detail = null;
    notifyListeners();
  }
}