// import 'package:flutter/material.dart';
// import 'package:package_info_plus/package_info_plus.dart';
// import 'package:pokakbilling/models/services/global_services.dart';

// class GlobalViewmodel extends ChangeNotifier {
//   bool getGeneratedNumberLoader = false;
//   String orderNumber = "";
//   String appVersion = "";

//   GlobalViewmodel() {
//     getAppVersion();
//   }

//   Future<void> getAllLeads(type) async {
//     try {
//       getGeneratedNumberLoader = true;
//       notifyListeners();
//       String? responseOrderNumber =
//           await GlobalServices.getGeneratedNumbers(type);

//       if (responseOrderNumber != null) {
//         orderNumber = responseOrderNumber;
//         notifyListeners();
//       } else {
//         orderNumber = "";
//         notifyListeners();
//       }
//     } catch (e) {
//       print(e);
//     } finally {
//       getGeneratedNumberLoader = false;
//       notifyListeners();
//     }
//   }

//   Future<void> getAppVersion() async {
//     final packageInfo = await PackageInfo.fromPlatform();
//     appVersion = packageInfo.version;
//     notifyListeners();
//   }
// }
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pokakbilling/models/services/global_services.dart';

class GlobalViewmodel extends ChangeNotifier {
  bool getGeneratedNumberLoader = false;
  String orderNumber = "";
  String appVersion = "";

  GlobalViewmodel() {
    getAppVersion();
  }

  void reset() {
    orderNumber = "";
    getGeneratedNumberLoader = false;
    notifyListeners();
  }

  Future<void> getAllLeads(type) async {
    try {
      getGeneratedNumberLoader = true;
      notifyListeners();
      String? responseOrderNumber =
          await GlobalServices.getGeneratedNumbers(type);
      if (responseOrderNumber != null) {
        orderNumber = responseOrderNumber;
        notifyListeners();
      } else {
        orderNumber = "";
        notifyListeners();
      }
    } catch (e) {
      print(e);
    } finally {
      getGeneratedNumberLoader = false;
      notifyListeners();
    }
  }

  Future<void> getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    appVersion = packageInfo.version;
    notifyListeners();
  }
}
