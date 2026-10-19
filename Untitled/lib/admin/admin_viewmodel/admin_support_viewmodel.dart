import 'package:flutter/foundation.dart';

import '../admin_api_client.dart';
import '../admin_model/admin_support_model.dart';
import '../admin_service/admin_support_service.dart';

class AdminSupportViewModel extends ChangeNotifier {
  final AdminSupportService _service;

  AdminSupportViewModel({AdminSupportService? service}) : _service = service ?? AdminSupportService();

  bool isLoading = false;
  String? error;
  AdminSupportStatsModel? stats;
  List<AdminSupportTicketModel> tickets = [];

  bool isLoadingDetail = false;
  String? detailError;
  AdminSupportTicketModel? selectedTicket;
  bool isUpdating = false;

  Future<void> fetchAll() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final results = await Future.wait([_service.getStats(), _service.getTickets()]);
      stats = results[0] as AdminSupportStatsModel;
      tickets = results[1] as List<AdminSupportTicketModel>;
      isLoading = false;
    } on AdminApiException catch (e) {
      isLoading = false;
      error = e.message;
    } catch (_) {
      isLoading = false;
      error = 'Could not load support tickets.';
    }
    notifyListeners();
  }

  Future<void> fetchDetail(int id) async {
    isLoadingDetail = true;
    detailError = null;
    selectedTicket = null;
    notifyListeners();
    try {
      selectedTicket = await _service.getDetail(id);
      isLoadingDetail = false;
    } on AdminApiException catch (e) {
      isLoadingDetail = false;
      detailError = e.message;
    } catch (_) {
      isLoadingDetail = false;
      detailError = 'Could not load this ticket.';
    }
    notifyListeners();
  }

  Future<bool> updateStatus(int id, String status) async {
    isUpdating = true;
    notifyListeners();
    bool success = false;
    try {
      selectedTicket = await _service.updateStatus(id, status);
      final index = tickets.indexWhere((t) => t.id == id);
      if (index != -1) tickets[index] = selectedTicket!;
      success = true;
    } on AdminApiException catch (e) {
      detailError = e.message;
    } catch (_) {
      detailError = 'Could not update this ticket.';
    }
    isUpdating = false;
    notifyListeners();
    return success;
  }
}