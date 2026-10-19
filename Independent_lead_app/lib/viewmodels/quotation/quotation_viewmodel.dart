import 'package:flutter/material.dart';
import 'package:pokakbilling/core/navigations.dart';
import 'package:pokakbilling/models/data-models/addQuotation_model.dart';
import 'package:pokakbilling/models/data-models/quotations-models/quotation_model.dart'
    hide AddProductQuotationModel;
import 'package:pokakbilling/models/services/quotation_services.dart';
import 'package:pokakbilling/viewmodels/setup/terms&condition_viewmodel.dart';
import 'package:pokakbilling/views/Screens/quotation/quotation_main.dart';
import 'package:pokakbilling/views/Screens/quotation/view/view_quotation.dart';
import 'package:pokakbilling/views/commonWidgets/response-message/error_message.dart';
import 'package:pokakbilling/views/commonWidgets/response-message/success-message.dart';
import 'package:provider/provider.dart';

class QuotationViewmodel extends ChangeNotifier {
  // ================= LOADING STATES =================
  bool addQuotationLoader = false;
  bool getQuotationLoader = false;
  bool deleteQuotationLoader = false;
  bool singleQuotationLoading = false;
  bool editLoading = false;
  bool deleteQuotationItemLoader = false;
  List<QuotationModel> filteredQuotationList = [];
  String? selectedQuotationNumber;
  int? selectedQuotationId;

  // ================= DATA =================
  List<QuotationModel> quotationList = [];
  QuotationModel? singleQuotation;
  List<AddProductQuotationModel> itemList = [];
  List<AddProductQuotationModel> editItemList = [];
  String grandTotal = "0.00";
  int selectedClientId = 0;
  String selectedClientName = "";
  int? selectedContractId = 0;
  String selectedContractName = "";
  int selectedLeadId = 0;
  String? errorMessage;

  // ================= CONSTRUCTOR =================
  QuotationViewmodel() {
    getAllQuotations();
  }

  void setSelectedQuotation(QuotationModel q) {
    selectedQuotationNumber = q.quotationNumber;
    selectedQuotationId = q.quotationId;
    notifyListeners();
  }

  void searchQuotation(String query) {
    final searchText = query.toLowerCase().trim();

    if (searchText.isEmpty) {
      filteredQuotationList = List.from(quotationList);
    } else {
      filteredQuotationList = quotationList.where((q) {
        final clientName = (q.clientName ?? '').toLowerCase();
        final clientDisplay = (q.clientNameDisplay ?? '').toLowerCase();
        return clientName.contains(searchText) ||
            clientDisplay.contains(searchText);
      }).toList();
    }

    notifyListeners();
  }

  // ======== filter ========================
  void filterQuotationByClient(int clientId) {
    selectedClientId = clientId;
    if (clientId == 0) {
      filteredQuotationList = quotationList;
    } else {
      filteredQuotationList =
          quotationList.where((q) => q.client == clientId).toList();
    }
    notifyListeners();
  }

  // ================= CLIENT =================
  void updateClientId(int id) {
    selectedClientId = id;
    notifyListeners();
  }

  void updateClientName(String name) {
    selectedClientName = name;
    notifyListeners();
  }

  // ================= CONTRACT =================
  void updateContractId(int? id) {
    selectedContractId = id;
    notifyListeners();
  }

  void updateContractName(String name) {
    selectedContractName = name;
    notifyListeners();
  }

  // ================= LEAD =================
  void updateLeadId(int id) {
    selectedLeadId = id;
    notifyListeners();
  }

  // ================= AUTO GENERATE QUOTATION NUMBER =================
  String generateNextQuotationNumber() {
    if (quotationList.isEmpty) {
      return "QU|100001";
    }

    int maxNumber = 0;

    for (final q in quotationList) {
      final number = q.quotationNumber;
      if (number.startsWith("QU|")) {
        final numPart = int.tryParse(number.substring(3)); // strip "QU|"
        if (numPart != null && numPart > maxNumber) {
          maxNumber = numPart;
        }
      }
    }

    final next = maxNumber + 1;
    // padLeft(6, '0') keeps it 6 digits; naturally extends beyond 6 if needed
    return "QU|${next.toString().padLeft(6, '0')}";
  }

  // ================= GRAND TOTAL =================
  double calculateGrandTotal(List<AddProductQuotationModel> list) {
    double total = 0.0;
    for (var item in list) {
      total += double.tryParse(item.subTotal) ?? 0.0;
    }
    return total;
  }

