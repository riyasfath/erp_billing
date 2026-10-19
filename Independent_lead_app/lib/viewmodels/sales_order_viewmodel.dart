// import 'package:flutter/material.dart';
// import 'package:pokakbilling/core/navigations.dart';
// import 'package:pokakbilling/models/data-models/addQuotation_model.dart';
// import 'package:pokakbilling/models/data-models/sales-order-models/salesOrderItems_model.dart';
// import 'package:pokakbilling/models/data-models/sales-order-models/salesOrder_model.dart';
// import 'package:pokakbilling/models/services/sales_order_services.dart';
// import 'package:pokakbilling/views/Screens/sales_order/sales_order.dart';
// import 'package:pokakbilling/views/Screens/sales_order/view/view_sales_order.dart';
// import 'package:pokakbilling/views/commonWidgets/response-message/error_message.dart';
// import 'package:pokakbilling/views/commonWidgets/response-message/success-message.dart';

// class SalesOrderViewmodel extends ChangeNotifier {
//   int selectedSalesPersonId = 0;
//   int selectedClientId = 0;
//   int selectedTermsId = 0;
//   String selectedTermsName = "";
//   String selectedSalesPersonName = "";
//   String selectedClientName = "";
//   List<AddProductQuotationModel> itemList = [];
//   List<AddProductQuotationModel> editItemList = [];
//   String grandTotal = "";
//   bool addSalesOrderLoading = false;
//   bool getSalesOrderLoader = false;
//   bool deleteSalesOrderLoader = false;
//   bool singleSalesOrderLoading = false;
//   bool editSalesOrderLoading = false;
//   bool deleteSalesOrderItemLoader = false;
//   var salesOrderList = <SalesOrderModel>[];
//   var singleSalesOrderList = <SalesOrderitemsModel>[];

//   // ========= sales person ==================
//   void updateSalesPersonId(int salesPersonId) {
//     selectedSalesPersonId = salesPersonId;
//     notifyListeners();
//   }

//   void updateSalesPersonName(String salesPersonName) {
//     selectedSalesPersonName = salesPersonName;
//     notifyListeners();
//   }

//   // ========== terms and condition ============
//   void updateTermsId(int termsId) {
//     selectedTermsId = termsId;
//     notifyListeners();
//   }

//   void updateTermsName(String termsName) {
//     selectedTermsName = termsName;
//     notifyListeners();
//   }

//   // ========= Client ==========================
//   void updateClientId(int clientId) {
//     selectedClientId = clientId;
//     notifyListeners();
//   }

//   void updateClientName(String clientName) {
//     selectedClientName = clientName;
//     notifyListeners();
//   }

//   void resetSelectedValues() {
//     selectedSalesPersonId = 0;
//     selectedSalesPersonName = "";
//     selectedClientId = 0;
//     selectedTermsId = 0;
//     selectedTermsName = "";
//     grandTotal = "";
//     notifyListeners();
//   }

//   void removeAll() {
//     itemList.clear();
//     resetGrandTotal();
//     notifyListeners();
//   }

//   void resetGrandTotal() {
//     grandTotal = "";
//     notifyListeners();
//   }

//   void addGrandTotal(String value) {
//     grandTotal = value;
//     notifyListeners();
//   }

//   void addSalesPerson(String value) {
//     selectedSalesPersonName = value;
//     notifyListeners();
//   }

//   void addItem() {
//     itemList.add(AddProductQuotationModel(itemNumber: itemList.length + 1));
//     Future.delayed(Duration.zero, () {
//       notifyListeners();
//     });
//   }

//   double calculateGrandTotal() {
//     double grandTotal = 0.0;

//     for (var item in itemList) {
//       grandTotal += double.tryParse(item.subTotal) ?? 0.0;
//     }

//     return grandTotal;
//   }

//   double editCalcGrandTotal() {
//     double grandTotal = 0.0;

//     for (var item in editItemList) {
//       grandTotal += double.tryParse(item.subTotal) ?? 0.0;
//     }

//     return grandTotal;
//   }

//   void updateGrandTotal() {
//     double res = calculateGrandTotal();
//     grandTotal = res.toStringAsFixed(2);
//     print("Updated Grand Total salesOrder add: $grandTotal");
//     notifyListeners();
//   }

