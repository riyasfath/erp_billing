import 'package:flutter/material.dart';
import 'package:pokakbilling/core/navigations.dart';
import 'package:pokakbilling/models/data-models/client_contract_model.dart';
import 'package:pokakbilling/models/services/client_contract_service.dart';
import 'package:pokakbilling/views/Screens/projectmanagement/client_contract/client_contract_main.dart';
import 'package:pokakbilling/views/commonWidgets/response-message/error_message.dart';
import 'package:pokakbilling/views/commonWidgets/response-message/success-message.dart';

class ClientContractViewmodel extends ChangeNotifier {
  bool addContractLoader = false;
  bool getContractLoader = false;
  bool deleteClientContractLoader = false;
  var contractList = <ClientContractModel>[];
  int selectedCustomerId = 0;
  ClientContractModel? selectedContract;
  bool singleContractLoading = false;

  void updateCustomerId(int customerId) {
    selectedCustomerId = customerId;
    notifyListeners();
  }

  ClientContractViewmodel() {
    getAllClientContracts();
  }

  Future<void> createClientContract({
    required int clientId,
    required String contractName,
    required String description,
    required String contractDate,
    required String startDate,
    required String endDate,
    required int duration,
    required BuildContext context,
  }) async {
    try {
      addContractLoader = true;
      notifyListeners();

      String? response = await ClientContractServices.createClientContract(
        clientId: clientId,
        contractName: contractName,
        description: description,
        contractDate: contractDate,
        startDate: startDate,
        endDate: endDate,
        duration: duration,
      );

      if (response == null) {
        if (!context.mounted) return;
        showSuccessMessage(
          context,
          "Client Contract Created Successfully!",
        );
        getAllClientContracts();
        pushNavigation(context, const ClientContractMain());
      } else {
        if (!context.mounted) return;
        showOverlayError(context, response);
      }
    } catch (e) {
      print(e);
    } finally {
      addContractLoader = false;
      notifyListeners();
    }
  }

  Future<void> getAllClientContracts() async {
    try {
      getContractLoader = true;
      notifyListeners();
      List<ClientContractModel> contractItems =
          await ClientContractServices.getAllClientContracts();

      contractList = contractItems.isNotEmpty ? contractItems : [];
    } catch (e) {
      print(e);
    } finally {
      getContractLoader = false;
      notifyListeners();
    }
  }

  Future<void> deleteClientContract(contractId, BuildContext context) async {
    try {
      deleteClientContractLoader = true;
      notifyListeners();
      String? response =
          await ClientContractServices.deleteClientContract(contractId);

      if (response == null) {
        if (!context.mounted) return;
        showSuccessMessage(
          context,
          "Client Contract Deleted Successfully!",
        );
        getAllClientContracts();
        pushAndRemoveUntilFun(context, const ClientContractMain());
      } else {
        if (!context.mounted) return;
        showOverlayError(context, response);
      }
    } catch (e) {
      print(e);
    } finally {
      deleteClientContractLoader = false;
      notifyListeners();
    }
  }

  // Future<void> getClientContractById(int contractId) async {
  //   try {
  //     singleContractLoading = true;
  //     notifyListeners();

  //     final contract =
  //         await ClientContractServices.getClientContractById(contractId);

  //     if (contract != null) {
  //       selectedContract = contract;
  //     } else {
  //       selectedContract = null;
  //     }
  //   } catch (e) {
  //     print("Error in getClientContractById: $e");
  //   } finally {
  //     singleContractLoading = false;
  //     notifyListeners();
  //   }
  // }
  Future<void> getClientContractById(int contractId) async {
    try {
      singleContractLoading = true;
      notifyListeners();

      final contract =
          await ClientContractServices.getClientContractById(contractId);

      if (contract != null) {
        selectedContract = contract;
      } else {
        throw Exception("Invalid contract data received.");
      }
    } catch (e) {
      print("Error in getClientContractById: $e");
      selectedContract = null;
    } finally {
      singleContractLoading = false;
      notifyListeners();
    }
  }

  Future<void> editClientContract({
    required int contractId,
    required int clientId,
    required String contractName,
    required String description,
    required String contractDate,
    required String startDate,
    required String endDate,
    required int duration,
    required BuildContext context,
  }) async {
    try {
      addContractLoader = true;
      notifyListeners();

      String? response = await ClientContractServices.updateClientContract(
        contractId: contractId,
        clientId: clientId,
        contractName: contractName,
        description: description,
        contractDate: contractDate,
        startDate: startDate,
        endDate: endDate,
        duration: duration,
      );

      if (response == null) {
        if (!context.mounted) return;
        showSuccessMessage(
          context,
          "Client Contract Updated Successfully!",
        );
        getAllClientContracts();
        pushNavigation(context, const ClientContractMain());
      } else {
        if (!context.mounted) return;
        showOverlayError(context, response);
      }
    } catch (e) {
      print(e);
    } finally {
      addContractLoader = false;
      notifyListeners();
    }
  }
}
