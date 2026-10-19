import 'package:flutter/material.dart';
import 'package:pokakbilling/core/navigations.dart';
import 'package:pokakbilling/models/data-models/addQuotation_model.dart';
import 'package:pokakbilling/models/data-models/quotations-models/quotationItems_model.dart';
import 'package:pokakbilling/models/data-models/quotations-models/quotation_model.dart';
import 'package:pokakbilling/models/data-models/setup/contract_info_model.dart';
import 'package:pokakbilling/models/services/quotation_services.dart';
import 'package:pokakbilling/models/services/setup/contract_service.dart';
import 'package:pokakbilling/viewmodels/product_viewmodel.dart';
import 'package:pokakbilling/views/Screens/quotation/quotation_main.dart';
import 'package:pokakbilling/views/Screens/quotation/view/view_quotation.dart';
import 'package:pokakbilling/views/commonWidgets/response-message/error_message.dart';
import 'package:pokakbilling/views/commonWidgets/response-message/success-message.dart';

class QuotationViewmodel extends ChangeNotifier {
  bool addQuotationLoader = false;
  bool getQuotationLoader = false;
  bool deleteCategoryLoader = false;
  bool singleQuotationLoading = false;
  bool editLoading = false;
  bool deleteQuotationProdLoader = false;
  bool deleteQuotationItemLoader = false;
  bool getCompleteContractInfoLoading = false;
  int selectedPersonId = 0;
  var quotationList = <QuotationModel>[];
  var singleQuotationList = <QuotationitemsModel>[];
  List<AddQuotationModel> itemList = [];
  List<AddQuotationModel> editItemList = [];
  int total = 0;
  String grandTotal = "";
  int selectedSalesPersonId = 0;
  String selectedSalesPersonName = "";
  int selectedClientId = 0;
  String selectedClientName = "";
  int selectedTermsId = 0;
  String selectedTermsTitle = "";
  List<int> editProductId = [];
  int selectedContractId = 0;
  String selectedContractName = "";
  var contractInfoList = <ContractInfoModel>[];
  Map<int, List<EditablePointModel>> editablePointsMap = {};
  Map<int, List<EditableSectionModel>> editableSectionsMap = {};

  QuotationViewmodel() {
    getAllQuotations();
  }

