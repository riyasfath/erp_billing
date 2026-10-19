// lib/viewmodels/admin_lead_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:pokakbilling/core/lead_status.dart';
import 'package:pokakbilling/models/data-models/lead_model.dart';
import 'package:pokakbilling/models/services/amdin_lead/lead_serviceAdmin.dart';
import 'package:pokakbilling/views/commonWidgets/response-message/error_message.dart';
import 'package:pokakbilling/views/commonWidgets/response-message/success-message.dart';

class AdminLeadViewmodel extends ChangeNotifier {
  bool getLeadLoader = false;
  bool deleteLeadLoading = false;
  bool assignLoading = false;
  bool editLoading = false;

  List<LeadModel> leadList = [];

  String selectedLeadStatus = '';
  String selectedLeadStatusKey = '';

  // All 11 statuses, from the shared list.
  final List<String> leadStatusList = kLeadStatusLabels;

  AdminLeadViewmodel() {
    getAllLeads();
  }

  void selectLeadStatus(String status) {
    // Accepts a label ("Follow Up") or an API key ("follow_up").
    final option = findLeadStatus(status);
    selectedLeadStatus = option?.label ?? '';
    selectedLeadStatusKey = option?.key ?? '';
    notifyListeners();
  }

  Future<void> getAllLeads() async {
    try {
      getLeadLoader = true;
      notifyListeners();
      leadList = await AdminLeadServices.getAdminLeads();
    } catch (e) {
      debugPrint('AdminLeadViewmodel.getAllLeads error: $e');
      leadList = [];
    } finally {
      getLeadLoader = false;
      notifyListeners();
    }
  }

  Future<void> deleteLead(int leadId, BuildContext context) async {
    try {
      deleteLeadLoading = true;
      notifyListeners();
      final error = await AdminLeadServices.deleteAdminLead(leadId);
      if (error == null) {
        leadList.removeWhere((l) => l.leadId == leadId);
        notifyListeners();
        if (context.mounted) {
          showSuccessMessage(context, 'Lead deleted successfully.');
          Navigator.pop(context); // pop view screen if open
        }
      } else {
        if (context.mounted) showOverlayError(context, error);
      }
    } catch (e) {
      if (context.mounted) showOverlayError(context, 'Failed to delete lead.');
    } finally {
      deleteLeadLoading = false;
      notifyListeners();
    }
  }

  Future<void> assignSalesperson({
    required int leadId,
    required int salespersonId,
    required BuildContext context,
  }) async {
    try {
      assignLoading = true;
      notifyListeners();
      final error = await AdminLeadServices.assignSalesperson(
        leadId: leadId,
        salespersonId: salespersonId,
      );
      if (error == null) {
        await getAllLeads();
        if (context.mounted) {
          showSuccessMessage(context, 'Salesperson assigned successfully.');
        }
      } else {
        if (context.mounted) showOverlayError(context, error);
      }
    } catch (e) {
      if (context.mounted) {
        showOverlayError(context, 'Failed to assign salesperson.');
      }
    } finally {
      assignLoading = false;
      notifyListeners();
    }
  }

  Future<void> editLead({
    required int leadId,
    required String name,
    required String company,
    required String email,
    required String phone,
    required String notes,
    required String leadStatus,
    int? leadSource,
    String? enquiry,
    int? location,
    int? salesperson,
    required BuildContext context,
  }) async {
    try {
      editLoading = true;
      notifyListeners();
      final error = await AdminLeadServices.editAdminLead(
        leadId: leadId,
        name: name,
        company: company,
        email: email,
        phone: phone,
        notes: notes,
        leadStatus: leadStatus,
        leadSource: leadSource,
        enquiry: enquiry,
        location: location,
        salesperson: salesperson,
      );
      if (error == null) {
        await getAllLeads();
        if (context.mounted) {
          showSuccessMessage(context, 'Lead updated successfully.');
        }
      } else {
        if (context.mounted) showOverlayError(context, error);
      }
    } catch (e) {
      if (context.mounted) showOverlayError(context, 'Failed to update lead.');
    } finally {
      editLoading = false;
      notifyListeners();
    }
  }

  void clearData() {
    leadList = [];
    getLeadLoader = false;
    deleteLeadLoading = false;
    assignLoading = false;
    editLoading = false;
    notifyListeners();
  }
}