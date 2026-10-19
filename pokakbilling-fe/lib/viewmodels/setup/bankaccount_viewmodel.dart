// import 'package:flutter/material.dart';
// import 'package:pokakbilling/core/api/api_exception.dart';
// import 'package:pokakbilling/core/navigations.dart';
// import 'package:pokakbilling/models/data-models/setup/bankaccount_model.dart';
// import 'package:pokakbilling/models/services/setup/bankaccount_services.dart';
// import 'package:pokakbilling/views/Screens/SetUp/bank_account/bank_account.dart';
// import 'package:pokakbilling/views/commonWidgets/response-message/error_message.dart';
// import 'package:pokakbilling/views/commonWidgets/response-message/success-message.dart';

// class BankaccountViewmodel extends ChangeNotifier {
//   bool createLoading = false;
//   bool getAccountLoader = false;
//   var accountList = <BankaccountModel>[];
//   int selectedAccountId = 0;
//   String selectedBankAcc = "";

//   BankaccountViewmodel() {
//     getAllBankAccount();
//   }

//   void updateSelectedAccId(int accountId) {
//     selectedAccountId = accountId;
//     notifyListeners();
//   }

//   void selectBankAcc(String name) {
//     selectedBankAcc = name;
//     notifyListeners();
//   }

//   Future<void> createBankAccount(
//     bankName,
//     holderName,
//     accountNumber,
//     ifscCode,
//     BuildContext context,
//   ) async {
//     try {
//       createLoading = true;
//       notifyListeners();

//       await BankaccountServices.createBankAccount(
//         bankName,
//         holderName,
//         accountNumber,
//         ifscCode,
//       );

//       if (!context.mounted) return;
//       showSuccessMessage(context, "Bank Account Created Successfully!");
//       getAllBankAccount();
//       pushAndRemoveUntilFun(context, const BankAccountMain());
//     } on ApiException catch (e) {
//       if (!context.mounted) return;
//       showOverlayError(context, e.message);
//     } catch (e) {
//       if (!context.mounted) return;
//       showOverlayError(context, "Something went wrong. Please try again.");
//       print("Unexpected error: $e");
//     } finally {
//       createLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<void> getAllBankAccount() async {
//     try {
//       getAccountLoader = true;
//       notifyListeners();
//       List<BankaccountModel> categoryItems =
//           await BankaccountServices.getAllAccounts();

//       if (categoryItems.isNotEmpty) {
//         accountList = categoryItems;
//       } else {
//         accountList.clear();
//       }
//     } catch (e) {
//       print(e);
//     } finally {
//       getAccountLoader = false;
//       notifyListeners();
//     }
//   }
// }
