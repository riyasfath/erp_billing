import 'package:flutter/material.dart';
import 'package:pokakbilling/ERP_UI_KIT.dart';

import 'package:pokakbilling/models/data-models/followup_model.dart';
import 'package:pokakbilling/models/services/folllowup_service.dart';
import 'package:pokakbilling/views/Screens/leads/lead_screens/leads_bottomsheets/follow_up_sheet.dart';

class FollowupsListScreen extends StatefulWidget {
  final int leadId;
  final String leadName;

  const FollowupsListScreen({
    super.key,
    required this.leadId,
    required this.leadName,
  });

  @override
  State<FollowupsListScreen> createState() => _FollowupsListScreenState();
}

class _FollowupsListScreenState extends State<FollowupsListScreen> {
  bool _loading = true;
  List<FollowupModel> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);

    try {
      final list = await FollowupServices.getFollowupsByLead(widget.leadId);
      final sorted = List<FollowupModel>.from(list)
        ..sort((a, b) {
          final da = erpParseDateTime(a.date, a.time) ?? DateTime(1970);
          final db = erpParseDateTime(b.date, b.time) ?? DateTime(1970);
          return db.compareTo(da);
        });
      if (mounted) setState(() => _items = sorted);
    } catch (e) {
      debugPrint('Followups load error: $e');
      if (mounted) setState(() => _items = []);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _addFollowup() async {
    final res = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          FollowupSheet(preselectType: 'Phone Call', leadId: widget.leadId),
    );
    if (res == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    int done = 0;
    int overdue = 0;
    for (final f in _items) {
      if (erpIsDone(f.status)) {
        done++;
      } else {
        final dt = erpParseDateTime(f.date, f.time);
        if (dt != null && dt.isBefore(now)) overdue++;
      }
    }

    return ErpListShell(
      title: 'Follow-ups',
      subtitle:
          widget.leadName.isNotEmpty ? widget.leadName : 'All follow-ups',
      watermark: Icons.event_repeat_rounded,
      color: ErpColors.orange,
      loading: _loading,
      onRefresh: _load,
      itemCount: _items.length,
      emptyIcon: Icons.event_busy_rounded,
      emptyTitle: 'No follow-ups yet',
      emptySubtitle:
          'No follow-ups found for this lead.\nTap + to schedule one.',
      stats: [
        ErpStat('Total', _items.length, Icons.event_repeat_rounded),
        ErpStat('Overdue', overdue, Icons.warning_amber_rounded),
        ErpStat('Done', done, Icons.check_circle_rounded),
      ],
      floatingAction: widget.leadId != 0
          ? ErpPressable(
              onTap: _addFollowup,
              child: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      ErpColors.tint(ErpColors.orange, 0.2),
                      ErpColors.orange
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: ErpColors.orange.withValues(alpha: 0.45),
                      blurRadius: 16,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: const Icon(Icons.add_rounded,
                    color: Colors.white, size: 30),
              ),
            )
          : null,
      itemBuilder: (_, i) {
        final f = _items[i];
        final title = f.title.trim().isNotEmpty ? f.title.trim() : 'Follow-up';
        final type = f.type.trim();
        final (icon, color) = erpTypeStyle(type.isEmpty ? 'follow' : type);
        final (date, time) = erpSplitDateTime(f.date, f.time);
        final dt = erpParseDateTime(f.date, f.time);
        final status = f.status.trim();
        final isDone = erpIsDone(status);

        return ErpActivityCard(
          icon: icon,
          color: color,
          title: title,
          typeLabel: type.isEmpty ? 'Follow-up' : erpTitleCase(type),
          date: date,
          time: time,
          notes: f.notes.trim(),
          status: status.isEmpty ? 'Pending' : erpTitleCase(status),
          done: isDone,
          overdue: dt != null && dt.isBefore(now),
        );
      },
    );
  }
}