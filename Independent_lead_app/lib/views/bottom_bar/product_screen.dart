import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/product_viewmodel.dart';
import 'package:pokakbilling/views/Screens/products/single_product_tile.dart';
import 'package:provider/provider.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productProvider = context.read<ProductViewModel>();
    Future.microtask(() => productProvider.getAllProducts());

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.violetblue,
        title: const Text(
          "Products",
          style: TextStyle(color: AppColors.white),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await productProvider.getAllProducts();
        },
        child: Consumer<ProductViewModel>(
          builder: (context, provider, child) {
            if (provider.getProductLoader) {
              return const Center(child: CircularProgressIndicator());
            } else if (provider.productList.isEmpty) {
              return const Center(
                child: Text('No products available.'),
              );
            } else {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        itemBuilder: (context, index) =>
                            SingleProductTile(index: index),
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemCount: provider.productList.length,
                      ),
                    )
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
