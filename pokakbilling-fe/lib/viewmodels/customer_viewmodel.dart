import 'package:flutter/material.dart';
import 'package:pokakbilling/models/data-models/customer_model.dart';
import 'package:pokakbilling/models/services/customer_services.dart';
import 'package:pokakbilling/views/Screens/customer/customer_main.dart';
import 'package:pokakbilling/views/commonWidgets/response-message/error_message.dart';
import 'package:pokakbilling/views/commonWidgets/response-message/success-message.dart';
import 'package:pokakbilling/core/navigations.dart';

class CustomerViewmodel extends ChangeNotifier {
  bool createLoading = false;
  bool isLoading = false;
  bool getCustomerLoader = false;
  bool singleCustomerLoading = false;
  bool deleteCustomerLoading = false;
  bool editLoading = false;

  var customerList = <CustomerModel>[];
  var singleCustomerList = <CustomerModel>[];
  String selectedCustomer = "";
  int selectedCustomerId = 0;

  final Map<int, bool> _canDeleteMap = {};
  final Map<int, String> _cannotDeleteReasonMap = {};

  bool canDeleteCustomer(int customerId) => _canDeleteMap[customerId] ?? true;
  String cannotDeleteReason(int customerId) =>
      _cannotDeleteReasonMap[customerId] ??
      'This customer is linked to existing records and cannot be deleted.';

  CustomerViewmodel() {
    getAllCustomers();
  }

  // ── reset ──────────────────────────────────────────────────────────────────
  void reset() {
    customerList = [];
    singleCustomerList = [];
    selectedCustomer = "";
    selectedCustomerId = 0;
    _canDeleteMap.clear();
    _cannotDeleteReasonMap.clear();
    createLoading = false;
    isLoading = false;
    getCustomerLoader = false;
    singleCustomerLoading = false;
    deleteCustomerLoading = false;
    editLoading = false;
    notifyListeners();
  }

  void clearData() => reset();

  void selectCustomer(String name) {
    selectedCustomer = name;
    notifyListeners();
  }

  void updateSelectedCustomerId(int customerId) {
    selectedCustomerId = customerId;
    notifyListeners();
  }

  // ── CREATE ─────────────────────────────────────────────────────────────────
  Future<void> createCustomer({
    required String moduleType,
    required String firstName,
    required String lastName,
    required String companyName,
    required String country,
    required String state,
    required String address,
    required String email,
    required String phone,
    required String mobile,
    required int salesPersonId,
    required String gstNumber,
    int? leadId,
    required BuildContext context,
  }) async {
    try {
      createLoading = true;
      notifyListeners();

      final String? response = await CustomerServices.createCustomer(
        moduleType: moduleType,
        firstName: firstName,
        lastName: lastName,
        companyName: companyName,
        country: country,
        state: state,
        address: address,
        email: email,
        phone: phone,
        mobile: mobile,
        salesPersonId: salesPersonId,
        gstNumber: gstNumber,
        leadId: leadId,
      );

      if (response == null) {
        if (!context.mounted) return;
        showSuccessMessage(context, "Customer Created Successfully!");
        getAllCustomers();
        pushReplacementNavigation(context, const CustomerMain());
      } else {
        if (!context.mounted) return;
        showOverlayError(context, response);
      }
    } catch (e) {
      debugPrint('createCustomer error: $e');
    } finally {
      createLoading = false;
      notifyListeners();
    }
  }

  // ── GET ALL ────────────────────────────────────────────────────────────────
  Future<void> getAllCustomers() async {
    try {
      getCustomerLoader = true;
      notifyListeners();
      final List<CustomerModel> customerItems =
          await CustomerServices.getCustomers();
      if (customerItems.isNotEmpty) {
        customerList = customerItems;
      } else {
        customerList.clear();
      }
    } catch (e) {
      debugPrint('getAllCustomers error: $e');
    } finally {
      getCustomerLoader = false;
      notifyListeners();
    }
  }

  // ── GET BY ID ──────────────────────────────────────────────────────────────
  Future<void> getCustomerById(int customerId) async {
    try {
      singleCustomerLoading = true;
      notifyListeners();
      final List<CustomerModel> customerItems =
          await CustomerServices.getCustomerById(customerId);
      if (customerItems.isNotEmpty) {
        singleCustomerList = customerItems;
      } else {
        singleCustomerList.clear();
      }
    } catch (e) {
      debugPrint('getCustomerById error: $e');
    } finally {
      singleCustomerLoading = false;
      notifyListeners();
    }
  }

  // ── DELETE ─────────────────────────────────────────────────────────────────
  Future<void> deleteCustomer(int customerId, BuildContext context) async {
    try {
      deleteCustomerLoading = true;
      notifyListeners();

      final String? response =
          await CustomerServices.deleteCustomer(customerId);

      if (response == null) {
        _canDeleteMap.remove(customerId);
        _cannotDeleteReasonMap.remove(customerId);
        if (!context.mounted) return;
        showSuccessMessage(context, "Customer Deleted Successfully!");
        getAllCustomers();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const CustomerMain()),
          (route) => false,
        );
      } else {
        _canDeleteMap[customerId] = false;
        _cannotDeleteReasonMap[customerId] = response;
        notifyListeners();
        if (!context.mounted) return;
        showOverlayError(context, response);
      }
    } catch (e) {
      debugPrint('deleteCustomer error: $e');
    } finally {
      deleteCustomerLoading = false;
      notifyListeners();
    }
  }

  // ── EDIT ───────────────────────────────────────────────────────────────────
  Future<void> editCustomer({
    required int customerId,
    required String moduleType,
    required String firstName,
    required String lastName,
    required String companyName,
    required String country,
    required String state,
    required String address,
    required String email,
    required String phone,
    required String mobile,
    required int salesPersonId,
    required String gstNumber,
    int? leadId,
    required BuildContext context,
  }) async {
    try {
      editLoading = true;
      notifyListeners();

      final String? response = await CustomerServices.editCustomer(
        customerId: customerId,
        moduleType: moduleType,
        firstName: firstName,
        lastName: lastName,
        companyName: companyName,
        country: country,
        state: state,
        address: address,
        email: email,
        phone: phone,
        mobile: mobile,
        salesPersonId: salesPersonId,
        gstNumber: gstNumber,
        leadId: leadId,
      );

      if (response == null) {
        if (!context.mounted) return;
        showSuccessMessage(
            context, "Customer information has been successfully updated!");
        getAllCustomers();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const CustomerMain()),
          (route) => false,
        );
      } else {
        if (!context.mounted) return;
        showOverlayError(context, response);
      }
    } catch (e) {
      debugPrint('editCustomer error: $e');
    } finally {
      editLoading = false;
      notifyListeners();
    }
  }
}
