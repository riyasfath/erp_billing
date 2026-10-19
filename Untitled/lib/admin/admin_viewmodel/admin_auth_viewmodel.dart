import 'package:ecommerce_app/admin/admin_api_client.dart';
import 'package:ecommerce_app/admin/admin_service/admin_auth_service.dart';
import 'package:flutter/foundation.dart';


class AdminAuthViewModel extends ChangeNotifier {
  final AdminAuthService _service;

  AdminAuthViewModel({AdminAuthService? service}) : _service = service ?? AdminAuthService();

  bool isLoading = false;
  String? error;

  Future<bool> login(String userId, String password) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      await _service.login(userId: userId, password: password);
      isLoading = false;
      notifyListeners();
      return true;
    } on AdminApiException catch (e) {
      isLoading = false;
      error = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      isLoading = false;
      error = 'Could not reach the server. Please try again.';
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() => _service.logout();
}