// import 'package:flutter/material.dart';
// import 'package:pokakbilling/core/navigations.dart';
// import 'package:pokakbilling/models/services/user_access_services.dart';
// import 'package:pokakbilling/views/Screens/user/module_config.dart';
// import 'package:pokakbilling/views/bottom_bar/bottomNavigationBar/bottom_bar.dart';
// import 'package:pokakbilling/views/commonWidgets/response-message/error_message.dart';
// import 'package:pokakbilling/views/commonWidgets/response-message/success-message.dart';

// class UserAccessViewmodel extends ChangeNotifier {
//   bool createUserAccessLoader = false;
//   var dataItems = [
//     "quotation",
//     "sales_order",
//     "delivery",
//     "client",
//     "sales_person",
//     "leads",
//     "projects",
//     "supplier",
//     "purchase",
//     "material_receive",
//     "invoice",
//     "receipt",
//     "stock",
//     "expense",
//     "reports",
//     "sales_returns",
//     "accounts",
//     "payments",
//   ];

//   List<ModuleConfig> moduleConfigs = [
//     ModuleConfig(
//         key: "quotation", title: "Quotation", icon: Icons.note_add_outlined),
//     ModuleConfig(
//         key: "sales_order", title: "Sales Order", icon: Icons.shopping_cart),
//     ModuleConfig(
//         key: "delivery", title: "Delivery", icon: Icons.local_shipping),
//     ModuleConfig(key: "client", title: "Client", icon: Icons.person),
//     ModuleConfig(
//         key: "sales_person", title: "Sales Person", icon: Icons.people_alt),
//     ModuleConfig(key: "leads", title: "Leads", icon: Icons.leaderboard),
//     ModuleConfig(key: "project_management", title: "Project Management", icon: Icons.show_chart),
//     ModuleConfig(key: "supplier", title: "Supplier", icon: Icons.shopping_bag),
//     ModuleConfig(
//         key: "purchase", title: "Purchase", icon: Icons.shopping_basket),
//     ModuleConfig(
//         key: "material_receive", title: "Material Receive", icon: Icons.work),
//     ModuleConfig(key: "invoice", title: "Invoice", icon: Icons.receipt_long),
//     ModuleConfig(key: "receipt", title: "Receipt", icon: Icons.add_card),
//     ModuleConfig(key: "stock", title: "Stock", icon: Icons.inventory),
//     ModuleConfig(
//         key: "expense", title: "Expense", icon: Icons.account_balance_wallet),
//     ModuleConfig(key: "reports", title: "Reports", icon: Icons.flag),
//     ModuleConfig(
//         key: "sales_returns", title: "Sales Returns", icon: Icons.assignment_returned),
//     ModuleConfig(
//         key: "accounts", title: "Accounts", icon: Icons.account_circle),
//     ModuleConfig(
//         key: "payments", title: "Payments", icon: Icons.account_balance),
//     ModuleConfig(key: "setup", title: "Set Up", icon: Icons.donut_large),
//   ];

//   Future<void> createUserAccess(
//     firstName,
//     lastName,
//     email,
//     password,
//     List<String> modules,
//     BuildContext context,
//   ) async {
//     try {
//       createUserAccessLoader = true;
//       notifyListeners();

//       String? response = await UserAccessServices.allowUserAccess(
//         firstName,
//         lastName,
//         email,
//         password,
//         modules,
//       );

//       if (response == null) {
//         if (!context.mounted) return;
//         showSuccessMessage(
//           context,
//           "Access Allowed to the User!",
//         );
//         pushAndRemoveUntilFun(context, const BottomBar(index: 0));
//       } else {
//         if (!context.mounted) return;
//         showOverlayError(context, response);
//       }
//     } catch (e) {
//       print(e);
//     } finally {
//       createUserAccessLoader = false;
//       notifyListeners();
//     }
//   }
// }
import 'package:flutter/material.dart';
import 'package:pokakbilling/core/navigations.dart';
import 'package:pokakbilling/models/services/user_access_services.dart';
import 'package:pokakbilling/views/Screens/user/module_config.dart';
import 'package:pokakbilling/views/bottom_bar/bottomNavigationBar/bottom_bar.dart';
import 'package:pokakbilling/views/commonWidgets/response-message/error_message.dart';
import 'package:pokakbilling/views/commonWidgets/response-message/success-message.dart';

class UserAccessViewmodel extends ChangeNotifier {
  bool createUserAccessLoader = false;

  var dataItems = [
    "quotation",
    "sales_order",
    "delivery",
    "client",
    "sales_person",
    "leads",
    "projects",
    "supplier",
    "purchase",
    "material_receive",
    "invoice",
    "receipt",
    "stock",
    "expense",
    "reports",
    "sales_returns",
    "accounts",
    "payments",
  ];

  List<ModuleConfig> moduleConfigs = [
    ModuleConfig(
        key: "quotation", title: "Quotation", icon: Icons.note_add_outlined),
    ModuleConfig(
        key: "sales_order", title: "Sales Order", icon: Icons.shopping_cart),
    ModuleConfig(
        key: "delivery", title: "Delivery", icon: Icons.local_shipping),
    ModuleConfig(key: "client", title: "Client", icon: Icons.person),
    ModuleConfig(
        key: "sales_person", title: "Sales Person", icon: Icons.people_alt),
    ModuleConfig(key: "leads", title: "Leads", icon: Icons.leaderboard),
    ModuleConfig(
        key: "project_management",
        title: "Project Management",
        icon: Icons.show_chart),
    ModuleConfig(key: "supplier", title: "Supplier", icon: Icons.shopping_bag),
    ModuleConfig(
        key: "purchase", title: "Purchase", icon: Icons.shopping_basket),
    ModuleConfig(
        key: "material_receive", title: "Material Receive", icon: Icons.work),
    ModuleConfig(key: "invoice", title: "Invoice", icon: Icons.receipt_long),
    ModuleConfig(key: "receipt", title: "Receipt", icon: Icons.add_card),
    ModuleConfig(key: "stock", title: "Stock", icon: Icons.inventory),
    ModuleConfig(
        key: "expense", title: "Expense", icon: Icons.account_balance_wallet),
    ModuleConfig(key: "reports", title: "Reports", icon: Icons.flag),
    ModuleConfig(
        key: "sales_returns",
        title: "Sales Returns",
        icon: Icons.assignment_returned),
    ModuleConfig(
        key: "accounts", title: "Accounts", icon: Icons.account_circle),
    ModuleConfig(
        key: "payments", title: "Payments", icon: Icons.account_balance),
    ModuleConfig(key: "setup", title: "Set Up", icon: Icons.donut_large),
  ];

  void reset() {
    createUserAccessLoader = false;
    notifyListeners();
  }

  Future<void> createUserAccess(
    firstName,
    lastName,
    email,
    password,
    List<String> modules,
    BuildContext context,
  ) async {
    try {
      createUserAccessLoader = true;
      notifyListeners();
      String? response = await UserAccessServices.allowUserAccess(
        firstName,
        lastName,
        email,
        password,
        modules,
      );
      if (response == null) {
        if (!context.mounted) return;
        showSuccessMessage(context, "Access Allowed to the User!");
        pushAndRemoveUntilFun(context, const BottomBar(index: 0));
      } else {
        if (!context.mounted) return;
        showOverlayError(context, response);
      }
    } catch (e) {
      print(e);
    } finally {
      createUserAccessLoader = false;
      notifyListeners();
    }
  }
}
