import 'package:flutter/material.dart';
import 'package:pokakbilling/models/data-models/customer_model.dart';
import 'package:pokakbilling/models/services/customer_services.dart';
import 'package:pokakbilling/views/Screens/customer/customer_main.dart';
import 'package:pokakbilling/views/commonWidgets/response-message/error_message.dart';
import 'package:pokakbilling/views/commonWidgets/response-message/success-message.dart';

class CustomerViewmodel extends ChangeNotifier {
  bool createLoading = false;
  bool isLoading = false;
  bool deleteCustomerLoading = false;
  bool editLoading = false;
  var singleCustomerList = <CustomerModel>[];
  bool getCustomerLoader = false;
  bool singleCustomerLoading = false;
  List<CustomerModel> customerList = [];
  CustomerModel? singleCustomer;
  int selectedCustomerId = 0;
  String selectedCustomer = "";

  // ✅ Removed getAllCustomers() from constructor to avoid setState during build
  CustomerViewmodel();

  int? selectedContractId;
  String? selectedContractName;

  void clearSelectedContract() {
    selectedContractId = null;
    selectedContractName = null;
    notifyListeners();
  }

  void selectContract(int id, String name) {
    selectedContractId = id;
    selectedContractName = name;
    notifyListeners();
  }

  // ================= CREATE =================
  Future<void> createCustomer(
    int? customerTypeId,
    String firstName,
    String lastName,
    String companyName,
    String email,
    String phone,
    String mobile,
    String address,
    String stateName,
    String countryName,
    int salesPersonId,
    int? contractId,
    BuildContext context,
  ) async {
    try {
      createLoading = true;
      notifyListeners();

      String? response = await CustomerServices.createCustomer(
        customerTypeId,
        firstName,
        lastName,
        companyName,
        email,
        phone,
        mobile,
        address,
        stateName,
        countryName,
        salesPersonId,
        contractId,
      );

      if (response == null) {
        if (!context.mounted) return;
        showSuccessMessage(context, "Customer Created Successfully!");
        await getAllCustomers();
        if (!context.mounted) return;
        // ✅ Navigate to CustomerMain (list screen) instead of ViewCustomer
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const CustomerMain()),
          (route) => false,
        );
      } else {
        if (!context.mounted) return;
        showOverlayError(context, response);
      }
    } catch (e) {
      print(e);
    } finally {
      createLoading = false;
      notifyListeners();
    }
  }

  // ================= GET ALL =================
  Future<void> getAllCustomers() async {
    try {
      getCustomerLoader = true;
      notifyListeners();
      customerList = await CustomerServices.getCustomers();
    } catch (e) {
      print(e);
    } finally {
      getCustomerLoader = false;
      notifyListeners();
    }
  }

  // ==================CUSTOMER BY ID========================
  Future<void> getCustomerById(int id) async {
    try {
      singleCustomerLoading = true;
      notifyListeners();
      singleCustomer = await CustomerServices.getCustomerById(id);
    } catch (e) {
      print(e);
    } finally {
      singleCustomerLoading = false;
      notifyListeners();
    }
  }

  // =================UI HELPER===================
  void updateSelectedCustomerId(int id) {
    selectedCustomerId = id;
    notifyListeners();
  }

  void selectCustomer(String name) {
    selectedCustomer = name;
    notifyListeners();
  }

  // ========================DELETE=============================
  Future<void> deleteCustomer(int customerId, BuildContext context) async {
    try {
      deleteCustomerLoading = true;
      notifyListeners();
      String? response = await CustomerServices.deleteCustomer(customerId);

      if (response == null) {
        await getAllCustomers();
        if (!context.mounted) return;
        showSuccessMessage(context, "Customer Deleted Successfully!");
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const CustomerMain()),
          (route) => false,
        );
      } else {
        if (!context.mounted) return;
        showOverlayError(context, response);
      }
    } catch (e) {
      print(e);
    } finally {
      deleteCustomerLoading = false;
      notifyListeners();
    }
  }

  // ======================EDIT==========================
  Future<void> editCustomer(
    int? customerId,
    int? customerTypeId,
    String firstName,
    String lastName,
    String companyName,
    String email,
    String phone,
    String mobile,
    String address,
    String stateName,
    String countryName,
    int? salesPersonId,
    int? contractId,
    BuildContext context,
  ) async {
    try {
      editLoading = true;
      notifyListeners();

      String? response = await CustomerServices.editCustomer(
        customerId,
        customerTypeId,
        firstName,
        lastName,
        companyName,
        email,
        phone,
        mobile,
        address,
        stateName,
        countryName,
        salesPersonId,
        contractId,
      );

      if (response == null) {
        if (!context.mounted) return;
        showSuccessMessage(
            context, "Customer information has been successfully updated!");
        await getAllCustomers();
        if (!context.mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const CustomerMain()),
          (route) => false,
        );
      } else {
        if (!context.mounted) return;
        showOverlayError(context, response);
      }
    } catch (e) {
      print(e);
    } finally {
      editLoading = false;
      notifyListeners();
    }
  }

  // ================= CLEAR CONTRACT FROM CUSTOMER =================
  void removeContractFromCustomer(int customerId) {
    final index = customerList.indexWhere((c) => c.customerId == customerId);
    if (index != -1) {
      customerList[index].contractId = null;
      customerList[index].contractName = null;
      notifyListeners();
    }
  }

  // ✅ Customer type helpers
  int? selectedCustomerTypeId;
  String? selectedCustomerTypeName;

  void selectCustomerType(int id, String name) {
    selectedCustomerTypeId = id;
    selectedCustomerTypeName = name;
    notifyListeners();
  }

  void clearCustomerType() {
    selectedCustomerTypeId = null;
    selectedCustomerTypeName = null;
    notifyListeners();
  }

  void reset() {
    // clear your quotation lists and loading flags
    notifyListeners();
  }
}
