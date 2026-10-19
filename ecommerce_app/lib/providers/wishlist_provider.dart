import 'package:flutter_riverpod/legacy.dart';
import '../models/product_model.dart';

final wishlistProvider = StateNotifierProvider<WishlistNotifier, List<Product>>(
  (ref) => WishlistNotifier(),
);

class WishlistNotifier extends StateNotifier<List<Product>> {
  WishlistNotifier() : super([]);

  void toggle(Product product) {
    state.contains(product)
        ? state = state.where((p) => p != product).toList()
        : state = [...state, product];
  }
}
