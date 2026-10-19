import 'package:ecommerce_app/models/pincode_checkmodel.dart';
import 'package:flutter/foundation.dart';

import 'package:ecommerce_app/core/api_exception.dart';
import 'package:ecommerce_app/service/pincode_service.dart';

class PincodeViewModel extends ChangeNotifier {
  final PincodeService _service;

  PincodeViewModel({PincodeService? service}) : _service = service ?? PincodeService();

  bool isChecking = false;
  String? error;
  PincodeCheckModel? result;

  Future<void> checkPincode(String pincode) async {
    isChecking = true;
    error = null;
    result = null;
    notifyListeners();

    try {
      result = await _service.checkPincode(pincode);
      isChecking = false;
    } on ApiException catch (e) {
      isChecking = false;
      error = e.message;
    } catch (_) {
      isChecking = false;
      error = 'Could not check delivery for this pincode. Please try again.';
    }
    notifyListeners();
  }

  /// Call when leaving the field/product so a stale result from a
  /// previous pincode doesn't linger if the user comes back.
  void reset() {
    isChecking = false;
    error = null;
    result = null;
    notifyListeners();
  }
}