import '../admin_api_client.dart';
import '../admin_endpoints.dart';
import '../admin_model/admin_employee_model.dart';

class AdminEmployeeService {
  final AdminApiClient _apiClient;

  AdminEmployeeService({AdminApiClient? apiClient}) : _apiClient = apiClient ?? AdminApiClient();

  /// Plain array response (not paginated), matching the sample given.
  Future<List<AdminEmployeeModel>> getEmployees() async {
    final data = await _apiClient.get(AdminEndpoints.employees);
    final list = (data['data'] as List?) ?? (data['results'] as List?) ?? [];
    return list.map((e) => AdminEmployeeModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<AdminEmployeeModel> createEmployee({
    required String email,
    required String fullName,
    required String phone,
    required String employeeId,
    required String pin,
    required String jobTitle,
    required List<String> permissions,
  }) async {
    final data = await _apiClient.postJson(AdminEndpoints.employees, {
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'employee_id': employeeId,
      'pin': pin,
      'job_title': jobTitle,
      'permissions': permissions,
    });
    return AdminEmployeeModel.fromJson(data);
  }

  /// Confirmed shape only sends the fields actually being changed —
  /// full_name, pin, permissions (job_title/phone are presumably also
  /// editable the same way, included here for completeness).
  Future<AdminEmployeeModel> updateEmployee(
    int id, {
    String? fullName,
    String? pin,
    String? jobTitle,
    String? phone,
    List<String>? permissions,
  }) async {
    final data = await _apiClient.patchJson(AdminEndpoints.employeeDetail(id), {
      if (fullName != null) 'full_name': fullName,
      if (pin != null) 'pin': pin,
      if (jobTitle != null) 'job_title': jobTitle,
      if (phone != null) 'phone': phone,
      if (permissions != null) 'permissions': permissions,
    });
    return AdminEmployeeModel.fromJson(data);
  }

  Future<void> deleteEmployee(int id) async {
    await _apiClient.delete(AdminEndpoints.employeeDetail(id));
  }
}