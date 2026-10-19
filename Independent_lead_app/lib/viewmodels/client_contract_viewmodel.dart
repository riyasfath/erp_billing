// import 'package:flutter/material.dart';
// import 'package:pokakbilling/models/data-models/client_contract_model.dart';
// import 'package:pokakbilling/models/services/client_contract_service.dart';
// import 'package:pokakbilling/viewmodels/customer_viewmodel.dart';
// import 'package:provider/provider.dart';

// class ContractViewmodel extends ChangeNotifier {
//   bool loading = false;
//   bool createLoading = false;
//   ContractModel? currentContract;
//   bool detailsLoading = false;

//   List<ContractModel> contractList = [];
//   int? selectedContractId;
//   String? selectedContractName = "";

//   void setContracts(List<ContractModel> contracts) {
//     contractList = contracts;

//     // ✅ AUTO SELECT SAFELY
//     if (contractList.length == 1 && selectedContractId == null) {
//       selectedContractId = contractList.first.id;
//       selectedContractName = contractList.first.name;
//     }

//     notifyListeners();
//   }

// //========== clear filed=============
//   void clearSelectedContract() {
//     selectedContractId = null;
//     selectedContractName = null;
//     notifyListeners();
//   }

//   // ================= GET ALL =================
//   Future<void> fetchContracts() async {
//     loading = true;
//     notifyListeners();

//     try {
//       contractList = await ContractServices.getContracts();
//     } catch (e) {
//       debugPrint(e.toString());
//     }

//     loading = false;
//     notifyListeners();
//   }

//   // ================= SELECT =================
//   void selectContract(int id, String name) {
//     selectedContractId = id;
//     selectedContractName = name;
//     notifyListeners();
//   }

//   // ================= CREATE =================
//   Future<bool> createContract(ContractModel contract) async {
//     createLoading = true;
//     notifyListeners();

//     String? response = await ContractServices.createContract(contract);

//     createLoading = false;
//     notifyListeners();

//     if (response == null) {
//       await fetchContracts();
//       return true;
//     }
//     return false;
//   }

//   // ================= EDIT / UPDATE =================
//   Future<bool> editContract(ContractModel contract) async {
//     createLoading = true; // reuse createLoading for UI
//     notifyListeners();

//     String? response =
//         await ContractServices.updateContract(contract.id!, contract);

//     createLoading = false;
//     notifyListeners();

//     if (response == null) {
//       await fetchContracts();
//       return true;
//     }
//     return false;
//   }

//   // ================= BY ID =================
//   Future<void> getContractById(int id) async {
//     detailsLoading = true;
//     notifyListeners();
//     currentContract = await ContractServices.getContractById(id);
//     await fetchContracts();

//     detailsLoading = false;
//     notifyListeners();
//   }

//   // ================= DELETE =================

//   Future<bool> deleteContract(
//     int contractId,
//     int customerId,
//     BuildContext context,
//   ) async {
//     String? response = await ContractServices.deleteContract(contractId);

//     if (response == null) {
//       // 🔥 THIS IS THE MAGIC LINE
//       context.read<CustomerViewmodel>().removeContractFromCustomer(customerId);

//       notifyListeners();
//       return true;
//     }
//     return false;
//   }
// }
import 'package:flutter/material.dart';
import 'package:pokakbilling/models/data-models/client_contract_model.dart';
import 'package:pokakbilling/models/services/client_contract_service.dart';
import 'package:pokakbilling/viewmodels/customer_viewmodel.dart';
import 'package:provider/provider.dart';

class ContractViewmodel extends ChangeNotifier {
  bool loading = false;
  bool createLoading = false;
  ContractModel? currentContract;
  bool detailsLoading = false;

  List<ContractModel> contractList = [];
  int? selectedContractId;
  String? selectedContractName = "";

  void reset() {
    contractList = [];
    currentContract = null;
    selectedContractId = null;
    selectedContractName = "";
    loading = false;
    createLoading = false;
    detailsLoading = false;
    notifyListeners();
  }

  void setContracts(List<ContractModel> contracts) {
    contractList = contracts;
    if (contractList.length == 1 && selectedContractId == null) {
      selectedContractId = contractList.first.id;
      selectedContractName = contractList.first.name;
    }
    notifyListeners();
  }

  void clearSelectedContract() {
    selectedContractId = null;
    selectedContractName = null;
    notifyListeners();
  }

  Future<void> fetchContracts() async {
    loading = true;
    notifyListeners();
    try {
      contractList = await ContractServices.getContracts();
    } catch (e) {
      debugPrint(e.toString());
    }
    loading = false;
    notifyListeners();
  }

  void selectContract(int id, String name) {
    selectedContractId = id;
    selectedContractName = name;
    notifyListeners();
  }

  Future<bool> createContract(ContractModel contract) async {
    createLoading = true;
    notifyListeners();
    String? response = await ContractServices.createContract(contract);
    createLoading = false;
    notifyListeners();
    if (response == null) {
      await fetchContracts();
      return true;
    }
    return false;
  }

  Future<bool> editContract(ContractModel contract) async {
    createLoading = true;
    notifyListeners();
    String? response =
        await ContractServices.updateContract(contract.id!, contract);
    createLoading = false;
    notifyListeners();
    if (response == null) {
      await fetchContracts();
      return true;
    }
    return false;
  }

  Future<void> getContractById(int id) async {
    detailsLoading = true;
    notifyListeners();
    currentContract = await ContractServices.getContractById(id);
    await fetchContracts();
    detailsLoading = false;
    notifyListeners();
  }

  Future<bool> deleteContract(
    int contractId,
    int customerId,
    BuildContext context,
  ) async {
    String? response = await ContractServices.deleteContract(contractId);
    if (response == null) {
      context.read<CustomerViewmodel>().removeContractFromCustomer(customerId);
      notifyListeners();
      return true;
    }
    return false;
  }
}
