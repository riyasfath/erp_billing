import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class ExpenseViewmodel extends ChangeNotifier {
  bool addExpenseLoader = false;
  String? selectedFileName;

  // ── ADD THIS ──
  void reset() {
    addExpenseLoader = false;
    selectedFileName = null;
    notifyListeners();
  }
  // ─────────────

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );
    if (result != null) {
      selectedFileName = result.files.single.name;
      notifyListeners();
      print("Selected file: ${result.files.single.path}");
    }
  }
}
