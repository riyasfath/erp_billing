
import 'package:flutter/material.dart';
import 'package:pokakbilling/models/services/auth_services.dart';
import 'package:pokakbilling/viewmodels/access_viewmodel.dart';
import 'package:pokakbilling/viewmodels/profile_viewmodel.dart';
import 'package:pokakbilling/views/bottom_bar/bottomNavigationBar/bottom_bar.dart';
import 'package:pokakbilling/views/commonWidgets/response-message/success-message.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginViewModel extends ChangeNotifier {
  bool isLoading = false;

  String? loggedInEmail;
  String? loggedInUsername;
  bool? isVerified;
  String role = '';

  // ── New fields from login response ────────────────────────────
  int? loggedInId;
  String? loggedInUserType;
  bool loggedInIsVerified = false;
  bool loggedInHasSubscription = false;

  bool get isAdmin => role == 'ADMIN';

  static const _kUsername = 'login_username';
  static const _kEmail = 'login_email';
  static const _kRole = 'login_role';
  static const _kId = 'login_id';
  static const _kUserType = 'login_user_type';
  static const _kIsVerified = 'login_is_verified';
  static const _kHasSubscription = 'login_has_subscription';

  LoginViewModel() {
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      loggedInUsername = prefs.getString(_kUsername);
      loggedInEmail = prefs.getString(_kEmail);
      role = prefs.getString(_kRole) ?? '';
      loggedInId = prefs.getInt(_kId);
      loggedInUserType = prefs.getString(_kUserType);
      loggedInIsVerified = prefs.getBool(_kIsVerified) ?? false;
      loggedInHasSubscription = prefs.getBool(_kHasSubscription) ?? false;
      if (loggedInUsername != null || loggedInEmail != null) {
        notifyListeners();
      }
    } catch (e) {
      debugPrint('LoginViewModel._restoreSession error: $e');
    }
  }

  Future<void> _persistSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (loggedInUsername != null)
        await prefs.setString(_kUsername, loggedInUsername!);
      if (loggedInEmail != null) await prefs.setString(_kEmail, loggedInEmail!);
      await prefs.setString(_kRole, role);
      if (loggedInId != null) await prefs.setInt(_kId, loggedInId!);
      if (loggedInUserType != null)
        await prefs.setString(_kUserType, loggedInUserType!);
      await prefs.setBool(_kIsVerified, loggedInIsVerified);
      await prefs.setBool(_kHasSubscription, loggedInHasSubscription);
    } catch (e) {
      debugPrint('LoginViewModel._persistSession error: $e');
    }
  }

  Future<void> _clearPersistedSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kUsername);
      await prefs.remove(_kEmail);
      await prefs.remove(_kRole);
      await prefs.remove(_kId);
      await prefs.remove(_kUserType);
      await prefs.remove(_kIsVerified);
      await prefs.remove(_kHasSubscription);
    } catch (e) {
      debugPrint('LoginViewModel._clearPersistedSession error: $e');
    }
  }

  Future<bool> userLogin(
    String email,
    String password,
    BuildContext context,
  ) async {
    try {
      isLoading = true;
      notifyListeners();

      final response = await AuthServices.userLogin(email, password, context);

      if (response == null) {
        if (!context.mounted) return false;

        loggedInEmail ??= email.trim().toLowerCase();
        await _persistSession();
        notifyListeners();

        showSuccessMessage(context, "You're in! Have a great time");

        Provider.of<AccessViewModel>(context, listen: false).fetchModules();
        Provider.of<ProfileViewmodel>(context, listen: false).getAllProfile();

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const BottomBar(index: 0)),
          (route) => false,
        );

        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setUserData({
    required String username,
    required String email,
    required bool isVerified,
    String role = '',
    int? userId,
    String? userType,
    bool hasSubscription = false,
  }) {
    loggedInUsername = username;
    loggedInEmail = email.trim().toLowerCase();
    this.isVerified = isVerified;
    loggedInIsVerified = isVerified;
    this.role = role.toUpperCase();
    loggedInId = userId;
    loggedInUserType = userType;
    loggedInHasSubscription = hasSubscription;
    notifyListeners();
    _persistSession();
  }

  Future<void> clearUserData() async {
    loggedInUsername = null;
    loggedInEmail = null;
    isVerified = null;
    loggedInIsVerified = false;
    role = '';
    loggedInId = null;
    loggedInUserType = null;
    loggedInHasSubscription = false;
    notifyListeners();
    await _clearPersistedSession();
  }
}
