import 'package:flutter/material.dart';
import 'package:pokakbilling/core/navigations.dart';
import 'package:pokakbilling/models/data-models/stack_model.dart';
import 'package:pokakbilling/models/services/stack_services.dart';
import 'package:pokakbilling/views/Screens/projectmanagement/stack/stack_main.dart';
import 'package:pokakbilling/views/commonWidgets/response-message/error_message.dart';
import 'package:pokakbilling/views/commonWidgets/response-message/success-message.dart';

class StackViewmodel extends ChangeNotifier {
  bool addStackLoader = false;
  bool getStackLoader = false;
  bool deleteStackLoading = false;
  var stackList = <StackModel>[];

  StackViewmodel() {
    getAllStacks();
  }

  Future<void> createStack(
    stackName,
    BuildContext context,
  ) async {
    try {
      addStackLoader = true;
      notifyListeners();
      String? response = await StackServices.createStack(
        stackName,
      );

      if (response == null) {
        if (!context.mounted) return;
        showSuccessMessage(
          context,
          "Stack Created Successfully!",
        );
        getAllStacks();
        pushNavigation(context, const StackMain());
      } else {
        if (!context.mounted) return;
        showOverlayError(context, response);
      }
    } catch (e) {
      print(e);
    } finally {
      addStackLoader = false;
      notifyListeners();
    }
  }

  Future<void> getAllStacks() async {
    try {
      getStackLoader = true;
      notifyListeners();
      List<StackModel> stackItems = await StackServices.getAllStack();

      if (stackItems.isNotEmpty) {
        stackList = stackItems;
      } else {
        stackList.clear();
      }
    } catch (e) {
      print(e);
    } finally {
      getStackLoader = false;
      notifyListeners();
    }
  }

  Future<void> deleteStack(stackId, BuildContext context) async {
    try {
      deleteStackLoading = true;
      notifyListeners();
      String? response = await StackServices.deleteStack(stackId);

      if (response == null) {
        if (!context.mounted) return;
        showSuccessMessage(
          context,
          "Stack Deleted Successfully!",
        );
        getAllStacks();
        pushNavigation(context, const StackMain());
      } else {
        if (!context.mounted) return;
        showOverlayError(context, response);
      }
    } catch (e) {
      print(e);
    } finally {
      deleteStackLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateStack(
      int stackId, String newName, BuildContext context) async {
    try {
      addStackLoader = true;
      notifyListeners();

      String? response = await StackServices.updateStack(stackId, newName);

      if (response == null) {
        if (!context.mounted) return;
        showSuccessMessage(context, "Stack Updated Successfully!");
        getAllStacks();
        Navigator.of(context).pop();
      } else {
        if (!context.mounted) return;
        showOverlayError(context, response);
      }
    } catch (e) {
      print(e);
    } finally {
      addStackLoader = false;
      notifyListeners();
    }
  }
}
