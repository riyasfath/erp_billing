import 'package:flutter/material.dart';
import 'package:pokakbilling/core/navigations.dart';
import 'package:pokakbilling/models/data-models/setup/terms&condition_model.dart';
import 'package:pokakbilling/models/services/setup/terms&condition_services.dart';
import 'package:pokakbilling/views/Screens/SetUp/terms_and_condition/terms_main_header/terms_header_.dart';
import 'package:pokakbilling/views/Screens/SetUp/terms_and_condition/terms_points/terms_point.dart';
import 'package:pokakbilling/views/commonWidgets/response-message/error_message.dart';
import 'package:pokakbilling/views/commonWidgets/response-message/success-message.dart';

class TermsViewmodel extends ChangeNotifier {
  bool createTermsTitleLoader = false;
  bool getTermsTitleLoader = false;
  bool deleteTermsTitleLoading = false;
  bool singleTermsTitleLoading = false;
  bool editTermsTitleLoading = false;
  bool getTermsPointsLoader = false;
  bool createTermsPointsLoader = false;
  bool deleteTermsPointLoading = false;
  var termsTitleList = <TermsTitleModel>[];
  var singleTermsTitleList = <TermsTitleModel>[];
  var termsPointsList = <TermsPointsModel>[];
  int selectedTermsId = 0;
  String selectedTermsTitle = "";

  TermsViewmodel() {
    getAllTermsTitle();
  }

  void updateSelectedTermsId(int titleId) {
    selectedTermsId = titleId;
    notifyListeners();
  }

  void selectTermsTitle(String name) {
    selectedTermsTitle = name;
    notifyListeners();
  }

  Future<void> createTermsTitle(
    title,
    BuildContext context,
  ) async {
    try {
      createTermsTitleLoader = true;
      notifyListeners();
      String? response = await TermsServices.createTermsTitle(
        title,
      );

      if (response == null) {
        if (!context.mounted) return;
        showSuccessMessage(
          context,
          "Terms and Condition title Created Successfully!",
        );
        getAllTermsTitle();
        pushReplacementNavigation(context, const TermsConditionHeaderScreen());
      } else {
        if (!context.mounted) return;
        showOverlayError(context, response);
      }
    } catch (e) {
      print(e);
    } finally {
      createTermsTitleLoader = false;
      notifyListeners();
    }
  }

  Future<void> getAllTermsTitle() async {
    try {
      getTermsTitleLoader = true;
      notifyListeners();
      List<TermsTitleModel> termsTitleItems =
          await TermsServices.getTermsTitle();

      if (termsTitleItems.isNotEmpty) {
        termsTitleList = termsTitleItems;
      } else {
        termsTitleList.clear();
      }
    } catch (e) {
      print(e);
    } finally {
      getTermsTitleLoader = false;
      notifyListeners();
    }
  }

  Future<void> deleteTermsTitle(termsId, BuildContext context) async {
    try {
      deleteTermsTitleLoading = true;
      notifyListeners();
      String? response = await TermsServices.deleteTermsTitle(termsId);

      if (response == null) {
        if (!context.mounted) return;
        showSuccessMessage(
          context,
          "Terms Title Deleted Successfully!",
        );
        getAllTermsTitle();
        pushReplacementNavigation(context, const TermsConditionHeaderScreen());
      } else {
        if (!context.mounted) return;
        showOverlayError(context, response);
      }
    } catch (e) {
      print(e);
    } finally {
      deleteTermsTitleLoading = false;
      notifyListeners();
    }
  }

  Future<void> getTermsTitleById(titleId) async {
    try {
      singleTermsTitleLoading = true;
      notifyListeners();
      List<TermsTitleModel> titleItems =
          await TermsServices.getTermsTitleById(titleId);

      if (titleItems.isNotEmpty) {
        singleTermsTitleList = titleItems;
      } else {
        singleTermsTitleList.clear();
      }
    } catch (e) {
      print(e);
    } finally {
      singleTermsTitleLoading = false;
      notifyListeners();
    }
  }

  Future<void> editTermsTitle(
    termsId,
    title,
    BuildContext context,
  ) async {
    try {
      editTermsTitleLoading = true;
      notifyListeners();

      String? response = await TermsServices.editTermsTitle(
        termsId,
        title,
      );

      if (response == null) {
        if (!context.mounted) return;
        showSuccessMessage(
          context,
          "Terms Title has been successfully updated!",
        );
        pushReplacementNavigation(context, const TermsConditionHeaderScreen());
      } else {
        if (!context.mounted) return;
        showOverlayError(context, response);
      }
    } catch (e) {
      print(e);
    } finally {
      editTermsTitleLoading = false;
      notifyListeners();
    }
  }

  Future<void> getAllTermsPoints(termsId) async {
    try {
      getTermsPointsLoader = true;
      notifyListeners();
      List<TermsPointsModel> termsPointsItems =
          await TermsServices.getTermsPoints(termsId);

      if (termsPointsItems.isNotEmpty) {
        termsPointsList = termsPointsItems;
      } else {
        termsPointsList.clear();
      }
    } catch (e) {
      print(e);
    } finally {
      getTermsPointsLoader = false;
      notifyListeners();
    }
  }

  Future<void> createTermsPoints(
    termsId,
    points,
    termsHeading,
    BuildContext context,
  ) async {
    try {
      createTermsPointsLoader = true;
      notifyListeners();
      String? response = await TermsServices.createTermsPoints(
        termsId,
        points,
      );

      if (response == null) {
        if (!context.mounted) return;
        showSuccessMessage(
          context,
          "Terms and Condition Points Created Successfully!",
        );
        getAllTermsPoints(termsId);
        pushReplacementNavigation(
            context,
            TermsConditionPointsScreen(
              termsId: termsId,
              heading: termsHeading,
            ));
      } else {
        if (!context.mounted) return;
        showOverlayError(context, response);
      }
    } catch (e) {
      print(e);
    } finally {
      createTermsPointsLoader = false;
      notifyListeners();
    }
  }

  Future<void> deleteTermsPoint(
    termsId,
    termsHeading,
    pointId,
    BuildContext context,
  ) async {
    try {
      deleteTermsPointLoading = true;
      notifyListeners();
      String? response = await TermsServices.deleteTermsPoints(pointId);

      if (response == null) {
        if (!context.mounted) return;
        showSuccessMessage(
          context,
          "Terms Points Deleted Successfully!",
        );
        getAllTermsPoints(termsId);
        pushReplacementNavigation(
            context,
            TermsConditionPointsScreen(
              termsId: termsId,
              heading: termsHeading,
            ));
      } else {
        if (!context.mounted) return;
        showOverlayError(context, response);
      }
    } catch (e) {
      print(e);
    } finally {
      deleteTermsPointLoading = false;
      notifyListeners();
    }
  }

  Future<void> editTermsPoint(
    pointId,
    termsId,
    point,
    heading,
    BuildContext context,
  ) async {
    try {
      editTermsTitleLoading = true;
      notifyListeners();

      String? response = await TermsServices.editTermsPoint(
        pointId,
        termsId,
        point,
      );

      if (response == null) {
        if (!context.mounted) return;
        showSuccessMessage(
          context,
          "Terms Point has been successfully updated!",
        );
        pushReplacementNavigation(
          context,
          TermsConditionPointsScreen(termsId: termsId, heading: heading),
        );
      } else {
        if (!context.mounted) return;
        showOverlayError(context, response);
      }
    } catch (e) {
      print(e);
    } finally {
      editTermsTitleLoading = false;
      notifyListeners();
    }
  }
}
