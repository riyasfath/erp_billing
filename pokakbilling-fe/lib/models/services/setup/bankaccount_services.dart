// import 'package:dio/dio.dart';
// import 'package:pokakbilling/core/api/api_constants.dart';
// import 'package:pokakbilling/core/api/api_helper.dart';
// import 'package:pokakbilling/models/data-models/setup/bankaccount_model.dart';

// class BankaccountServices {
//   static Future<void> createBankAccount(
//     String bankName,
//     String holderName,
//     String accountNumber,
//     String ifscCode,
//   ) async {
//     final dio = Dio();
//     // final dio = await DioClient().getAuthorizedDio();
//     final apiHelper = ApiHelper(dio);
//     var data = {
//       'bank_name': bankName,
//       'account_holder_name': holderName,
//       'account_number': accountNumber,
//       'ifsc_code': ifscCode,
//       'customer': "2"
//     };
//     print("Sending Bank Account Data: $data");

//     final response = await apiHelper.execute(
//       method: Method.post,
//       url: ApiConstants.bankAccountEndPoint,
//       data: data,
//     );

//     print(response);
//   }

//   static Future<List<BankaccountModel>> getAllAccounts() async {
//     final dio = Dio();
//     // final dio = await DioClient().getAuthorizedDio();

//     final response = await dio.get(
//       ApiConstants.bankAccountEndPoint,
//     );

//     if (response.statusCode == 200) {
//       Map<String, dynamic> jsonData = response.data;
//       List<dynamic> accountJson = jsonData["data"];

//       if (jsonData["status"] == "1") {
//         List<BankaccountModel> accountList =
//             accountJson.map((json) => BankaccountModel.fromJson(json)).toList();

//         return accountList;
//       } else {
//         throw Exception('Error: ${jsonData["message"]}');
//       }
//     } else {
//       throw Exception('Failed to load Bank Account');
//     }
//   }
// }