  // ✅ Call this on logout to wipe stale data
  void clearData() {
    quotationList = [];
    singleQuotationList = [];
    itemList = [];
    editItemList = [];
    contractInfoList = [];
    editablePointsMap = {};
    editableSectionsMap = {};
    editProductId = [];
    grandTotal = "";
    total = 0;
    selectedPersonId = 0;
    selectedSalesPersonId = 0;
    selectedSalesPersonName = "";
    selectedClientId = 0;
    selectedClientName = "";
    selectedTermsId = 0;
    selectedTermsTitle = "";
    selectedContractId = 0;
    selectedContractName = "";
    addQuotationLoader = false;
    getQuotationLoader = false;
    deleteCategoryLoader = false;
    singleQuotationLoading = false;
    editLoading = false;
    deleteQuotationProdLoader = false;
    deleteQuotationItemLoader = false;
    getCompleteContractInfoLoading = false;
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

  void updateClientId(int value) {
    selectedClientId = value;
    notifyListeners();
  }

  void addGrandTotal(String value) {
    grandTotal = value;
    notifyListeners();
  }

  void updateClientName(String value) {
    selectedClientName = value;
    notifyListeners();
  }

  void updateSelectedTermsId(int value) {
    selectedTermsId = value;
    notifyListeners();
  }

  void selectTermsTitle(String name) {
    selectedTermsTitle = name;
    notifyListeners();
  }

  void updateContractId(int value) {
    selectedContractId = value;
    notifyListeners();
  }

  void updateContractName(String value) {
    selectedContractName = value;
    notifyListeners();
  }

  void updateGrandTotal() {
    grandTotal = calculateGrandTotal().toStringAsFixed(2);
    notifyListeners();
  }

  void editGrandTotal() {
    grandTotal = editCalcGrandTotal().toStringAsFixed(2);
    notifyListeners();
  }

  void resetGrandTotal() {
    grandTotal = "";
    notifyListeners();
  }

  double calculateGrandTotal() {
    double result = 0.0;
    for (var item in itemList) {
      result += double.tryParse(item.subTotal) ?? 0.0;
    }
    return result;
  }

  double editCalcGrandTotal() {
    double result = 0.0;
    for (var item in editItemList) {
      result += double.tryParse(item.subTotal) ?? 0.0;
    }
    return result;
  }

  void addItem() {
    itemList.add(AddQuotationModel(itemNumber: itemList.length + 1));
    Future.delayed(Duration.zero, () => notifyListeners());
  }

  void removeItem(int itemNumber) {
    itemList.removeWhere((item) => item.itemNumber == itemNumber);
    for (int i = 0; i < itemList.length; i++) {
      itemList[i].itemNumber = i + 1;
    }
    updateGrandTotal();
    notifyListeners();
  }

  void removeAll() {
    itemList.clear();
    editItemList.clear();
    resetGrandTotal();
    notifyListeners();
  }

  void addSelectedPersonId(int id) {
    selectedPersonId = id;
    notifyListeners();
  }

  Future<void> createQuotation(
    quotationNumber,
    quotationDate,
    clientId,
    termsId,
    deliveryAddress,
    deliveryLocation,
    projectName,
    BuildContext context, {
    required ProductViewModel productViewModel,
  }) async {
    try {
      addQuotationLoader = true;
      notifyListeners();

      var response = await QuotationServices.createQuotation(
        quotationNumber,
        quotationDate,
        clientId,
        termsId,
        deliveryAddress,
        deliveryLocation,
        projectName,
        getFormattedItems(),
        buildContractJson(),
      );

      if (response != null) {
        final Map<int, int> deductions = {};
        for (final item in itemList) {
          final productId = int.tryParse(item.selectedProduct);
          final qty = int.tryParse(item.quantity) ?? 0;
          if (productId != null && qty > 0) {
            deductions[productId] = (deductions[productId] ?? 0) + qty;
          }
        }
        productViewModel.deductStockForItems(deductions);

        if (!context.mounted) return;
        showSuccessMessage(context, "Quotation Created Successfully!");
        await getQuotationById(response.quotationId);
        await getAllQuotations();
        itemList.clear();
        if (!context.mounted) return;
        pushReplacementNavigation(context, const ViewQuotation());
      } else {
        if (!context.mounted) return;
        showOverlayError(context, "Unable to create");
      }
    } catch (e) {
      print('Error creating quotation: $e');
    } finally {
      addQuotationLoader = false;
      notifyListeners();
    }
  }

  Future<void> getAllQuotations() async {
    try {
      getQuotationLoader = true;
      notifyListeners();
      List<QuotationModel> items = await QuotationServices.getAllQuotations();
      if (items.isNotEmpty) {
        quotationList = items;
      } else {
        quotationList.clear();
      }
    } catch (e) {
      print('Error getting quotations: $e');
    } finally {
      getQuotationLoader = false;
      notifyListeners();
    }
  }

  Future<void> deleteQuotation(quotationId, BuildContext context) async {
    try {
      deleteCategoryLoader = true;
      notifyListeners();
      String? response = await QuotationServices.deleteQuotation(quotationId);
      if (response == null) {
        if (!context.mounted) return;
        showSuccessMessage(context, "Quotation Deleted Successfully!");
        getAllQuotations();
        pushAndRemoveUntilFun(context, const QuotationMain());
      } else {
        if (!context.mounted) return;
        showOverlayError(context, response);
      }
    } catch (e) {
      print('Error deleting quotation: $e');
    } finally {
      deleteCategoryLoader = false;
      notifyListeners();
    }
  }

  Future<void> getQuotationById(quotationId) async {
    try {
      singleQuotationLoading = true;
      notifyListeners();
      List<QuotationitemsModel> items =
          await QuotationServices.getQuotationById(quotationId);
      if (items.isNotEmpty) {
        singleQuotationList = items;
      } else {
        singleQuotationList.clear();
      }
    } catch (e) {
      print('Error getting quotation by ID: $e');
    } finally {
      singleQuotationLoading = false;
      notifyListeners();
    }
  }

  Future<void> editQuotation(
    quotationId,
    quotationNumber,
    quotationDate,
    clientId,
    termsId,
    deliveryAddress,
    deliveryLocation,
    contractId,
    projectName,
    BuildContext context,
  ) async {
    try {
      editLoading = true;
      notifyListeners();
      String? response = await QuotationServices.editQuotation(
        quotationId,
        quotationNumber,
        quotationDate,
        clientId,
        termsId,
        deliveryAddress,
        deliveryLocation,
        contractId,
        projectName,
        getFormattedEditItems(),
      );
      if (response == null) {
        if (!context.mounted) return;
        showSuccessMessage(context, "Quotation Updated Successfully!");
        await getQuotationById(quotationId);
        await getAllQuotations();
        editItemList.clear();
        if (!context.mounted) return;
        pushReplacementNavigation(context, const ViewQuotation());
      } else {
        if (!context.mounted) return;
        showOverlayError(context, "Unable to Edit");
      }
    } catch (e) {
      print('Error editing quotation: $e');
    } finally {
      editLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteQuotationItem(
    quotationId,
    productTabId,
    BuildContext context,
  ) async {
    try {
      deleteQuotationItemLoader = true;
      notifyListeners();
      String? response = await QuotationServices.deleteQuotationItems(
          quotationId, productTabId);
      if (response == null) {
        if (!context.mounted) return;
        showSuccessMessage(context, "Quotation Item Deleted Successfully!");
        getAllQuotations();
        pushAndRemoveUntilFun(context, const QuotationMain());
      } else {
        if (!context.mounted) return;
        showOverlayError(context, response);
      }
    } catch (e) {
      print('Error deleting quotation item: $e');
    } finally {
      deleteQuotationItemLoader = false;
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

  List<Map<String, dynamic>> getFormattedEditItems() {
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

  Map<String, dynamic> buildContractJson() {
    if (contractInfoList.isEmpty) return {};
    final contract = contractInfoList.first;
    return {
      "title": contract.title,
      "sections": editableSectionsMap[contract.id]?.map((section) {
            return {
              "title": section.titleController.text.trim(),
              "points": section.points.map((point) {
                return {"points": point.controller.text.trim()};
              }).toList(),
            };
          }).toList() ??
          [],
    };
  }

  void updateItem(int itemNumber, String field, String value) {
    final item = itemList.firstWhere(
      (e) => e.itemNumber == itemNumber,
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

  void addEditItem(AddQuotationModel item) {
    editItemList.add(item);
    notifyListeners();
  }

  void updateEditItem(int itemNumber, String field, String value) {
    final item = editItemList.firstWhere(
      (e) => e.itemNumber == itemNumber,
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

  Future<void> deleteQuotationProduct(
    quotationId,
    productId,
    BuildContext context,
  ) async {
    try {
      deleteQuotationProdLoader = true;
      notifyListeners();
      String? response = await QuotationServices.deleteSingleQuotationProduct(
          quotationId, productId);
      if (response == null) {
        if (!context.mounted) return;
        showSuccessMessage(context, "Quotation Product Deleted Successfully!");
        await getQuotationById(quotationId);
      } else {
        if (!context.mounted) return;
        showOverlayError(context, response);
      }
    } catch (e) {
      print('Error deleting quotation product: $e');
    } finally {
      deleteQuotationProdLoader = false;
      notifyListeners();
    }
  }

  Future<void> getCompleteContractInfo(int contractId) async {
    try {
      getCompleteContractInfoLoading = true;
      notifyListeners();
      List<ContractInfoModel> info =
          await ContractService.getAllContractInfo(contractId);
      if (info.isNotEmpty) {
        contractInfoList = info;
        editablePointsMap.clear();
        editableSectionsMap.clear();
        for (var contract in contractInfoList) {
          editableSectionsMap[contract.id] = contract.sections.map((section) {
            return EditableSectionModel(
              id: section.id,
              title: section.title,
              points: section.points.map((point) {
                return EditablePointModel(
                  id: point.id,
                  section: point.section,
                  initialText: point.points,
                );
              }).toList(),
            );
          }).toList();
        }
      } else {
        contractInfoList.clear();
      }
    } catch (e) {
      print('Error fetching contract info: $e');
    } finally {
      getCompleteContractInfoLoading = false;
      notifyListeners();
    }
  }
}
