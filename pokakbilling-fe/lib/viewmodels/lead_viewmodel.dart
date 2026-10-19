import 'package:flutter/material.dart';
import 'package:pokakbilling/core/lead_status.dart';
import 'package:pokakbilling/models/data-models/lead_model.dart';
import 'package:pokakbilling/models/services/lead_services.dart';
import 'package:pokakbilling/views/Screens/leads/lead_screens/leadsnewscreen.dart';
import 'package:pokakbilling/views/commonWidgets/response-message/error_message.dart';
import 'package:pokakbilling/views/commonWidgets/response-message/success-message.dart';
import 'package:pokakbilling/views/no_permission.dart';

class LeadViewmodel extends ChangeNotifier {
  String selectedLeadStatus = "";
  String selectedLeadStatusKey = "";

  bool addLeadLoader = false;
  bool getLeadLoader = false;
  bool deleteLeadLoading = false;
  bool singleLeadLoading = false;
  bool editLoading = false;

  var leadList = <LeadModel>[];
  var singleLeadList = <LeadModel>[];

  LeadViewmodel() {
    getAllLeads();
  }

  // All statuses, from the shared list.
  final List<String> leadStatusList = kLeadStatusLabels;

  void reset() {
    leadList = [];
    singleLeadList = [];
    selectedLeadStatus = "";
    selectedLeadStatusKey = "";
    addLeadLoader = false;
    getLeadLoader = false;
    deleteLeadLoading = false;
    singleLeadLoading = false;
    editLoading = false;
    notifyListeners();
  }

  void clearData() => reset();

  void selectLeadStatus(String leadStatus) {
    // Accepts a label ("Follow Up") or an API key ("follow_up").
    final option = findLeadStatus(leadStatus);
    selectedLeadStatus = option?.label ?? "";
    selectedLeadStatusKey = option?.key ?? "";
    notifyListeners();
  }

  // ── Helper: routes an error response to either the clean "no permission"
  // popup or the standard error overlay, depending on what the service
  // returned. Keeps this logic in one place instead of repeating it.
  void _handleErrorResponse(BuildContext context, String response) {
    if (!context.mounted) return;
    if (response == LeadServices.kNoPermissionError) {
      showNoPermissionPopup(context);
    } else {
      showOverlayError(context, response);
    }
  }

  // ── Catches the case where the service layer THROWS (e.g. Dio's
  // RequestOptions.validateStatus rejecting a 400/403 response) instead of
  // returning an error string.
  void _handleThrownError(BuildContext context, Object e) {
    if (!context.mounted) return;

    final text = e.toString();
    final isPermissionIssue = text.contains('400') ||
        text.contains('401') ||
        text.contains('403') ||
        text.toLowerCase().contains('permission');

    if (isPermissionIssue) {
      showNoPermissionPopup(context);
    } else if (text.toLowerCase().contains('socketexception') ||
        text.toLowerCase().contains('network')) {
      showOverlayError(context, 'No internet connection. Please try again.');
    } else {
      showOverlayError(context, 'Something went wrong. Please try again.');
    }
  }

