import 'package:flutter/material.dart';
import 'package:pokakbilling/core/navigations.dart';
import 'package:pokakbilling/models/data-models/delivery-models/deliveryOrderItems_model.dart';
import 'package:pokakbilling/models/data-models/delivery-models/delivery_models.dart';
import 'package:pokakbilling/models/data-models/delivery-models/items_by_salesOrder.dart';
import 'package:pokakbilling/models/data-models/delivery-models/salesOrder_by_client_model.dart';
import 'package:pokakbilling/models/services/delivery_services.dart';
import 'package:pokakbilling/views/Screens/delivery/delivery_main.dart';
import 'package:pokakbilling/views/Screens/delivery/view_delivery/view_delivery.dart';
import 'package:pokakbilling/views/commonWidgets/response-message/error_message.dart';
import 'package:pokakbilling/views/commonWidgets/response-message/success-message.dart';

class DeliveryViewmodel extends ChangeNotifier {
  int selectedSalesPersonId = 0;
  int selectedClientId = 0;
  int selectedSalesOrderId = 0;
  int selectedTermsId = 0;
  String selectedSalesPersonName = "";
  String selectedClientName = "";
  String selectedTermsName = "";
  bool salesOrderClientLoader = false;
  bool hasClientDropdownBeenTouched = false;
  bool itemsBySalesOrderLoader = false;
  bool addDeliveryOrderLoading = false;
  var salesOrderClientList = <SalesorderByClientModel>[];
  var salesOrderItemsList = <ItemsBySalesOrder>[];
  int itemLength = 0;
  List<bool> checkboxStates = [];
  List<TextEditingController> deliveryQuantityControllers = [];
  bool getDeliveryOrderLoader = false;
  var deliveryOrderList = <DeliveryModel>[];
  bool singleDeliveryOrderLoading = false;
  var singleDeliveryOrderList = <DeliveryOrderItemsModel>[];
  bool deleteDeliveryOrderLoader = false;

  void disposeControllers() {
    for (var controller in deliveryQuantityControllers) {
      controller.dispose();
    }
  }

  DeliveryViewmodel() {
    getAllDeliveryOrders();
  }

  @override
  void dispose() {
    disposeControllers();
    super.dispose();
  }

  void initializeCheckboxStates() {
    checkboxStates = List.filled(itemLength, false);
    deliveryQuantityControllers =
        List.generate(itemLength, (_) => TextEditingController());
    notifyListeners();
  }

  void resetSelectedValues() {
    selectedSalesPersonId = 0;
    selectedSalesPersonName = "";
    selectedClientId = 0;
    selectedSalesOrderId = 0;
    hasClientDropdownBeenTouched = false;
    itemLength = 0;
    selectedTermsId = 0;
    selectedTermsName = "";
    salesOrderItemsList.clear();
    initializeCheckboxStates();
    notifyListeners();
  }

  void clearLists() {
    salesOrderItemsList.clear();
    notifyListeners();
  }

  void dropDownStatus() {
    hasClientDropdownBeenTouched = true;
    notifyListeners();
  }

  // ========= Client ==========================
  void updateClientId(int clientId) {
    selectedClientId = clientId;
    notifyListeners();
  }

  void updateClientName(String clientName) {
    selectedClientName = clientName;
    notifyListeners();
  }

  // ========== terms and condition ============
  void updateTermsId(int termsId) {
    selectedTermsId = termsId;
    notifyListeners();
  }

  void updateTermsName(String termsName) {
    selectedTermsName = termsName;
    notifyListeners();
  }

  // ========= sales person ==================
  void updateSalesPersonId(int salesPersonId) {
    selectedSalesPersonId = salesPersonId;
    notifyListeners();
  }

  void updateSalesPersonName(String salesPersonName) {
    selectedSalesPersonName = salesPersonName;
    notifyListeners();
  }

  void toggleCheckbox(int index) {
    checkboxStates[index] = !checkboxStates[index];
    notifyListeners();
  }

  bool getCheckboxState(int index) => checkboxStates[index];

  // ========= sales Order ==================
  void updateSalesOrderId(int salesOrderId) {
    print("salesORderId $salesOrderId");
    selectedSalesOrderId = salesOrderId;
    notifyListeners();
  }

  void printPayload() {
    final payload = buildCheckedItemsPayload();
    print(payload);
  }

  List<Map<String, dynamic>> buildCheckedItemsPayload() {
    List<Map<String, dynamic>> payload = [];

    for (int i = 0; i < salesOrderItemsList.length; i++) {
      if (checkboxStates[i]) {
        final item = salesOrderItemsList[i];
        final deliveredQty =
            int.tryParse(deliveryQuantityControllers[i].text) ?? 0;

        payload.add({
          "product": item.productId,
          "quantity": item.quantity,
          "unit_price": item.unitPrice,
          "delivered_quantity": deliveredQty,
          "sgst_percentage": item.sgstPercentage,
          "cgst_percentage": item.cgstPercentage,
        });
      }
    }

    return payload;
  }

