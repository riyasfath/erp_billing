import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:ecommerce_app/core/token_storage.dart';
import 'package:ecommerce_app/models/product_model.dart';

/// Tracks products the user has actually opened the detail page for.
/// No backend endpoint exists for "recently viewed" — this is stored
/// locally (most-recent-first, capped at 10) via TokenStorage, and
/// wiped on logout like other user-scoped data.
class RecentlyViewedViewModel extends ChangeNotifier {
  static const int _maxItems = 10;

  List<ProductModel> products = [];
  bool _loaded = false;

  /// Call once (e.g. when Home mounts) — cheap no-op on later calls.
  Future<void> loadFromStorage() async {
    if (_loaded) return;
    _loaded = true;

    final json = await TokenStorage.instance.getRecentlyViewedJson();
    if (json == null || json.isEmpty) return;

    try {
      final List<dynamic> decoded = jsonDecode(json) as List<dynamic>;
      products = decoded
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
      notifyListeners();
    } catch (_) {
      // Corrupt/old-shape data — just start fresh rather than crash.
    }
  }

  /// Call when a product detail screen opens. Moves it to the front if
  /// already present, trims to the cap, persists.
  Future<void> addProduct(ProductModel product) async {
    products = [
      product,
      ...products.where((p) => p.id != product.id),
    ];
    if (products.length > _maxItems) {
      products = products.sublist(0, _maxItems);
    }
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    final json = jsonEncode(products.map((p) => p.toJson()).toList());
    await TokenStorage.instance.saveRecentlyViewedJson(json);
  }

  /// Called on logout so a new login on this device starts with no
  /// leftover browsing history from the previous user.
  void reset() {
    products = [];
    _loaded = false;
    notifyListeners();
  }
}