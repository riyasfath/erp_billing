// import 'package:flutter/material.dart';
// import 'package:pokakbilling/models/data-models/invoice-model/invoice-model.dart'
//     show InvoiceModel, ProductItemModel;
// import 'package:pokakbilling/models/services/invoice_service.dart';
// import 'package:pokakbilling/views/commonWidgets/response-message/error_message.dart';
// import 'package:pokakbilling/views/commonWidgets/response-message/success-message.dart';

// class InvoiceViewModel extends ChangeNotifier {
//   // ================= LOADING =================
//   bool isLoading = false;
//   bool createLoading = false;
//   bool editLoading = false;
//   bool deleteLoading = false;

//   int activeCount = 0;
//   int draftCount = 0;
//   int cancelCount = 0;

//   // ================= DATA =================
//   List<InvoiceModel> invoiceList = [];
//   InvoiceModel? singleInvoice;
//   String? errorMessage;
//   List<InvoiceModel> _allInvoices = []; // original data

//   void setInvoices(List<InvoiceModel> data) {
//     // ✅ Sort latest first
//     data.sort((a, b) {
//       // If createdAt exists
//       if (a.createdAt != null && b.createdAt != null) {
//         return DateTime.parse(b.createdAt!)
//             .compareTo(DateTime.parse(a.createdAt!));
//       }

//       // ✅ fallback: sort by ID
//       return (b.id ?? 0).compareTo(a.id ?? 0);
//     });

//     _allInvoices = data;
//     invoiceList = data;
//     notifyListeners();
//   }

// // ============== for search ==============
//   void searchInvoice(String query) {
//     if (query.isEmpty) {
//       invoiceList = _allInvoices;
//     } else {
//       final q = query.toLowerCase();

//       invoiceList = _allInvoices.where((inv) {
//         final name = (inv.clientNameDisplay ?? "").toLowerCase();
//         final number = (inv.invoiceNumber ?? "").toLowerCase();

//         return name.contains(q) || number.contains(q);
//       }).toList();
//     }

//     notifyListeners();
//   }

// //   // ================= PRODUCT ITEMS =================
//   List<ProductItemModel> itemList = [];
//   List<ProductItemModel> editItemList = [];

// //   // ================= FORMAT ITEMS (CREATE) =================
//   List<Map<String, dynamic>> getFormattedItems() {
//     return itemList.map((item) {
//       return {
//         "product_id": item.productId,
//         "quantity": int.tryParse(item.quantity) ?? 0,
//         "unit_price": double.tryParse(item.unitPrice) ?? 0,
//         "sgst": double.tryParse(item.sgst) ?? 0,
//         "cgst": double.tryParse(item.cgst) ?? 0,
//       };
//     }).toList();
//   }

// //   // ================= FORMAT ITEMS (EDIT) =================
//   List<Map<String, dynamic>> getFormattedEditItems() {
//     return editItemList.map((item) {
//       return {
//         "item_row_id": item.itemRowId, // ✅ VERY IMPORTANT
//         "product_id": item.productId,
//         "quantity": int.tryParse(item.quantity) ?? 0,
//         "unit_price": double.tryParse(item.unitPrice) ?? 0,
//         "sgst": double.tryParse(item.sgst) ?? 0,
//         "cgst": double.tryParse(item.cgst) ?? 0,
//       };
//     }).toList();
//   }

// // ================= PREFILL HELPER =================
//   void setEditDataToControllers({
//     required InvoiceModel invoice,
//     required TextEditingController invoiceNumber,
//     required TextEditingController invoiceDate,
//     required TextEditingController dueDate,
//     required TextEditingController project,
//     required TextEditingController address,
//     required TextEditingController location,
//     required TextEditingController paidAmount,
//     required TextEditingController notes,
//     required Function(String?) setType,
//     required Function(String?) setStatus,
//     required Function(String?) setPaymentStatus,
//     required Function(String?) setPaymentMethod,
//   }) {
//     invoiceNumber.text = invoice.invoiceNumber ?? "";
//     invoiceDate.text = invoice.date ?? "";
//     dueDate.text = invoice.dueDate ?? "";
//     project.text = invoice.projectName ?? "";
//     address.text = invoice.companyAddress ?? "";
//     location.text = invoice.companyLocation ?? "";
//     paidAmount.text = invoice.paidAmount ?? "0";
//     notes.text = invoice.notes ?? "";

