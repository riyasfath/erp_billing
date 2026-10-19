// import 'package:flutter/material.dart';
// import 'package:pokakbilling/models/data-models/salesperson_model.dart';
// import 'package:pokakbilling/models/services/sales_person_service.dart';

// class SalesPersonViewmodel extends ChangeNotifier {
//   // ================= LOADING FLAGS =================
//   bool addSalesPersonLoading = false;
//   bool getSalesPersonLoading = false;
//   bool deleteSalesPersonLoading = false;
//   bool singleSalesPersonLoading = false;
//   bool editLoading = false;

//   // ================= DATA =================
//   List<SalesPersonModel> salesPersonList = [];
//   List<SalesPersonModel> singleSalesPersonList = [];

//   String selectedSalesPerson = "";
//   int selectedSalesPersonId = 0;

//   String? errorMessage;

//   SalesPersonViewmodel() {
//     getAllSalesPerson(); // 🔥 REQUIRED for listing
//   }

//   // ================= CREATE =================
//   Future<void> createSalesPerson(
//     String firstName,
//     String lastName,
//     String designation,
//     String country,
//     String state,
//     String city,
//     String address,
//     String email,
//     String phone,
//     String mobile,
//     String incentive,
//     String password,
//     BuildContext context,
//   ) async {
//     try {
//       addSalesPersonLoading = true;
//       notifyListeners();

//       final res = await SalesPersonService.createSalesPerson(
//         firstName,
//         lastName,
//         designation,
//         country,
//         state,
//         city,
//         address,
//         email,
//         phone,
//         mobile,
//         incentive,
//         password,
//       );

//       if (res == null) {
//         await getAllSalesPerson();
//         Navigator.pop(context);
//       } else {
//         errorMessage = res;
//       }
//     } catch (e) {
//       errorMessage = e.toString();
//     } finally {
//       addSalesPersonLoading = false;
//       notifyListeners();
//     }
//   }

//   // ================= GET ALL =================
//   Future<void> getAllSalesPerson() async {
//     try {
//       getSalesPersonLoading = true;
//       errorMessage = null;
//       notifyListeners();

//       salesPersonList = await SalesPersonService.getSalesPersons();
//     } catch (e) {
//       errorMessage = e.toString();
//       salesPersonList = [];
//     } finally {
//       getSalesPersonLoading = false;
//       notifyListeners();
//     }
//   }

//   // ================= GET BY ID =================
//   Future<void> getSalesPersonById(int salesPersonId) async {
//     try {
//       singleSalesPersonLoading = true;
//       notifyListeners();

//       final items = await SalesPersonService.getSalesPersonById(salesPersonId);

//       if (items.isNotEmpty) {
//         singleSalesPersonList = items;
//         selectedSalesPersonId = items.first.salesPersonId;
//         selectedSalesPerson = items.first.fullName;
//       } else {
//         singleSalesPersonList = [];
//       }
//     } catch (e) {
//       errorMessage = e.toString();
//       singleSalesPersonList = [];
//     } finally {
//       singleSalesPersonLoading = false;
//       notifyListeners();
//     }
//   }

//   // ================= DELETE =================
//   Future<void> deleteSalesPerson(
//       int salesPersonId, BuildContext context) async {
//     try {
//       deleteSalesPersonLoading = true;
//       notifyListeners();

//       final res = await SalesPersonService.deleteSalesPerson(salesPersonId);

//       if (res == null) {
//         await getAllSalesPerson();
//       } else {
//         errorMessage = res;
//       }
//     } catch (e) {
//       errorMessage = e.toString();
//     } finally {
//       deleteSalesPersonLoading = false;
//       notifyListeners();
//     }
//   }

//   // ================= EDIT =================
//   // Future<void> editSalesPerson(
//   //   int salesPersonId,
//   //   String firstName,
//   //   String lastName,
//   //   String designation,
//   //   String country,
//   //   String state,
//   //   String city,
//   //   String address,
//   //   String email,
//   //   String phone,
//   //   String mobile,
//   //   String incentive,
//   //   BuildContext context,
//   // ) async {
//   //   try {
//   //     editLoading = true;
//   //     notifyListeners();

//   //     final res = await SalesPersonService.editSalesPerson(
//   //       salesPersonId,
//   //       firstName,
//   //       lastName,
//   //       designation,
//   //       country,
//   //       state,
//   //       city,
//   //       address,
//   //       email,
//   //       phone,
//   //       mobile,
//   //       incentive,
//   //     );

//   //     if (res == null) {
//   //       await getAllSalesPerson();
//   //       Navigator.pop(context);
//   //     } else {
//   //       errorMessage = res;
//   //     }
//   //   } catch (e) {
//   //     errorMessage = e.toString();
//   //   } finally {
//   //     editLoading = false;
//   //     notifyListeners();
//   //   }
//   // }

//   Future<void> editSalesPerson(
//     int salesPersonId,
//     String firstName,
//     String lastName,
//     String designation,
//     String country,
//     String state,
//     String city,
//     String address,
//     String email,
//     String phone,
//     String mobile,
//     String incentive,
//     BuildContext context, {
//     int? linkedUser,
//     String? profilePicture,
//   }) async {
//     try {
//       editLoading = true;
//       notifyListeners();

