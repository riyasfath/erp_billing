import 'package:flutter_riverpod/legacy.dart';
import '../models/product_model.dart';

final cartProvider = StateNotifierProvider<CartNotifier, Map<Product, int>>(
  (ref) => CartNotifier(),
);

class CartNotifier extends StateNotifier<Map<Product, int>> {
  CartNotifier() : super({});

  void add(Product product) {
    state = {...state, product: (state[product] ?? 0) + 1};
  }

  void remove(Product product) {
    final qty = state[product] ?? 0;
    if (qty > 1) {
      state = {...state, product: qty - 1};
    } else {
      state.remove(product);
      state = {...state};
    }
  }

  double get total =>
      state.entries.fold(0, (sum, e) => sum + e.key.price * e.value);
}
