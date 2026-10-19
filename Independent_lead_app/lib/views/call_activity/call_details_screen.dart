import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/models/call_activity/call_lead_model.dart';
import 'package:pokakbilling/models/call_activity/call_details_model.dart';
import 'package:pokakbilling/viewmodels/call_activity/dashboard_viewmodel.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// CALL DETAILS — full page
/// Replaces the "eye icon" side panel from the web version. Shows call
/// info (date/time, duration, lead source), lets the user update lead
/// status, schedule a follow-up date, and add call notes.
/// GET/PATCH /call-activity/call-details/<lead_id>/
///
/// ✅ CHANGES (this pass):
///   • Removed the call icon button from the app bar / header (per
///     request). `ActiveCallScreen` import removed since it's no longer
///     used from this screen.
///   • Field styling (still pending — needs add_callLog_screen.dart to
///     match exactly, see chat).
/// ─────────────────────────────────────────────────────────────────────────
class CallDetailsScreen extends StatefulWidget {
  final CallLeadModel lead;
  const CallDetailsScreen({super.key, required this.lead});

  @override
  State<CallDetailsScreen> createState() => _CallDetailsScreenState();
}

class _CallDetailsScreenState extends State<CallDetailsScreen> {
  static const List<String> _statusOptions = [
    'New',
    'Contacted',
    'Qualified',
    'Converted',
    'Lost',
  ];

