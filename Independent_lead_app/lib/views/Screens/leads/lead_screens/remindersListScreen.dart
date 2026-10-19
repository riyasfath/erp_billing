// lib/views/Screens/leads/reminders_list_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/models/data-models/reminder_model.dart';
import 'package:pokakbilling/models/services/reminder_service.dart';

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
  List<ReminderModel> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      List<ReminderModel> list;
      // If leadId is provided (>0) fetch reminders for that lead, otherwise fetch all reminders
      if (widget.leadId != 0) {
        list = await ReminderServices.getRemindersByLead(widget.leadId);
      } else {
        // fetchReminders can accept a leadId string — passing null fetches all
        list = await ReminderServices.fetchReminders();
      }
      if (mounted) setState(() => _items = list);
    } catch (e) {
      if (mounted) setState(() => _items = []);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _formatDateTime(String? date, String? time) {
    final dateStr = (date ?? '').trim();
    final timeStr = (time ?? '').trim();
    if (dateStr.isEmpty && timeStr.isEmpty) return '';

    final combined = dateStr + (timeStr.isNotEmpty ? ' $timeStr' : '');
    try {
      final dt = DateTime.parse(combined.trim());
      return DateFormat('yyyy-MM-dd – hh:mm a').format(dt);
    } catch (_) {
      return combined.trim();
    }
  }

  Widget _tile(ReminderModel r) {
    // ReminderModel fields per your model: subject, notes, date, time, status, type
    final title = (r.subject ?? '').isNotEmpty ? (r.subject ?? '') : 'Untitled';
    final notes = (r.notes ?? '').toString();
    final rtype = (r.type ?? '').toString();
    final date = (r.date ?? '');
    final time = (r.time ?? '');
    final status = (r.status ?? '').trim();

    final statusLabel = status.isNotEmpty
        ? (status[0].toUpperCase() +
            (status.length > 1 ? status.substring(1) : ''))
        : '';

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
              rtype.isNotEmpty ? rtype[0].toUpperCase() : 'R',
              style: const TextStyle(color: AppColors.c1),
            ),
          ),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text(_formatDateTime(date, time),
                style: const TextStyle(fontSize: 12)),
            if (notes.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(notes, style: const TextStyle(fontSize: 13)),
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
            Text(rtype, style: const TextStyle(fontSize: 11)),
          ],
        ),
        onTap: () {
          // optionally open reminder detail/edit
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
              'Reminders • ${widget.leadName}',
              style: const TextStyle(
                color: AppColors.cdark,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: Builder(builder: (ctx) {
          if (_loading) return const Center(child: CircularProgressIndicator());

          if (_items.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 80),
                const Center(
                    child: Text('No reminders found for this lead.',
                        style:
                            TextStyle(fontSize: 15, color: AppColors.cdark))),
                const SizedBox(height: 12),
                Center(
                    child: TextButton.icon(
                        onPressed: _load,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh'))),
              ],
            );
          }

          return ListView.builder(
            itemCount: _items.length,
            itemBuilder: (_, i) => _tile(_items[i]),
          );
        }),
      ),
    );
  }
}
