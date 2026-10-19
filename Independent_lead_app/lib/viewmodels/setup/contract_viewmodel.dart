import 'package:flutter/material.dart';
import 'package:pokakbilling/core/navigations.dart';
import 'package:pokakbilling/models/data-models/setup/contract_model.dart';
import 'package:pokakbilling/models/services/setup/contract_service.dart';
import 'package:pokakbilling/views/Screens/SetUp/contract_details/contract_header/contract_header.dart';
import 'package:pokakbilling/views/commonWidgets/response-message/error_message.dart';
import 'package:pokakbilling/views/commonWidgets/response-message/success-message.dart';

class ContractViewmodel extends ChangeNotifier {
  bool createContractLoading = false;
  bool getContractLoading = false;
  bool deleteContractHeadingLoader = false;
  bool editContractHeadingLoading = false;
  var contractHeadingList = <ContractHeadingModel>[];
  var contractSubHeadingList = <ContractSubHeadingModel>[];
  //List<String> contractSubHeadingList = [];
  bool createSubHeadingLoading = false;
  bool getSubHeadingLoading = false;

  // bool createPointLoading = false;
  // bool getPointsLoading = false;
  // bool editPointLoading = false;
  // bool deletePointLoading = false;
  // List contractPointsList = <ContractPointsModel>[];
  List<ContractPointsModel> contractPointsList = [];
  bool createPointLoading = false;
  bool getPointsLoading = false;

  ContractViewmodel() {
    getAllContractHeading();
  }

  Future<void> createContractHeading(
    contractHeading,
    BuildContext context,
  ) async {
    try {
      createContractLoading = true;
      notifyListeners();

      String? response = await ContractService.createContractHeading(
        contractHeading,
      );

      if (response == null) {
        if (!context.mounted) return;
        showSuccessMessage(
          context,
          "Contract Heading Created Successfully!",
        );
        getAllContractHeading();
        pushReplacementNavigation(context, const ContractDetailsHeaderScreen());
      } else {
        if (!context.mounted) return;
        showOverlayError(context, response);
      }
    } catch (e) {
      print(e);
    } finally {
      createContractLoading = false;
      notifyListeners();
    }
  }

