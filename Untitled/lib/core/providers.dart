// import 'env_config.dart';

import 'package:ecommerce_app/core/env_config.dart';

/// Central registry of EVERY API endpoint used in the app.
/// Services must never hardcode a URL string — they call a getter here.
class ApiEndpoints {
  ApiEndpoints._();

  // ---------------------------------------------------------------------
  // Auth — accounts service
  // ---------------------------------------------------------------------
  static String get register =>
      '${EnvConfig.accountsBaseUrl}/api/accounts/register/';

  static String get registerVerify =>
      '${EnvConfig.accountsBaseUrl}/api/accounts/register-verify/';

  // ---------------------------------------------------------------------
  // Login
  // ---------------------------------------------------------------------
  static String get login => '${EnvConfig.authBaseUrl}/api/accounts/login/';

  // ---------------------------------------------------------------------
  // Social login (Google / Apple)
  // ---------------------------------------------------------------------
  static String get socialLogin =>
      '${EnvConfig.accountsBaseUrl}/api/accounts/auth/social/';

  // ---------------------------------------------------------------------
  // Forgot password (forgot -> verify OTP -> reset)
  // ---------------------------------------------------------------------
  static String get forgotPassword =>
      '${EnvConfig.accountsBaseUrl}/api/accounts/forgot-password/';

  static String get verifyResetOtp =>
      '${EnvConfig.accountsBaseUrl}/api/accounts/verify-otp/';

  static String get resetPassword =>
      '${EnvConfig.accountsBaseUrl}/api/accounts/reset-password/';

  // ---------------------------------------------------------------------
  // Product
  // ---------------------------------------------------------------------
  static String get productList =>
      '${EnvConfig.accountsBaseUrl}/api/products/';

  static String productDetail(String id) =>
      '${EnvConfig.accountsBaseUrl}/api/products/$id/';

  static String get bestSellerProducts =>
      '${EnvConfig.accountsBaseUrl}/api/products/bestseller/';

  static String get categories =>
      '${EnvConfig.accountsBaseUrl}/api/products/categories/';

  // ---------------------------------------------------------------------
  // Cart
  // ---------------------------------------------------------------------
  static String get cart => '${EnvConfig.accountsBaseUrl}/api/cart/';

  static String get cartAdd => '${EnvConfig.accountsBaseUrl}/api/cart/add/';

  static String cartUpdate(String cartItemId) =>
      '${EnvConfig.accountsBaseUrl}/api/cart/update/$cartItemId/';

  static String cartRemove(String cartItemId) =>
      '${EnvConfig.accountsBaseUrl}/api/cart/remove/$cartItemId/';

  static String get cartSelectAddress =>
      '${EnvConfig.accountsBaseUrl}/api/cart/select-address/';

  // ---------------------------------------------------------------------
  // Addresses — same URL serves GET (list) and POST (add)
  // ---------------------------------------------------------------------
  static String get addresses =>
      '${EnvConfig.accountsBaseUrl}/api/accounts/addresses/';

  // ---------------------------------------------------------------------
  // Orders
  // ---------------------------------------------------------------------
  static String get orderAdd => '${EnvConfig.accountsBaseUrl}/api/orders/add/';

  static String get orderDirectBuy =>
      '${EnvConfig.accountsBaseUrl}/api/orders/direct-buy/';

  static String get orders => '${EnvConfig.accountsBaseUrl}/api/orders/';

  static String orderDetail(String id) =>
      '${EnvConfig.accountsBaseUrl}/api/orders/$id/';

  static String orderCancel(String id) =>
      '${EnvConfig.accountsBaseUrl}/api/orders/$id/cancel/';

  static String orderReturn(String id) =>
      '${EnvConfig.accountsBaseUrl}/api/orders/$id/return/';

  static String cancelReturn(String returnId) =>
      '${EnvConfig.accountsBaseUrl}/api/orders/cancel-return/$returnId/';

  // ---------------------------------------------------------------------
  // Notifications
  // ---------------------------------------------------------------------
  static String get notifications =>
      '${EnvConfig.accountsBaseUrl}/api/notifications/';

  static String get notificationsUnreadCount =>
      '${EnvConfig.accountsBaseUrl}/api/notifications/unread-count/';

  static String notificationRead(String id) =>
      '${EnvConfig.accountsBaseUrl}/api/notifications/$id/read/';

  static String get notificationsReadAll =>
      '${EnvConfig.accountsBaseUrl}/api/notifications/read-all/';

  // ---------------------------------------------------------------------
  // Payments — Razorpay
  // ---------------------------------------------------------------------
  static String razorpayCreate(String orderId) =>
      '${EnvConfig.accountsBaseUrl}/api/payments/razorpay/create/$orderId/';

  static String get razorpayVerify =>
      '${EnvConfig.accountsBaseUrl}/api/payments/razorpay/verify/';

      static String get addProductReview =>
    '${EnvConfig.accountsBaseUrl}/api/products/reviews/';

static String get myProductReviews =>
    '${EnvConfig.accountsBaseUrl}/api/products/reviews/my/';

static String relatedProducts(String id) =>
    '${EnvConfig.accountsBaseUrl}/api/products/$id/related/';

    static String get checkPincode =>
    '${EnvConfig.accountsBaseUrl}/api/products/check-pincode/';
}