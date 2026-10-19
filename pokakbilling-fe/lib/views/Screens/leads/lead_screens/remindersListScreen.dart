import 'package:flutter/material.dart';
import 'package:pokakbilling/ERP_UI_KIT.dart';
import 'package:provider/provider.dart';

import 'package:pokakbilling/models/data-models/reminder_model.dart';
import 'package:pokakbilling/viewmodels/reminder/reminder_viewmodel.dart';
import 'package:pokakbilling/views/Screens/leads/lead_screens/leads_bottomsheets/reminder_sheet.dart';

class RemindersListScreen extends StatefulWidget {
  final int leadId;
  final String leadName;

  const RemindersListScreen({
    super.key,
    required this.leadId,
    required this.leadName,
  });

  @override
  State<RemindersListScreen> createState() => _RemindersListScreenState();
}

class _RemindersListScreenState extends State<RemindersListScreen> {
  bool _loading = true;
  String? _errorMessage;
  List<ReminderModel> _items = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final vm = context.read<ReminderViewmodel>();

      // ERP: attach context so viewmodel can resolve lead names
      vm.attachContext(context);

      // ERP: use viewmodel's fetchRemindersForLead with forceReload
      final list = await vm.fetchRemindersForLead(
        widget.leadId.toString(),
        forceReload: true,
      );

      debugPrint(
          '=== RemindersListScreen: leadId=${widget.leadId} → ${list.length} reminders ===');

      final sorted = List<ReminderModel>.from(list)
        ..sort((a, b) {
          final da = erpParseDateTime(a.date, a.time) ?? DateTime(1970);
          final db = erpParseDateTime(b.date, b.time) ?? DateTime(1970);
          return db.compareTo(da);
        });

      if (mounted) setState(() => _items = sorted);
    } catch (e, st) {
      debugPrint('=== REMINDER LOAD ERROR: $e ===');
      debugPrint(st.toString());
      if (mounted) setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _addReminder() async {
    final res = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          ReminderSheet(leadId: widget.leadId, leadName: widget.leadName),
    );
    if (res == true) _load();
  }

  bool _isDone(ReminderModel r) =>
      r.completed == true || erpIsDone(r.status ?? '');

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    int done = 0;
    int pending = 0;
    for (final r in _items) {
      if (_isDone(r)) {
        done++;
      } else {
        pending++;
      }
    }

    return ErpListShell(
      title: 'Reminders',
      subtitle: widget.leadName.isNotEmpty ? widget.leadName : 'All reminders',
      watermark: Icons.alarm_rounded,
      color: ErpColors.amber,
      loading: _loading,
      error: _errorMessage,
      onRefresh: _load,
      itemCount: _items.length,
      emptyIcon: Icons.notifications_off_rounded,
      emptyTitle: 'No reminders yet',
      emptySubtitle:
          'No reminders found for this lead.\nTap + to set one.',
      stats: [
        ErpStat('Total', _items.length, Icons.alarm_rounded),
        ErpStat('Pending', pending, Icons.hourglass_top_rounded),
        ErpStat('Done', done, Icons.check_circle_rounded),
      ],
      floatingAction: widget.leadId != 0
          ? ErpPressable(
              onTap: _addReminder,
              child: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      ErpColors.tint(ErpColors.amber, 0.2),
                      ErpColors.amber
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: ErpColors.amber.withValues(alpha: 0.45),
                      blurRadius: 16,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: const Icon(Icons.add_alarm_rounded,
                    color: Colors.white, size: 28),
              ),
            )
          : null,
      itemBuilder: (_, i) {
        final r = _items[i];
        final title =
            (r.subject ?? '').isNotEmpty ? (r.subject ?? '') : 'Untitled';
        final type = (r.type ?? '').toString();
        final (icon, color) = erpTypeStyle(type.isEmpty ? 'call' : type);
        final (date, time) = erpSplitDateTime(r.date, r.time);
        final dt = erpParseDateTime(r.date, r.time);
        final isDone = _isDone(r);
        final rawStatus = (r.status ?? '').trim();

        return ErpActivityCard(
          icon: icon,
          color: color,
          title: title,
          typeLabel: type.isEmpty ? 'Reminder' : erpTitleCase(type),
          date: date,
          time: time,
          notes: (r.notes ?? '').toString(),
          status: isDone
              ? 'Completed'
              : (rawStatus.isEmpty ? 'Pending' : erpTitleCase(rawStatus)),
          done: isDone,
          overdue: dt != null && dt.isBefore(now),
        );
      },
    );
  }
}