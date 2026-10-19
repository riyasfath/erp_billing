import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/models/data-models/followup_model.dart';
import 'package:pokakbilling/models/services/folllowup_service.dart';

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
    setState(() => _loading = true);

    try {
      final list = await FollowupServices.getFollowupsByLead(widget.leadId);

      if (mounted) {
        setState(() => _items = list);
      }
    } catch (e) {
      debugPrint('Followups load error: $e');

      if (mounted) {
        setState(() => _items = []);
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  String _formatDateTime(String? date, String? time) {
    final dateStr = (date ?? '').trim();
    final timeStr = (time ?? '').trim();

    if (dateStr.isEmpty && timeStr.isEmpty) {
      return '';
    }

    final combined = dateStr + (timeStr.isNotEmpty ? ' $timeStr' : '');

    try {
      final dt = DateTime.parse(combined.trim());

      return DateFormat('yyyy-MM-dd – hh:mm a').format(dt);
    } catch (_) {
      return combined.trim();
    }
  }

  Widget _tile(FollowupModel f) {
    final title = f.title.trim().isNotEmpty ? f.title.trim() : 'Follow-up';

    final notes = f.notes.trim();
    final type = f.type.trim();
    final status = f.status.trim();

    final statusLabel = status.isNotEmpty
        ? status[0].toUpperCase() +
            (status.length > 1 ? status.substring(1) : '')
        : '';

    return Card(
      color: AppColors.white,
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(
          color: AppColors.c1,
          width: 1.2,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
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
              type.isNotEmpty ? type[0].toUpperCase() : 'F',
              style: const TextStyle(
                color: AppColors.c1,
              ),
            ),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text(
              _formatDateTime(
                f.date,
                f.time,
              ),
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
            if (notes.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                notes,
                style: const TextStyle(
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              statusLabel.isNotEmpty ? statusLabel : 'Pending',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.cdark,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              type.isNotEmpty ? type : 'Follow-up',
              style: const TextStyle(
                fontSize: 11,
              ),
            ),
          ],
        ),
        onTap: () {
          // Open detail/edit screen if needed
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
                  border: Border.all(
                    color: AppColors.cborder,
                  ),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.c3,
                  size: 15,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Follow-ups • ${widget.leadName}',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.cdark,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: Builder(
          builder: (ctx) {
            if (_loading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (_items.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 80),
                  const Center(
                    child: Text(
                      'No follow-ups found for this lead.',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.cdark,
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
              );
            }

            return ListView.builder(
              itemCount: _items.length,
              itemBuilder: (_, i) => _tile(_items[i]),
            );
          },
        ),
      ),
    );
  }
}
