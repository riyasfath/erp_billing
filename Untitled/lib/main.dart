import 'package:ecommerce_app/admin/admin_viewmodel/admin_auth_viewmodel.dart';
import 'package:ecommerce_app/admin/admin_viewmodel/admin_customer_viewmodel.dart';
import 'package:ecommerce_app/admin/admin_viewmodel/admin_dashboard_viewmodel.dart';
import 'package:ecommerce_app/admin/admin_viewmodel/admin_employee_viewmodel.dart';
import 'package:ecommerce_app/admin/admin_viewmodel/admin_order_viewmodel.dart';
import 'package:ecommerce_app/admin/admin_viewmodel/admin_payment_viewmodel.dart';
import 'package:ecommerce_app/admin/admin_viewmodel/admin_product_viewmodel.dart';
import 'package:ecommerce_app/admin/admin_viewmodel/admin_return_viewmodel.dart';
import 'package:ecommerce_app/admin/admin_viewmodel/admin_support_viewmodel.dart';
import 'package:ecommerce_app/core/env_config.dart';
import 'package:ecommerce_app/viewmodel/address_viewmodel.dart';
import 'package:ecommerce_app/viewmodel/admin_notification_viewmodel.dart';
import 'package:ecommerce_app/viewmodel/auth_viewmodel.dart';
import 'package:ecommerce_app/viewmodel/best_seller_viewmodel.dart';
import 'package:ecommerce_app/viewmodel/cart_viewmodel.dart';
import 'package:ecommerce_app/viewmodel/category_viewmodel.dart';
import 'package:ecommerce_app/viewmodel/favorites_viewmodel.dart';
import 'package:ecommerce_app/viewmodel/login_viewmodel.dart';
import 'package:ecommerce_app/viewmodel/notification_viewmodel.dart';
import 'package:ecommerce_app/viewmodel/order_detail_viewmodel.dart';
import 'package:ecommerce_app/viewmodel/order_list_viewmodel.dart';
import 'package:ecommerce_app/viewmodel/password_reset_viewmodel.dart';
import 'package:ecommerce_app/viewmodel/pincode_viewmodel.dart';
import 'package:ecommerce_app/viewmodel/place_order_viewmodel.dart';
import 'package:ecommerce_app/viewmodel/product_details_viewmodel.dart';
import 'package:ecommerce_app/viewmodel/product_review_viewmodel.dart';
import 'package:ecommerce_app/viewmodel/product_viewmodel.dart';
import 'package:ecommerce_app/viewmodel/recently_viewmodel.dart';
import 'package:ecommerce_app/viewmodel/related_products_viewmodel.dart';
import 'package:ecommerce_app/viewmodel/social_auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnvConfig.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => SocialAuthViewModel()),
        ChangeNotifierProvider(create: (_) => PasswordResetViewModel()),
        ChangeNotifierProvider(create: (_) => ProductViewModel()),
        ChangeNotifierProvider(create: (_) => ProductDetailViewModel()),
        ChangeNotifierProvider(create: (_) => BestSellerViewModel()),
        ChangeNotifierProvider(create: (_) => CategoryViewModel()),
        ChangeNotifierProvider(create: (_) => CartViewModel()),
        ChangeNotifierProvider(create: (_) => AddressViewModel()),
        ChangeNotifierProvider(create: (_) => OrderListViewModel()),
        ChangeNotifierProvider(create: (_) => OrderDetailViewModel()),
        ChangeNotifierProvider(create: (_) => PlaceOrderViewModel()),
        ChangeNotifierProvider(create: (_) => NotificationViewModel()),
        ChangeNotifierProvider(create: (_) => RecentlyViewedViewModel()),
        // Admin module — same app now, so the shared LoginScreen can
        // fall back into AdminShell after a failed customer login.
        ChangeNotifierProvider(create: (_) => AdminAuthViewModel()),
        ChangeNotifierProvider(create: (_) => AdminDashboardViewModel()),
        ChangeNotifierProvider(create: (_) => AdminProductViewModel()),
        ChangeNotifierProvider(create: (_) => AdminOrderViewModel()),
        ChangeNotifierProvider(create: (_) => AdminReturnViewModel()),
        ChangeNotifierProvider(create: (_) => AdminPaymentViewModel()),
        ChangeNotifierProvider(create: (_) => AdminEmployeeViewModel()),
        ChangeNotifierProvider(create: (_) => AdminCustomerViewModel()),
        ChangeNotifierProvider(create: (_) => AdminSupportViewModel()),
        ChangeNotifierProvider(create: (_) => AdminNotificationViewModel()),
        ChangeNotifierProvider(create: (_) => FavoritesViewModel()),
        ChangeNotifierProvider(create: (_) => ProductReviewViewModel()),
        ChangeNotifierProvider(create: (_) => RelatedProductsViewModel()),
        ChangeNotifierProvider(create: (_) => PincodeViewModel()),
      ],
      child: const KicksApp(),
    ),
  );
}