  Future<void> getSalesOrderByClientId(clientId) async {
    try {
      print("client id => $clientId");
      salesOrderClientLoader = true;
      salesOrderClientList.clear();
      notifyListeners();
      List<SalesorderByClientModel> salesOrderItems =
          await DeliveryServices.getSalesOrderByClient(clientId);

      if (salesOrderItems.isNotEmpty) {
        salesOrderClientList = salesOrderItems;
      } else {
        salesOrderClientList.clear();
      }
    } catch (e) {
      print(e);
    } finally {
      salesOrderClientLoader = false;
      notifyListeners();
    }
  }

  Future<void> getItemsBySalesOrderId(salesOrderId) async {
    try {
      itemsBySalesOrderLoader = true;
      salesOrderItemsList.clear();
      itemLength = 0;
      notifyListeners();
      List<ItemsBySalesOrder> productItems =
          await DeliveryServices.getItemsBySalesOrder(salesOrderId);

      if (productItems.isNotEmpty) {
        salesOrderItemsList = productItems;
        itemLength = salesOrderItemsList.length;
        initializeCheckboxStates();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
      } else {
        salesOrderItemsList.clear();
      }
    } catch (e) {
      print(e);
    } finally {
      itemsBySalesOrderLoader = false;
      notifyListeners();
    }
  }

  Future<void> createDeliveryOrder(
    customerId,
    deliveryNumber,
    deliveryDate,
    salesOrderId,
    deliveryLocation,
    deliveryAddress,
    contactPerson,
    mobileNumber,
    termsandConditionId,
    time,
    date,
    BuildContext context,
  ) async {
    try {
      addDeliveryOrderLoading = true;
      notifyListeners();

      final items = buildCheckedItemsPayload();

      var response = await DeliveryServices.createDeliveryOrder(
        customerId,
        deliveryNumber,
        deliveryDate,
        salesOrderId,
        deliveryLocation,
        deliveryAddress,
        contactPerson,
        mobileNumber,
        termsandConditionId,
        time,
        date,
        items,
      );

      if (response != 0) {
        if (!context.mounted) return;
        showSuccessMessage(
          context,
          "Delivery Order Created Successfully!",
        );
        await getAllDeliveryOrders();
        await getDeliveryOrderById(response);
        // itemList.clear();
        if (!context.mounted) return;
        pushReplacementNavigation(context, const ViewDelivery());
      } else {
        if (!context.mounted) return;
        showOverlayError(context, "Unable to create");
      }
    } catch (e) {
      print(e);
    } finally {
      addDeliveryOrderLoading = false;
      notifyListeners();
    }
  }

  Future<void> getAllDeliveryOrders() async {
    try {
      getDeliveryOrderLoader = true;
      notifyListeners();
      List<DeliveryModel> deliveryOrderItems =
          await DeliveryServices.getAllDeliveryOrders();

      if (deliveryOrderItems.isNotEmpty) {
        deliveryOrderList = deliveryOrderItems;
      } else {
        deliveryOrderList.clear();
      }
    } catch (e) {
      print(e);
    } finally {
      getDeliveryOrderLoader = false;
      notifyListeners();
    }
  }

  Future<void> getDeliveryOrderById(deliveryOrderId) async {
    try {
      singleDeliveryOrderLoading = true;
      notifyListeners();
      List<DeliveryOrderItemsModel> deliveryOrderItems =
          await DeliveryServices.getDeliveryOrderById(deliveryOrderId);

      if (deliveryOrderItems.isNotEmpty) {
        singleDeliveryOrderList = deliveryOrderItems;
      } else {
        singleDeliveryOrderList.clear();
      }
    } catch (e) {
      print(e);
    } finally {
      singleDeliveryOrderLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteDeliveryOrder(
      deliveryOrderId, BuildContext context) async {
    try {
      deleteDeliveryOrderLoader = true;
      notifyListeners();
      String? response =
          await DeliveryServices.deleteDeliveryOrder(deliveryOrderId);

      if (response == null) {
        if (!context.mounted) return;
        showSuccessMessage(
          context,
          "Delivery Order Deleted Successfully!",
        );
        getAllDeliveryOrders();
        pushAndRemoveUntilFun(context, const DeliveryMain());
      } else {
        if (!context.mounted) return;
        showOverlayError(context, response);
      }
    } catch (e) {
      print(e);
    } finally {
      deleteDeliveryOrderLoader = false;
      notifyListeners();
    }
  }
}