  void updateGrandTotal() {
    grandTotal = calculateGrandTotal(itemList).toStringAsFixed(2);
    notifyListeners();
  }

  void updateEditGrandTotal() {
    grandTotal = calculateGrandTotal(editItemList).toStringAsFixed(2);
    notifyListeners();
  }

  void resetGrandTotal() {
    grandTotal = "0.00";
    notifyListeners();
  }

  // ================= ADD ITEM (create mode) =================
  void addItem() {
    itemList.add(AddProductQuotationModel(
      itemNumber: itemList.length + 1,
    ));
    notifyListeners();
  }

  // ================= ADD ITEM (edit mode) =================
  void addEditItem() {
    editItemList.add(AddProductQuotationModel(
      itemNumber: editItemList.length + 1,
    ));
    notifyListeners();
  }

  void removeItem(int itemNumber) {
    itemList.removeWhere((item) => item.itemNumber == itemNumber);
    for (int i = 0; i < itemList.length; i++) {
      itemList[i].itemNumber = i + 1;
    }
    updateGrandTotal();
  }

  // ✅ Remove item from editItemList in edit mode
  void removeEditItem(int itemNumber) {
    editItemList.removeWhere((item) => item.itemNumber == itemNumber);
    for (int i = 0; i < editItemList.length; i++) {
      editItemList[i].itemNumber = i + 1;
    }
    updateEditGrandTotal();
  }

  void removeAll() {
    itemList.clear();
    editItemList.clear();
    resetGrandTotal();
  }

  // ====================For Invoice ===================
  double get calcSubtotal {
    double sum = 0;
    for (var item in itemList) {
      sum += double.tryParse(item.total) ?? 0;
    }
    return sum;
  }

  double get calcTax {
    double tax = 0;
    for (var item in itemList) {
      final total = double.tryParse(item.total) ?? 0;
      final cgst = double.tryParse(item.cgst) ?? 0;
      final sgst = double.tryParse(item.sgst) ?? 0;

      tax += (total * cgst / 100) + (total * sgst / 100);
    }
    return tax;
  }

  double get calcGrandTotal {
    return calcSubtotal + calcTax;
  }

