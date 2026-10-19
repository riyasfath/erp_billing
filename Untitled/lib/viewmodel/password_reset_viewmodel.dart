import 'package:flutter/foundation.dart';

import 'package:ecommerce_app/core/api_exception.dart';
import 'package:ecommerce_app/core/view_status.dart';
import 'package:ecommerce_app/models/password_reset_model.dart';
import 'package:ecommerce_app/service/password_reset_service.dart';

/// ViewModel for forgot-password -> verify-OTP -> reset-password.
class PasswordResetViewModel extends ChangeNotifier {
  final PasswordResetService _passwordResetService;

  PasswordResetViewModel({PasswordResetService? passwordResetService})
      : _passwordResetService = passwordResetService ?? PasswordResetService();

  ViewStatus forgotStatus = ViewStatus.idle;
  String? forgotError;

  ViewStatus verifyOtpStatus = ViewStatus.idle;
  String? verifyOtpError;

  ViewStatus resetStatus = ViewStatus.idle;
  String? resetError;

  bool get isSendingOtp => forgotStatus == ViewStatus.loading;
  bool get isVerifyingOtp => verifyOtpStatus == ViewStatus.loading;
  bool get isResetting => resetStatus == ViewStatus.loading;

  Future<bool> forgotPassword({required String email}) async {
    forgotStatus = ViewStatus.loading;
    forgotError = null;
    notifyListeners();

    try {
      final model = ForgotPasswordModel(email: email);
      await _passwordResetService.forgotPassword(model);

      forgotStatus = ViewStatus.success;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      forgotStatus = ViewStatus.error;
      forgotError = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      forgotStatus = ViewStatus.error;
      forgotError = 'Something went wrong. Please try again.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyResetOtp({
    required String email,
    required String otp,
  }) async {
    verifyOtpStatus = ViewStatus.loading;
    verifyOtpError = null;
    notifyListeners();

    try {
      final model = VerifyResetOtpModel(email: email, otp: otp);
      await _passwordResetService.verifyResetOtp(model);

      verifyOtpStatus = ViewStatus.success;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      verifyOtpStatus = ViewStatus.error;
      verifyOtpError = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      verifyOtpStatus = ViewStatus.error;
      verifyOtpError = 'Something went wrong. Please try again.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    resetStatus = ViewStatus.loading;
    resetError = null;
    notifyListeners();

    try {
      final model = ResetPasswordModel(
        email: email,
        otp: otp,
        newPassword: newPassword,
      );
      await _passwordResetService.resetPassword(model);

      resetStatus = ViewStatus.success;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      resetStatus = ViewStatus.error;
      resetError = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      resetStatus = ViewStatus.error;
      resetError = 'Something went wrong. Please try again.';
      notifyListeners();
      return false;
    }
  }

  void resetForgotStatus() {
    forgotStatus = ViewStatus.idle;
    forgotError = null;
    notifyListeners();
  }

  void resetVerifyOtpStatus() {
    verifyOtpStatus = ViewStatus.idle;
    verifyOtpError = null;
    notifyListeners();
  }

  void resetResetStatus() {
    resetStatus = ViewStatus.idle;
    resetError = null;
    notifyListeners();
  }
}