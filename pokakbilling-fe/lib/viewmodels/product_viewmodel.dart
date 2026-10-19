import 'package:flutter/material.dart';
import 'package:pokakbilling/models/data-models/product_model.dart';
import 'package:pokakbilling/models/services/product_services.dart';
import 'package:pokakbilling/views/bottom_bar/bottomNavigationBar/bottom_bar.dart';
import 'package:pokakbilling/views/commonWidgets/response-message/error_message.dart';
import 'package:pokakbilling/views/commonWidgets/response-message/success-message.dart';

class ProductViewModel extends ChangeNotifier {
  bool addProductLoader = false;
  bool getProductLoader = false;
  bool deleteProductLoading = false;
  bool singleProductLoading = false;
  bool editLoading = false;
  var productList = <ProductModel>[];
  var singleProductList = <ProductModel>[];
  var selectedProductIds = <int>[];
  ProductModel? selectedProduct;

  ProductViewModel() {
    getAllProducts();
  }

  void addProductIds(ProductModel? product) async {
    if (selectedProduct == product) return;
    selectedProduct = product;
    notifyListeners();
  }

  void selectCategory(ProductModel? product) async {
    if (selectedProduct == product) return;
    selectedProduct = product;
    notifyListeners();
  }

  Future<void> getAllProducts() async {
    try {
      getProductLoader = true;
      notifyListeners();
      List<ProductModel> productItems = await ProductServices.getProducts();
      if (productItems.isNotEmpty) {
        productList = productItems;
      } else {
        productList.clear();
      }
    } catch (e) {
      print('Error getting products: $e');
    } finally {
      getProductLoader = false;
      notifyListeners();
    }
  }

  Future<bool> createProduct(
    productName,
    productDescription,
    unit,
    unitPrice,
    category,
    stock,
    sgst,
    cgst,
    BuildContext context,
  ) async {
    try {
      addProductLoader = true;
      notifyListeners();
      String? response = await ProductServices.addProduct(
        productName,
        productDescription,
        unit,
        unitPrice,
        category,
        stock,
        sgst,
        cgst,
      );
      if (response == null) {
        await getAllProducts();
        if (!context.mounted) return true;
        showSuccessMessage(context, "Product Created Successfully!");
        return true;
      } else {
        if (!context.mounted) return false;
        showOverlayError(context, response);
        return false;
      }
    } catch (e) {
      print('Error creating product: $e');
      if (context.mounted) {
        showOverlayError(context, 'Failed to create product: $e');
      }
      return false;
    } finally {
      addProductLoader = false;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(productId, BuildContext context) async {
    try {
      deleteProductLoading = true;
      notifyListeners();
      String? response = await ProductServices.deleteProduct(productId);
      if (response == null) {
        if (!context.mounted) return;
        showSuccessMessage(context, "Product Deleted Successfully!");
        getAllProducts();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const ErpBottomBar(index: 1)),
          (route) => false,
        );
      } else {
        if (!context.mounted) return;
        showOverlayError(context, response);
      }
    } catch (e) {
      print('Error deleting product: $e');
    } finally {
      deleteProductLoading = false;
      notifyListeners();
    }
  }

  Future<bool> getProductById(productId) async {
    try {
      singleProductLoading = true;
      singleProductList.clear();
      notifyListeners();
      List<ProductModel> productItems =
          await ProductServices.getProductById(productId);
      if (productItems.isNotEmpty) {
        singleProductList = productItems;
        return true;
      } else {
        singleProductList.clear();
        return false;
      }
    } catch (e) {
      print('Error getting product by ID: $e');
      singleProductList.clear();
      return false;
    } finally {
      singleProductLoading = false;
      notifyListeners();
    }
  }

  Future<void> editProduct(
    productId,
    productName,
    productDescription,
    unit,
    unitPrice,
    category,
    stock,
    sgst,
    cgst,
    BuildContext context,
  ) async {
    try {
      editLoading = true;
      notifyListeners();
      String? response = await ProductServices.updateProduct(
        productId,
        productName,
        productDescription,
        unit,
        unitPrice,
        category,
        stock,
        sgst,
        cgst,
      );
      if (response == null) {
        if (!context.mounted) return;
        showSuccessMessage(context, "Product has been successfully updated!");
        getAllProducts();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const ErpBottomBar(index: 1)),
          (route) => false,
        );
      } else {
        if (!context.mounted) return;
        showOverlayError(context, response);
      }
    } catch (e) {
      print('Error editing product: $e');
    } finally {
      editLoading = false;
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // STOCK MANAGEMENT — local in-memory only
  // ─────────────────────────────────────────────────────────────────────────

  /// Get current stock for a product by id. Returns 0 if not found.
  int getStockForProduct(int productId) {
    try {
      return productList.firstWhere((p) => p.productId == productId).stock;
    } catch (_) {
      return 0;
    }
  }

  /// Deduct [quantity] from local stock of [productId] after quotation submit.
  /// Stock will never go below 0.
  void deductStock(int productId, int quantity) {
    try {
      final idx = productList.indexWhere((p) => p.productId == productId);
      if (idx == -1) return;
      final newStock = (productList[idx].stock - quantity).clamp(0, 999999);
      productList[idx].stock = newStock;

      // Keep singleProductList in sync too
      final sIdx =
          singleProductList.indexWhere((p) => p.productId == productId);
      if (sIdx != -1) singleProductList[sIdx].stock = newStock;

      notifyListeners();
    } catch (e) {
      print('Error deducting stock: $e');
    }
  }

  /// Restore [quantity] back to local stock of [productId].
  /// Called when user switches product or removes a quotation item.
  void restoreStock(int productId, int quantity) {
    try {
      final idx = productList.indexWhere((p) => p.productId == productId);
      if (idx == -1) return;
      productList[idx].stock = productList[idx].stock + quantity;

      final sIdx =
          singleProductList.indexWhere((p) => p.productId == productId);
      if (sIdx != -1) singleProductList[sIdx].stock = productList[idx].stock;

      notifyListeners();
    } catch (e) {
      print('Error restoring stock: $e');
    }
  }

  /// Deduct stock for multiple products at once.
  /// Pass { productId: quantityToDeduct }.
  void deductStockForItems(Map<int, int> items) {
    for (final entry in items.entries) {
      deductStock(entry.key, entry.value);
    }
  }
}