  String _selectedStatus = 'New';
  DateTime? _followUpDate;
  final TextEditingController _notesCtrl = TextEditingController();
  bool _hydrated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CallActivityViewmodel>().getCallDetails(widget.lead.leadId);
    });
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  /// Populates local form state from the fetched details exactly once,
  /// so the user's in-progress edits aren't clobbered on rebuild.
  void _hydrate(CallDetailsModel details) {
    if (_hydrated) return;
    _hydrated = true;
    _selectedStatus = _statusFromApi(details.leadStatus);
    if (details.followUpDate != null) {
      _followUpDate = DateTime.tryParse(details.followUpDate!);
    }
    _notesCtrl.text = details.notes ?? '';
  }

  String _statusFromApi(String raw) {
    return _statusOptions.firstWhere(
      (s) => s.toUpperCase() == raw.toUpperCase(),
      orElse: () => 'New',
    );
  }

  String get _statusApiValue => _selectedStatus.toUpperCase();

  String _formatDate(DateTime d) {
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '${d.year}-$mm-$dd';
  }

  Future<void> _pickFollowUpDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _followUpDate ?? now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365 * 2)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme:
              Theme.of(ctx).colorScheme.copyWith(primary: AppColors.c1),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _followUpDate = picked);
  }

  Future<void> _save() async {
    final vm = context.read<CallActivityViewmodel>();
    final ok = await vm.updateCallDetails(
      leadId: widget.lead.leadId,
      leadStatus: _statusApiValue,
      followUpDate: _followUpDate != null ? _formatDate(_followUpDate!) : null,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(ok ? 'Call details updated' : 'Failed to update call details'),
        backgroundColor: ok ? AppColors.tagGreen : AppColors.tagRed,
      ),
    );

    if (ok) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cxl,
      body: Column(
        children: [
          _header(context),
          Expanded(
            child: Consumer<CallActivityViewmodel>(
              builder: (context, vm, _) {
                if (vm.getCallDetailsLoader && vm.callDetails == null) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.c1),
                  );
                }

                final details = vm.callDetails ??
                    CallDetailsModel.empty(widget.lead.leadId);
                _hydrate(details);

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoCard(details),
                      const SizedBox(height: 16),
                      _sectionLabel('UPDATE LEAD STATUS'),
                      const SizedBox(height: 8),
                      _statusField(),
                      const SizedBox(height: 16),
                      _sectionLabel('SCHEDULE FOLLOW-UP'),
                      const SizedBox(height: 8),
                      _card([_followUpField()]),
                      const SizedBox(height: 16),
                      _sectionLabel('CALL NOTES'),
                      const SizedBox(height: 8),
                      _card([
                        TextField(
                          controller: _notesCtrl,
                          maxLines: 4,
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.cdark),
                          decoration: InputDecoration(
                            hintText: 'Add notes about this call…',
                            hintStyle: TextStyle(
                                fontSize: 12,
                                color: AppColors.ctext.withOpacity(0.55)),
                            border: InputBorder.none,
                            isCollapsed: true,
                          ),
                        ),
                      ]),
                      const SizedBox(height: 24),
                      _actionButtons(vm),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Call icon removed — header now only has back button + title/subtitle.
  Widget _header(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 14, 20, 16),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border:
            Border(bottom: BorderSide(color: AppColors.cborder, width: 1.5)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 34,
              height: 34,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: AppColors.cxl,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cborder),
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  color: AppColors.c1, size: 17),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Call Details',
                    style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: AppColors.cdark)),
                Text(widget.lead.name,
                    style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.ctext.withOpacity(0.7))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: AppColors.cdark,
            letterSpacing: 1.1),
      );

  Widget _card(List<Widget> children) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cborder, width: 1.2),
        ),
        child: Column(children: children),
      );

  Widget _infoCard(CallDetailsModel details) {
    return _card([
      _infoRow('Date & Time', details.dateTime ?? '—'),
      const Divider(height: 18, color: AppColors.cborder),
      _infoRow('Duration', details.duration ?? '—'),
      const Divider(height: 18, color: AppColors.cborder),
      _infoRow('Lead Source', details.leadSource ?? widget.lead.source ?? '—'),
    ]);
  }

  Widget _infoRow(String label, String value) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 12.5, color: AppColors.ctext.withOpacity(0.7))),
          Text(value,
              style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.cdark)),
        ],
      );

  Color _statusColor(String status) {
    switch (status) {
      case 'New':
        return AppColors.c1;
      case 'Contacted':
        return AppColors.amber;
      case 'Qualified':
        return AppColors.c3;
      case 'Converted':
        return AppColors.tagGreen;
      case 'Lost':
        return AppColors.tagRed;
      default:
        return AppColors.c1;
    }
  }

  // ✅ Compact, tap-to-open field (fixed ~50px height) instead of the
  // stock DropdownButton — matches the filter-chip look used elsewhere
  // in the app rather than stretching to fit the menu's intrinsic size.
  Widget _statusField() {
    final color = _statusColor(_selectedStatus);
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: _showStatusSheet,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.cborder, width: 1.2),
          ),
          child: Row(
            children: [
              Container(
                width: 9,
                height: 9,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              Expanded(
                child: Text(
                  _selectedStatus,
                  style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.cdark),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Lead Status',
                  style: TextStyle(
                      fontSize: 9, fontWeight: FontWeight.w700, color: color),
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.keyboard_arrow_down_rounded,
                  size: 18, color: AppColors.ctext.withOpacity(0.55)),
            ],
          ),
        ),
      ),
    );
  }

  void _showStatusSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.cborder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              'Update Lead Status',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.cdark),
            ),
            const SizedBox(height: 6),
            ..._statusOptions.map((o) {
              final selected = o == _selectedStatus;
              final color = _statusColor(o);
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    setState(() => _selectedStatus = o);
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: selected ? color.withOpacity(0.08) : AppColors.cxl,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected
                            ? color.withOpacity(0.35)
                            : AppColors.cborder,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 9,
                          height: 9,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                              color: color, shape: BoxShape.circle),
                        ),
                        Expanded(
                          child: Text(o,
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: selected
                                      ? FontWeight.w800
                                      : FontWeight.w500,
                                  color: selected ? color : AppColors.cdark)),
                        ),
                        if (selected)
                          Icon(Icons.check_circle_rounded,
                              color: color, size: 18),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _followUpField() {
    return GestureDetector(
      onTap: _pickFollowUpDate,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _followUpDate != null ? _formatDate(_followUpDate!) : 'dd-mm-yyyy',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _followUpDate != null
                  ? AppColors.cdark
                  : AppColors.ctext.withOpacity(0.55),
            ),
          ),
          Row(
            children: [
              if (_followUpDate != null)
                GestureDetector(
                  onTap: () => setState(() => _followUpDate = null),
                  child: const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(Icons.close_rounded,
                        size: 15, color: AppColors.c1),
                  ),
                ),
              const Icon(Icons.calendar_month_rounded,
                  size: 17, color: AppColors.ctext),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButtons(CallActivityViewmodel vm) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.cborder),
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Cancel',
                style: TextStyle(
                    color: AppColors.cdark, fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: vm.updatingCallDetails ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.c1,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: vm.updatingCallDetails
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.white),
                  )
                : const Text('Save Changes',
                    style: TextStyle(
                        color: AppColors.white, fontWeight: FontWeight.w800)),
          ),
        ),
      ],
    );
  }
}
