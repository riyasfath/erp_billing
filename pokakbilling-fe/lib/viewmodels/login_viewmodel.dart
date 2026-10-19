import 'package:flutter/material.dart';
import 'package:pokakbilling/core/services.dart';
import 'package:pokakbilling/models/services/auth_services.dart';
import 'package:pokakbilling/viewmodels/access_viewmodel.dart';
import 'package:pokakbilling/viewmodels/profile_viewmodel.dart';
import 'package:pokakbilling/views/bottom_bar/bottomNavigationBar/bottom_bar.dart';
import 'package:pokakbilling/views/commonWidgets/response-message/success-message.dart';
import 'package:provider/provider.dart';

class LoginViewModel extends ChangeNotifier {
  bool isLoading = false;
  String? loggedInEmail;

  // Holds the JWT access token after a successful login,
  // so other parts of the app can read it via Provider without
  // hitting secure storage every time.
  String? authToken;

  String? errorMessage;

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  final _storage = SecureStorageService();

  LoginViewModel() {
    _restoreEmail();
  }

  Future<void> _restoreEmail() async {
    final saved = await _storage.getEmail();
    if (saved != null && saved.isNotEmpty) {
      loggedInEmail = saved;
      notifyListeners();
    }
  }

  Future<void> userLogin(
    String email,
    String password,
    String turnstileToken, // token from the CloudflareTurnstile widget
    BuildContext context,
  ) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final response = await AuthServices.userLogin(
        email,
        password,
        turnstileToken,
        context,
      );

      if (response == null) {
        if (!context.mounted) return;

        loggedInEmail = email.trim().toLowerCase();
        await _storage.storeEmail(loggedInEmail!);

        // AuthServices.userLogin() -> universalLogin() already saved the JWT
        // via secureStorage.storeToken(accessToken). Read it back.
        final jwtToken = await _storage.getToken();
        authToken = jwtToken;
        debugPrint('=========================================');
        debugPrint('LOGIN SUCCESS — JWT TOKEN:');
        debugPrint('$jwtToken');
        debugPrint('=========================================');

        notifyListeners();

        if (!context.mounted) return;
        showSuccessMessage(context, "You're in! Have a great time");

        final accessVm = Provider.of<AccessViewModel>(context, listen: false);
        final profileVm = Provider.of<ProfileViewmodel>(context, listen: false);

        // FIX: mark the user as logged in BEFORE the home page opens,
        // otherwise ErpHomePage sees checkingIsLoggedIn == false and
        // shows the "Session Expired" dialog right after login.
        await accessVm.checkLoginStatus();

        accessVm.fetchModules();
        profileVm.getAllProfile();

        if (!context.mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const ErpBottomBar(index: 0)),
          (route) => false,
        );
      } else {
        // Matches the Django error bodies from the Turnstile guide:
        // { "detail": "Verification is required." }
        // { "detail": "Verification failed. Please refresh the page and try again." }
        if (response.toLowerCase().contains('verification')) {
          errorMessage = response;
        } else if (response.contains('active')) {
          errorMessage = 'No active account found with these credentials.';
        } else {
          errorMessage = response;
        }
        notifyListeners();
      }
    } catch (e) {
      errorMessage = 'Something went wrong. Please try again.';
      notifyListeners();
      debugPrint('Login error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    loggedInEmail = null;
    authToken = null;
    await _storage.deleteToken();
    await _storage.deleteEmail();
    notifyListeners();
  }

  void clearSession() {
    loggedInEmail = null;
    errorMessage = null;
    notifyListeners();
  }
}