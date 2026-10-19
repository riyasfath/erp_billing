import 'package:erp_academy/models/app_user_model.dart';
import 'package:flutter/material.dart';

import '../core/navigation/app_navigator.dart';
import '../core/network/api_exception.dart';
import '../models/login_request_model.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._service);

  final AuthService _service;

  bool loading = false;
  bool obscure = true;
  bool remember = true; // ✅ ticked by default → stays logged in after restart
  String? error;
  AppUser? user;

  bool get isLoggedIn => user != null;

  void toggleObscure() {
    obscure = !obscure;
    notifyListeners();
  }

  void setRemember(bool v) {
    remember = v;
    notifyListeners();
  }

  void clearError() {
    if (error == null) return;
    error = null;
    notifyListeners();
  }

  // ---------- Field validators (used by the Form) ----------
  static final _emailRegex = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');

  String? validateEmail(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return 'Email is required';
    if (!_emailRegex.hasMatch(value)) return 'Enter a valid email address';
    return null;
  }

  String? validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    return null;
  }

  /// Returns true ONLY when the API returned 2xx with valid tokens.
  Future<bool> login(String email, String password) async {
    if (loading) return false;
    loading = true;
    error = null;
    user = null;
    notifyListeners();

    try {
      final res = await _service.adminLogin(
        LoginRequestModel(email: email, password: password),
        remember: remember,
      );
      user = res.toAppUser();
      return true;
    } on ApiException catch (e) {
      error = e.message;
      return false;
    } catch (_) {
      error = 'Something went wrong. Please try again.';
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Splash screen calls this. True → go straight to home.
  Future<bool> tryAutoLogin() async {
    try {
      user = await _service.restoreSession();
    } catch (_) {
      user = null;
    }
    debugPrint(user == null
        ? '🔑 Auto-login: no saved session → Login screen'
        : '🔑 Auto-login: restored ${user!.email} → Home');
    notifyListeners();
    return user != null;
  }

  /// Logout button.
  Future<void> logout() async {
    await _service.logout();
    user = null;
    error = null;
    notifyListeners();
    AppNavigator.toLogin();
  }

  /// Called automatically when the token expires or server says it's invalid.
  Future<void> handleSessionExpired() async {
    if (user == null) return; // already logged out
    await _service.logout();
    user = null;
    notifyListeners();
    AppNavigator.toLogin(message: 'Session expired. Please log in again.');
  }
}