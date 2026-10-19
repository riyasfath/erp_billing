import 'package:flutter/material.dart';
import 'package:pokakbilling/core/navigations.dart';
import 'package:pokakbilling/models/data-models/supplier_model.dart';
import 'package:pokakbilling/models/services/supplier_services.dart';
import 'package:pokakbilling/views/Screens/supplier/supplier_main.dart';
import 'package:pokakbilling/views/commonWidgets/response-message/error_message.dart';
import 'package:pokakbilling/views/commonWidgets/response-message/success-message.dart';

class SupplierViewmodel extends ChangeNotifier {
  String selectedCurrency = "";
  int selectedTermsId = 0;
  bool createSupplierLoading = false;
  bool getSuppliersLoader = false;
  var supplierList = <SupplierModel>[];
  var singleSupplierList = <SupplierDetailModel>[];
  bool supplierDetailLoading = false;
  bool editSupplierLoading = false;

  var currencyList = [
    "INR",
    "USD",
    "AED",
    "EUR",
    "RUB",
  ];

  void updateCurrency(String value) {
    selectedCurrency = value;
    notifyListeners();
  }

  void updateSelectedTermsId(int value) {
    selectedTermsId = value;
    notifyListeners();
  }

  SupplierViewmodel() {
    getAllSuppliers();
  }

  Future<void> createSupplier(
    supplierType,
    supplierNumber,
    date,
    firstName,
    lastName,
    companyName,
    contactPerson,
    contactPersonNumber,
    state,
    country,
    address,
    email,
    phone,
    mobile,
    currency,
    termsId,
    BuildContext context,
  ) async {
    try {
      createSupplierLoading = true;
      notifyListeners();

      String? response = await SupplierServices.createSupplier(
        supplierType,
        supplierNumber,
        date,
        firstName,
        lastName,
        companyName,
        contactPerson,
        contactPersonNumber,
        state,
        country,
        address,
        email,
        phone,
        mobile,
        currency,
        termsId,
      );

      if (response == null) {
        if (!context.mounted) return;
        showSuccessMessage(
          context,
          "Supplier Created Successfully!",
        );
        getAllSuppliers();
        pushReplacementNavigation(context, const SupplierMain());
      } else {
        if (!context.mounted) return;
        showOverlayError(context, response);
      }
    } catch (e) {
      print(e);
    } finally {
      createSupplierLoading = false;
      notifyListeners();
    }
  }

  Future<void> getAllSuppliers() async {
    try {
      getSuppliersLoader = true;
      notifyListeners();
      List<SupplierModel> supplierItems = await SupplierServices.getSuppliers();

      if (supplierItems.isNotEmpty) {
        supplierList = supplierItems;
      } else {
        supplierList.clear();
      }
    } catch (e) {
      print(e);
    } finally {
      getSuppliersLoader = false;
      notifyListeners();
    }
  }

  Future<void> deleteSupplier(int supplierId, BuildContext context) async {
    try {
      String? response = await SupplierServices.deleteSupplier(supplierId);

      if (response == null) {
        showSuccessMessage(context, "Supplier deleted successfully.");
        getAllSuppliers();
      } else {
        showOverlayError(context, response);
      }
    } catch (e) {
      print("Delete error: $e");
      showOverlayError(context, "Failed to delete supplier.");
    }
  }

  Future<void> getSupplierById(supplierId) async {
    try {
      supplierDetailLoading = true;
      notifyListeners();

      List<SupplierDetailModel> supplier =
          await SupplierServices.getSupplierById(supplierId);

      if (supplier.isNotEmpty) {
        singleSupplierList = supplier;
      } else {
        singleSupplierList.clear();
      }
    } catch (e) {
      print(e);
    } finally {
      supplierDetailLoading = false;
      notifyListeners();
    }
  }

  Future<void> editSupplier(
    supplierId,
    supplierType,
    supplierNumber,
    date,
    firstName,
    lastName,
    companyName,
    contactPerson,
    contactPersonNumber,
    state,
    country,
    address,
    email,
    phone,
    mobile,
    currency,
    termsId,
    BuildContext context,
  ) async {
    try {
      editSupplierLoading = true;
      notifyListeners();

      String? response = await SupplierServices.updateSupplier(
        supplierId,
        supplierType,
        supplierNumber,
        date,
        firstName,
        lastName,
        companyName,
        contactPerson,
        contactPersonNumber,
        state,
        country,
        address,
        email,
        phone,
        mobile,
        currency,
        termsId,
      );

      if (response == null) {
        if (!context.mounted) return;
        showSuccessMessage(
          context,
          "Supplier Updated Successfully!",
        );
        getAllSuppliers();
        pushReplacementNavigation(context, const SupplierMain());
      } else {
        if (!context.mounted) return;
        showOverlayError(context, response);
      }
    } catch (e) {
      print(e);
    } finally {
      editSupplierLoading = false;
      notifyListeners();
    }
  }
}
