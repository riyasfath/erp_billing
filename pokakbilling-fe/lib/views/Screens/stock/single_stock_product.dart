import 'package:flutter/material.dart';
import 'package:pokakbilling/core/navigations.dart';
import 'package:pokakbilling/viewmodels/product_viewmodel.dart';
import 'package:pokakbilling/views/Screens/products/create_product.dart';
import 'package:pokakbilling/views/Screens/stock/view_stock_product.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/action_button.dart';
import 'package:pokakbilling/views/commonWidgets/popups/delete_popup.dart';
import 'package:provider/provider.dart';

class SingleStockProduct extends StatelessWidget {
  final int index;
  const SingleStockProduct({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductViewModel>(context);
    var product = productProvider.productList[index];
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      height: 90,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 2.0, left: 2.0, right: 2.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${(index + 1).toString()}.",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.productName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "Unit : ${product.unitName}",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "₹ ${product.unitPrice}",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Stock: ${product.stock}",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Consumer<ProductViewModel>(
                  builder: (context, provider, child) {
                    return ActionButton(
                      text: "VIEW",
                      loading: false,
                      onPressed: () async {
                        await provider.getProductById(product.productId);

                        if (provider.singleProductLoading) {
                          const CircularProgressIndicator();
                        } else {
                          if (!context.mounted) return;
                          pushNavigation(context, const ViewStockProduct());
                        }
                      },
                      isColored: true,
                    );
                  },
                ),
                SizedBox(
                  width: screenWidth * 0.03,
                ),
                Consumer<ProductViewModel>(
                  builder: (context, provider, child) {
                    return ActionButton(
                      text: "DELETE",
                      loading: false,
                      onPressed: () async {
                        showDeleteDialog(
                          context,
                          "Product",
                          () => provider.deleteProduct(
                            product.productId,
                            context,
                          ),
                        );
                      },
                      isColored: false,
                    );
                  },
                ),
                SizedBox(
                  width: screenWidth * 0.03,
                ),
                Consumer<ProductViewModel>(
                  builder: (context, provider, child) {
                    return ActionButton(
                      text: "EDIT",
                      loading: false,
                      onPressed: () async {
                        await provider.getProductById(product.productId);

                        if (provider.singleProductLoading) {
                          const CircularProgressIndicator();
                        } else {
                          if (!context.mounted) return;
                          var product = provider.singleProductList[0];
                          pushNavigation(
                            context,
                            AddProduct(
                              isEdit: true,
                              product: product,
                            ),
                          );
                        }
                      },
                      isColored: false,
                    );
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
