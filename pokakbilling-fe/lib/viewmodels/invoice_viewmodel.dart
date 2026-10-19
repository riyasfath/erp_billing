// lib/viewmodels/invoice_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:pokakbilling/models/data-models/invoice/invoice_model.dart';
import 'package:pokakbilling/models/services/invoice_service.dart';
import 'package:pokakbilling/views/commonWidgets/response-message/error_message.dart';
import 'package:pokakbilling/views/commonWidgets/response-message/success-message.dart';

class InvoiceViewmodel extends ChangeNotifier {
  // ── loaders ────────────────────────────────────────────────────────────────
  bool getInvoiceLoader = false;
  bool createInvoiceLoader = false;
  bool editInvoiceLoader = false;

  // ── data ───────────────────────────────────────────────────────────────────
  List<InvoiceModel> invoiceList = [];

  // ── lifecycle ──────────────────────────────────────────────────────────────
  InvoiceViewmodel() {
    getAllInvoices();
  }

  void clearData() {
    invoiceList = [];
    getInvoiceLoader = false;
    createInvoiceLoader = false;
    editInvoiceLoader = false;
    notifyListeners();
  }

  // ── GET ALL ────────────────────────────────────────────────────────────────
  Future<void> getAllInvoices() async {
    try {
      getInvoiceLoader = true;
      notifyListeners();

      final list = await InvoiceServices.getAllInvoices();
      invoiceList = list;
    } catch (e) {
      debugPrint('Error fetching invoices: $e');
      invoiceList = [];
    } finally {
      getInvoiceLoader = false;
      notifyListeners();
    }
  }

  // ── CREATE CLIENT INVOICE ──────────────────────────────────────────────────
  Future<void> createClientInvoice({
    required String invoiceNumber,
    required String invoiceDate,
    required int clientId,
    required List<Map<String, dynamic>> items,
    required String remark,
    required BuildContext context,
    required VoidCallback onSuccess,
    int? termsAndConditions,
  }) async {
    try {
      createInvoiceLoader = true;
      notifyListeners();

      final error = await InvoiceServices.createClientInvoice(
        invoiceNumber: invoiceNumber,
        invoiceDate: invoiceDate,
        clientId: clientId,
        items: items,
        remark: remark,
        termsAndConditions: termsAndConditions,
      );

      if (!context.mounted) return;

      if (error == null) {
        showSuccessMessage(context, 'Invoice created successfully!');
        await getAllInvoices();
        onSuccess();
      } else {
        showOverlayError(context, error);
      }
    } catch (e) {
      debugPrint('Error creating client invoice: $e');
      if (context.mounted) showOverlayError(context, 'Something went wrong.');
    } finally {
      createInvoiceLoader = false;
      notifyListeners();
    }
  }

  // ── CREATE INTERN INVOICE ──────────────────────────────────────────────────
  Future<void> createInternInvoice({
    required String invoiceNumber,
    required String invoiceDate,
    required int studentId,
    required int courseId,
    required String feeAmount,
    required String sgstPercentage,
    required String cgstPercentage,
    required String remark,
    required String description,
    required BuildContext context,
    required VoidCallback onSuccess,
    int? termsAndConditions,
  }) async {
    try {
      createInvoiceLoader = true;
      notifyListeners();

      final error = await InvoiceServices.createInternInvoice(
        invoiceNumber: invoiceNumber,
        invoiceDate: invoiceDate,
        studentId: studentId,
        courseId: courseId,
        feeAmount: feeAmount,
        sgstPercentage: sgstPercentage,
        cgstPercentage: cgstPercentage,
        remark: remark,
        description: description,
        termsAndConditions: termsAndConditions,
      );

      if (!context.mounted) return;

      if (error == null) {
        showSuccessMessage(context, 'Invoice created successfully!');
        await getAllInvoices();
        onSuccess();
      } else {
        showOverlayError(context, error);
      }
    } catch (e) {
      debugPrint('Error creating intern invoice: $e');
      if (context.mounted) showOverlayError(context, 'Something went wrong.');
    } finally {
      createInvoiceLoader = false;
      notifyListeners();
    }
  }

  // ── EDIT CLIENT INVOICE ────────────────────────────────────────────────────
  Future<void> editClientInvoice(
    int invoiceId, {
    required List<Map<String, dynamic>> items,
    required String remark,
    required BuildContext context,
    required VoidCallback onSuccess,
  }) async {
    try {
      editInvoiceLoader = true;
      notifyListeners();

      final error = await InvoiceServices.editClientInvoice(
        invoiceId,
        items: items,
        remark: remark,
      );

      if (!context.mounted) return;

      if (error == null) {
        showSuccessMessage(context, 'Invoice updated successfully!');
        await getAllInvoices();
        onSuccess();
      } else {
        showOverlayError(context, error);
      }
    } catch (e) {
      debugPrint('Error editing client invoice: $e');
      if (context.mounted) showOverlayError(context, 'Something went wrong.');
    } finally {
      editInvoiceLoader = false;
      notifyListeners();
    }
  }

  // ── EDIT INTERN INVOICE ────────────────────────────────────────────────────
  Future<void> editInternInvoice(
    int invoiceId, {
    required String feeAmount,
    required String sgstPercentage,
    required String cgstPercentage,
    required String remark,
    required BuildContext context,
    required VoidCallback onSuccess,
  }) async {
    try {
      editInvoiceLoader = true;
      notifyListeners();

      final error = await InvoiceServices.editInternInvoice(
        invoiceId,
        feeAmount: feeAmount,
        sgstPercentage: sgstPercentage,
        cgstPercentage: cgstPercentage,
        remark: remark,
      );

      if (!context.mounted) return;

      if (error == null) {
        showSuccessMessage(context, 'Invoice updated successfully!');
        await getAllInvoices();
        onSuccess();
      } else {
        showOverlayError(context, error);
      }
    } catch (e) {
      debugPrint('Error editing intern invoice: $e');
      if (context.mounted) showOverlayError(context, 'Something went wrong.');
    } finally {
      editInvoiceLoader = false;
      notifyListeners();
    }
  }
}