//   void editGrandTotal() {
//     double res = editCalcGrandTotal();
//     grandTotal = res.toStringAsFixed(2);
//     print("Updated Grand Total salesOrder edit: $grandTotal");
//     notifyListeners();
//   }

//   void removeItem(int itemNumber) {
//     itemList.removeWhere((item) => item.itemNumber == itemNumber);

//     for (int i = 0; i < itemList.length; i++) {
//       itemList[i].itemNumber = i + 1;
//     }
//     updateGrandTotal();
//     notifyListeners();
//   }

//   void updateItem(int itemNumber, String field, String value) {
//     print("itemNumber == $itemNumber");
//     final item = itemList.firstWhere(
//       (element) => element.itemNumber == itemNumber,
//       orElse: () => AddProductQuotationModel(itemNumber: itemNumber),
//     );

//     switch (field) {
//       case "selectedProduct":
//         item.selectedProduct = value;
//         break;
//       case "quantity":
//         item.quantity = value;
//         break;
//       case "unitPrice":
//         item.unitPrice = value;
//         break;
//       case "total":
//         item.total = value;
//         break;
//       case "cgst":
//         item.cgst = value;
//         break;
//       case "sgst":
//         item.sgst = value;
//         break;
//       case "subTotal":
//         item.subTotal = value;
//         break;
//     }
//     updateGrandTotal();
//     notifyListeners();
//   }

//   void updateEditItem(int itemNumber, String field, String value) {
//     print("itemNumber == $itemNumber");
//     final item = editItemList.firstWhere(
//       (element) => element.itemNumber == itemNumber,
//       orElse: () => AddProductQuotationModel(itemNumber: itemNumber),
//     );

//     switch (field) {
//       case "selectedProduct":
//         item.selectedProduct = value;
//         break;
//       case "quantity":
//         item.quantity = value;
//         break;
//       case "unitPrice":
//         item.unitPrice = value;
//         break;
//       case "total":
//         item.total = value;
//         break;
//       case "cgst":
//         item.cgst = value;
//         break;
//       case "sgst":
//         item.sgst = value;
//         break;
//       case "subTotal":
//         item.subTotal = value;
//         break;
//     }
//     editGrandTotal();
//     notifyListeners();
//   }

//   void clearEditItems() {
//     editItemList.clear();
//   }

//   void addEditItem(AddProductQuotationModel item) {
//     editItemList.add(item);
//   }

//   Future<void> createSalesOrder(
//     salesOrderNumber,
//     salesDate,
//     customerId,
//     purchaseOrderNumber,
//     terms,
//     deliveryLocation,
//     deliveryAddress,
//     termsandConditionId,
//     remarks,
//     BuildContext context,
//   ) async {
//     try {
//       addSalesOrderLoading = true;
//       notifyListeners();

//       var response = await SalesOrderServices.createSalesOrder(
//         salesOrderNumber,
//         salesDate,
//         customerId,
//         purchaseOrderNumber,
//         terms,
//         deliveryLocation,
//         deliveryAddress,
//         termsandConditionId,
//         remarks,
//         getFormattedItems(),
//       );

//       if (response != 0) {
//         if (!context.mounted) return;
//         showSuccessMessage(
//           context,
//           "Sales Order Created Successfully!",
//         );
//         await getSalesOrderById(response);
//         await getAllSalesOrder();
//         itemList.clear();
//         if (!context.mounted) return;
//         pushReplacementNavigation(context, const ViewSalesOrder());
//       } else {
//         if (!context.mounted) return;
//         showOverlayError(context, "Unable to create");
//       }
//     } catch (e) {
//       print(e);
//     } finally {
//       addSalesOrderLoading = false;
//       notifyListeners();
//     }
//   }

//   List<Map<String, dynamic>> getFormattedItems() {
//     return itemList.map((item) {
//       return {
//         "product": int.tryParse(item.selectedProduct) ?? 0,
//         "quantity": int.tryParse(item.quantity) ?? 0,
//         "unit_price": double.tryParse(item.unitPrice) ?? 0.0,
//         "sgst_percentage": double.tryParse(item.sgst) ?? 0.0,
//         "cgst_percentage": double.tryParse(item.cgst) ?? 0.0,
//       };
//     }).toList();
//   }