  Future<void> getAllContractHeading() async {
    try {
      getContractLoading = true;
      notifyListeners();
      List<ContractHeadingModel> contractTitleItems =
          await ContractService.getAllContractHeading();

      if (contractTitleItems.isNotEmpty) {
        contractHeadingList = contractTitleItems;
      } else {
        contractHeadingList.clear();
      }
    } catch (e) {
      print(e);
    } finally {
      getContractLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteContractHeading(contractId, BuildContext context) async {
    try {
      deleteContractHeadingLoader = true;
      notifyListeners();
      String? response =
          await ContractService.deleteContractHeading(contractId);

      if (response == null) {
        if (!context.mounted) return;
        showSuccessMessage(
          context,
          "Contract Heading Deleted Successfully!",
        );
        getAllContractHeading();
        pushReplacementNavigation(context, const ContractDetailsHeaderScreen());
      } else {
        if (!context.mounted) return;
        showOverlayError(context, response);
      }
    } catch (e) {
      print(e);
    } finally {
      deleteContractHeadingLoader = false;
      notifyListeners();
    }
  }

  Future<void> editContractHeading(
    contractId,
    heading,
    BuildContext context,
  ) async {
    try {
      editContractHeadingLoading = true;
      notifyListeners();

      String? response = await ContractService.editContractHeading(
        contractId,
        heading,
      );

      if (response == null) {
        if (!context.mounted) return;
        showSuccessMessage(
          context,
          "Contract Heading has been successfully updated!",
        );
        pushReplacementNavigation(context, const ContractDetailsHeaderScreen());
      } else {
        if (!context.mounted) return;
        showOverlayError(context, response);
      }
    } catch (e) {
      print(e);
    } finally {
      editContractHeadingLoading = false;
      notifyListeners();
    }
  }

  Future<void> createContractSubHeading(
    int contractId,
    String subHeading,
    BuildContext context,
  ) async {
    try {
      createSubHeadingLoading = true;
      notifyListeners();

      String? response = await ContractService.createContractSubHeading(
        contractId,
        subHeading,
      );

      if (response == null) {
        if (!context.mounted) return;

        showSuccessMessage(context, "Subheading created successfully!");
        await getAllContractSubHeadings(contractId);
      } else {
        if (!context.mounted) return;
        showOverlayError(context, response);
      }
    } catch (e) {
      print("Error in createContractSubHeading: $e");
    } finally {
      createSubHeadingLoading = false;
      notifyListeners();
    }
  }

  Future<void> getAllContractSubHeadings(int contractId) async {
    try {
      getSubHeadingLoading = true;
      notifyListeners();
      List<ContractSubHeadingModel> contractSubHeadings =
          await ContractService.getAllContractSubHeadings(contractId);
      print("Fetched Subheadings: $contractSubHeadings");
      if (contractSubHeadings.isNotEmpty) {
        contractSubHeadingList = contractSubHeadings;
        for (var subHeading in contractSubHeadings) {}
      } else {
        contractSubHeadingList.clear();
      }
    } catch (e) {
      print('Error fetching subheadings: $e');
    } finally {
      getSubHeadingLoading = false;
      notifyListeners();
    }
  }

  Future<void> editContractSubHeading(
    int contractId,
    int sectionId,
    String newTitle,
    BuildContext context,
  ) async {
    try {
      final response = await ContractService.editContractSubHeading(
        contractId,
        sectionId,
        newTitle,
      );

      if (response == null) {
        if (!context.mounted) return;
        showSuccessMessage(context, "Subheading updated successfully!");
        await getAllContractSubHeadings(contractId);
      } else {
        if (!context.mounted) return;
        showOverlayError(context, response);
      }
    } catch (e) {
      print("Edit error: $e");
    }
  }

  Future<void> deleteContractSubHeading(
    int contractId,
    int sectionId,
    BuildContext context,
  ) async {
    try {
      final response = await ContractService.deleteContractSubHeading(
        contractId,
        sectionId,
      );

      if (response == null) {
        if (!context.mounted) return;
        showSuccessMessage(context, "Subheading deleted successfully!");
        await getAllContractSubHeadings(contractId);
      } else {
        if (!context.mounted) return;
        showOverlayError(context, response);
      }
    } catch (e) {
      print("Delete error: $e");
    }
  }

  Future<void> createContractPoint(
    int contractId,
    int sectionId,
    String points,
    BuildContext context,
  ) async {
    try {
      createPointLoading = true;
      notifyListeners();

      String? result = await ContractService.createContractPoint(
          contractId, sectionId, points);

      if (result == null) {
        if (!context.mounted) return;
        showSuccessMessage(context, "Point created successfully!");
        await getAllContractPoints(contractId, sectionId);
      } else {
        if (!context.mounted) return;
        showOverlayError(context, result);
      }
    } catch (e) {
      print("Error in createContractPoint: $e");
    } finally {
      createPointLoading = false;
      notifyListeners();
    }
  }

  Future<void> getAllContractPoints(int contractId, int sectionId) async {
    try {
      getPointsLoading = true;
      notifyListeners();

      final points =
          await ContractService.getAllContractPoints(contractId, sectionId);
      contractPointsList = points;
    } catch (e) {
      print("Error fetching points: $e");
      contractPointsList.clear();
    } finally {
      getPointsLoading = false;
      notifyListeners();
    }
  }

  Future<void> editContractPoint(
    int contractId,
    int sectionId,
    int pointId,
    String updatedPoints,
    BuildContext context,
  ) async {
    try {
      createPointLoading = true;
      notifyListeners();

      String? result = await ContractService.editContractPoint(
        contractId,
        sectionId,
        pointId,
        updatedPoints,
      );

      if (result == null) {
        if (!context.mounted) return;
        showSuccessMessage(context, "Point updated successfully!");
        await getAllContractPoints(contractId, sectionId);
      } else {
        if (!context.mounted) return;
        showOverlayError(context, result);
      }
    } catch (e) {
      print("Error in editContractPoint: $e");
    } finally {
      createPointLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteContractPoint(
    int contractId,
    int sectionId,
    int pointId,
    BuildContext context,
  ) async {
    try {
      createPointLoading = true;
      notifyListeners();

      String? result = await ContractService.deleteContractPoint(
        contractId,
        sectionId,
        pointId,
      );

      if (result == null) {
        if (!context.mounted) return;
        showSuccessMessage(context, "Point deleted successfully!");
        await getAllContractPoints(contractId, sectionId);
      } else {
        if (!context.mounted) return;
        showOverlayError(context, result);
      }
    } catch (e) {
      print("Error in deleteContractPoint: $e");
    } finally {
      createPointLoading = false;
      notifyListeners();
    }
  }
}
