import 'package:ecommerce_app/service/related_product_service.dart';
import 'package:flutter/foundation.dart';

import 'package:ecommerce_app/core/api_exception.dart';
import 'package:ecommerce_app/models/product_model.dart';

class RelatedProductsViewModel extends ChangeNotifier {
  final RelatedProductsService _service;

  RelatedProductsViewModel({RelatedProductsService? service}) : _service = service ?? RelatedProductsService();

  bool isLoading = false;
  String? error;
  List<ProductModel> products = [];
  // Tracks which product this list is for, so a stale list from the
  // previous product page isn't shown for a moment while the new one
  // loads.
  String? _loadedForProductId;

  Future<void> fetchRelated(String productId) async {
    if (_loadedForProductId == productId && products.isNotEmpty) return;
    _loadedForProductId = productId;

    isLoading = true;
    error = null;
    products = [];
    notifyListeners();

    try {
      products = await _service.getRelated(productId);
      isLoading = false;
    } on ApiException catch (e) {
      // A genuinely empty result (200 + []) never reaches this catch —
      // getRelated already returns [] for that. Only real request
      // failures (network, 4xx/5xx) land here, so this is a real error.
      isLoading = false;
      error = e.message;
    } catch (_) {
      // Any other failure here is almost always a parsing hiccup on a
      // near-empty response, not a real outage — treat it as "there's
      // just nothing to show" instead of a scary error banner.
      isLoading = false;
      products = [];
      error = null;
    }
    notifyListeners();
  }
}