//   List<Map<String, dynamic>> getFormattededitItems() {
//     return editItemList.map((item) {
//       return {
//         "product": item.productId,
//         "quantity": int.tryParse(item.quantity) ?? 0,
//         "unit_price": double.tryParse(item.unitPrice) ?? 0.0,
//         "sgst_percentage": double.tryParse(item.sgst) ?? 0.0,
//         "cgst_percentage": double.tryParse(item.cgst) ?? 0.0,
//       };
//     }).toList();
//   }

//   Future<void> getAllSalesOrder() async {
//     try {
//       getSalesOrderLoader = true;
//       notifyListeners();
//       List<SalesOrderModel> salesOrderItems =
//           await SalesOrderServices.getAllSalesOrder();

//       if (salesOrderItems.isNotEmpty) {
//         salesOrderList = salesOrderItems;
//       } else {
//         salesOrderList.clear();
//       }
//     } catch (e) {
//       print(e);
//     } finally {
//       getSalesOrderLoader = false;
//       notifyListeners();
//     }
//   }

//   Future<void> deleteSalesOrder(salesOrderId, BuildContext context) async {
//     try {
//       deleteSalesOrderLoader = true;
//       notifyListeners();
//       String? response =
//           await SalesOrderServices.deleteSalesOrder(salesOrderId);

//       if (response == null) {
//         if (!context.mounted) return;
//         showSuccessMessage(
//           context,
//           "Sales Order Deleted Successfully!",
//         );
//         getAllSalesOrder();
//         pushAndRemoveUntilFun(context, const SalesOrder());
//       } else {
//         if (!context.mounted) return;
//         showOverlayError(context, response);
//       }
//     } catch (e) {
//       print(e);
//     } finally {
//       deleteSalesOrderLoader = false;
//       notifyListeners();
//     }
//   }

//   Future<void> getSalesOrderById(salesOrderId) async {
//     try {
//       singleSalesOrderLoading = true;
//       notifyListeners();

//       List<SalesOrderitemsModel> salesOrderItems =
//           await SalesOrderServices.getSalesOrderById(salesOrderId);

//       if (salesOrderItems.isNotEmpty) {
//         singleSalesOrderList = salesOrderItems;
//       } else {
//         singleSalesOrderList.clear();
//       }
//     } catch (e) {
//       print(e);
//     } finally {
//       singleSalesOrderLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<void> updateSalesOrder(
//     salesOrderId,
//     salesOrderNumber,
//     salesDate,
//     customerId,
//     purchaseOrderNumber,
//     deliveryLocation,
//     deliveryAddress,
//     termsandConditionId,
//     remarks,
//     BuildContext context,
//   ) async {
//     try {
//       editSalesOrderLoading = true;
//       notifyListeners();

//       String? response = await SalesOrderServices.editSalesOrder(
//         salesOrderId,
//         salesOrderNumber,
//         salesDate,
//         customerId,
//         purchaseOrderNumber,
//         deliveryLocation,
//         deliveryAddress,
//         termsandConditionId,
//         remarks,
//         getFormattededitItems(),
//       );

//       if (response == null) {
//         if (!context.mounted) return;
//         showSuccessMessage(
//           context,
//           "Sales Order Updated Successfully!",
//         );
//         editItemList.clear();
//         await getSalesOrderById(salesOrderId);
//         if (!context.mounted) return;
//         pushReplacementNavigation(context, const ViewSalesOrder());
//       } else {
//         if (!context.mounted) return;
//         showOverlayError(context, "Unable to Update");
//       }
//     } catch (e) {
//       print(e);
//     } finally {
//       editSalesOrderLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<void> deleteSalesOrderItem(
//     salesOrderId,
//     productTabId,
//     BuildContext context,
//   ) async {
//     try {
//       deleteSalesOrderItemLoader = true;
//       notifyListeners();
//       String? response = await SalesOrderServices.deleteSalesOrderItems(
//         salesOrderId,
//         productTabId,
//       );

