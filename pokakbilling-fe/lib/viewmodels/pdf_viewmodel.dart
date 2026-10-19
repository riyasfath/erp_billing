import 'package:flutter/material.dart';
import 'package:pokakbilling/models/data-models/delivery-models/delivery_pdf_model.dart';
import 'package:pokakbilling/models/data-models/material_receive/mr_items_model.dart';
import 'package:pokakbilling/models/data-models/purchase-order-models/purchase_order_items_model.dart';
import 'package:pokakbilling/models/data-models/quotations-models/pdf_model.dart';
import 'package:pokakbilling/models/data-models/receipt/receipt_pdf_model.dart';
import 'package:pokakbilling/models/data-models/sales-order-models/salesorder_pdf_model.dart';
import 'package:pokakbilling/models/services/pdf_services.dart';

class PdfViewmodel with ChangeNotifier {
  List<QuotationPdfModel> _quotationList = [];
  bool _isLoading = false;
  List<QuotationPdfModel> get quotationList => _quotationList;
  bool get isLoading => _isLoading;

  // Sales Order
  List<SalesOrderPdfModel> _salesorderList = [];
  bool _issalesorderLoading = false;

  List<SalesOrderPdfModel> get salesorderList => _salesorderList;
  bool get issalesorderLoading => _issalesorderLoading;

  List<PurchaseOrderItemsModel> purchaseOrderList = [];
  bool _isPurchaseOrderLoading = false;
  bool get isPurchaseOrderLoading => _isPurchaseOrderLoading;

  List<MaterialReceiveItemModel> materialReceiveList = [];
  final bool _isMaterialReceiveLoading = false;
  bool get isMaterialReceiveLoading => _isMaterialReceiveLoading;

  List<DeliveryPdfModel> _deliveryOrderList = [];
  bool _isDeliveryOrderLoading = false;
  List<DeliveryPdfModel> get deliveryOrderList => _deliveryOrderList;
  bool get isDeliveryOrderLoading => _isDeliveryOrderLoading;

  List<ReceiptPdfModel> _receiptList = [];
  bool _isReceiptLoading = false;

  List<ReceiptPdfModel> get receiptList => _receiptList;
  bool get isReceiptLoading => _isReceiptLoading;

  Future<void> fetchQuotationPdf(int quotationPdfId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _quotationList = await PdfServices.getQuotationPdf(quotationPdfId);
    } catch (e) {
      _quotationList = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sales Order PDF fetch
  Future<void> fetchSalesorderPdf(int salesorderPdfId) async {
    _issalesorderLoading = true;
    notifyListeners();
    try {
      _salesorderList = await PdfServices.getSalesorderPdf(salesorderPdfId);
    } catch (e) {
      _salesorderList = [];
    } finally {
      _issalesorderLoading = false;
      notifyListeners();
    }
  }

  // Purchase Order PDF fetch
  Future<void> fetchPurchaseOrderPdf(int purchaseOrderId) async {
    _isPurchaseOrderLoading = true;
    notifyListeners();

    try {
      purchaseOrderList =
          await PdfServices.getPurchaseOrderPdf(purchaseOrderId);
    } catch (e) {
      purchaseOrderList = [];
    } finally {
      _isPurchaseOrderLoading = false;
      notifyListeners();
    }
  }

  // // Material Receive PDF fetch
  // Future<void> fetchMaterialReceivePdf(int mrId) async {
  //   _isMaterialReceiveLoading = true;
  //   notifyListeners();

  //   try {
  //     materialReceiveList = await PdfServices.getMaterialReceivePdf(mrId);
  //   } catch (e) {
  //     materialReceiveList = [];
  //   } finally {
  //     _isMaterialReceiveLoading = false;
  //     notifyListeners();
  //   }
  // }

  Future<void> fetchDeliveryOrderPdf(int deliveryOrderId) async {
    _isDeliveryOrderLoading = true;
    notifyListeners();
    try {
      _deliveryOrderList = await PdfServices.getDeliveryPdf(deliveryOrderId);
      print("Fetched Delivery Order List: $_deliveryOrderList");
    } catch (e) {
      print("Error: $e");
      _deliveryOrderList = [];
    } finally {
      _isDeliveryOrderLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchReceiptPdf(int receiptPdfId) async {
    _isReceiptLoading = true;
    notifyListeners();

    try {
      _receiptList = await PdfServices.getReceiptPdf(receiptPdfId);
    } catch (e) {
      _receiptList = [];
    } finally {
      _isReceiptLoading = false;
      notifyListeners();
    }
  }
}