//     /// ✅ FIX 1: Invoice Type (API → UI)
//     switch (invoice.invoiceType) {
//       case "SALES":
//         setType("Sales Invoice");
//         break;
//       case "PURCHASE":
//         setType("Purchase Invoice");
//         break;
//       case "CREDIT_NOTE":
//         setType("Credit Note");
//         break;
//       default:
//         setType("Sales Invoice");
//     }

//     /// ✅ FIX 2: Status (already matching usually)
//     setStatus(invoice.status);

//     /// ✅ FIX 3: Payment Status (IMPORTANT FIX)
//     switch (invoice.paymentStatus) {
//       case "UNPAID":
//         setPaymentStatus("Unpaid");
//         break;
//       case "PARTIAL":
//         setPaymentStatus("Partial");
//         break;
//       case "PAID":
//         setPaymentStatus("Paid");
//         break;
//       default:
//         setPaymentStatus("Unpaid");
//     }

//     /// ✅ FIX 4: Payment Method (optional safety)
//     setPaymentMethod(invoice.paymentMethod ?? "Bank Transfer");
//   }

//   // ================= GET ALL =================
//   // Future<void> getAllInvoices() async {
//   //   try {
//   //     isLoading = true;
//   //     notifyListeners();

//   //     final data = await InvoiceServices.getInvoices();

//   //     /// ✅ Use setter
//   //     setInvoices(data);
//   //   } catch (e) {
//   //     errorMessage = e.toString();
//   //   } finally {
//   //     isLoading = false;
//   //     notifyListeners();
//   //   }
//   // }
//   Future<void> getAllInvoices({
//     String? status,
//   }) async {
//     try {
//       isLoading = true;
//       notifyListeners();

//       final data = await InvoiceServices.getInvoices(
//         status: status,
//       );

//       invoiceList = data;

//       /// UPDATE COUNTS
//       if (status == "FINAL") {
//         activeCount = data.length;
//       }

//       if (status == "DRAFT") {
//         draftCount = data.length;
//       }

//       if (status == "CANCELLED") {
//         cancelCount = data.length;
//       }
//     } catch (e) {
//       errorMessage = e.toString();
//     } finally {
//       isLoading = false;
//       notifyListeners();
//     }
//   }

//   // ================= GET BY ID =================
//   Future<void> getInvoiceById(int id) async {
//     try {
//       isLoading = true;
//       notifyListeners();

//       singleInvoice = await InvoiceServices.getInvoiceById(id);
//       editItemList = List<ProductItemModel>.from(singleInvoice!.items);
//     } finally {
//       isLoading = false;
//       notifyListeners();
//     }
//   }

// // ================= CREATE =================
//   Future<void> createInvoice({
//     required String invoiceNumber,
//     required String date,
//     required String dueDate,
//     required String projectName,
//     required String location,
//     required String address,
//     required int clientId,
//     required int? quotationId,
//     required String invoiceType,
//     required String status,
//     required String paymentStatus,
//     required String paymentMethod,
//     required String paidAmount,
//     required String notes,
//     required String terms,
//     required List<Map<String, dynamic>> items,
//     required BuildContext context,
//   }) async {
//     createLoading = true;
//     notifyListeners();

//     try {
//       if (items.isEmpty) {
//         showOverlayError(context, "Add at least one product");
//         return;
//       }