//       if (response == null) {
//         if (!context.mounted) return;
//         showSuccessMessage(
//           context,
//           "Sales Order Item Deleted Successfully!",
//         );
//         getAllSalesOrder();
//         pushAndRemoveUntilFun(context, const SalesOrder());
//       } else {
//         if (!context.mounted) return;
//         showOverlayError(context, response);
//       }
//     } catch (e) {
//       print(e);
//     } finally {
//       deleteSalesOrderItemLoader = false;
//       notifyListeners();
//     }
//   }
// }
import 'package:flutter/material.dart';
import 'package:pokakbilling/core/navigations.dart';
import 'package:pokakbilling/models/data-models/addQuotation_model.dart';
import 'package:pokakbilling/models/data-models/sales-order-models/salesOrderItems_model.dart';
import 'package:pokakbilling/models/data-models/sales-order-models/salesOrder_model.dart';
import 'package:pokakbilling/models/services/sales_order_services.dart';
import 'package:pokakbilling/views/Screens/sales_order/sales_order.dart';
import 'package:pokakbilling/views/Screens/sales_order/view/view_sales_order.dart';
import 'package:pokakbilling/views/commonWidgets/response-message/error_message.dart';
import 'package:pokakbilling/views/commonWidgets/response-message/success-message.dart';

class SalesOrderViewmodel extends ChangeNotifier {
  int selectedSalesPersonId = 0;
  int selectedClientId = 0;
  int selectedTermsId = 0;
  String selectedTermsName = "";
  String selectedSalesPersonName = "";
  String selectedClientName = "";
  List<AddProductQuotationModel> itemList = [];
  List<AddProductQuotationModel> editItemList = [];
  String grandTotal = "";
  bool addSalesOrderLoading = false;
  bool getSalesOrderLoader = false;
  bool deleteSalesOrderLoader = false;
  bool singleSalesOrderLoading = false;
  bool editSalesOrderLoading = false;
  bool deleteSalesOrderItemLoader = false;
  var salesOrderList = <SalesOrderModel>[];
  var singleSalesOrderList = <SalesOrderitemsModel>[];

  void reset() {
    salesOrderList = [];
    singleSalesOrderList = [];
    itemList = [];
    editItemList = [];
    selectedSalesPersonId = 0;
    selectedClientId = 0;
    selectedTermsId = 0;
    selectedTermsName = "";
    selectedSalesPersonName = "";
    selectedClientName = "";
    grandTotal = "";
    addSalesOrderLoading = false;
    getSalesOrderLoader = false;
    deleteSalesOrderLoader = false;
    singleSalesOrderLoading = false;
    editSalesOrderLoading = false;
    deleteSalesOrderItemLoader = false;
    notifyListeners();
  }

  void updateSalesPersonId(int salesPersonId) {
    selectedSalesPersonId = salesPersonId;
    notifyListeners();
  }

  void updateSalesPersonName(String salesPersonName) {
    selectedSalesPersonName = salesPersonName;
    notifyListeners();
  }

  void updateTermsId(int termsId) {
    selectedTermsId = termsId;
    notifyListeners();
  }

  void updateTermsName(String termsName) {
    selectedTermsName = termsName;
    notifyListeners();
  }

  void updateClientId(int clientId) {
    selectedClientId = clientId;
    notifyListeners();
  }

  void updateClientName(String clientName) {
    selectedClientName = clientName;
    notifyListeners();
  }

  void resetSelectedValues() {
    selectedSalesPersonId = 0;
    selectedSalesPersonName = "";
    selectedClientId = 0;
    selectedTermsId = 0;
    selectedTermsName = "";
    grandTotal = "";
    notifyListeners();
  }

  void removeAll() {
    itemList.clear();
    resetGrandTotal();
    notifyListeners();
  }

  void resetGrandTotal() {
    grandTotal = "";
    notifyListeners();
  }

  void addGrandTotal(String value) {
    grandTotal = value;
    notifyListeners();
  }

  void addSalesPerson(String value) {
    selectedSalesPersonName = value;
    notifyListeners();
  }

  void addItem() {
    itemList.add(AddProductQuotationModel(itemNumber: itemList.length + 1));
    Future.delayed(Duration.zero, () {
      notifyListeners();
    });
  }

