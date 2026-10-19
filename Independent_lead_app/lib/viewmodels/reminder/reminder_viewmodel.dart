
import 'package:flutter/material.dart';
import 'package:pokakbilling/models/data-models/lead_model.dart';
import 'package:pokakbilling/models/services/reminder_service.dart';
import 'package:provider/provider.dart';
import 'package:pokakbilling/models/data-models/reminder_model.dart';
import 'package:pokakbilling/viewmodels/lead_viewmodel.dart';

class ReminderViewmodel extends ChangeNotifier {
  List<ReminderModel> _reminders = [];
  bool _loading = false;
  Map<String, dynamic> _stats = {};

  List<ReminderModel> get reminders => _reminders;
  bool get loading => _loading;
  Map<String, dynamic> get stats => _stats;

  BuildContext? appContext;

  void attachContext(BuildContext ctx) {
    appContext = ctx;
  }

  ReminderViewmodel() {
    fetchReminders();
  }

  bool _isIdLikeLeadName(String? leadName, String? leadId) {
    if (leadName == null) return true;
    final trimmed = leadName.trim();
    if (trimmed.isEmpty) return true;
    if (leadId != null && trimmed == leadId.trim()) return true;
    final numericOnly = RegExp(r'^[0-9]+$');
    if (numericOnly.hasMatch(trimmed)) return true;
    return false;
  }

  String _combineDateTimeToISO(String date, String time) {
    String combined = '${date}T$time';
    final timeParts = time.split(':');
    if (timeParts.length == 2) {
      combined = '${date}T$time:00';
    }
    if (!combined.endsWith('Z') && !combined.contains('+')) {
      combined += 'Z';
    }
    return combined;
  }

  Future<void> fetchReminders({
    String? leadId,
    String? status,
    String? dueDateAfter,
    String? dueDateBefore,
  }) async {
    _loading = true;
    notifyListeners();

    try {
      final fetched = await ReminderServices.fetchReminders(
        leadId: leadId,
        status: status,
        dueDateAfter: dueDateAfter,
        dueDateBefore: dueDateBefore,
      );

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
              (l) =>
                  l.leadId.toString() == r.leadId.toString() ||
                  l.id.toString() == r.leadId.toString(),
              orElse: () => LeadModel(
                id: 0,
                leadId: '',
                name: '',
                company: '',
                email: '',
                phone: '',
                status: 'NEW',
                createdAt: '',
                updatedAt: '',
              ),
            );
            if (matchingLead.name.isNotEmpty) {
              leadName = matchingLead.name;
            }
          } catch (_) {}
        }

        return r.copyWith(leadName: leadName);
      }).toList();

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
      _reminders = [];
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> fetchStats() async {
    try {
      _stats = await ReminderServices.getReminderStats();
      notifyListeners();
    } catch (e) {
      debugPrint('fetchStats error: $e');
      _stats = {};
    }
  }

  Future<bool> createReminder({
    required String lead,
    required String title,
    required String subtype,
    required String date,
    required String time,
    String? description,
  }) async {
    try {
      final dueDate = _combineDateTimeToISO(date, time);

      final error = await ReminderServices.createReminder(
        lead: lead,
        title: title,
        subtype: subtype,
        dueDate: dueDate,
        description: description,
      );

      if (error == null) {
        await fetchReminders();
        await fetchStats();
        return true;
      } else {
        debugPrint('Create reminder error: $error');
        return false;
      }
    } catch (e) {
      debugPrint('createReminder exception: $e');
      return false;
    }
  }

  Future<void> addReminder(ReminderModel reminder) async {
    _reminders.insert(0, reminder);
    notifyListeners();

    try {
      final created = await ReminderServices.createReminderAndReturn(
        lead: reminder.leadId ?? '',
        title: reminder.title ?? '',
        subtype: reminder.subtype ?? 'Email',
        date: reminder.date ?? '',
        time: reminder.time ?? '',
        description: reminder.description,
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

  Future<bool> markCompleted(String id) async {
    final idx = _reminders.indexWhere((r) => r.id == id);
    if (idx == -1) return false;

    final updated = _reminders[idx].copyWith(
      status: 'COMPLETED',
      completed: true,
    );
    _reminders[idx] = updated;
    notifyListeners();

    try {
      final error = await ReminderServices.markCompleted(id);

      if (error == null) {
        await fetchReminders();
        await fetchStats();
        return true;
      } else {
        debugPrint('markCompleted error: $error');
        await fetchReminders();
        return false;
      }
    } catch (e) {
      debugPrint('markCompleted exception: $e');
      await fetchReminders();
      return false;
    }
  }

  Future<bool> deleteReminder(String id) async {
    try {
      final success = await ReminderServices.deleteReminder(id);
      if (success) {
        await fetchReminders();
        await fetchStats();
      }
      return success;
    } catch (e) {
      debugPrint('deleteReminder error: $e');
      return false;
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
        return r.leadId.toString() == leadId.toString();
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
      if (_reminders.isEmpty || forceReload) {
        final serverList = await ReminderServices.getRemindersByLead(
          int.tryParse(leadId) ?? 0,
        );

        if (forceReload) {
          _reminders = serverList;
        } else {
          final existingIds = _reminders.map((e) => e.id).toSet();
          final merged = <ReminderModel>[];
          merged.addAll(serverList);
          merged.addAll(_reminders.where((r) => !existingIds.contains(r.id)));
          _reminders = merged;
        }

        if (appContext != null) {
          await fetchReminders(leadId: leadId);
        } else {
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('fetchRemindersForLead error: $e');
    }

    final parsedLeadId = int.tryParse(leadId) ?? 0;
    return remindersForLead(parsedLeadId);
  }

  Future<void> refreshAllReminders() async {
    await fetchReminders();
    await fetchStats();
  }

  Future<void> refreshForLead(int leadId) async {
    await fetchRemindersForLead(leadId.toString(), forceReload: true);
  }

  // ✅ THE FIX: was `void reset() { notifyListeners(); }` — never cleared data.
  void reset() {
    _reminders = [];
    _loading = false;
    _stats = {};
    appContext = null;
    notifyListeners();
  }
}
