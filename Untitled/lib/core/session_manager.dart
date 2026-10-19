import 'package:ecommerce_app/viewmodel/recently_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ecommerce_app/viewmodel/address_viewmodel.dart';
import 'package:ecommerce_app/viewmodel/cart_viewmodel.dart';
import 'package:ecommerce_app/viewmodel/notification_viewmodel.dart';
import 'package:ecommerce_app/viewmodel/order_detail_viewmodel.dart';
import 'package:ecommerce_app/viewmodel/order_list_viewmodel.dart';
import 'package:ecommerce_app/viewmodel/place_order_viewmodel.dart';
import 'package:ecommerce_app/views/screens/login/login_screen.dart';
import 'navigation_service.dart';
import 'token_storage.dart';

/// The one place a session actually ends — whether the user tapped
/// Logout, or the backend rejected our token as expired/invalid. Both
/// paths converge here so the app always resets to the exact same
/// clean state: storage cleared, every user-scoped provider wiped, and
/// navigation sent back to LoginScreen with the whole stack cleared.
class SessionManager {
  SessionManager._();
  static final SessionManager instance = SessionManager._();

  bool _isLoggingOut = false;

  /// Called by ApiClient when a request comes back 401 while a token
  /// was actually attached — i.e. we believed we had a valid session.
  /// (A 401 on /login/ for wrong credentials never reaches this, since
  /// ApiClient only calls this when a saved token existed.)
  Future<void> handleUnauthorized() => logout(showExpiredMessage: true);

  /// Full logout — call this from the Logout button too, not just
  /// TokenStorage.clear(), so provider state gets wiped the same way.
  Future<void> logout({bool showExpiredMessage = false}) async {
    if (_isLoggingOut) return;
    _isLoggingOut = true;

    await TokenStorage.instance.clear();

    final context = NavigationService.navigatorKey.currentContext;
    if (context != null) {
      _resetUserScopedProviders(context);
    }

    NavigationService.navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );

    if (showExpiredMessage) {
      NavigationService.scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text('Your session has expired. Please log in again.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    _isLoggingOut = false;
  }

  void _resetUserScopedProviders(BuildContext context) {
    context.read<CartViewModel>().reset();
    context.read<AddressViewModel>().reset();
    context.read<OrderListViewModel>().reset();
    context.read<OrderDetailViewModel>().reset();
    context.read<PlaceOrderViewModel>().reset();
    context.read<NotificationViewModel>().reset();
    context.read<RecentlyViewedViewModel>().reset();
    // Note: favorites currently live as local State in MainTabScreen,
    // not a provider — pushAndRemoveUntil above creates a brand new
    // MainTabScreen instance on next login, so that Set resets to
    // empty automatically. Nothing to do here for it.
  }
}