  double calculateGrandTotal() {
    double grandTotal = 0.0;
    for (var item in itemList) {
      grandTotal += double.tryParse(item.subTotal) ?? 0.0;
    }
    return grandTotal;
  }

  double editCalcGrandTotal() {
    double grandTotal = 0.0;
    for (var item in editItemList) {
      grandTotal += double.tryParse(item.subTotal) ?? 0.0;
    }
    return grandTotal;
  }

  void updateGrandTotal() {
    double res = calculateGrandTotal();
    grandTotal = res.toStringAsFixed(2);
    print("Updated Grand Total salesOrder add: $grandTotal");
    notifyListeners();
  }

  void editGrandTotal() {
    double res = editCalcGrandTotal();
    grandTotal = res.toStringAsFixed(2);
    print("Updated Grand Total salesOrder edit: $grandTotal");
    notifyListeners();
  }

  void removeItem(int itemNumber) {
    itemList.removeWhere((item) => item.itemNumber == itemNumber);
    for (int i = 0; i < itemList.length; i++) {
      itemList[i].itemNumber = i + 1;
    }
    updateGrandTotal();
    notifyListeners();
  }

  void updateItem(int itemNumber, String field, String value) {
    print("itemNumber == $itemNumber");
    final item = itemList.firstWhere(
      (element) => element.itemNumber == itemNumber,
      orElse: () => AddProductQuotationModel(itemNumber: itemNumber),
    );
    switch (field) {
      case "selectedProduct":
        item.selectedProduct = value;
        break;
      case "quantity":
        item.quantity = value;
        break;
      case "unitPrice":
        item.unitPrice = value;
        break;
      case "total":
        item.total = value;
        break;
      case "cgst":
        item.cgst = value;
        break;
      case "sgst":
        item.sgst = value;
        break;
      case "subTotal":
        item.subTotal = value;
        break;
    }
    updateGrandTotal();
    notifyListeners();
  }

  void updateEditItem(int itemNumber, String field, String value) {
    print("itemNumber == $itemNumber");
    final item = editItemList.firstWhere(
      (element) => element.itemNumber == itemNumber,
      orElse: () => AddProductQuotationModel(itemNumber: itemNumber),
    );
    switch (field) {
      case "selectedProduct":
        item.selectedProduct = value;
        break;
      case "quantity":
        item.quantity = value;
        break;
      case "unitPrice":
        item.unitPrice = value;
        break;
      case "total":
        item.total = value;
        break;
      case "cgst":
        item.cgst = value;
        break;
      case "sgst":
        item.sgst = value;
        break;
      case "subTotal":
        item.subTotal = value;
        break;
    }
    editGrandTotal();
    notifyListeners();
  }

  void clearEditItems() {
    editItemList.clear();
  }

  void addEditItem(AddProductQuotationModel item) {
    editItemList.add(item);
  }

