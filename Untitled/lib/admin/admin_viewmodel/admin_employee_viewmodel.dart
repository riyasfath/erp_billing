import 'package:flutter/foundation.dart';

import '../admin_api_client.dart';
import '../admin_model/admin_employee_model.dart';
import '../admin_service/admin_employee_service.dart';

class AdminEmployeeViewModel extends ChangeNotifier {
  final AdminEmployeeService _service;

  AdminEmployeeViewModel({AdminEmployeeService? service}) : _service = service ?? AdminEmployeeService();

  bool isLoading = false;
  String? error;
  List<AdminEmployeeModel> employees = [];

  bool isSaving = false;
  String? saveError;

  final Set<int> _busyIds = {};
  bool isBusy(int id) => _busyIds.contains(id);

  Future<void> fetchEmployees() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      employees = await _service.getEmployees();
      isLoading = false;
    } on AdminApiException catch (e) {
      isLoading = false;
      error = e.message;
    } catch (_) {
      isLoading = false;
      error = 'Could not load employees.';
    }
    notifyListeners();
  }

  Future<bool> createEmployee({
    required String email,
    required String fullName,
    required String phone,
    required String employeeId,
    required String pin,
    required String jobTitle,
    required List<String> permissions,
  }) async {
    isSaving = true;
    saveError = null;
    notifyListeners();
    bool success = false;
    try {
      final created = await _service.createEmployee(
        email: email,
        fullName: fullName,
        phone: phone,
        employeeId: employeeId,
        pin: pin,
        jobTitle: jobTitle,
        permissions: permissions,
      );
      employees = [created, ...employees];
      success = true;
    } on AdminApiException catch (e) {
      saveError = e.message;
    } catch (_) {
      saveError = 'Could not create employee.';
    }
    isSaving = false;
    notifyListeners();
    return success;
  }

  Future<bool> updateEmployee(
    int id, {
    String? fullName,
    String? pin,
    String? jobTitle,
    String? phone,
    List<String>? permissions,
  }) async {
    isSaving = true;
    saveError = null;
    notifyListeners();
    bool success = false;
    try {
      final updated = await _service.updateEmployee(id, fullName: fullName, pin: pin, jobTitle: jobTitle, phone: phone, permissions: permissions);
      final index = employees.indexWhere((e) => e.id == id);
      if (index != -1) employees[index] = updated;
      success = true;
    } on AdminApiException catch (e) {
      saveError = e.message;
    } catch (_) {
      saveError = 'Could not update employee.';
    }
    isSaving = false;
    notifyListeners();
    return success;
  }

  Future<bool> deleteEmployee(AdminEmployeeModel employee) async {
    _busyIds.add(employee.id);
    notifyListeners();
    bool success = false;
    try {
      await _service.deleteEmployee(employee.id);
      employees = employees.where((e) => e.id != employee.id).toList();
      success = true;
    } catch (_) {
      error = 'Could not delete this employee.';
    }
    _busyIds.remove(employee.id);
    notifyListeners();
    return success;
  }
}