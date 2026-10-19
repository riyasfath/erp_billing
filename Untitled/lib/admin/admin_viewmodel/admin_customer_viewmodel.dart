import 'package:flutter/foundation.dart';

import '../admin_api_client.dart';
import '../admin_model/admin_customer_model.dart';
import '../admin_service/admin_customer_service.dart';

class AdminCustomerViewModel extends ChangeNotifier {
  final AdminCustomerService _service;

  AdminCustomerViewModel({AdminCustomerService? service}) : _service = service ?? AdminCustomerService();

  bool isLoading = false;
  String? error;
  List<AdminCustomerModel> customers = [];

  bool isSaving = false;
  String? saveError;

  final Set<int> _busyIds = {};
  bool isBusy(int id) => _busyIds.contains(id);

  Future<void> fetchCustomers() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      customers = await _service.getCustomers();
      isLoading = false;
    } on AdminApiException catch (e) {
      isLoading = false;
      error = e.message;
    } catch (_) {
      isLoading = false;
      error = 'Could not load customers.';
    }
    notifyListeners();
  }

  Future<bool> updateCustomer(int id, {required String fullName, required String email}) async {
    isSaving = true;
    saveError = null;
    notifyListeners();
    bool success = false;
    try {
      final updated = await _service.updateCustomer(id, fullName: fullName, email: email);
      final index = customers.indexWhere((c) => c.id == id);
      if (index != -1) customers[index] = updated;
      success = true;
    } on AdminApiException catch (e) {
      saveError = e.message;
    } catch (_) {
      saveError = 'Could not update customer.';
    }
    isSaving = false;
    notifyListeners();
    return success;
  }

  Future<bool> deleteCustomer(AdminCustomerModel customer) async {
    _busyIds.add(customer.id);
    notifyListeners();
    bool success = false;
    try {
      await _service.deleteCustomer(customer.id);
      customers = customers.where((c) => c.id != customer.id).toList();
      success = true;
    } catch (_) {
      error = 'Could not delete this customer.';
    }
    _busyIds.remove(customer.id);
    notifyListeners();
    return success;
  }
}