//       final data = {
//         "invoice_number": invoiceNumber,
//         "date": date,
//         "due_date": dueDate,
//         "project_name": projectName,
//         "company_location": location,
//         "company_address": address,
//         "client": clientId,
//         "quotation": quotationId,
//         "invoice_type": invoiceType,
//         "status": status,
//         "payment_status": paymentStatus,
//         "payment_method": paymentMethod,
//         "paid_amount": paidAmount,
//         "notes": notes,
//         "terms_and_conditions": terms,

//         // // ✅ IMPORTANT
//         // "subtotal": subTotal,
//         // "tax_total": taxTotal,
//         // "grand_total": grandTotal,

//         "items": items,
//       };

//       final res = await InvoiceServices.createInvoice(data);

//       if (res == null) {
//         showSuccessMessage(context, "Invoice Created Successfully");

//         // itemList.clear();
//         // subTotal = 0;
//         // taxTotal = 0;
//         // grandTotal = 0;

//         await getAllInvoices();
//       } else {
//         showOverlayError(context, res);
//       }
//     } finally {
//       createLoading = false;
//       notifyListeners();
//     }
//   }

//   // ================= EDIT =================
//   Future<void> editInvoice({
//     required int id,
//     required String invoiceNumber,
//     required String date,
//     required String dueDate,
//     required String projectName,
//     required String location,
//     required String address,
//     required int clientId,
//     required int? quotationId,
//     required String invoiceType,
//     required String status,
//     required String paymentStatus,
//     required String paymentMethod,
//     required String paidAmount,
//     required String notes,
//     required String terms,
//     required List<Map<String, dynamic>> items,
//     required BuildContext context,
//   }) async {
//     editLoading = true;
//     notifyListeners();

//     try {
//       if (items.isEmpty) {
//         showOverlayError(context, "Add at least one product");
//         return;
//       }

//       final data = {
//         "invoice_number": invoiceNumber,
//         "date": date,
//         "due_date": dueDate,
//         "project_name": projectName,
//         "company_location": location,
//         "company_address": address,
//         "client": clientId,
//         "quotation": quotationId,
//         "invoice_type": invoiceType,
//         "status": status,
//         "payment_status": paymentStatus,
//         "payment_method": paymentMethod,
//         "paid_amount": paidAmount,
//         "notes": notes,
//         "terms_and_conditions": terms,

//         // // ✅ IMPORTANT
//         // "subtotal": subTotal,
//         // "tax_total": taxTotal,
//         // "grand_total": grandTotal,

//         "items": items,
//       };

//       final res = await InvoiceServices.editInvoice(id, data);

//       if (res == null) {
//         showSuccessMessage(context, "Invoice Updated Successfully");

//         // editItemList.clear();
//         // subTotal = 0;
//         // taxTotal = 0;
//         // grandTotal = 0;

//         await getAllInvoices();
//       } else {
//         showOverlayError(context, res);
//       }
//     } finally {
//       editLoading = false;
//       notifyListeners();
//     }
//   }

//   // ================= DELETE =================
//   Future<void> deleteInvoice(int id, BuildContext context) async {
//     try {
//       deleteLoading = true;
//       notifyListeners();

//       final response = await InvoiceServices.deleteInvoice(id);

//       if (response == null) {
//         showSuccessMessage(context, "Invoice Deleted Successfully");
//         await getAllInvoices();
//       } else {
//         showOverlayError(context, response);
//       }
//     } finally {
//       deleteLoading = false;
//       notifyListeners();
//     }
//   }
// }
import 'package:flutter/material.dart';
import 'package:pokakbilling/models/data-models/invoice-model/invoice-model.dart'
    show InvoiceModel, ProductItemModel;
import 'package:pokakbilling/models/services/invoice_service.dart';
import 'package:pokakbilling/views/commonWidgets/response-message/error_message.dart';
import 'package:pokakbilling/views/commonWidgets/response-message/success-message.dart';

class InvoiceViewModel extends ChangeNotifier {
  // ================= LOADING =================
  bool isLoading = false;
  bool createLoading = false;
  bool editLoading = false;
  bool deleteLoading = false;

  int activeCount = 0;
  int draftCount = 0;
  int cancelCount = 0;

