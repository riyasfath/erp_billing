import 'package:flutter/material.dart';
import 'package:pokakbilling/ERP_UI_KIT.dart';
import 'package:provider/provider.dart';

import 'package:pokakbilling/models/data-models/meeting_model.dart';
import 'package:pokakbilling/viewmodels/meeting_viewmodel.dart';
import 'package:pokakbilling/views/Screens/leads/lead_screens/leads_bottomsheets/meeting_sheet.dart';

class MeetingsListScreen extends StatefulWidget {
  final int leadId;
  final String leadName;

  const MeetingsListScreen({
    super.key,
    required this.leadId,
    required this.leadName,
  });

  @override
  State<MeetingsListScreen> createState() => _MeetingsListScreenState();
}

class _MeetingsListScreenState extends State<MeetingsListScreen> {
  List<MeetingModel> _leadMeetings = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadMeetings());
  }

  Future<void> _loadMeetings() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final vm = Provider.of<MeetingViewmodel>(context, listen: false);
      await vm.getAllMeetings();
      if (mounted) {
        final list = widget.leadId != 0
            ? vm.meetingList.where((m) => m.leadId == widget.leadId).toList()
            : List<MeetingModel>.from(vm.meetingList);

        // Newest first
        list.sort((a, b) {
          final da = erpParseDateTime(a.date, a.time) ?? DateTime(1970);
          final db = erpParseDateTime(b.date, b.time) ?? DateTime(1970);
          return db.compareTo(da);
        });
        setState(() => _leadMeetings = list);
      }
    } catch (e) {
      debugPrint('MeetingsListScreen load error: $e');
      if (mounted) setState(() => _leadMeetings = []);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _addMeeting() async {
    final res = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          MeetingSheet(leadName: widget.leadName, leadId: widget.leadId),
    );
    if (res == true) _loadMeetings();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    int upcoming = 0;
    int done = 0;
    for (final m in _leadMeetings) {
      if (erpIsDone(m.status)) {
        done++;
      } else {
        final dt = erpParseDateTime(m.date, m.time);
        if (dt != null && dt.isAfter(now)) upcoming++;
      }
    }

    return ErpListShell(
      title: 'Meetings',
      subtitle: widget.leadName.isNotEmpty
          ? widget.leadName
          : 'All scheduled meetings',
      watermark: Icons.video_camera_front_rounded,
      color: ErpColors.blue,
      loading: _loading,
      onRefresh: _loadMeetings,
      itemCount: _leadMeetings.length,
      emptyIcon: Icons.event_busy_rounded,
      emptyTitle: 'No meetings yet',
      emptySubtitle: widget.leadId != 0
          ? 'No meetings found for this lead.\nTap + to schedule one.'
          : 'No meetings found.',
      stats: [
        ErpStat('Total', _leadMeetings.length, Icons.event_note_rounded),
        ErpStat('Upcoming', upcoming, Icons.upcoming_rounded),
        ErpStat('Done', done, Icons.check_circle_rounded),
      ],
      floatingAction: widget.leadId != 0
          ? _AddFab(color: ErpColors.blue, onTap: _addMeeting)
          : null,
      itemBuilder: (_, i) {
        final m = _leadMeetings[i];
        final title = m.title.isNotEmpty ? m.title : (m.description ?? '');
        final type =
            (m.meetingType ?? '').isNotEmpty ? m.meetingType! : 'Meeting';
        final (icon, color) = erpTypeStyle(type);
        final (date, time) = erpSplitDateTime(m.date, m.time);
        final dt = erpParseDateTime(m.date, m.time);
        final isDone = erpIsDone(m.status);

        return ErpActivityCard(
          icon: icon,
          color: color,
          title: title.isNotEmpty ? title : 'Meeting',
          typeLabel: erpTitleCase(type),
          date: date,
          time: time,
          notes: (m.description ?? '').isNotEmpty && m.description != title
              ? m.description
              : null,
          status: erpTitleCase(m.status),
          done: isDone,
          overdue: dt != null && dt.isBefore(now),
        );
      },
    );
  }
}

class _AddFab extends StatelessWidget {
  final Color color;
  final VoidCallback onTap;
  const _AddFab({required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => ErpPressable(
        onTap: onTap,
        child: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [ErpColors.tint(color, 0.2), color],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.45),
                blurRadius: 16,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
        ),
      );
}