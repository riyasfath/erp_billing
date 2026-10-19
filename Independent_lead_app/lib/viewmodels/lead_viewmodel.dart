// lib/viewmodels/lead_viewmodel.dart
// UPDATED: priority support (create / edit / quick update), priority summary,
// paginated lead loading.

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pokakbilling/models/data-models/lead_model.dart';
import 'package:pokakbilling/models/services/lead_services.dart';
import 'package:pokakbilling/views/Screens/leads/lead_screens/leads.dart';
import 'package:pokakbilling/views/commonWidgets/response-message/error_message.dart';
import 'package:pokakbilling/views/commonWidgets/response-message/success-message.dart';
import 'package:pokakbilling/core/navigations.dart';

class LeadViewmodel extends ChangeNotifier {
  String selectedLeadStatus = "";
  bool isLeadStatusOther = false;

  bool addLeadLoader = false;
  bool getLeadLoader = false;
  bool deleteLeadLoading = false;
  bool singleLeadLoading = false;
  bool editLoading = false;
  bool scheduleCallLoading = false;

  var leadList = <LeadModel>[];
  var assignedLeadList = <LeadModel>[];
  var singleLeadList = <LeadModel>[];
  String selectedLead = "";

  /// Counts returned by the API (`priority_summary`) – may be null.
  PrioritySummary? serverPrioritySummary;

  String currentLeadId = '';
  final Random _random = Random();

  LeadViewmodel() {
    getAllLeads();
    getAssignedLeads();
  }

  // ── Priority helpers ─────────────────────────────────────────────────────
  final List<String> leadPriorityList = const ['Hot', 'Warm', 'Cool'];

  static String priorityKeyFromLabel(String label) {
    switch (label.trim().toLowerCase()) {
      case 'hot':
        return 'HOT';
      case 'warm':
        return 'WARM';
      case 'cool':
        return 'COOL';
      default:
        return label.trim().toUpperCase();
    }
  }

  PrioritySummary get prioritySummary =>
      serverPrioritySummary ?? PrioritySummary.fromLeads(leadList);

  void selectLead(String name) {
    selectedLead = name;
    notifyListeners();
  }

  var leadStatusList = [
    "New",
    "Contacted",
    "Qualified",
    "Converted",
    "Lost",
    "Other",
  ];

  String get selectedLeadStatusKey {
    switch (selectedLeadStatus) {
      case "New":
        return "NEW";
      case "Contacted":
        return "CONTACTED";
      case "Qualified":
        return "QUALIFIED";
      case "Converted":
        return "CONVERTED";
      case "Lost":
        return "LOST";
      case "Other":
        return "OTHER";
      default:
        return selectedLeadStatus.trim().toUpperCase();
    }
  }

  void selectLeadStatus(String leadStatus) {
    selectedLeadStatus = leadStatus;
    isLeadStatusOther = leadStatus == "Other";
    notifyListeners();
  }

  bool _leadIdExists(String leadId) {
    final target = leadId.trim().toUpperCase();
    return leadList.any((lead) => lead.leadId.trim().toUpperCase() == target);
  }

  String _generateRandomLeadId() {
    final value = 10000 + _random.nextInt(90000);
    return 'LD$value';
  }

  Future<String> generateUniqueLeadId({int maxRetries = 100}) async {
    if (leadList.isEmpty) {
      await getAllLeads();
    }

    for (int i = 0; i < maxRetries; i++) {
      final id = _generateRandomLeadId();
      if (!_leadIdExists(id)) return id;
    }

    int maxNumber = 10000;
    for (final lead in leadList) {
      final id = lead.leadId.trim().toUpperCase();
      if (id.startsWith('LD')) {
        final numberPart = int.tryParse(id.substring(2));
        if (numberPart != null && numberPart > maxNumber) {
          maxNumber = numberPart;
        }
      }
    }
    return 'LD${maxNumber + 1}';
  }

  Future<void> createLead({
    String? leadId,
    required String name,
    required String company,
    required String email,
    required String phone,
    String? location,
    String? enquiry,
    String? address,
    String? projectRequirements,
    String? additionalNotes,
    String? source,
    String? status,
    String? priority, // HOT | WARM | COOL
    String? receivedDate,
    String? reason,
    int? assignedTo,
    required BuildContext context,
  }) async {
    try {
      addLeadLoader = true;
      notifyListeners();

      await getAllLeads();

      String nextLeadId = (leadId == null || leadId.trim().isEmpty)
          ? await generateUniqueLeadId()
          : leadId.trim();

      currentLeadId = nextLeadId;
      notifyListeners();

      String? response;
      int retryCount = 0;
      const int maxRetries = 10;

      final String trimmedEmail = email.trim();
      final String? normalizedEmail =
          trimmedEmail.isEmpty ? null : trimmedEmail;

      while (retryCount < maxRetries) {
        response = await LeadServices.createLead(
          leadId: nextLeadId,
          name: name,
          company: company,
          email: normalizedEmail,
          phone: phone,
          location: location,
          enquiry: enquiry,
          address: address,
          projectRequirements: projectRequirements,
          additionalNotes: additionalNotes,
          source: source,
          status: status ?? selectedLeadStatusKey,
          priority: priority,
          receivedDate: receivedDate,
          reason: reason,
          assignedTo: assignedTo,
        );

        if (response == null) break;

        if (_isDuplicateLeadIdError(response)) {
          retryCount++;
          await getAllLeads();
          nextLeadId = await generateUniqueLeadId();
          currentLeadId = nextLeadId;
          notifyListeners();
          continue;
        }

        break;
      }

      if (response == null) {
        if (!context.mounted) return;
        showSuccessMessage(context, "Lead Created Successfully!");
        await getAllLeads();
        await getAssignedLeads();
        if (!context.mounted) return;
        pushReplacementNavigation(context, const LeadScreen());
      } else {
        if (!context.mounted) return;
        showOverlayError(context, response);
      }
    } catch (e) {
      if (context.mounted) {
        showOverlayError(context, 'Unexpected error: $e');
      }
    } finally {
      addLeadLoader = false;
      notifyListeners();
    }
  }

