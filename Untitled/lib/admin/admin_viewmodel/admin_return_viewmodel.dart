import 'package:flutter/foundation.dart';

import '../admin_api_client.dart';
import '../admin_model/admin_return_model.dart';
import '../admin_service/admin_return_service.dart';

class AdminReturnViewModel extends ChangeNotifier {
  final AdminReturnService _service;

  AdminReturnViewModel({AdminReturnService? service}) : _service = service ?? AdminReturnService();

  bool isLoading = false;
  String? error;
  List<AdminReturnModel> returns = [];

  bool isLoadingDetail = false;
  String? detailError;
  AdminReturnModel? selectedReturn;
  bool isProcessing = false;

  Future<void> fetchReturns() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      returns = await _service.getReturns();
      isLoading = false;
    } on AdminApiException catch (e) {
      isLoading = false;
      error = e.message;
    } catch (_) {
      isLoading = false;
      error = 'Could not load returns.';
    }
    notifyListeners();
  }

  Future<void> fetchDetail(int id) async {
    isLoadingDetail = true;
    detailError = null;
    selectedReturn = null;
    notifyListeners();
    try {
      selectedReturn = await _service.getDetail(id);
      isLoadingDetail = false;
    } on AdminApiException catch (e) {
      isLoadingDetail = false;
      detailError = e.message;
    } catch (_) {
      isLoadingDetail = false;
      detailError = 'Could not load this return.';
    }
    notifyListeners();
  }

  Future<bool> processReturn(int id, String action, {String? category, String? note}) async {
    isProcessing = true;
    notifyListeners();
    bool success = false;
    try {
      await _service.processReturn(id, action, category: category, note: note);
      await fetchDetail(id);
      success = true;
    } on AdminApiException catch (e) {
      detailError = e.message;
    } catch (_) {
      detailError = 'Could not process this return.';
    }
    isProcessing = false;
    notifyListeners();
    return success;
  }
}