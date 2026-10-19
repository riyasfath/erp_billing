import 'package:flutter/foundation.dart';

import 'package:ecommerce_app/core/api_exception.dart';
import 'package:ecommerce_app/core/view_status.dart';
import 'package:ecommerce_app/models/adress_model.dart';
import 'package:ecommerce_app/service/address_service.dart';

class AddressViewModel extends ChangeNotifier {
  final AddressService _addressService;

  AddressViewModel({AddressService? addressService})
      : _addressService = addressService ?? AddressService();

  ViewStatus status = ViewStatus.idle;
  String? error;
  List<AddressModel> addresses = [];

  bool isAdding = false;
  String? addError;

  bool get isLoading => status == ViewStatus.loading;

  Future<void> fetchAddresses() async {
    status = ViewStatus.loading;
    error = null;
    notifyListeners();

    try {
      addresses = await _addressService.getAddresses();
      status = ViewStatus.success;
    } on ApiException catch (e) {
      status = ViewStatus.error;
      error = e.message;
    } catch (_) {
      status = ViewStatus.error;
      error = 'Something went wrong. Please try again.';
    }

    notifyListeners();
  }

  /// Returns the created address on success, null on failure
  /// (check [addError] for the message).
  Future<AddressModel?> addAddress(AddressModel address) async {
    isAdding = true;
    addError = null;
    notifyListeners();

    try {
      final created = await _addressService.addAddress(address);
      addresses = [...addresses, created];
      isAdding = false;
      notifyListeners();
      return created;
    } on ApiException catch (e) {
      isAdding = false;
      addError = e.message;
      notifyListeners();
      return null;
    } catch (_) {
      isAdding = false;
      addError = 'Could not save this address. Please try again.';
      notifyListeners();
      return null;
    }
  }

  /// Called on logout so a new login on this device starts with no
  /// leftover addresses from the previous user.
  void reset() {
    addresses = [];
    status = ViewStatus.idle;
    error = null;
    isAdding = false;
    addError = null;
    notifyListeners();
  }
}