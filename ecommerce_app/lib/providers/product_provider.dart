import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api/api_service.dart';
import '../models/product_model.dart';

final apiServiceProvider = Provider((ref) => ApiService());

final productProvider = FutureProvider<List<Product>>((ref) async {
  return ref.read(apiServiceProvider).fetchProducts();
});