  // ================= DATA =================
  List<InvoiceModel> invoiceList = [];
  InvoiceModel? singleInvoice;
  String? errorMessage;
  List<InvoiceModel> _allInvoices = [];

  void reset() {
    invoiceList = [];
    _allInvoices = [];
    singleInvoice = null;
    itemList = [];
    editItemList = [];
    activeCount = 0;
    draftCount = 0;
    cancelCount = 0;
    isLoading = false;
    createLoading = false;
    editLoading = false;
    deleteLoading = false;
    errorMessage = null;
    notifyListeners();
  }

  void setInvoices(List<InvoiceModel> data) {
    data.sort((a, b) {
      if (a.createdAt != null && b.createdAt != null) {
        return DateTime.parse(b.createdAt!)
            .compareTo(DateTime.parse(a.createdAt!));
      }
      return (b.id ?? 0).compareTo(a.id ?? 0);
    });

    _allInvoices = data;
    invoiceList = data;
    notifyListeners();
  }

  void searchInvoice(String query) {
    if (query.isEmpty) {
      invoiceList = _allInvoices;
    } else {
      final q = query.toLowerCase();
      invoiceList = _allInvoices.where((inv) {
        final name = (inv.clientNameDisplay ?? "").toLowerCase();
        final number = (inv.invoiceNumber ?? "").toLowerCase();
        return name.contains(q) || number.contains(q);
      }).toList();
    }
    notifyListeners();
  }

  List<ProductItemModel> itemList = [];
  List<ProductItemModel> editItemList = [];

  List<Map<String, dynamic>> getFormattedItems() {
    return itemList.map((item) {
      return {
        "product_id": item.productId,
        "quantity": int.tryParse(item.quantity) ?? 0,
        "unit_price": double.tryParse(item.unitPrice) ?? 0,
        "sgst": double.tryParse(item.sgst) ?? 0,
        "cgst": double.tryParse(item.cgst) ?? 0,
      };
    }).toList();
  }

  List<Map<String, dynamic>> getFormattedEditItems() {
    return editItemList.map((item) {
      return {
        "item_row_id": item.itemRowId,
        "product_id": item.productId,
        "quantity": int.tryParse(item.quantity) ?? 0,
        "unit_price": double.tryParse(item.unitPrice) ?? 0,
        "sgst": double.tryParse(item.sgst) ?? 0,
        "cgst": double.tryParse(item.cgst) ?? 0,
      };
    }).toList();
  }

  void setEditDataToControllers({
    required InvoiceModel invoice,
    required TextEditingController invoiceNumber,
    required TextEditingController invoiceDate,
    required TextEditingController dueDate,
    required TextEditingController project,
    required TextEditingController address,
    required TextEditingController location,
    required TextEditingController paidAmount,
    required TextEditingController notes,
    required Function(String?) setType,
    required Function(String?) setStatus,
    required Function(String?) setPaymentStatus,
    required Function(String?) setPaymentMethod,
  }) {
    invoiceNumber.text = invoice.invoiceNumber ?? "";
    invoiceDate.text = invoice.date ?? "";
    dueDate.text = invoice.dueDate ?? "";
    project.text = invoice.projectName ?? "";
    address.text = invoice.companyAddress ?? "";
    location.text = invoice.companyLocation ?? "";
    paidAmount.text = invoice.paidAmount ?? "0";
    notes.text = invoice.notes ?? "";

    switch (invoice.invoiceType) {
      case "SALES":
        setType("Sales Invoice");
        break;
      case "PURCHASE":
        setType("Purchase Invoice");
        break;
      case "CREDIT_NOTE":
        setType("Credit Note");
        break;
      default:
        setType("Sales Invoice");
    }

    setStatus(invoice.status);

    switch (invoice.paymentStatus) {
      case "UNPAID":
        setPaymentStatus("Unpaid");
        break;
      case "PARTIAL":
        setPaymentStatus("Partial");
        break;
      case "PAID":
        setPaymentStatus("Paid");
        break;
      default:
        setPaymentStatus("Unpaid");
    }

    setPaymentMethod(invoice.paymentMethod ?? "Bank Transfer");
  }

