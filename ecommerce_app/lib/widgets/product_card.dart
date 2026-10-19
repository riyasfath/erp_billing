import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import '../screens/product_detail_screen.dart';

class ProductCard extends ConsumerWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlist = ref.watch(wishlistProvider);

    return Card(
      elevation: 3,
      child: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailScreen(product: product),
                  ),
                );
              },
              child: Image.network(product.image, fit: BoxFit.contain),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(6),
            child: Text(
              product.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text("₹ ${product.price}"),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(
                  wishlist.contains(product)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: Colors.red,
                ),
                onPressed: () =>
                    ref.read(wishlistProvider.notifier).toggle(product),
              ),
              ElevatedButton(
                onPressed: () => ref.read(cartProvider.notifier).add(product),
                child: const Text("Add"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
