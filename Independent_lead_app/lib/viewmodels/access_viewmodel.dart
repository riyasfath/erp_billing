// // // import 'package:flutter/material.dart';
// // // import 'package:pokakbilling/core/services.dart';
// // // import 'package:pokakbilling/models/services/global_services.dart';

// // // class AccessViewModel extends ChangeNotifier {
// // //   bool checkingIsLoggedIn = false;
// // //   bool isModuleLoading = true;
// // //   List<String> userModules = [];
// // //   SecureStorageService secureStorage = SecureStorageService();

// // //   AccessViewModel() {
// // //     checkLoginStatus();
// // //     fetchModules();
// // //   }

// // //   void reset() {
// // //     checkingIsLoggedIn = false;
// // //     isModuleLoading = false;
// // //     userModules = [];
// // //     notifyListeners();
// // //   }

// // //   Future<void> isLogin() async {
// // //     checkingIsLoggedIn = true;
// // //     notifyListeners();
// // //   }

// // //   Future<void> isLogout() async {
// // //     await secureStorage.deleteToken();
// // //     checkingIsLoggedIn = false;
// // //     notifyListeners();
// // //   }

// // //   Future<void> checkLoginStatus() async {
// // //     String? token = await secureStorage.getToken();
// // //     checkingIsLoggedIn = token != null;
// // //     notifyListeners();
// // //   }

// // //   Future<void> fetchModules() async {
// // //     try {
// // //       isModuleLoading = true;
// // //       notifyListeners();
// // //       userModules = await GlobalServices.getUserModules();
// // //     } catch (e) {
// // //       debugPrint("Module fetch error: $e");
// // //       userModules = [];
// // //     } finally {
// // //       isModuleLoading = false;
// // //       notifyListeners();
// // //     }
// // //   }
// // // }
// // import 'package:flutter/material.dart';
// // import 'package:pokakbilling/core/services.dart';
// // import 'package:pokakbilling/models/services/global_services.dart';

// // class AccessViewModel extends ChangeNotifier {
// //   bool checkingIsLoggedIn = false;
// //   bool isModuleLoading = true;
// //   List<String> userModules = [];
// //   SecureStorageService secureStorage = SecureStorageService();

// //   AccessViewModel() {
// //     checkLoginStatus();
// //   }

// //   void reset() {
// //     checkingIsLoggedIn = false;
// //     isModuleLoading = false;
// //     userModules = [];
// //     notifyListeners();
// //   }

// //   Future<void> isLogin() async {
// //     checkingIsLoggedIn = true;
// //     notifyListeners();
// //     await fetchModules();
// //   }

// //   Future<void> isLogout() async {
// //     await secureStorage.deleteToken();
// //     checkingIsLoggedIn = false;
// //     userModules = [];
// //     notifyListeners();
// //   }

// //   Future<void> checkLoginStatus() async {
// //     String? token = await secureStorage.getToken();
// //     checkingIsLoggedIn = token != null;
// //     notifyListeners();

// //     if (checkingIsLoggedIn) {
// //       await fetchModules();
// //     } else {
// //       isModuleLoading = false;
// //       notifyListeners();
// //     }
// //   }

// //   Future<void> fetchModules() async {
// //     try {
// //       isModuleLoading = true;
// //       notifyListeners();
// //       userModules = await GlobalServices.getUserModules();
// //     } catch (e) {
// //       debugPrint("Module fetch error: $e");
// //       userModules = [];
// //     } finally {
// //       isModuleLoading = false;
// //       notifyListeners();
// //     }
// //   }
// // }import 'package:dio/dio.dart';
// import 'package:dio/dio.dart';
// import 'package:pokakbilling/core/api/api_constants.dart';
// import 'package:pokakbilling/core/api/dio_client.dart';

// class GlobalServices {
//   static Future<String?> getGeneratedNumbers(String type) async {
//     final dio = Dio();

//     final response = await dio.get(
//       ApiConstants.generateNumberEndPoint(type),
//     );

//     if (response.statusCode == 200) {
//       Map<String, dynamic> jsonData = response.data;

//       if (jsonData["status"] == "1") {
//         return jsonData["order_number"];
//       } else {
//         throw Exception('Error: ${jsonData["message"]}');
//       }
//     } else {
//       throw Exception('Failed to load order number');
//     }
//   }

//   static Future<List<String>> getUserModules() async {
//     final dio = await DioClient().getAuthorizedDio();

//     final response = await dio.get(ApiConstants.userAccessModulesEndpoint);

//     if (response.statusCode == 200) {
//       Map<String, dynamic> jsonData = response.data;
//       if (jsonData.containsKey("modules") && jsonData["modules"] is List) {
//         return List<String>.from(jsonData["modules"]);
//       } else {
//         throw Exception("Invalid response format");
//       }
//     } else if (response.statusCode == 401 || response.statusCode == 403) {
//       // Not logged in / token invalid — expected pre-auth state, not a
//       // real error, so don't throw. Caller just gets an empty list.
//       return [];
//     } else {
//       throw Exception(
//           'Failed to load user modules (status ${response.statusCode})');
//     }
//   }
// }import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:pokakbilling/core/services.dart';
import 'package:pokakbilling/models/services/global_services.dart';

class AccessViewModel extends ChangeNotifier {
  bool checkingIsLoggedIn = false;
  bool isModuleLoading = true;
  List<String> userModules = [];
  SecureStorageService secureStorage = SecureStorageService();

  AccessViewModel() {
    checkLoginStatus();
  }

  void reset() {
    checkingIsLoggedIn = false;
    isModuleLoading = false;
    userModules = [];
    notifyListeners();
  }

  Future<void> isLogin() async {
    checkingIsLoggedIn = true;
    notifyListeners();
    await fetchModules();
  }

  Future<void> isLogout() async {
    await secureStorage.deleteToken();
    checkingIsLoggedIn = false;
    userModules = [];
    notifyListeners();
  }

  Future<void> checkLoginStatus() async {
    String? token = await secureStorage.getToken();
    checkingIsLoggedIn = token != null;
    notifyListeners();

    if (checkingIsLoggedIn) {
      await fetchModules();
    } else {
      isModuleLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchModules() async {
    try {
      isModuleLoading = true;
      notifyListeners();
      userModules = await GlobalServices.getUserModules();
    } catch (e) {
      debugPrint("Module fetch error: $e");
      userModules = [];
    } finally {
      isModuleLoading = false;
      notifyListeners();
    }
  }
}