  // ================= CREATE QUOTATION =================
  Future<void> createQuotation(
    String quotationNumber,
    String quotationDate,
    String projectName,
    String companyLocation,
    String companyAddress,
    BuildContext context,
  ) async {
    try {
      addQuotationLoader = true;
      notifyListeners();
      final termsVM = Provider.of<TermsViewModel>(context, listen: false);
      final selectedTermsId = termsVM.selectedTerms?.id;
      final response = await QuotationServices.createQuotation(
        quotationNumber,
        quotationDate,
        selectedClientId,
        projectName,
        companyLocation,
        companyAddress,
        getFormattedItems(),
        selectedContractId,
        terms: selectedTermsId,
      );

      if (response != null) {
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
    } finally {
      addQuotationLoader = false;
      notifyListeners();
    }
  }

  // ================= GET ALL =================
  Future<void> getAllQuotations() async {
    try {
      getQuotationLoader = true;
      notifyListeners();
      quotationList = await QuotationServices.getAllQuotations();
      filteredQuotationList = quotationList;
    } finally {
      getQuotationLoader = false;
      notifyListeners();
    }
  }

  // ================= GET SINGLE =================
  Future<void> getQuotationById(int quotationId) async {
    try {
      singleQuotationLoading = true;
      notifyListeners();

      final response = await QuotationServices.getQuotationById(quotationId);

      if (response != null) {
        singleQuotation = response;
        editItemList.clear();

        for (var item in singleQuotation!.items) {
          editItemList.add(
            AddProductQuotationModel(
              itemNumber: editItemList.length + 1,
              itemRowId: item.id, // ✅ row ID for delete
              productId: item.productId, // ✅ product ID for PATCH
              selectedProduct: item.productId.toString(),
              quantity: item.quantity.toString(),
              unitPrice: item.unitPrice,
              sgst: item.sgst,
              cgst: item.cgst,
              subTotal: item.total,
            ),
          );
        }

        updateEditGrandTotal();
      }
    } finally {
      singleQuotationLoading = false;
      notifyListeners();
    }
  }

  // ================= EDIT =================
  Future<void> editQuotation(
    int quotationId,
    String quotationNumber,
    String quotationDate,
    String projectName,
    String companyLocation,
    String companyAddress,
    BuildContext context,
  ) async {
    try {
      editLoading = true;
      notifyListeners();
      final termsVM = Provider.of<TermsViewModel>(context, listen: false);
      final selectedTermsId = termsVM.selectedTerms?.id;
      final response = await QuotationServices.editQuotation(
        quotationId,
        quotationNumber,
        quotationDate,
        selectedClientId,
        projectName,
        companyLocation,
        companyAddress,
        getFormattedEditItems(), // ✅ uses productId correctly
        selectedContractId,
        terms: selectedTermsId,
      );

      if (response == null) {
        await getQuotationById(quotationId);
        await getAllQuotations();
        if (!context.mounted) return;
        showSuccessMessage(context, "Quotation Updated Successfully!");
        pushReplacementNavigation(context, const ViewQuotation());
      } else {
        if (!context.mounted) return;
        showOverlayError(context, response);
      }
    } finally {
      editLoading = false;
      notifyListeners();
    }
  }

  // ================= DELETE QUOTATION =================
  Future<void> deleteQuotation(int quotationId, BuildContext context) async {
    try {
      deleteQuotationLoader = true;
      notifyListeners();

      final response = await QuotationServices.deleteQuotation(quotationId);

      if (response == null) {
        if (selectedQuotationId == quotationId) {
          selectedQuotationId = null;
          selectedQuotationNumber = null;
        }

        await getAllQuotations();
        if (!context.mounted) return;
        showSuccessMessage(context, "Quotation Deleted Successfully!");
        pushAndRemoveUntilFun(context, const QuotationMain());
      } else {
        if (!context.mounted) return;
        showOverlayError(context, response);
      }
    } finally {
      deleteQuotationLoader = false;
      notifyListeners();
    }
  }

  // ================= DELETE ITEM =================
  Future<void> deleteQuotationItem(
    int quotationId,
    int productId,
    BuildContext context,
  ) async {
    try {
      deleteQuotationItemLoader = true;
      notifyListeners();

      final response = await QuotationServices.deleteQuotationItem(
        quotationId,
        productId,
      );

      if (response == null) {
        await getQuotationById(quotationId);
        if (!context.mounted) return;
        showSuccessMessage(context, "Quotation Item Deleted Successfully!");
      } else {
        if (!context.mounted) return;
        showOverlayError(context, response);
      }
    } finally {
      deleteQuotationItemLoader = false;
      notifyListeners();
    }
  }

  // ================= UPDATE ITEM (create mode) =================
  void updateItem(int itemNumber, String field, String value) {
    final item = itemList.firstWhere(
      (element) => element.itemNumber == itemNumber,
      orElse: () => AddProductQuotationModel(itemNumber: itemNumber),
    );
    _applyField(item, field, value);
    updateGrandTotal();
    notifyListeners();
  }

  // ================= UPDATE EDIT ITEM (edit mode) =================
  void updateEditItem(int itemNumber, String field, String value) {
    final item = editItemList.firstWhere(
      (element) => element.itemNumber == itemNumber,
      orElse: () => AddProductQuotationModel(itemNumber: itemNumber),
    );
    _applyField(item, field, value);
    updateEditGrandTotal();
    notifyListeners();
  }

  void _applyField(AddProductQuotationModel item, String field, String value) {
    switch (field) {
      case "selectedProduct":
        item.selectedProduct = value;
        item.productId = int.tryParse(value) ?? 0;
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
  }

  // ================= FORMAT ITEMS =================
  List<Map<String, dynamic>> getFormattedItems() {
    return itemList.map((item) {
      return {
        "product_id": int.tryParse(item.selectedProduct) ?? 0,
        "quantity": int.tryParse(item.quantity) ?? 0,
        "unit_price": double.tryParse(item.unitPrice) ?? 0.0,
        "sgst_percentage": double.tryParse(item.sgst) ?? 0.0,
        "cgst_percentage": double.tryParse(item.cgst) ?? 0.0,
      };
    }).toList();
  }

  // ✅ FIXED: uses item.productId (the actual product), not item.tabId
  List<Map<String, dynamic>> getFormattedEditItems() {
    return editItemList.map((item) {
      return {
        "product_id": item.productId, // ✅ correct: actual product ID
        "quantity": int.tryParse(item.quantity) ?? 0,
        "unit_price": double.tryParse(item.unitPrice) ?? 0.0,
        "sgst_percentage": double.tryParse(item.sgst) ?? 0.0,
        "cgst_percentage": double.tryParse(item.cgst) ?? 0.0,
      };
    }).toList();
  }

  void reset() {
    // clear your quotation lists and loading flags
    notifyListeners();
  }
}
