import 'package:flutter/material.dart';
import 'package:pokakbilling/models/data-models/setup/unit_model.dart';
import 'package:pokakbilling/models/services/setup/unit_services.dart';
import 'package:pokakbilling/views/Screens/SetUp/unit/unit.dart';
import 'package:pokakbilling/views/commonWidgets/response-message/error_message.dart';
import 'package:pokakbilling/views/commonWidgets/response-message/success-message.dart';

class UnitViewmodel extends ChangeNotifier {
  bool createLoading = false;
  bool getUnitLoader = false;
  bool deleteUnitLoader = false;
  bool singleUnitLoader = false;
  bool editLoading = false;
  var unitList = <UnitModel>[];
  var singleUnitList = <UnitModel>[];
  String selectedUnit = "";

  void selectUnit(String unit) {
    selectedUnit = unit;
    notifyListeners();
  }

  UnitViewmodel() {
    getAllUnits();
  }

  Future<void> createUnit(
    unitName,
    unitDescription,
    BuildContext context,
  ) async {
    try {
      createLoading = true;
      notifyListeners();

      String? response = await UnitServices.createUnit(
        unitName,
        unitDescription,
      );

      if (response == null) {
        if (!context.mounted) return;
        showSuccessMessage(
          context,
          "Unit Created Successfully!",
        );
        getAllUnits();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const UnitMain()),
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

  Future<void> getAllUnits() async {
    try {
      getUnitLoader = true;
      notifyListeners();
      List<UnitModel> unitItems = await UnitServices.getAllUnits();

      if (unitItems.isNotEmpty) {
        unitList = unitItems;
      } else {
        unitList.clear();
      }
    } catch (e) {
      print(e);
    } finally {
      getUnitLoader = false;
      notifyListeners();
    }
  }

  Future<void> deleteUnit(unitId, BuildContext context) async {
    try {
      deleteUnitLoader = true;
      notifyListeners();
      String? response = await UnitServices.deleteUnit(unitId);

      if (response == null) {
        if (!context.mounted) return;
        showSuccessMessage(
          context,
          "Unit Deleted Successfully!",
        );
        getAllUnits();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const UnitMain()),
          (route) => false,
        );
      } else {
        if (!context.mounted) return;
        showOverlayError(context, response);
      }
    } catch (e) {
      print(e);
    } finally {
      deleteUnitLoader = false;
      notifyListeners();
    }
  }

  Future<void> getUnitById(unitId) async {
    try {
      singleUnitLoader = true;
      notifyListeners();
      List<UnitModel> unitItems = await UnitServices.getUnitById(unitId);

      if (unitItems.isNotEmpty) {
        singleUnitList = unitItems;
      } else {
        singleUnitList.clear();
      }
    } catch (e) {
      print(e);
    } finally {
      singleUnitLoader = false;
      notifyListeners();
    }
  }

  Future<void> editUnit(
    unitId,
    unitName,
    unitDescription,
    BuildContext context,
  ) async {
    try {
      editLoading = true;
      notifyListeners();

      String? response = await UnitServices.editUnit(
        unitId,
        unitName,
        unitDescription,
      );

      if (response == null) {
        if (!context.mounted) return;
        showSuccessMessage(
          context,
          "Unit information has been successfully updated!",
        );
        getAllUnits();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const UnitMain()),
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
}
