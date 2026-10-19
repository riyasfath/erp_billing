import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:ecommerce_app/core/api_exception.dart';
import 'package:ecommerce_app/core/env_config.dart';
import 'package:ecommerce_app/core/token_storage.dart';
import 'package:ecommerce_app/core/view_status.dart';
import 'package:ecommerce_app/models/social_login_model.dart';
import 'package:ecommerce_app/service/social_auth_service.dart';

/// ViewModel for social login. Currently wired for Google; add another
/// `signInWithX()` method the same shape when Apple sign-in is ready
/// (the backend already accepts `provider: "apple"` per its own comment).
class SocialAuthViewModel extends ChangeNotifier {
  final SocialAuthService _socialAuthService;
  late final GoogleSignIn _googleSignIn;

  SocialAuthViewModel({SocialAuthService? socialAuthService})
      : _socialAuthService = socialAuthService ?? SocialAuthService() {
    _googleSignIn = GoogleSignIn(
      scopes: ['email'],
      // Only pass serverClientId if it's set — GoogleSignIn errors on an
      // empty string. Required on Android; harmless extra safety on iOS.
      serverClientId: EnvConfig.googleServerClientId.isNotEmpty
          ? EnvConfig.googleServerClientId
          : null,
    );
  }

  ViewStatus googleStatus = ViewStatus.idle;
  String? googleError;
  bool isLoggedIn = false;

  bool get isGoogleSigningIn => googleStatus == ViewStatus.loading;

  /// Returns true on success, false on failure OR if the user simply
  /// cancelled the Google account picker (googleError stays null then —
  /// that's not a real error worth showing a SnackBar for).
  Future<bool> signInWithGoogle() async {
    googleStatus = ViewStatus.loading;
    googleError = null;
    notifyListeners();

    try {
      // Clear any stale session so the account picker always shows,
      // rather than silently re-using a previously chosen Google account.
      await _googleSignIn.signOut();

      final account = await _googleSignIn.signIn();
      if (account == null) {
        // User closed the picker — not an error.
        googleStatus = ViewStatus.idle;
        notifyListeners();
        return false;
      }

      final googleAuth = await account.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null || idToken.isEmpty) {
        googleStatus = ViewStatus.error;
        googleError = 'Could not get a Google ID token. Please try again.';
        notifyListeners();
        return false;
      }

      final model = SocialLoginModel(provider: 'google', token: idToken);
      final tokens = await _socialAuthService.loginWithProvider(model);

      await TokenStorage.instance.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );
      if (account.email.isNotEmpty) {
        await TokenStorage.instance.saveEmail(account.email);
      }
      isLoggedIn = true;

      googleStatus = ViewStatus.success;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      googleStatus = ViewStatus.error;
      googleError = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      googleStatus = ViewStatus.error;
      googleError = 'Google sign-in failed. Please try again.';
      notifyListeners();
      return false;
    }
  }

  void resetGoogleStatus() {
    googleStatus = ViewStatus.idle;
    googleError = null;
    notifyListeners();
  }
}