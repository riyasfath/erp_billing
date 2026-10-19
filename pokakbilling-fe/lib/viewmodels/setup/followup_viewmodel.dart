import 'package:flutter/material.dart';
import 'package:pokakbilling/models/data-models/followup_model.dart';
import 'package:pokakbilling/models/services/folllowup_service.dart';

class FollowupViewmodel extends ChangeNotifier {
  bool loading = false;
  List<FollowupModel> followups = [];

  FollowupViewmodel() {
    fetchFollowups();
  }

  /// ✅ RESET (for session expiry)
  void reset() {
    followups = [];
    loading = false;
    notifyListeners();
  }

  /// (optional alias)
  void clearData() => reset();

  Future<void> fetchFollowups() async {
    loading = true;
    notifyListeners();

    try {
      final list = await FollowupServices.getFollowups();
      followups = list;
    } catch (e) {
      followups = [];
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<String?> createFollowup({
    required int lead,
    required String title,
    required String date,
    required String time,
    required String status,
    required String type,
    String notes = '',
  }) async {
    try {
      final created = await FollowupServices.createFollowup(
        lead: lead,
        title: title,
        date: date,
        time: time,
        status: status,
        type: type,
        notes: notes,
      );

      if (created != null) {
        followups.insert(0, created);
      } else {
        await fetchFollowups();
      }

      return null;
    } catch (e) {
      return e.toString();
    } finally {
      notifyListeners();
    }
  }

  List<FollowupModel> followupsForLead(int leadId) {
    try {
      final filtered = followups.where((f) => f.lead == leadId).toList();

      filtered.sort((a, b) => b.id.compareTo(a.id));

      return filtered;
    } catch (_) {
      return <FollowupModel>[];
    }
  }

  Future<List<FollowupModel>> fetchFollowupsForLead(
    int leadId, {
    bool forceReload = false,
  }) async {
    if (followups.isEmpty || forceReload) {
      await fetchFollowups();
    }
    return followupsForLead(leadId);
  }

  Future<void> refreshFollowups() async {
    await fetchFollowups();
  }
}
