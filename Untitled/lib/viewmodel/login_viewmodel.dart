import 'package:ecommerce_app/core/api_exception.dart';
import 'package:ecommerce_app/core/token_storage.dart';
import 'package:ecommerce_app/core/view_status.dart';
import 'package:ecommerce_app/service/login_service.dart';
import 'package:flutter/foundation.dart';

import 'package:ecommerce_app/models/login_model.dart';

/// ViewModel for /login/ only.
class LoginViewModel extends ChangeNotifier {
  final LoginService _loginService;

  LoginViewModel({LoginService? loginService})
      : _loginService = loginService ?? LoginService();

  ViewStatus loginStatus = ViewStatus.idle;
  String? loginError;
  bool isLoggedIn = false;

  bool get isLoggingIn => loginStatus == ViewStatus.loading;

  Future<bool> login({required String email, required String password}) async {
    loginStatus = ViewStatus.loading;
    loginError = null;
    notifyListeners();

    try {
      final model = LoginModel(email: email, password: password);
      final tokens = await _loginService.login(model);

      // TEMP DEBUG — remove once the real cause is found. Prints
      // whether a usable access token actually came back.
      debugPrint('[LOGIN DEBUG] raw response: ${tokens.raw}');
      debugPrint('[LOGIN DEBUG] accessToken: ${tokens.accessToken}');
      debugPrint('[LOGIN DEBUG] hasAccessToken: ${tokens.hasAccessToken}');

      await TokenStorage.instance.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );
      await TokenStorage.instance.saveEmail(email);
      isLoggedIn = true;

      loginStatus = ViewStatus.success;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      // TEMP DEBUG — remove once the real cause is found.
      debugPrint('[LOGIN DEBUG] ApiException: ${e.message} (status ${e.statusCode}) errors: ${e.errors}');
      loginStatus = ViewStatus.error;
      loginError = e.message;
      notifyListeners();
      return false;
    } catch (e, stack) {
      // TEMP DEBUG — this is the branch that was showing the generic
      // text with no clue why. Now it prints the real exception type
      // and message.
      debugPrint('[LOGIN DEBUG] Unexpected error: $e');
      debugPrint('[LOGIN DEBUG] Stack: $stack');
      loginStatus = ViewStatus.error;
      loginError = 'Something went wrong. Please try again.';
      notifyListeners();
      return false;
    }
  }

  void resetLoginStatus() {
    loginStatus = ViewStatus.idle;
    loginError = null;
    notifyListeners();
  }
}