  Future<void> getAllInvoices({String? status}) async {
    try {
      isLoading = true;
      notifyListeners();

      final data = await InvoiceServices.getInvoices(status: status);
      invoiceList = data;

      if (status == "FINAL") activeCount = data.length;
      if (status == "DRAFT") draftCount = data.length;
      if (status == "CANCELLED") cancelCount = data.length;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getInvoiceById(int id) async {
    try {
      isLoading = true;
      notifyListeners();
      singleInvoice = await InvoiceServices.getInvoiceById(id);
      editItemList = List<ProductItemModel>.from(singleInvoice!.items);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createInvoice({
    required String invoiceNumber,
    required String date,
    required String dueDate,
    required String projectName,
    required String location,
    required String address,
    required int clientId,
    required int? quotationId,
    required String invoiceType,
    required String status,
    required String paymentStatus,
    required String paymentMethod,
    required String paidAmount,
    required String notes,
    required String terms,
    required List<Map<String, dynamic>> items,
    required BuildContext context,
  }) async {
    createLoading = true;
    notifyListeners();

    try {
      if (items.isEmpty) {
        showOverlayError(context, "Add at least one product");
        return;
      }

      final data = {
        "invoice_number": invoiceNumber,
        "date": date,
        "due_date": dueDate,
        "project_name": projectName,
        "company_location": location,
        "company_address": address,
        "client": clientId,
        "quotation": quotationId,
        "invoice_type": invoiceType,
        "status": status,
        "payment_status": paymentStatus,
        "payment_method": paymentMethod,
        "paid_amount": paidAmount,
        "notes": notes,
        "terms_and_conditions": terms,
        "items": items,
      };

      final res = await InvoiceServices.createInvoice(data);

      if (res == null) {
        showSuccessMessage(context, "Invoice Created Successfully");
        await getAllInvoices();
      } else {
        showOverlayError(context, res);
      }
    } finally {
      createLoading = false;
      notifyListeners();
    }
  }

  Future<void> editInvoice({
    required int id,
    required String invoiceNumber,
    required String date,
    required String dueDate,
    required String projectName,
    required String location,
    required String address,
    required int clientId,
    required int? quotationId,
    required String invoiceType,
    required String status,
    required String paymentStatus,
    required String paymentMethod,
    required String paidAmount,
    required String notes,
    required String terms,
    required List<Map<String, dynamic>> items,
    required BuildContext context,
  }) async {
    editLoading = true;
    notifyListeners();

    try {
      if (items.isEmpty) {
        showOverlayError(context, "Add at least one product");
        return;
      }

      final data = {
        "invoice_number": invoiceNumber,
        "date": date,
        "due_date": dueDate,
        "project_name": projectName,
        "company_location": location,
        "company_address": address,
        "client": clientId,
        "quotation": quotationId,
        "invoice_type": invoiceType,
        "status": status,
        "payment_status": paymentStatus,
        "payment_method": paymentMethod,
        "paid_amount": paidAmount,
        "notes": notes,
        "terms_and_conditions": terms,
        "items": items,
      };

      final res = await InvoiceServices.editInvoice(id, data);

      if (res == null) {
        showSuccessMessage(context, "Invoice Updated Successfully");
        await getAllInvoices();
      } else {
        showOverlayError(context, res);
      }
    } finally {
      editLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteInvoice(int id, BuildContext context) async {
    try {
      deleteLoading = true;
      notifyListeners();
      final response = await InvoiceServices.deleteInvoice(id);
      if (response == null) {
        showSuccessMessage(context, "Invoice Deleted Successfully");
        await getAllInvoices();
      } else {
        showOverlayError(context, response);
      }
    } finally {
      deleteLoading = false;
      notifyListeners();
    }
  }
}
