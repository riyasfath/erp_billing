import 'package:flutter/material.dart';
import 'package:pokakbilling/models/data-models/sales_model.dart';

class SaleModel extends ChangeNotifier {
  final Sale sale = Sale();
  bool isLoading = false;

  void updateCustomerName(String name) {
    sale.customerName = name;
    notifyListeners();
  }

  void updateSerial(String serial) {
    sale.serial = serial;
    notifyListeners();
  }

  void updateSerialNumber(String serialNumber) {
    sale.serialNumber = serialNumber;
    notifyListeners();
  }

  void updateDate(DateTime date) {
    sale.date = date;
    notifyListeners();
  }

  void updateDescription(String description) {
    sale.description = description;
    notifyListeners();
  }

  void updateSubject(String subject) {
    sale.subject = subject;
    notifyListeners();
  }

  Future<void> submitForm() async {
    isLoading = true;
    notifyListeners();

    // Perform submit logic here, e.g., API call or database storage.

    isLoading = false;
    notifyListeners();
  }
}
