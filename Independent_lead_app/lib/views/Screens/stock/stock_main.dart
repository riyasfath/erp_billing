import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/product_viewmodel.dart';
import 'package:pokakbilling/views/Screens/stock/single_stock_product.dart';
import 'package:provider/provider.dart';

class StockMain extends StatelessWidget {
  const StockMain({super.key});

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
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: AppColors.white),
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
                            SingleStockProduct(index: index),
                        separatorBuilder: (context, index) => const Divider(
                          color: AppColors.grey,
                          thickness: 1.5,
                        ),
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
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 40),
        child: SizedBox(
          height: 80,
          width: 80,
          child: FloatingActionButton(
            onPressed: () {
              //pushNavigation(context, const AddProduct(isEdit: false));
            },
            backgroundColor: AppColors.violetblue,
            shape: const CircleBorder(),
            child: const Icon(Icons.add, color: AppColors.white),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
