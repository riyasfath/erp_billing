import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/models/data-models/meeting_model.dart';
import 'package:pokakbilling/viewmodels/meeting_viewmodel.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMeetings();
    });
  }

  Future<void> _loadMeetings() async {
    final vm = Provider.of<MeetingViewmodel>(context, listen: false);
    final meetings = await vm.getMeetingsByLead(widget.leadId);
    if (mounted) {
      setState(() {
        _leadMeetings = meetings;
      });
    }
  }

  Future<void> _load() async {
    await _loadMeetings();
  }

  /// ✅ UPDATED: Parse NEW dueDate ISO field
  String _formatDateTime(MeetingModel m) {
    final dateTime = _parseDateTime(m.dueDate);
    if (dateTime == null) return m.dueDate.isNotEmpty ? m.dueDate : '';

    return DateFormat('yyyy-MM-dd – hh:mm a').format(dateTime);
  }

  DateTime? _parseDateTime(String s) {
    if (s.isEmpty) return null;
    try {
      return DateTime.parse(s);
    } catch (_) {
      return null;
    }
  }

  Widget _tile(MeetingModel m) {
    final title = m.title.isNotEmpty ? m.title : (m.description ?? '');
    final meetingType = (m.subtype ?? '').isNotEmpty ? m.subtype! : 'Meeting';
    final status = m.status.trim();

    final statusLabel = status.isNotEmpty
        ? (status[0].toUpperCase() +
            (status.length > 1 ? status.substring(1) : ''))
        : '';

    final statusColor = status.toLowerCase() == 'completed'
        ? AppColors.green
        : AppColors.tagRed;

    return Card(
      color: AppColors.white,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(
          color: AppColors.c1,
          width: 1.2,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.cxl,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.cborder,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              meetingType.isNotEmpty ? meetingType[0].toUpperCase() : 'M',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.c1,
              ),
            ),
          ),
        ),
        title: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.w600, color: AppColors.cdark)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text(_formatDateTime(m), style: const TextStyle(fontSize: 12)),
            if (m.description?.isNotEmpty ?? false) ...[
              const SizedBox(height: 6),
              Text(
                m.description!,
                style: const TextStyle(fontSize: 13, color: AppColors.cdark),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              statusLabel,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.cdark,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              meetingType,
              style: const TextStyle(fontSize: 11, color: AppColors.cdark),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        onTap: () {
          // Optionally open meeting detail/edit
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.white,
          title: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.cxl,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.cborder),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColors.c3,
                    size: 15,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Meetings • ${widget.leadName}',
                style: const TextStyle(
                  color: AppColors.cdark,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          )),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _leadMeetings.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 80),
                  Center(
                    child: Text(
                      widget.leadId != 0
                          ? 'No meetings found for this lead.'
                          : 'No meetings found.',
                      style: const TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton.icon(
                      onPressed: _load,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                    ),
                  ),
                ],
              )
            : ListView.builder(
                itemCount: _leadMeetings.length,
                itemBuilder: (_, i) => _tile(_leadMeetings[i]),
              ),
      ),
    );
  }
}
