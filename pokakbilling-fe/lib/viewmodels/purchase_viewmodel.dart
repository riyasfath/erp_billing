import 'package:flutter/material.dart';
import 'package:pokakbilling/core/navigations.dart';
import 'package:pokakbilling/models/data-models/addQuotation_model.dart';
import 'package:pokakbilling/models/data-models/purchase-order-models/purchase_order_items_model.dart';
import 'package:pokakbilling/models/data-models/purchase-order-models/purchase_order_model.dart';
import 'package:pokakbilling/models/services/purchase_order_service.dart';
import 'package:pokakbilling/views/Screens/purchase/purchase_main.dart';
import 'package:pokakbilling/views/Screens/purchase/view_purchase/view_purchase.dart';
import 'package:pokakbilling/views/commonWidgets/response-message/error_message.dart';
import 'package:pokakbilling/views/commonWidgets/response-message/success-message.dart';

class PurchaseViewmodel extends ChangeNotifier {
  int selectedSupplierId = 0;
  String selectedSupplierName = "";
  List<AddQuotationModel> itemList = [];
  List<AddQuotationModel> editItemList = [];
  String grandTotal = "";
  bool addPurchaseOrderLoader = false;
  int selectedTermsId = 0;
  bool getPurchaseOrderLoader = false;
  bool singlePurchaseOrderLoading = false;
  bool deletePurchaseOrderLoader = false;
  bool editPurchaseOrderLoader = false;
  var purchaseOrderList = <PurchaseOrderModel>[];
  var singlePurchaseOrderList = <PurchaseOrderItemsModel>[];

  PurchaseViewmodel() {
    getAllPurchaseOrders();
  }

  // ✅ Call this on logout to wipe stale data
  void clearData() {
    purchaseOrderList = [];
    singlePurchaseOrderList = [];
    itemList = [];
    editItemList = [];
    grandTotal = "";
    selectedSupplierId = 0;
    selectedSupplierName = "";
    selectedTermsId = 0;
    addPurchaseOrderLoader = false;
    getPurchaseOrderLoader = false;
    singlePurchaseOrderLoading = false;
    deletePurchaseOrderLoader = false;
    editPurchaseOrderLoader = false;
    notifyListeners();
  }

  void removeAll() {
    itemList.clear();
    editItemList.clear();
    resetGrandTotal();
    notifyListeners();
  }

  void resetGrandTotal() {
    grandTotal = "";
    notifyListeners();
  }

  void updateSuppliertName(String value) {
    selectedSupplierName = value;
    notifyListeners();
  }

  void updateSupplierId(int value) {
    selectedSupplierId = value;
    notifyListeners();
  }

  void updateTermsId(int value) {
    selectedTermsId = value;
    notifyListeners();
  }

  void addItem() {
    itemList.add(AddQuotationModel(itemNumber: itemList.length + 1));
    Future.delayed(Duration.zero, () {
      notifyListeners();
    });
  }

  void addGrandTotal(String value) {
    grandTotal = value;
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
    notifyListeners();
  }

  void editGrandTotal() {
    double res = editCalcGrandTotal();
    grandTotal = res.toStringAsFixed(2);
    notifyListeners();
  }

