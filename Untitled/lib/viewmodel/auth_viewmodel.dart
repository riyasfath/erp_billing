import 'package:ecommerce_app/core/api_exception.dart';
import 'package:ecommerce_app/core/token_storage.dart';
import 'package:ecommerce_app/core/view_status.dart';
import 'package:ecommerce_app/models/auth_model.dart';
import 'package:ecommerce_app/service/auth_service.dart';
import 'package:flutter/foundation.dart';


/// ViewModel for register -> verify-OTP. Login has its own
/// [LoginViewModel] — kept separate on purpose.
class AuthViewModel extends ChangeNotifier {
  final AuthService _authService;

  AuthViewModel({AuthService? authService})
      : _authService = authService ?? AuthService();

  ViewStatus registerStatus = ViewStatus.idle;
  String? registerError;

  ViewStatus verifyStatus = ViewStatus.idle;
  String? verifyError;

  bool isVerifiedAndLoggedIn = false;

  bool get isRegistering => registerStatus == ViewStatus.loading;
  bool get isVerifying => verifyStatus == ViewStatus.loading;

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
    required bool termsAccepted,
  }) async {
    registerStatus = ViewStatus.loading;
    registerError = null;
    notifyListeners();

    try {
      final model = RegisterModel(
        fullName: fullName,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        termsAccepted: termsAccepted,
      );
      await _authService.register(model);
      await TokenStorage.instance.saveEmail(email);

      registerStatus = ViewStatus.success;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      registerStatus = ViewStatus.error;
      registerError = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      registerStatus = ViewStatus.error;
      registerError = 'Something went wrong. Please try again.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyOtp({required String email, required String otp}) async {
    verifyStatus = ViewStatus.loading;
    verifyError = null;
    notifyListeners();

    try {
      final model = OtpModel(email: email, otp: otp);
      final tokens = await _authService.verifyOtp(model);

      if (tokens.hasAccessToken) {
        await TokenStorage.instance.saveTokens(
          accessToken: tokens.accessToken,
          refreshToken: tokens.refreshToken,
        );
        isVerifiedAndLoggedIn = true;
      }

      verifyStatus = ViewStatus.success;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      verifyStatus = ViewStatus.error;
      verifyError = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      verifyStatus = ViewStatus.error;
      verifyError = 'Something went wrong. Please try again.';
      notifyListeners();
      return false;
    }
  }

  void resetRegisterStatus() {
    registerStatus = ViewStatus.idle;
    registerError = null;
    notifyListeners();
  }

  void resetVerifyStatus() {
    verifyStatus = ViewStatus.idle;
    verifyError = null;
    notifyListeners();
  }
}