  Future<void> createLead(
    String name,
    String companyName,
    String emailId,
    String phoneNumber,
    String notes,
    String leadStatus,
    int? leadSource,
    String enquiry,
    BuildContext context, {
    int? location,
    String? date,
    String? leadCategory,
    String? otherCategoryDetail,
    int? course,
    int? salesperson,
    String? reasonNote, // ← NEW (lead_status == 'lost')
    String? otherNote, // ← NEW (lead_status == 'other')
  }) async {
    try {
      addLeadLoader = true;
      notifyListeners();

      final String? response = await LeadServices.createLead(
        name,
        companyName,
        emailId,
        phoneNumber,
        notes,
        leadStatus,
        leadSource,
        enquiry,
        location: location,
        date: date,
        leadCategory: leadCategory,
        otherCategoryDetail: otherCategoryDetail,
        course: course,
        salesperson: salesperson,
        reasonNote: reasonNote,
        otherNote: otherNote,
      );

      if (response == null) {
        await getAllLeads();
        if (!context.mounted) return;
        showSuccessMessage(context, "Lead Created Successfully!");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const LeadsNewScreen(),
          ),
        );
      } else {
        _handleErrorResponse(context, response);
      }
    } catch (e) {
      if (context.mounted) {
        _handleThrownError(context, e);
      }
    } finally {
      addLeadLoader = false;
      notifyListeners();
    }
  }

  Future<void> getAllLeads({bool staffOnly = false}) async {
    try {
      getLeadLoader = true;
      notifyListeners();

      final List<LeadModel> leadItems =
          await LeadServices.getLeads(staffOnly: staffOnly);

      if (leadItems.isNotEmpty) {
        leadList = leadItems;
      } else {
        leadList.clear();
      }
    } catch (e) {
      debugPrint('getAllLeads error: $e');
      leadList.clear();
    } finally {
      getLeadLoader = false;
      notifyListeners();
    }
  }

  Future<void> deleteLead(int leadId, BuildContext context) async {
    try {
      deleteLeadLoading = true;
      notifyListeners();

      final String? response = await LeadServices.deleteLead(leadId);

      if (response == null) {
        await getAllLeads();
        if (!context.mounted) return;
        showSuccessMessage(context, "Lead Deleted Successfully!");
      } else {
        _handleErrorResponse(context, response);
      }
    } catch (e) {
      debugPrint('deleteLead error: $e');
      if (context.mounted) {
        _handleThrownError(context, e);
      }
    } finally {
      deleteLeadLoading = false;
      notifyListeners();
    }
  }

  Future<void> getLeadById(int leadId) async {
    try {
      singleLeadLoading = true;
      notifyListeners();

      final LeadModel leadItem = await LeadServices.getLeadById(leadId);
      singleLeadList = [leadItem];
    } catch (e) {
      debugPrint('getLeadById error: $e');
      singleLeadList.clear();
    } finally {
      singleLeadLoading = false;
      notifyListeners();
    }
  }

  Future<void> editLead(
    int leadId,
    String name,
    String companyName,
    String emailId,
    String phoneNumber,
    String notes,
    String leadStatus,
    int? leadSource,
    String enquiry,
    BuildContext context, {
    int? location,
    String? date,
    String? leadCategory,
    String? otherCategoryDetail,
    int? course,
    int? salesperson,
    String? reasonNote, // ← NEW (lead_status == 'lost')
    String? otherNote, // ← NEW (lead_status == 'other')
  }) async {
    try {
      editLoading = true;
      notifyListeners();

      final String? response = await LeadServices.editLead(
        leadId,
        name,
        companyName,
        emailId,
        phoneNumber,
        notes,
        leadStatus,
        leadSource,
        enquiry,
        location: location,
        date: date,
        leadCategory: leadCategory,
        otherCategoryDetail: otherCategoryDetail,
        course: course,
        salesperson: salesperson,
        reasonNote: reasonNote,
        otherNote: otherNote,
      );

      if (response == null) {
        await getAllLeads();
        if (!context.mounted) return;
        showSuccessMessage(context, "Lead has been successfully updated!");
        Navigator.pop(context, true);
      } else {
        _handleErrorResponse(context, response);
      }
    } catch (e) {
      debugPrint('editLead error: $e');
      if (context.mounted) {
        _handleThrownError(context, e);
      }
    } finally {
      editLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchLeadsByName(String name) async {
    try {
      getLeadLoader = true;
      notifyListeners();

      final List<LeadModel> leadItems =
          await LeadServices.searchLeadsByName(name);

      leadList = leadItems;
    } catch (e) {
      debugPrint('searchLeadsByName error: $e');
    } finally {
      getLeadLoader = false;
      notifyListeners();
    }
  }

  Future<void> searchLeadsByDate(
    String fromDate,
    String toDate,
    BuildContext context,
  ) async {
    try {
      getLeadLoader = true;
      notifyListeners();

      final List<LeadModel> searchedLeads =
          await LeadServices.searchLeadsByDate(
        fromDate: fromDate,
        toDate: toDate,
      );

      leadList = searchedLeads;
    } catch (e) {
      debugPrint("Date search failed: $e");
      if (context.mounted) {
        showOverlayError(context, "Failed to search leads by date.");
      }
    } finally {
      getLeadLoader = false;
      notifyListeners();
    }
  }

  Future<void> scheduleFollowup({
    required int leadId,
    required String title,
    required String date,
    required String time,
    required String status,
    required String type,
    required String notes,
    required BuildContext context,
  }) async {
    try {
      final String? error = await LeadServices.createFollowup(
        leadId: leadId,
        title: title,
        date: date,
        time: time,
        status: status,
        type: type,
        notes: notes,
      );

      if (error == null) {
        if (!context.mounted) return;
        showSuccessMessage(context, 'Follow-up created successfully.');
        await getAllLeads();
      } else {
        _handleErrorResponse(context, error);
      }
    } catch (e) {
      debugPrint('scheduleFollowup error: $e');
      if (context.mounted) {
        _handleThrownError(context, e);
      }
    }
  }
}