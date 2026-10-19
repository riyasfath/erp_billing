import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:ecommerce_app/core/token_storage.dart';

/// Tracks which product IDs the user has wishlisted. No backend
/// wishlist endpoint exists — stored locally via TokenStorage (same
/// approach as RecentlyViewedViewModel), and wiped on logout like
/// other user-scoped data. This is what makes the heart button
/// survive app close/reopen instead of resetting to empty every time.
class FavoritesViewModel extends ChangeNotifier {
  Set<String> favoriteIds = {};
  bool _loaded = false;

  /// Call once (e.g. when MainTabScreen mounts) — cheap no-op on later calls.
  Future<void> loadFromStorage() async {
    if (_loaded) return;
    _loaded = true;

    final json = await TokenStorage.instance.getFavoritesJson();
    if (json == null || json.isEmpty) return;

    try {
      final List<dynamic> decoded = jsonDecode(json) as List<dynamic>;
      favoriteIds = decoded.map((e) => e.toString()).toSet();
      notifyListeners();
    } catch (_) {
      // Corrupt/old-shape data — just start fresh rather than crash.
    }
  }

  bool isFavorite(String productId) => favoriteIds.contains(productId);

  Future<void> toggleFavorite(String productId) async {
    if (favoriteIds.contains(productId)) {
      favoriteIds = {...favoriteIds}..remove(productId);
    } else {
      favoriteIds = {...favoriteIds, productId};
    }
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    final json = jsonEncode(favoriteIds.toList());
    await TokenStorage.instance.saveFavoritesJson(json);
  }

  /// Called on logout so a new login on this device starts with no
  /// leftover wishlist from the previous user.
  void reset() {
    favoriteIds = {};
    _loaded = false;
    notifyListeners();
  }
}