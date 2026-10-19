import 'package:flutter/material.dart';
import 'package:pokakbilling/core/navigations.dart';
import 'package:pokakbilling/models/data-models/receipt_model.dart';
import 'package:pokakbilling/models/services/receipt_services.dart';
import 'package:pokakbilling/views/Screens/receipt/receipt_main.dart';
import 'package:pokakbilling/views/commonWidgets/response-message/error_message.dart';
import 'package:pokakbilling/views/commonWidgets/response-message/success-message.dart';

class ReceiptViewmodel extends ChangeNotifier {
  bool getInvoiceLoader = false;
  bool addReceiptLoading = false;
  bool getReceiptLoader = false;
  bool singleReceiptLoading = false;
  bool editReceiptLoading = false;
  var invoiceList = <InvoiceModel>[];
  var receiptList = <ReceiptModel>[];
  var singleReceiptList = <SingleReceiptModel>[];
  int selectedClientId = 0;
  int selectedInvoiceId = 0;
  int selectedTermsId = 0;

  ReceiptViewmodel() {
    getAllInvoice();
    getAllReceipts();
  }

  // ✅ Call this on logout to wipe stale data
  void clearData() {
    invoiceList = [];
    receiptList = [];
    singleReceiptList = [];
    selectedClientId = 0;
    selectedInvoiceId = 0;
    selectedTermsId = 0;
    getInvoiceLoader = false;
    addReceiptLoading = false;
    getReceiptLoader = false;
    singleReceiptLoading = false;
    editReceiptLoading = false;
    notifyListeners();
  }

  void updateClientId(int value) {
    selectedClientId = value;
    notifyListeners();
  }

  void updateInvoiceId(int value) {
    selectedInvoiceId = value;
    notifyListeners();
  }

  void updateTermsId(int value) {
    selectedTermsId = value;
    notifyListeners();
  }

  Future<void> getAllInvoice() async {
    try {
      getInvoiceLoader = true;
      notifyListeners();
      List<InvoiceModel> invoiceItems = await ReceiptServices.getInvoice();
      if (invoiceItems.isNotEmpty) {
        invoiceList = invoiceItems;
      } else {
        invoiceList.clear();
      }
    } catch (e) {
      print(e);
    } finally {
      getInvoiceLoader = false;
      notifyListeners();
    }
  }

  Future<void> createReceipt(
    receiptNumber,
    receiptDate,
    clientId,
    invoiceId,
    termsId,
    remark,
    BuildContext context,
  ) async {
    try {
      addReceiptLoading = true;
      notifyListeners();

      var response = await ReceiptServices.createReceipt(
        receiptNumber,
        receiptDate,
        clientId,
        invoiceId,
        termsId,
        remark,
      );

      if (response != 0 && response != null) {
        if (!context.mounted) return;
        showSuccessMessage(context, "Receipt Created Successfully!");
        await getAllReceipts();
        if (!context.mounted) return;
        pushReplacementNavigation(context, const ReceiptMain());
      } else {
        if (!context.mounted) return;
        showOverlayError(context, "Unable to create");
      }
    } catch (e) {
      print(e);
    } finally {
      addReceiptLoading = false;
      notifyListeners();
    }
  }

  Future<void> getAllReceipts() async {
    try {
      getReceiptLoader = true;
      notifyListeners();
      List<ReceiptModel> receiptItems = await ReceiptServices.getAllReceipt();
      if (receiptItems.isNotEmpty) {
        receiptList = receiptItems;
      } else {
        receiptList.clear();
      }
    } catch (e) {
      print(e);
    } finally {
      getReceiptLoader = false;
      notifyListeners();
    }
  }

  Future<void> getReceiptById(receiptId) async {
    try {
      singleReceiptLoading = true;
      notifyListeners();
      List<SingleReceiptModel> receiptItems =
          await ReceiptServices.getReceiptById(receiptId);
      if (receiptItems.isNotEmpty) {
        singleReceiptList = receiptItems;
      } else {
        singleReceiptList.clear();
      }
    } catch (e) {
      print(e);
    } finally {
      singleReceiptLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateReceipt(
    receiptId,
    receiptNumber,
    receiptDate,
    clientId,
    invoiceId,
    termsId,
    remark,
    BuildContext context,
  ) async {
    try {
      editReceiptLoading = true;
      notifyListeners();

      var response = await ReceiptServices.updateReceipt(
        receiptId,
        receiptNumber,
        receiptDate,
        clientId,
        invoiceId,
        termsId,
        remark,
      );

      if (response == null) {
        if (!context.mounted) return;
        showSuccessMessage(context, "Receipt Edited Successfully!");
        await getAllReceipts();
        if (!context.mounted) return;
        pushReplacementNavigation(context, const ReceiptMain());
      } else {
        if (!context.mounted) return;
        showOverlayError(context, "Unable to Edit");
      }
    } catch (e) {
      print(e);
    } finally {
      editReceiptLoading = false;
      notifyListeners();
    }
  }
}