  Future<void> createSalesOrder(
    salesOrderNumber,
    salesDate,
    customerId,
    purchaseOrderNumber,
    terms,
    deliveryLocation,
    deliveryAddress,
    termsandConditionId,
    remarks,
    BuildContext context,
  ) async {
    try {
      addSalesOrderLoading = true;
      notifyListeners();
      var response = await SalesOrderServices.createSalesOrder(
        salesOrderNumber,
        salesDate,
        customerId,
        purchaseOrderNumber,
        terms,
        deliveryLocation,
        deliveryAddress,
        termsandConditionId,
        remarks,
        getFormattedItems(),
      );
      if (response != 0) {
        if (!context.mounted) return;
        showSuccessMessage(context, "Sales Order Created Successfully!");
        await getSalesOrderById(response);
        await getAllSalesOrder();
        itemList.clear();
        if (!context.mounted) return;
        pushReplacementNavigation(context, const ViewSalesOrder());
      } else {
        if (!context.mounted) return;
        showOverlayError(context, "Unable to create");
      }
    } catch (e) {
      print(e);
    } finally {
      addSalesOrderLoading = false;
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> getFormattedItems() {
    return itemList.map((item) {
      return {
        "product": int.tryParse(item.selectedProduct) ?? 0,
        "quantity": int.tryParse(item.quantity) ?? 0,
        "unit_price": double.tryParse(item.unitPrice) ?? 0.0,
        "sgst_percentage": double.tryParse(item.sgst) ?? 0.0,
        "cgst_percentage": double.tryParse(item.cgst) ?? 0.0,
      };
    }).toList();
  }

  List<Map<String, dynamic>> getFormattededitItems() {
    return editItemList.map((item) {
      return {
        "product": item.productId,
        "quantity": int.tryParse(item.quantity) ?? 0,
        "unit_price": double.tryParse(item.unitPrice) ?? 0.0,
        "sgst_percentage": double.tryParse(item.sgst) ?? 0.0,
        "cgst_percentage": double.tryParse(item.cgst) ?? 0.0,
      };
    }).toList();
  }

  Future<void> getAllSalesOrder() async {
    try {
      getSalesOrderLoader = true;
      notifyListeners();
      List<SalesOrderModel> salesOrderItems =
          await SalesOrderServices.getAllSalesOrder();
      if (salesOrderItems.isNotEmpty) {
        salesOrderList = salesOrderItems;
      } else {
        salesOrderList.clear();
      }
    } catch (e) {
      print(e);
    } finally {
      getSalesOrderLoader = false;
      notifyListeners();
    }
  }

  Future<void> deleteSalesOrder(salesOrderId, BuildContext context) async {
    try {
      deleteSalesOrderLoader = true;
      notifyListeners();
      String? response =
          await SalesOrderServices.deleteSalesOrder(salesOrderId);
      if (response == null) {
        if (!context.mounted) return;
        showSuccessMessage(context, "Sales Order Deleted Successfully!");
        getAllSalesOrder();
        pushAndRemoveUntilFun(context, const SalesOrder());
      } else {
        if (!context.mounted) return;
        showOverlayError(context, response);
      }
    } catch (e) {
      print(e);
    } finally {
      deleteSalesOrderLoader = false;
      notifyListeners();
    }
  }

  Future<void> getSalesOrderById(salesOrderId) async {
    try {
      singleSalesOrderLoading = true;
      notifyListeners();
      List<SalesOrderitemsModel> salesOrderItems =
          await SalesOrderServices.getSalesOrderById(salesOrderId);
      if (salesOrderItems.isNotEmpty) {
        singleSalesOrderList = salesOrderItems;
      } else {
        singleSalesOrderList.clear();
      }
    } catch (e) {
      print(e);
    } finally {
      singleSalesOrderLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateSalesOrder(
    salesOrderId,
    salesOrderNumber,
    salesDate,
    customerId,
    purchaseOrderNumber,
    deliveryLocation,
    deliveryAddress,
    termsandConditionId,
    remarks,
    BuildContext context,
  ) async {
    try {
      editSalesOrderLoading = true;
      notifyListeners();
      String? response = await SalesOrderServices.editSalesOrder(
        salesOrderId,
        salesOrderNumber,
        salesDate,
        customerId,
        purchaseOrderNumber,
        deliveryLocation,
        deliveryAddress,
        termsandConditionId,
        remarks,
        getFormattededitItems(),
      );
      if (response == null) {
        if (!context.mounted) return;
        showSuccessMessage(context, "Sales Order Updated Successfully!");
        editItemList.clear();
        await getSalesOrderById(salesOrderId);
        if (!context.mounted) return;
        pushReplacementNavigation(context, const ViewSalesOrder());
      } else {
        if (!context.mounted) return;
        showOverlayError(context, "Unable to Update");
      }
    } catch (e) {
      print(e);
    } finally {
      editSalesOrderLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteSalesOrderItem(
    salesOrderId,
    productTabId,
    BuildContext context,
  ) async {
    try {
      deleteSalesOrderItemLoader = true;
      notifyListeners();
      String? response = await SalesOrderServices.deleteSalesOrderItems(
        salesOrderId,
        productTabId,
      );
      if (response == null) {
        if (!context.mounted) return;
        showSuccessMessage(context, "Sales Order Item Deleted Successfully!");
        getAllSalesOrder();
        pushAndRemoveUntilFun(context, const SalesOrder());
      } else {
        if (!context.mounted) return;
        showOverlayError(context, response);
      }
    } catch (e) {
      print(e);
    } finally {
      deleteSalesOrderItemLoader = false;
      notifyListeners();
    }
  }
}
