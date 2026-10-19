import 'package:flutter/material.dart';

class UserLoginProvider with ChangeNotifier {
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isButtonEnabled = false;
  bool _isPasswordVisible = false;

  TextEditingController get mobileNumberController => _mobileNumberController;
  TextEditingController get usernameController => _usernameController;
  TextEditingController get passwordController => _passwordController;

  bool get isButtonEnabled => _isButtonEnabled;
  bool get isPasswordVisible => _isPasswordVisible;

  UserLoginProvider() {
    _mobileNumberController.addListener(_checkButtonState);
    _usernameController.addListener(_checkButtonState);
    _passwordController.addListener(_checkButtonState);
  }

  void _checkButtonState() {
    _isButtonEnabled = _mobileNumberController.text.isNotEmpty &&
        _usernameController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  @override
  void dispose() {
    _mobileNumberController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
