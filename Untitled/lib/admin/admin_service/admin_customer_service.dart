import '../admin_api_client.dart';
import '../admin_endpoints.dart';
import '../admin_model/admin_customer_model.dart';

class AdminCustomerService {
  final AdminApiClient _apiClient;

  AdminCustomerService({AdminApiClient? apiClient}) : _apiClient = apiClient ?? AdminApiClient();

  /// Plain array response (not paginated), matching the sample given.
  Future<List<AdminCustomerModel>> getCustomers() async {
    final data = await _apiClient.get(AdminEndpoints.customers);
    final list = (data['data'] as List?) ?? (data['results'] as List?) ?? [];
    return list.map((e) => AdminCustomerModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Confirmed shape (PUT): {full_name, first_name, last_name, email}.
  /// The API only returns full_name (not split first/last), so the
  /// caller splits the edited full name on the first space.
  Future<AdminCustomerModel> updateCustomer(
    int id, {
    required String fullName,
    required String email,
  }) async {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    final firstName = parts.isNotEmpty ? parts.first : '';
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    final data = await _apiClient.putJson(AdminEndpoints.customerDetail(id), {
      'full_name': fullName,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
    });
    return AdminCustomerModel.fromJson(data);
  }

  Future<void> deleteCustomer(int id) async {
    await _apiClient.delete(AdminEndpoints.customerDetail(id));
  }
}