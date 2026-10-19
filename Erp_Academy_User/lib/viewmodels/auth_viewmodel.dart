import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _service;
  AuthViewModel(this._service);

  bool loading = false, obscure = true, remember = false;
  String? error;
  AppUser? user;

  void toggleObscure() {
    obscure = !obscure;
    notifyListeners();
  }

  void setRemember(bool v) {
    remember = v;
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    loading = true;
    error = null;
    notifyListeners();

    user = await _service.login(username, password);
    if (user == null) {
      error = 'Enter valid credentials';
    } else if (user!.role != UserRole.user) {
      error = 'Admin accounts must use the Admin app.';
      user = null;
    }

    loading = false;
    notifyListeners();
    return user != null;
  }
}