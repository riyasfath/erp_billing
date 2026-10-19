
import 'package:ecommerce_app/admin/admin_api_client.dart';
import 'package:ecommerce_app/admin/admin_endpoints.dart';
import 'package:ecommerce_app/admin/admin_token_storage.dart';

class AdminAuthService {
  final AdminApiClient _apiClient;

  AdminAuthService({AdminApiClient? apiClient}) : _apiClient = apiClient ?? AdminApiClient();

  Future<void> login({required String userId, required String password}) async {
    final data = await _apiClient.postJson(AdminEndpoints.login, {'user_id': userId, 'password': password});
    final access = data['access']?.toString() ?? '';
    final refresh = data['refresh']?.toString() ?? '';
    final role = data['role']?.toString() ?? '';
    if (access.isEmpty) {
      throw AdminApiException('Login succeeded but no token was returned. Please try again.');
    }
    await AdminTokenStorage.instance.saveSession(access: access, refresh: refresh, role: role);
  }

  Future<void> logout() => AdminTokenStorage.instance.clear();
}