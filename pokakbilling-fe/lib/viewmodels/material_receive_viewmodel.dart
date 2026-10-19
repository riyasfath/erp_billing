import 'package:flutter/material.dart';
import 'package:pokakbilling/core/navigations.dart';
import 'package:pokakbilling/models/data-models/addQuotation_model.dart';
import 'package:pokakbilling/models/data-models/material_receive/material_receive_model.dart';
import 'package:pokakbilling/models/data-models/material_receive/mr_items_model.dart';
import 'package:pokakbilling/models/services/material_receive_service.dart';
import 'package:pokakbilling/views/Screens/material_receive/view/view_mr.dart';
import 'package:pokakbilling/views/commonWidgets/response-message/error_message.dart';
import 'package:pokakbilling/views/commonWidgets/response-message/success-message.dart';

class MaterialReceiveViewmodel extends ChangeNotifier {
  int selectedSupplierId = 0;
  String selectedSupplierName = "";
  int selectedPurchaseId = 0;
  String selectedPurchaseName = "";
  bool addMrLoader = false;
  bool editMrLoader = false;
  List<MaterialReceiveModel> materialReceiveList = [];
  List<AddQuotationModel> editItemList = [];
  bool getMaterialReceiveLoader = false;
  List<MaterialReceiveItemModel> singleMaterialReceiveList = [];
  bool singleMaterialReceiveLoading = false;
  bool deleteMaterialReceiveLoader = false;

  MaterialReceiveViewmodel() {
    getAllMaterialReceive();
  }

  void removeAll() {
    itemList.clear();
    resetGrandTotal();
    editItemList.clear();
    notifyListeners();
  }

  void resetGrandTotal() {
    grandTotal = "";
    notifyListeners();
  }

  List<AddQuotationModel> itemList = [];
  String grandTotal = "";

  void updateSupplierId(int supplierId) {
    selectedSupplierId = supplierId;
    notifyListeners();
  }

  void addGrandTotal(String value) {
    grandTotal = value;
    notifyListeners();
  }

  void updateSupplierName(String value) {
    selectedSupplierName = value;
    notifyListeners();
  }

  void updatePurchaseId(int purchaseId) {
    selectedPurchaseId = purchaseId;
    notifyListeners();
  }

  void updatePurchaseName(String value) {
    selectedPurchaseName = value;
    notifyListeners();
  }

  void addItem() {
    itemList.add(AddQuotationModel(itemNumber: itemList.length + 1));
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
    print("itemNumber == $itemNumber");
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

  Future<void> createMaterialReceive(
    mrNumber,
    mrDate,
    supplierId,
    purchaseOrderId,
    grandTotal,
    remarks,
    BuildContext context,
  ) async {
    try {
      addMrLoader = true;
      notifyListeners();

      int? response = await MaterialReceiveService.createMaterialReceive(
        mrNumber,
        mrDate,
        supplierId,
        purchaseOrderId,
        grandTotal,
        remarks,
        getFormattedItems(),
      );

      if (response != null) {
        if (!context.mounted) return;
        showSuccessMessage(
          context,
          "Material Receive Created Successfully!",
        );
        await getMaterialReceiveById(response);
        await getAllMaterialReceive();
        itemList.clear();
        if (!context.mounted) return;
        pushReplacementNavigation(context, const ViewMaterialReceive());
      } else {
        if (!context.mounted) return;
        showOverlayError(context, "Unable to create");
      }
    } catch (e) {
      print(e);
    } finally {
      addMrLoader = false;
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

  Future<void> getAllMaterialReceive() async {
    try {
      getMaterialReceiveLoader = true;
      notifyListeners();

      List<MaterialReceiveModel> receiveItems =
          await MaterialReceiveService.getAllMaterialReceive();

      if (receiveItems.isNotEmpty) {
        materialReceiveList = receiveItems;
      } else {
        materialReceiveList.clear();
      }
    } catch (e) {
      print("Error fetching material receive: $e");
    } finally {
      getMaterialReceiveLoader = false;
      notifyListeners();
    }
  }

  Future<void> getMaterialReceiveById(mrId) async {
    try {
      singleMaterialReceiveLoading = true;
      notifyListeners();

      List<MaterialReceiveItemModel> mrItems =
          await MaterialReceiveService.getMaterialReceiveById(mrId);

      if (mrItems.isNotEmpty) {
        singleMaterialReceiveList = mrItems;
      } else {
        singleMaterialReceiveList.clear();
      }
    } catch (e) {
      print(e);
    } finally {
      singleMaterialReceiveLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteMaterialReceive(int mrId, BuildContext context) async {
    try {
      deleteMaterialReceiveLoader = true;
      notifyListeners();

      bool isDeleted = await MaterialReceiveService.deleteMaterialReceive(mrId);

      if (isDeleted) {
        showSuccessMessage(context, "Material Receive deleted successfully.");
        await getAllMaterialReceive();
      } else {
        showOverlayError(context, "Failed to delete Material Receive.");
      }
    } catch (e) {
      print("Error deleting Material Receive: $e");
      showOverlayError(context, "An error occurred.");
    } finally {
      deleteMaterialReceiveLoader = false;
      notifyListeners();
    }
  }

  Future<void> editMaterialReceive(
    int mrId,
    String mrNumber,
    String mrDate,
    int supplierId,
    int purchaseOrderId,
    String grandTotal,
    String remarks,
    BuildContext context,
  ) async {
    try {
      editMrLoader = true;
      notifyListeners();

      var response = await MaterialReceiveService.editMaterialReceive(
        mrId,
        mrNumber,
        mrDate,
        supplierId,
        purchaseOrderId,
        grandTotal,
        remarks,
        getFormattededitItems(),
      );

      if (response == null) {
        if (!context.mounted) return;
        showSuccessMessage(
          context,
          "Material Receive Updated Successfully!",
        );
        await getMaterialReceiveById(mrId);
        await getAllMaterialReceive();
        editItemList.clear();
        if (!context.mounted) return;
        pushReplacementNavigation(context, const ViewMaterialReceive());
      } else {
        if (!context.mounted) return;
        showOverlayError(context, "Unable to Edit");
      }
    } catch (e) {
      print("Edit error: $e");
    } finally {
      editMrLoader = false;
      notifyListeners();
    }
  }
}
