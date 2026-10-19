// import 'package:flutter/material.dart';
// import 'package:pokakbilling/models/data-models/product_model.dart';
// import 'package:pokakbilling/models/services/product_services.dart';
// import 'package:pokakbilling/views/bottom_bar/bottomNavigationBar/bottom_bar.dart';
// import 'package:pokakbilling/views/commonWidgets/response-message/error_message.dart';
// import 'package:pokakbilling/views/commonWidgets/response-message/success-message.dart';

// class ProductViewModel extends ChangeNotifier {
//   bool addProductLoader = false;
//   bool getProductLoader = false;
//   bool deleteProductLoading = false;
//   bool singleProductLoading = false;
//   bool editLoading = false;
//   var productList = <ProductModel>[];
//   var singleProductList = <ProductModel>[];
//   var selectedProductIds = <int>[];
//   ProductModel? selectedProduct;

//   // Search
//   String _searchQuery = '';
//   List<ProductModel> get filteredProductList {
//     if (_searchQuery.isEmpty) return productList;
//     return productList
//         .where((p) =>
//             p.productName.toLowerCase().contains(_searchQuery.toLowerCase()))
//         .toList();
//   }

//   void searchProduct(String query) {
//     _searchQuery = query;
//     notifyListeners();
//   }

//   void searchProducts(String query) {
//     if (query.isEmpty) {
//       getAllProducts();
//     } else {
//       productList = productList
//           .where(
//               (p) => p.productName.toLowerCase().contains(query.toLowerCase()))
//           .toList();
//       notifyListeners();
//     }
//   }

//   ProductViewModel() {
//     getAllProducts();
//   }

//   void addProductIds(ProductModel? product) async {
//     if (selectedProduct == product) return;
//     selectedProduct = product;
//     notifyListeners();
//   }

//   void selectCategory(ProductModel? product) async {
//     if (selectedProduct == product) return;
//     selectedProduct = product;
//     notifyListeners();
//   }

//   int? selectedProductId;
//   String selectedProductName = "";

//   //======Helper=====================
//   void updateSelectedProductId(int id) {
//     selectedProductId = id;
//     notifyListeners();
//   }

//   void selectProduct(String name) {
//     selectedProductName = name;
//     notifyListeners();
//   }

//   //================== GET ALL PRODUCT ========================
//   Future<void> getAllProducts() async {
//     try {
//       getProductLoader = true;
//       notifyListeners();
//       List<ProductModel> productItems = await ProductServices.getProducts();

//       if (productItems.isNotEmpty) {
//         productList = productItems;
//       } else {
//         productList.clear();
//       }
//     } catch (e) {
//       print(e);
//     } finally {
//       getProductLoader = false;
//       notifyListeners();
//     }
//   }

//   //================== CREATE PRODUCT ========================
//   Future<void> createProduct(
//     productName,
//     productDescription,
//     unit,
//     unitPrice,
//     category,
//     stock,
//     sgst,
//     cgst,
//     BuildContext context,
//   ) async {
//     try {
//       addProductLoader = true;
//       notifyListeners();
//       String? response = await ProductServices.addProduct(
//         productName,
//         productDescription,
//         unit,
//         unitPrice,
//         category,
//         stock,
//         sgst,
//         cgst,
//       );

//       if (response == null) {
//         if (!context.mounted) return;
//         showSuccessMessage(context, "Product Created Successfully!");
//         getAllProducts();
//         Navigator.of(context).pushAndRemoveUntil(
//           MaterialPageRoute(builder: (context) => const BottomBar(index: 1)),
//           (route) => false,
//         );
//       } else {
//         if (!context.mounted) return;
//         showOverlayError(context, response);
//       }
//     } catch (e) {
//       print(e);
//     } finally {
//       addProductLoader = false;
//       notifyListeners();
//     }
//   }

//   //================== DELETE PRODUCT ========================
//   Future<void> deleteProduct(int productId, BuildContext context) async {
//     try {
//       deleteProductLoading = true;
//       notifyListeners();

//       String? response = await ProductServices.deleteProduct(productId);

//       if (response == null) {
//         if (!context.mounted) return;
//         showSuccessMessage(context, "Product Deleted Successfully!");
//         await getAllProducts();
//       } else {
//         if (!context.mounted) return;
//         showOverlayError(context, response);
//       }
//     } catch (e) {
//       print(e);
//     } finally {
//       deleteProductLoading = false;
//       notifyListeners();
//     }
//   }

