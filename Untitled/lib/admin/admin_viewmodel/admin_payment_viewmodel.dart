import 'package:flutter/foundation.dart';

import '../admin_api_client.dart';
import '../admin_model/admin_payment_model.dart';
import '../admin_service/admin_export_service.dart';
import '../admin_service/admin_payment_service.dart';

class AdminPaymentViewModel extends ChangeNotifier {
  final AdminPaymentService _service;
  final AdminExportService _exportService;

  AdminPaymentViewModel({AdminPaymentService? service, AdminExportService? exportService})
      : _service = service ?? AdminPaymentService(),
        _exportService = exportService ?? AdminExportService();

  bool isLoading = false;
  String? error;
  List<AdminPaymentModel> payments = [];

  bool isExporting = false;
  String? exportError;

  Future<void> fetchPayments() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      payments = await _service.getPayments();
      isLoading = false;
    } on AdminApiException catch (e) {
      isLoading = false;
      error = e.message;
    } catch (_) {
      isLoading = false;
      error = 'Could not load payments.';
    }
    notifyListeners();
  }

  Future<bool> exportPayments() async {
    isExporting = true;
    exportError = null;
    notifyListeners();
    bool success = false;
    try {
      await _exportService.exportPayments();
      success = true;
    } on AdminApiException catch (e) {
      exportError = e.message;
    } catch (_) {
      exportError = 'Could not export payments.';
    }
    isExporting = false;
    notifyListeners();
    return success;
  }
}