import 'package:flutter/material.dart';
import 'package:pokakbilling/models/data-models/lead_model.dart';
import 'package:provider/provider.dart';
import 'package:pokakbilling/models/data-models/reminder_model.dart';
import 'package:pokakbilling/models/services/reminder_service.dart';
import 'package:pokakbilling/viewmodels/lead_viewmodel.dart';

class ReminderViewmodel extends ChangeNotifier {
  List<ReminderModel> _reminders = [];
  bool _loading = false;

  final Set<String> _permanentlyCompletedIds = {};

  List<ReminderModel> get reminders => _reminders;
  bool get loading => _loading;

  BuildContext? appContext;

  void attachContext(BuildContext ctx) {
    appContext = ctx;
  }

  ReminderViewmodel();

  /// ✅ RESET (for session expiry)
  void reset() {
    _reminders = [];
    _loading = false;
    _permanentlyCompletedIds.clear();
    appContext = null;
    notifyListeners();
  }

  /// (optional alias)
  void clearData() => reset();

  bool _isIdLikeLeadName(String? leadName, String? leadId) {
    if (leadName == null) return true;

    final trimmed = leadName.trim();
    if (trimmed.isEmpty) return true;

    if (leadId != null && trimmed == leadId.trim()) return true;

    final numericOnly = RegExp(r'^[0-9]+$');
    if (numericOnly.hasMatch(trimmed)) return true;

    return false;
  }

  List<ReminderModel> _applyPermanentCompleted(List<ReminderModel> list) {
    return list.map((r) {
      if (_permanentlyCompletedIds.contains(r.id)) {
        return r.copyWith(status: 'completed', completed: true);
      }
      return r;
    }).toList();
  }

  Future<void> fetchReminders({String? leadId}) async {
    _loading = true;
    notifyListeners();

    try {
      final fetched = await ReminderServices.fetchReminders(leadId: leadId);

      List<ReminderModel> enriched = fetched.map((r) {
        String? leadName = r.leadName;

        final bool shouldResolveFromLeadVm = appContext != null &&
            r.leadId != null &&
            ((leadName == null || leadName.isEmpty) ||
                _isIdLikeLeadName(leadName, r.leadId));

        if (shouldResolveFromLeadVm) {
          try {
            final leadVm = appContext!.read<LeadViewmodel>();

            final matchingLead = leadVm.leadList.firstWhere(
              (l) => l.leadId.toString() == r.leadId.toString(),
              orElse: () => LeadModel(
                leadId: 0,
                name: '',
                phone: '',
                emailId: '',
                enquiry: '',
                leadNumber: '',
                leadStatus: '',
                notes: '',
                createdAt: '',
                date: '',
              ),
            );

            if (matchingLead.name.isNotEmpty) {
              leadName = matchingLead.name;
            }
          } catch (_) {}
        }

        return r.copyWith(leadName: leadName);
      }).toList();

      enriched = _applyPermanentCompleted(enriched);

      enriched.sort((a, b) {
        final da = _parseDateTimeForSort(a);
        final db = _parseDateTimeForSort(b);

        if (da == null && db == null) return 0;
        if (da == null) return 1;
        if (db == null) return -1;

        return da.compareTo(db);
      });

      _reminders = enriched;
    } catch (e) {
      debugPrint("Reminder fetch error: $e");
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> addReminder(ReminderModel reminder) async {
    _reminders.insert(0, reminder);
    notifyListeners();

    try {
      final created = await ReminderServices.createReminderAndReturn(
        lead: reminder.leadId ?? '',
        title: reminder.subject ?? '',
        type: reminder.type ?? '',
        date: reminder.date ?? '',
        time: reminder.time ?? '',
        description: reminder.notes,
      );

      final merged = created.copyWith(
        leadName: created.leadName == null || created.leadName!.isEmpty
            ? reminder.leadName
            : created.leadName,
      );

      final idx = _reminders.indexWhere((r) => r.id == reminder.id);

      if (idx != -1) {
        _reminders[idx] = merged;
      } else {
        _reminders.insert(0, merged);
      }

      notifyListeners();
    } catch (e) {
      _reminders.removeWhere((r) => r.id == reminder.id);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> markCompleted(String id) async {
    final idx = _reminders.indexWhere((r) => r.id == id);
    if (idx == -1) return;

    final old = _reminders[idx];
    final updated = old.copyWith(status: 'completed', completed: true);

    _reminders[idx] = updated;
    notifyListeners();

    try {
      final ok = await ReminderServices.markCompleted(id);

      if (ok) {
        _permanentlyCompletedIds.add(id);
      } else {
        _reminders[idx] = old;
        notifyListeners();
      }
    } catch (e) {
      _permanentlyCompletedIds.add(id);
      rethrow;
    }
  }

  DateTime? _parseDateTimeForSort(ReminderModel r) {
    try {
      if (r.date != null && r.date!.isNotEmpty) {
        final date = DateTime.tryParse(r.date!);
        if (date == null) return null;

        int hh = 0, mm = 0, ss = 0;

        if (r.time != null && r.time!.isNotEmpty) {
          final parts = r.time!.split(":");
          hh = int.tryParse(parts[0]) ?? 0;
          mm = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
          ss = int.tryParse(parts.length > 2 ? parts[2] : '0') ?? 0;
        }

        return DateTime(date.year, date.month, date.day, hh, mm, ss);
      }
    } catch (_) {}

    return null;
  }

  List<ReminderModel> remindersForLead(int leadId) {
    try {
      final filtered = _reminders.where((r) {
        if (r.leadId == null) return false;
        return r.leadId.toString().trim() == leadId.toString().trim();
      }).toList();

      filtered.sort((a, b) {
        final da = _parseDateTimeForSort(a);
        final db = _parseDateTimeForSort(b);

        if (da == null && db == null) return 0;
        if (da == null) return 1;
        if (db == null) return -1;

        return da.compareTo(db);
      });

      return filtered;
    } catch (_) {
      return <ReminderModel>[];
    }
  }

  Future<List<ReminderModel>> fetchRemindersForLead(
    String leadId, {
    bool forceReload = false,
  }) async {
    try {
      final parsedId = int.tryParse(leadId) ?? 0;

      if (parsedId == 0) {
        debugPrint('fetchRemindersForLead: invalid leadId "$leadId"');
        return [];
      }

      final serverList = await ReminderServices.getRemindersByLead(parsedId);

      final withCompleted = _applyPermanentCompleted(serverList);

      withCompleted.sort((a, b) {
        final da = _parseDateTimeForSort(a);
        final db = _parseDateTimeForSort(b);

        if (da == null && db == null) return 0;
        if (da == null) return 1;
        if (db == null) return -1;

        return da.compareTo(db);
      });

      return withCompleted;
    } catch (e, st) {
      debugPrint('fetchRemindersForLead error: $e');
      debugPrint(st.toString());
      rethrow;
    }
  }

  Future<void> refreshAllReminders() async {
    await fetchReminders();
  }
}
