import 'package:flutter/material.dart';

class TextfieldViewmodel extends ChangeNotifier {
  // Define individual controllers
  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController unitPriceController = TextEditingController();
  final TextEditingController totalController = TextEditingController();
  final TextEditingController sgstController = TextEditingController();
  final TextEditingController cgstController = TextEditingController();
  final TextEditingController subTotalController = TextEditingController();

  // Function to initialize controllers with API data
  void initializeControllers({
    required String itemName,
    required String quantity,
    required String unitPrice,
    required String total,
    required String sgst,
    required String cgst,
    required String subTotal,
  }) {
    itemNameController.text = itemName;
    quantityController.text = quantity;
    unitPriceController.text = unitPrice;
    totalController.text = total;
    sgstController.text = sgst;
    cgstController.text = cgst;
    subTotalController.text = subTotal;
    notifyListeners();
  }

  // Function to retrieve updated values
  Map<String, String> getUpdatedValues() {
    return {
      "itemName": itemNameController.text,
      "quantity": quantityController.text,
      "unitPrice": unitPriceController.text,
      "total": totalController.text,
      "sgst": sgstController.text,
      "cgst": cgstController.text,
      "subTotal": subTotalController.text,
    };
  }

  // Dispose controllers to prevent memory leaks
  @override
  void dispose() {
    itemNameController.dispose();
    quantityController.dispose();
    unitPriceController.dispose();
    totalController.dispose();
    sgstController.dispose();
    cgstController.dispose();
    subTotalController.dispose();
    super.dispose();
  }
}
