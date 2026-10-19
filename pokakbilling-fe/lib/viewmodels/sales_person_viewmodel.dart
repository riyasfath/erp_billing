import 'package:flutter/material.dart';
import 'package:pokakbilling/models/data-models/addQuotation_model.dart';
import 'package:pokakbilling/models/data-models/salesperson_model.dart';
import 'package:pokakbilling/models/services/sales_person_service.dart';
import 'package:pokakbilling/views/commonWidgets/response-message/error_message.dart';
import 'package:pokakbilling/views/commonWidgets/response-message/success-message.dart';

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

  // ── Date filter state ──────────────────────────────────────────────────────
  List<SalesPersonModel> _filteredSalesPersonList = [];
  DateTime? _fromDate;
  DateTime? _toDate;

  /// The list consumed by the UI — always reflects the active date filter.
  /// Falls back to the full list when no date filter is active.
  List<SalesPersonModel> get filteredSalesPersonList =>
      _filteredSalesPersonList;

  List<AddQuotationModel> itemList = [];

  int total = 0;
  String grandTotal = "";

  String? errorMessage;

  SalesPersonViewmodel() {
    getAllSalesPerson();
  }

  // ── Date filter ────────────────────────────────────────────────────────────

  /// Filters [salesPersonList] by [fromDate] and/or [toDate].
  /// Pass null for either bound to leave that side open.
  /// Pass null for both to clear the filter (shows all records).
  void filterByDateRange(DateTime? fromDate, DateTime? toDate) {
    _fromDate = fromDate;
    _toDate = toDate;

    if (_fromDate == null && _toDate == null) {
      // No active filter — always show all records
      _filteredSalesPersonList = List.from(salesPersonList);
    } else {
      _filteredSalesPersonList = salesPersonList.where((person) {
        final DateTime? personDate = person.createdDate;
        if (personDate == null) return false;

        // Normalise to midnight so time-of-day differences are ignored
        final DateTime personDay =
            DateTime(personDate.year, personDate.month, personDate.day);

        if (_fromDate != null && _toDate != null) {
          final DateTime from =
              DateTime(_fromDate!.year, _fromDate!.month, _fromDate!.day);
          final DateTime to =
              DateTime(_toDate!.year, _toDate!.month, _toDate!.day);
          return !personDay.isBefore(from) && !personDay.isAfter(to);
        } else if (_fromDate != null) {
          final DateTime from =
              DateTime(_fromDate!.year, _fromDate!.month, _fromDate!.day);
          return !personDay.isBefore(from);
        } else {
          // Only toDate is set
          final DateTime to =
              DateTime(_toDate!.year, _toDate!.month, _toDate!.day);
          return !personDay.isAfter(to);
        }
      }).toList();
    }

    notifyListeners();
  }

  // ── Grand total helpers ────────────────────────────────────────────────────

  void updateGrandTotal() {
    double res = calculateGrandTotal();
    grandTotal = res.toStringAsFixed(2);
    notifyListeners();
  }

  void resetGrandTotal() {
    grandTotal = "";
    notifyListeners();
  }

  double calculateGrandTotal() {
    double grandTotal = 0.0;
    for (var item in itemList) {
      grandTotal += double.tryParse(item.subTotal) ?? 0.0;
    }
    return grandTotal;
  }

  // ── Item list helpers ──────────────────────────────────────────────────────

  void addItem() {
    itemList.add(AddQuotationModel(itemNumber: itemList.length + 1));
    Future.delayed(Duration.zero, () {
      notifyListeners();
    });
  }

  void removeItem(int itemNumber) {
    itemList.removeWhere((item) => item.itemNumber == itemNumber);
    for (int i = 0; i < itemList.length; i++) {
      itemList[i].itemNumber = i + 1;
    }
    updateGrandTotal();
    notifyListeners();
  }

  // ── Sales person selection ─────────────────────────────────────────────────

  void selectSalesPerson(String name) {
    selectedSalesPerson = name;
    notifyListeners();
  }

  void updateSelectedSalesPersonId(int salesPersonId) {
    selectedSalesPersonId = salesPersonId;
    notifyListeners();
  }

  // ── CRUD operations ────────────────────────────────────────────────────────

  Future<bool> createSalesPerson(
    String firstName,
    String lastName,
    String designation,
    String countryName,
    String stateName,
    String address,
    String email,
    String phone,
    String mobile,
    String incentive,
    BuildContext context,
  ) async {
    try {
      addSalesPersonLoading = true;
      errorMessage = null;
      notifyListeners();

      final response = await SalesPersonService.createSalesPerson(
        firstName,
        lastName,
        designation,
        countryName,
        stateName,
        address,
        email,
        phone,
        mobile,
        incentive,
      );

      if (response == null) {
        // Success
        await getAllSalesPerson();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sales Person Created Successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.pop(context);
        }
        return true;
      } else {
        // Error
        errorMessage = response;
        print('createSalesPerson error: $response');

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        return false;
      }
    } catch (e) {
      errorMessage = e.toString();
      print('createSalesPerson exception: $e');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return false;
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

      final items = await SalesPersonService.getSalesPersons();
      salesPersonList = items;
      _filteredSalesPersonList = List.from(items);

      print('DEBUG getAllSalesPerson: fetched ${items.length} items');
      print('DEBUG salesPersonList: ${salesPersonList.length}');
      print(
          'DEBUG filteredSalesPersonList: ${_filteredSalesPersonList.length}');
    } catch (e) {
      final msg = e.toString();
      errorMessage = msg;
      print('getAllSalesPerson error: $msg');
      salesPersonList = [];
      _filteredSalesPersonList = [];
    } finally {
      getSalesPersonLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteSalesPerson(
      int salesPersonId, BuildContext context) async {
    try {
      deleteSalesPersonLoading = true;
      errorMessage = null;
      notifyListeners();

      final response =
          await SalesPersonService.deleteSalesPerson(salesPersonId);

      if (response == null) {
        // Success — same pattern as CustomerViewmodel.deleteCustomer
        if (!context.mounted) return false;
        showSuccessMessage(
          context,
          "Sales Person Deleted Successfully",
        );
        await getAllSalesPerson();
        if (context.mounted) {
          Navigator.pop(context);
        }
        return true;
      } else {
        // Error
        errorMessage = response;
        print('deleteSalesPerson error: $response');

        if (!context.mounted) return false;
        showOverlayError(context, response);
        return false;
      }
    } catch (e) {
      errorMessage = e.toString();
      print('deleteSalesPerson exception: $e');

      if (context.mounted) {
        showOverlayError(context, e.toString());
      }
      return false;
    } finally {
      deleteSalesPersonLoading = false;
      notifyListeners();
    }
  }

  Future<void> getSalesPersonById(int salesPersonId) async {
    try {
      singleSalesPersonLoading = true;
      errorMessage = null;
      notifyListeners();

      final items = await SalesPersonService.getSalesPersonById(salesPersonId);

      if (items.isNotEmpty) {
        singleSalesPersonList = items;
        final p = items.first;
        selectedSalesPerson = p.fullName;
        selectedSalesPersonId = p.salesPersonId;
      } else {
        singleSalesPersonList = [];
      }
    } catch (e) {
      errorMessage = e.toString();
      print('getSalesPersonById error: $e');
      singleSalesPersonList = [];
    } finally {
      singleSalesPersonLoading = false;
      notifyListeners();
    }
  }

  Future<bool> editSalesPerson(
    int salesPersonId,
    String firstName,
    String lastName,
    String designation,
    String countryName,
    String stateName,
    String address,
    String email,
    String phone,
    String mobile,
    String incentive,
    BuildContext context,
  ) async {
    try {
      editLoading = true;
      errorMessage = null;
      notifyListeners();

      final response = await SalesPersonService.editSalesPerson(
        salesPersonId,
        firstName,
        lastName,
        designation,
        countryName,
        stateName,
        address,
        email,
        phone,
        mobile,
        incentive,
      );

      if (response == null) {
        // Success
        await getAllSalesPerson();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sales Person Updated Successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.pop(context);
        }
        return true;
      } else {
        // Error
        errorMessage = response;
        print('editSalesPerson error: $response');

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        return false;
      }
    } catch (e) {
      errorMessage = e.toString();
      print('editSalesPerson exception: $e');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return false;
    } finally {
      editLoading = false;
      notifyListeners();
    }
  }

  // ── Item update ────────────────────────────────────────────────────────────

  void updateItem(int itemNumber, String field, String value) {
    final index = itemList.indexWhere((item) => item.itemNumber == itemNumber);
    if (index == -1) return;

    switch (field) {
      case "selectedProduct":
        itemList[index].selectedProduct = value;
        break;
      case "quantity":
        itemList[index].quantity = value;
        break;
      case "unitPrice":
        itemList[index].unitPrice = value;
        break;
      case "sgst":
        itemList[index].sgst = value;
        break;
      case "cgst":
        itemList[index].cgst = value;
        break;
      case "subTotal":
        itemList[index].subTotal = value;
        break;
    }

    final quantity = int.tryParse(itemList[index].quantity) ?? 0;
    final unitPrice = int.tryParse(itemList[index].unitPrice) ?? 0;
    final kgstPercentage = double.tryParse(itemList[index].sgst) ?? 0.0;
    final cgstPercentage = double.tryParse(itemList[index].cgst) ?? 0.0;

    final total = (quantity > 0 && unitPrice > 0) ? (quantity * unitPrice) : 0;
    itemList[index].total = total.toString();

    final kgstAmount = (total * kgstPercentage) / 100.0;
    final cgstAmount = (total * cgstPercentage) / 100.0;
    final subTotal = total + kgstAmount + cgstAmount;
    itemList[index].subTotal = subTotal.toStringAsFixed(2);

    updateGrandTotal();
    notifyListeners();
  }
}
