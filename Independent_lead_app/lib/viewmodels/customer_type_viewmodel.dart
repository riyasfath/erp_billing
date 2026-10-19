import 'package:flutter/material.dart';
import 'package:pokakbilling/models/data-models/customer_type_model.dart';
import 'package:pokakbilling/models/services/customer_type_service.dart';

class CustomerTypeViewmodel extends ChangeNotifier {
  List<CustomerTypeModel> customerTypeList = [];
  bool loading = false;
  String? error;

  // ✅ ADDED: tracks selected type ID (sent to API) alongside name (shown in UI)
  int? selectedTypeId;
  String? selectedTypeName;

  Future<void> getCustomerTypes() async {
    try {
      loading = true;
      error = null;
      notifyListeners();

      customerTypeList = await CustomerTypeService.getCustomerTypes();
    } catch (e) {
      error = e.toString();
      print("CustomerTypeViewmodel error: $e");
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // ✅ ADDED: select by name — also resolves and stores the matching ID
  void selectTypeByName(String name) {
    final match = customerTypeList.where((t) => t.name == name).firstOrNull;
    if (match != null) {
      selectedTypeId = match.id;
      selectedTypeName = match.name;
      notifyListeners();
    }
  }

  // ✅ ADDED: select by ID — used in edit mode to prefill from existing customer
  void selectTypeById(int id) {
    final match = customerTypeList.where((t) => t.id == id).firstOrNull;
    if (match != null) {
      selectedTypeId = match.id;
      selectedTypeName = match.name;
      notifyListeners();
    }
  }

  // kept from original
  void selectType(String name) {
    selectedTypeName = name;
    notifyListeners();
  }

  void clearSelectedType() {
    selectedTypeId = null;
    selectedTypeName = null;
    notifyListeners();
  }

  void reset() {
    customerTypeList = [];
    selectedTypeId = null;
    selectedTypeName = null;
    loading = false;
    error = null;
    notifyListeners();
  }
}