//       final res = await SalesPersonService.editSalesPerson(
//         salesPersonId,
//         firstName,
//         lastName,
//         designation,
//         country,
//         state,
//         city,
//         address,
//         email,
//         phone,
//         mobile,
//         incentive,
//         linkedUser: linkedUser,
//         profilePicture: profilePicture,
//       );

//       if (res == null) {
//         await getAllSalesPerson();
//         Navigator.pop(context);
//       } else {
//         errorMessage = res;
//       }
//     } catch (e) {
//       errorMessage = e.toString();
//     } finally {
//       editLoading = false;
//       notifyListeners();
//     }
//   }

//   // ================= UI HELPERS =================
//   void selectSalesPerson(String name) {
//     selectedSalesPerson = name;
//     notifyListeners();
//   }

//   void updateSelectedSalesPersonId(int id) {
//     selectedSalesPersonId = id;
//     notifyListeners();
//   }
// }
import 'package:flutter/material.dart';
import 'package:pokakbilling/models/data-models/salesperson_model.dart';
import 'package:pokakbilling/models/services/sales_person_service.dart';

class SalesPersonViewmodel extends ChangeNotifier {
  bool addSalesPersonLoading = false;
  bool getSalesPersonLoading = false;
  bool deleteSalesPersonLoading = false;
  bool singleSalesPersonLoading = false;
  bool editLoading = false;

  List<SalesPersonModel> salesPersonList = [];
  List<SalesPersonModel> singleSalesPersonList = [];

  String selectedSalesPerson = "";
  int selectedSalesPersonId = 0;

  String? errorMessage;

  SalesPersonViewmodel() {
    getAllSalesPerson();
  }

  void reset() {
    salesPersonList = [];
    singleSalesPersonList = [];
    selectedSalesPerson = "";
    selectedSalesPersonId = 0;
    errorMessage = null;
    addSalesPersonLoading = false;
    getSalesPersonLoading = false;
    deleteSalesPersonLoading = false;
    singleSalesPersonLoading = false;
    editLoading = false;
    notifyListeners();
  }

  Future<void> createSalesPerson(
    String firstName,
    String lastName,
    String designation,
    String country,
    String state,
    String city,
    String address,
    String email,
    String phone,
    String mobile,
    String incentive,
    String password,
    BuildContext context,
  ) async {
    try {
      addSalesPersonLoading = true;
      notifyListeners();
      final res = await SalesPersonService.createSalesPerson(
        firstName,
        lastName,
        designation,
        country,
        state,
        city,
        address,
        email,
        phone,
        mobile,
        incentive,
        password,
      );
      if (res == null) {
        await getAllSalesPerson();
        Navigator.pop(context);
      } else {
        errorMessage = res;
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      addSalesPersonLoading = false;
      notifyListeners();
    }
  }

  Future<void> getAllSalesPerson() async {
    try {
      getSalesPersonLoading = true;
      errorMessage = null;
      notifyListeners();
      salesPersonList = await SalesPersonService.getSalesPersons();
    } catch (e) {
      errorMessage = e.toString();
      salesPersonList = [];
    } finally {
      getSalesPersonLoading = false;
      notifyListeners();
    }
  }

  Future<void> getSalesPersonById(int salesPersonId) async {
    try {
      singleSalesPersonLoading = true;
      notifyListeners();
      final items = await SalesPersonService.getSalesPersonById(salesPersonId);
      if (items.isNotEmpty) {
        singleSalesPersonList = items;
        selectedSalesPersonId = items.first.salesPersonId;
        selectedSalesPerson = items.first.fullName;
      } else {
        singleSalesPersonList = [];
      }
    } catch (e) {
      errorMessage = e.toString();
      singleSalesPersonList = [];
    } finally {
      singleSalesPersonLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteSalesPerson(
      int salesPersonId, BuildContext context) async {
    try {
      deleteSalesPersonLoading = true;
      notifyListeners();
      final res = await SalesPersonService.deleteSalesPerson(salesPersonId);
      if (res == null) {
        await getAllSalesPerson();
      } else {
        errorMessage = res;
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      deleteSalesPersonLoading = false;
      notifyListeners();
    }
  }

  Future<void> editSalesPerson(
    int salesPersonId,
    String firstName,
    String lastName,
    String designation,
    String country,
    String state,
    String city,
    String address,
    String email,
    String phone,
    String mobile,
    String incentive,
    BuildContext context, {
    int? linkedUser,
    String? profilePicture,
  }) async {
    try {
      editLoading = true;
      notifyListeners();
      final res = await SalesPersonService.editSalesPerson(
        salesPersonId,
        firstName,
        lastName,
        designation,
        country,
        state,
        city,
        address,
        email,
        phone,
        mobile,
        incentive,
        linkedUser: linkedUser,
        profilePicture: profilePicture,
      );
      if (res == null) {
        await getAllSalesPerson();
        Navigator.pop(context);
      } else {
        errorMessage = res;
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      editLoading = false;
      notifyListeners();
    }
  }

  void selectSalesPerson(String name) {
    selectedSalesPerson = name;
    notifyListeners();
  }

  void updateSelectedSalesPersonId(int id) {
    selectedSalesPersonId = id;
    notifyListeners();
  }
}