  void updateItem(int itemNumber, String field, String value) {
    final item = itemList.firstWhere(
      (element) => element.itemNumber == itemNumber,
      orElse: () => AddQuotationModel(itemNumber: itemNumber),
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
    final item = editItemList.firstWhere(
      (element) => element.itemNumber == itemNumber,
      orElse: () => AddQuotationModel(itemNumber: itemNumber),
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

  void addEditItem(AddQuotationModel item) {
    editItemList.add(item);
  }

  Future<void> createPurchaseOrder(
    purchaseOrderNumber,
    purchaseOrderDate,
    supplierId,
    quotationNumber,
    contactPersonName,
    contactPersonNumber,
    grandTotal,
    remarks,
    termsandConditionId,
    BuildContext context,
  ) async {
    try {
      addPurchaseOrderLoader = true;
      notifyListeners();

      var response = await PurchaseOrderService.createPurchaseOrder(
        purchaseOrderNumber,
        purchaseOrderDate,
        supplierId,
        quotationNumber,
        contactPersonName,
        contactPersonNumber,
        grandTotal,
        remarks,
        termsandConditionId,
        getFormattedItems(),
      );

      if (response != 0) {
        if (!context.mounted) return;
        showSuccessMessage(context, "Purchase Order Created Successfully!");
        await getPurchaseOrderById(response);
        await getAllPurchaseOrders();
        itemList.clear();
        if (!context.mounted) return;
        pushReplacementNavigation(context, const ViewPurchase());
      } else {
        if (!context.mounted) return;
        showOverlayError(context, "Unable to create");
      }
    } catch (e) {
      print(e);
    } finally {
      addPurchaseOrderLoader = false;
      notifyListeners();
    }
  }

  Future<void> getAllPurchaseOrders() async {
    try {
      getPurchaseOrderLoader = true;
      notifyListeners();
      List<PurchaseOrderModel> purchaseOrderItems =
          await PurchaseOrderService.getAllPurchaseOrders();
      if (purchaseOrderItems.isNotEmpty) {
        purchaseOrderList = purchaseOrderItems;
      } else {
        purchaseOrderList.clear();
      }
    } catch (e) {
      print(e);
    } finally {
      getPurchaseOrderLoader = false;
      notifyListeners();
    }
  }

  Future<void> getPurchaseOrderById(purchaseOrderId) async {
    try {
      singlePurchaseOrderLoading = true;
      notifyListeners();
      List<PurchaseOrderItemsModel> purchaseOrderItems =
          await PurchaseOrderService.getPurchaseOrderById(purchaseOrderId);
      if (purchaseOrderItems.isNotEmpty) {
        singlePurchaseOrderList = purchaseOrderItems;
      } else {
        singlePurchaseOrderList.clear();
      }
    } catch (e) {
      print(e);
    } finally {
      singlePurchaseOrderLoading = false;
      notifyListeners();
    }
  }

  Future<void> deletePurchaseOrder(
      purchaseOrderId, BuildContext context) async {
    try {
      deletePurchaseOrderLoader = true;
      notifyListeners();
      String? response =
          await PurchaseOrderService.deletePurchaseOrder(purchaseOrderId);
      if (response == null) {
        if (!context.mounted) return;
        showSuccessMessage(context, "Purchase Order Deleted Successfully!");
        getAllPurchaseOrders();
        pushAndRemoveUntilFun(context, const PurchaseMain());
      } else {
        if (!context.mounted) return;
        showOverlayError(context, response);
      }
    } catch (e) {
      print(e);
    } finally {
      deletePurchaseOrderLoader = false;
      notifyListeners();
    }
  }

  Future<void> editPurchaseOrder(
    purchaseId,
    purchaseOrderNumber,
    purchaseOrderDate,
    supplierId,
    quotationNumber,
    contactPersonName,
    contactPersonNumber,
    grandTotal,
    remarks,
    termsandConditionId,
    BuildContext context,
  ) async {
    try {
      editPurchaseOrderLoader = true;
      notifyListeners();

      var response = await PurchaseOrderService.editPurchaseOrder(
        purchaseId,
        purchaseOrderNumber,
        purchaseOrderDate,
        supplierId,
        quotationNumber,
        contactPersonName,
        contactPersonNumber,
        grandTotal,
        remarks,
        termsandConditionId,
        getFormattededitItems(),
      );

      if (response == null) {
        if (!context.mounted) return;
        showSuccessMessage(context, "Purchase Order Edited Successfully!");
        await getPurchaseOrderById(purchaseId);
        await getAllPurchaseOrders();
        itemList.clear();
        if (!context.mounted) return;
        pushReplacementNavigation(context, const ViewPurchase());
      } else {
        if (!context.mounted) return;
        showOverlayError(context, "Unable to Edit");
      }
    } catch (e) {
      print(e);
    } finally {
      editPurchaseOrderLoader = false;
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> getFormattedItems() {
    return itemList.map((item) {
      return {
        "product": int.tryParse(item.selectedProduct) ?? 0,
        "quantity": int.tryParse(item.quantity) ?? 0,
        "unit_price": double.tryParse(item.unitPrice) ?? 0.0,
        "total": double.tryParse(item.total) ?? 0.0,
        "sgst_percentage": double.tryParse(item.sgst) ?? 0.0,
        "cgst_percentage": double.tryParse(item.cgst) ?? 0.0,
        "sub_total": double.tryParse(item.subTotal) ?? 0.0,
      };
    }).toList();
  }

  List<Map<String, dynamic>> getFormattededitItems() {
    return editItemList.map((item) {
      return {
        "product": item.productId,
        "quantity": item.quantity,
        "unit_price": double.tryParse(item.unitPrice) ?? 0.0,
        "total": double.tryParse(item.total) ?? 0.0,
        "sgst_percentage": double.tryParse(item.sgst) ?? 0.0,
        "cgst_percentage": double.tryParse(item.cgst) ?? 0.0,
        "sub_total": double.tryParse(item.subTotal) ?? 0.0,
      };
    }).toList();
  }
}