//   //================== PRODUCT BY ID ========================
//   Future<void> getProductById(productId) async {
//     try {
//       singleProductLoading = true;
//       notifyListeners();
//       List<ProductModel> productItems =
//           await ProductServices.getProductById(productId);

//       if (productItems.isNotEmpty) {
//         singleProductList = productItems;
//       } else {
//         singleProductList.clear();
//       }
//     } catch (e) {
//       print(e);
//     } finally {
//       singleProductLoading = false;
//       notifyListeners();
//     }
//   }

//   //================== EDIT PRODUCT ========================
//   Future<void> editProduct(
//     productId,
//     productName,
//     productDescription,
//     unit,
//     unitPrice,
//     category,
//     stock,
//     sgst,
//     cgst,
//     BuildContext context,
//   ) async {
//     try {
//       editLoading = true;
//       notifyListeners();

//       String? response = await ProductServices.updateProduct(
//         productId,
//         productName,
//         productDescription,
//         unit,
//         unitPrice,
//         category,
//         stock,
//         sgst,
//         cgst,
//       );

//       if (response == null) {
//         if (!context.mounted) return;
//         showSuccessMessage(context, "Product has been successfully updated!");
//         getAllProducts();
//         Navigator.of(context).pushAndRemoveUntil(
//           MaterialPageRoute(builder: (context) => const BottomBar(index: 1)),
//           (route) => false,
//         );
//       } else {
//         if (!context.mounted) return;
//         showOverlayError(context, response);
//       }
//     } catch (e) {
//       print(e);
//     } finally {
//       editLoading = false;
//       notifyListeners();
//     }
//   }
// }
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

  String _searchQuery = '';
  List<ProductModel> get filteredProductList {
    if (_searchQuery.isEmpty) return productList;
    return productList
        .where((p) =>
            p.productName.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  void searchProduct(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void searchProducts(String query) {
    if (query.isEmpty) {
      getAllProducts();
    } else {
      productList = productList
          .where(
              (p) => p.productName.toLowerCase().contains(query.toLowerCase()))
          .toList();
      notifyListeners();
    }
  }

  ProductViewModel() {
    getAllProducts();
  }

  void reset() {
    productList = [];
    singleProductList = [];
    selectedProductIds = [];
    selectedProduct = null;
    selectedProductId = null;
    selectedProductName = "";
    _searchQuery = '';
    addProductLoader = false;
    getProductLoader = false;
    deleteProductLoading = false;
    singleProductLoading = false;
    editLoading = false;
    notifyListeners();
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

  int? selectedProductId;
  String selectedProductName = "";

  void updateSelectedProductId(int id) {
    selectedProductId = id;
    notifyListeners();
  }

  void selectProduct(String name) {
    selectedProductName = name;
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
      print(e);
    } finally {
      getProductLoader = false;
      notifyListeners();
    }
  }

  Future<void> createProduct(
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
        if (!context.mounted) return;
        showSuccessMessage(context, "Product Created Successfully!");
        getAllProducts();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const BottomBar(index: 1)),
          (route) => false,
        );
      } else {
        if (!context.mounted) return;
        showOverlayError(context, response);
      }
    } catch (e) {
      print(e);
    } finally {
      addProductLoader = false;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(int productId, BuildContext context) async {
    try {
      deleteProductLoading = true;
      notifyListeners();
      String? response = await ProductServices.deleteProduct(productId);
      if (response == null) {
        if (!context.mounted) return;
        showSuccessMessage(context, "Product Deleted Successfully!");
        await getAllProducts();
      } else {
        if (!context.mounted) return;
        showOverlayError(context, response);
      }
    } catch (e) {
      print(e);
    } finally {
      deleteProductLoading = false;
      notifyListeners();
    }
  }

  Future<void> getProductById(productId) async {
    try {
      singleProductLoading = true;
      notifyListeners();
      List<ProductModel> productItems =
          await ProductServices.getProductById(productId);
      if (productItems.isNotEmpty) {
        singleProductList = productItems;
      } else {
        singleProductList.clear();
      }
    } catch (e) {
      print(e);
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
          MaterialPageRoute(builder: (context) => const BottomBar(index: 1)),
          (route) => false,
        );
      } else {
        if (!context.mounted) return;
        showOverlayError(context, response);
      }
    } catch (e) {
      print(e);
    } finally {
      editLoading = false;
      notifyListeners();
    }
  }
}