  bool _isDuplicateLeadIdError(String error) {
    final lower = error.toLowerCase();
    return lower.contains('duplicate') ||
        lower.contains('integrity') ||
        lower.contains('already exists') ||
        lower.contains('unique') ||
        lower.contains('lead_id') ||
        lower.contains('lead id');
  }

  Future<void> getAllLeads() async {
    try {
      getLeadLoader = true;
      notifyListeners();

      final LeadPage page = await LeadServices.getLeadsPage();
      leadList = page.leads;
      serverPrioritySummary = page.summary;
    } catch (e) {
      debugPrint('getAllLeads error: $e');
      leadList = <LeadModel>[];
    } finally {
      getLeadLoader = false;
      notifyListeners();
    }
  }

  Future<void> getAssignedLeads() async {
    try {
      final List<LeadModel> leads = await LeadServices.getAssignedLeads();
      assignedLeadList = leads;
      notifyListeners();
    } catch (e) {
      debugPrint('getAssignedLeads error: $e');
      assignedLeadList = <LeadModel>[];
      notifyListeners();
    }
  }

  Future<void> deleteLead(int leadId, BuildContext context) async {
    try {
      deleteLeadLoading = true;
      notifyListeners();

      final String? response = await LeadServices.deleteLead(leadId);

      if (response == null) {
        if (!context.mounted) return;
        showSuccessMessage(context, "Lead Deleted Successfully!");
        await getAllLeads();
        await getAssignedLeads();
        if (!context.mounted) return;
        pushNavigation(context, const LeadScreen());
      } else {
        if (!context.mounted) return;
        showOverlayError(context, response);
      }
    } catch (e) {
      debugPrint('deleteLead error: $e');
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
      singleLeadList = <LeadModel>[];
    } finally {
      singleLeadLoading = false;
      notifyListeners();
    }
  }

  Future<void> editLead({
    required int leadId,
    String? name,
    String? company,
    String? email,
    String? phone,
    String? location,
    String? enquiry,
    String? address,
    String? projectRequirements,
    String? additionalNotes,
    String? source,
    String? status,
    String? priority,
    String? receivedDate,
    String? reason,
    int? assignedTo,
    bool navigateOnSuccess = true,
    required BuildContext context,
  }) async {
    try {
      editLoading = true;
      notifyListeners();

      final String? response = await LeadServices.editLead(
        leadId: leadId,
        name: name,
        company: company,
        email: email,
        phone: phone,
        location: location,
        enquiry: enquiry,
        address: address,
        projectRequirements: projectRequirements,
        additionalNotes: additionalNotes,
        source: source,
        status: status ?? selectedLeadStatusKey,
        priority: priority,
        receivedDate: receivedDate,
        reason: reason,
        assignedTo: assignedTo,
      );

      if (response == null) {
        if (!context.mounted) return;
        showSuccessMessage(context, "Lead Updated Successfully!");
        await getAllLeads();
        await getAssignedLeads();
        if (navigateOnSuccess && context.mounted) {
          pushAndRemoveUntilFun(context, const LeadScreen());
        }
      } else {
        if (!context.mounted) return;
        showOverlayError(context, response);
      }
    } catch (e) {
      debugPrint('editLead error: $e');
      if (context.mounted) {
        showOverlayError(context, 'Unexpected error.');
      }
    } finally {
      editLoading = false;
      notifyListeners();
    }
  }

  /// Quick priority change (used by the lead detail screen). Returns error
  /// message or null on success.
  Future<String?> updateLeadPriority(int leadId, String priorityKey) async {
    final err =
        await LeadServices.editLead(leadId: leadId, priority: priorityKey);
    if (err == null) {
      await getAllLeads();
      await getAssignedLeads();
    }
    return err;
  }

  Future<void> searchLeadsByName(String name) async {
    try {
      getLeadLoader = true;
      notifyListeners();

      leadList = await LeadServices.searchLeadsByName(name);
    } catch (e) {
      debugPrint('searchLeadsByName error: $e');
    } finally {
      getLeadLoader = false;
      notifyListeners();
    }
  }

  Future<bool> scheduleCall(int leadId, BuildContext context) async {
    try {
      scheduleCallLoading = true;
      notifyListeners();

      final String? response = await LeadServices.scheduleCall(leadId);

      if (response == null) {
        if (context.mounted) {
          showSuccessMessage(context, "Call Scheduled");
        }
        return true;
      } else {
        if (context.mounted) {
          showOverlayError(context, response);
        }
        return false;
      }
    } catch (e) {
      debugPrint('scheduleCall error: $e');
      if (context.mounted) {
        showOverlayError(context, 'Unexpected error: $e');
      }
      return false;
    } finally {
      scheduleCallLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    notifyListeners();
  }
}