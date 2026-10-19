import 'package:flutter/material.dart';
import 'package:pokakbilling/views/call_activity/call_activity_helpers.dart';
import 'package:provider/provider.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/models/call_activity/dashboard_model.dart';
import 'package:pokakbilling/models/call_activity/call_lead_model.dart';
import 'package:pokakbilling/viewmodels/call_activity/dashboard_viewmodel.dart';
import 'package:pokakbilling/views/call_activity/active_call_screen.dart';

/// "Call History" tab — history-list UI: a card per call with an eye icon
/// that opens one bottom sheet showing Call Information, Lead Stage
/// (read-only), an editable Status, Follow-up date, and Notes.
///
/// ⚠️ FIX: the old "Update Lead Status" dropdown sent lead-stage values
/// (new/contacted/qualified/converted/lost) into the PATCH `status` field.
/// Per `CallActivityService.updateCallDetails`'s own confirmed-working
/// payload comment, that `status` field is the CALL OUTCOME
/// (completed/busy/no_answer/failed) — there's no backend endpoint here
/// for editing lead stage separately. That mismatch is why nothing showed
/// as selected and saves didn't visibly do anything. This version's
/// dropdown uses the real, working value set, and the lead's `stage` is
/// still shown (as a read-only badge) since the API does return it.
///
/// ── CARD REDESIGN ───────────────────────────────────────────────────────
/// The list card (`_historyCard`) was rebuilt for a richer, more
/// "finished" look: a colored left accent rail keyed to call outcome, a
/// ring-avatar, an outcome icon+chip instead of plain text, a divider
/// before the meta row, and a trailing chevron to signal it's tappable.
/// No data/behavior changes — same fields, same tap target, same sheet.
class CallHistoryTab extends StatelessWidget {
  /// Called after returning from a call — mirrors the parent's
  /// `_resetFilters(refresh: true)` call from the original file.
  final VoidCallback onAfterCall;

  const CallHistoryTab({super.key, required this.onAfterCall});

  CallLeadModel _leadFromHistory(CallHistoryItemModel h) => CallLeadModel(
        leadId: h.id ?? 0,
        name: h.name,
        phone: h.phone,
        status: h.status,
      );

  Future<void> _startCallWithLead(
      BuildContext context, CallLeadModel lead) async {
    if (lead.phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No phone number on file for this lead')),
      );
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ActiveCallScreen(lead: lead)),
    );
    onAfterCall();
  }

  // Call-outcome status color (initiated / no_answer / completed / busy…)
  Color _callStatusColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('no') && s.contains('answer')) return AppColors.tagRed;
    if (s.contains('fail')) return AppColors.tagRed;
    if (s.contains('busy')) return AppColors.amber;
    if (s.contains('complete') || (s.contains('answer') && !s.contains('no'))) {
      return AppColors.tagGreen;
    }
    // "initiated" and anything unrecognized
    return AppColors.amber;
  }

  // Call-outcome icon, paired with the color above.
  IconData _callStatusIcon(String status) {
    final s = status.toLowerCase();
    if (s.contains('no') && s.contains('answer'))
      return Icons.phone_missed_rounded;
    if (s.contains('fail')) return Icons.error_rounded;
    if (s.contains('busy')) return Icons.phone_paused_rounded;
    if (s.contains('complete') || (s.contains('answer') && !s.contains('no'))) {
      return Icons.check_circle_rounded;
    }
    return Icons.hourglass_top_rounded;
  }

  // Lead-stage color (new / contacted / qualified / converted / lost)
  Color _leadStageColor(String stage) {
    switch (stage.toLowerCase()) {
      case 'qualified':
        return AppColors.c2;
      case 'contacted':
        return AppColors.c3;
      case 'converted':
        return AppColors.tagGreen;
      case 'lost':
        return AppColors.tagRed;
      case 'new':
      default:
        return AppColors.amber;
    }
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  @override
  Widget build(BuildContext context) {
    return Consumer<CallActivityViewmodel>(
      builder: (context, vm, _) {
        if (vm.getHistoryLoader && !vm.historyLoaded) {
          return callActivityLoadingState();
        }

        final items = vm.historyData.results;
        if (items.isEmpty) {
          return callActivityEmptyState(
            icon: Icons.history_rounded,
            title: 'No call history yet',
            subtitle: 'Completed calls will be logged here.',
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            sectionLabelWithBadge('CALL HISTORY', vm.historyData.count,
                AppColors.ctext, Icons.history_rounded),
            const SizedBox(height: 10),
            ...items.map((h) => _historyCard(context, h)),
          ],
        );
      },
    );
  }

  // ── Redesigned history card ─────────────────────────────────────────
  Widget _historyCard(BuildContext context, CallHistoryItemModel h) {
    final callColor = _callStatusColor(h.status);
    final callIcon = _callStatusIcon(h.status);
    final stageColor = _leadStageColor(h.stage);
    final isOutgoing = (h.callType ?? 'Outgoing').toLowerCase() != 'incoming';

    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.cdark.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: callColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showHistoryDetail(context, h),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Colored accent rail keyed to call outcome
                Container(
                  width: 5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [callColor, callColor.withOpacity(0.55)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Top row: ring-avatar + name/phone + chevron
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: callColor.withOpacity(0.35),
                                    width: 1.6),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      callColor.withOpacity(0.16),
                                      callColor.withOpacity(0.06),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  initialsFromName(
                                      h.name.isEmpty ? '?' : h.name),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: callColor,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          h.name.isEmpty ? 'Unknown' : h.name,
                                          style: const TextStyle(
                                              fontSize: 14.5,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.cdark),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (h.stage.isNotEmpty &&
                                          h.stage != '-') ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 7, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: stageColor.withOpacity(0.10),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                                color: stageColor
                                                    .withOpacity(0.3)),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.flag_rounded,
                                                  size: 9, color: stageColor),
                                              const SizedBox(width: 3),
                                              Text(
                                                _capitalize(h.stage),
                                                style: TextStyle(
                                                    fontSize: 9.5,
                                                    fontWeight: FontWeight.w800,
                                                    color: stageColor),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.phone_rounded,
                                          size: 11,
                                          color:
                                              AppColors.ctext.withOpacity(0.5)),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          h.phone.isEmpty ? '-' : h.phone,
                                          style: TextStyle(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.ctext
                                                  .withOpacity(0.65)),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.chevron_right_rounded,
                                size: 20,
                                color: AppColors.ctext.withOpacity(0.35)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Divider(
                          height: 1,
                          color: AppColors.cborder.withOpacity(0.55),
                        ),
                        const SizedBox(height: 10),
                        // ── Bottom meta row: outcome chip, direction
                        // chip, duration — with icons for quick scanning.
                        Wrap(
                          spacing: 8,
                          runSpacing: 7,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 9, vertical: 5),
                              decoration: BoxDecoration(
                                color: callColor.withOpacity(0.10),
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(callIcon, size: 12, color: callColor),
                                  const SizedBox(width: 5),
                                  Text(
                                    h.status.isEmpty
                                        ? '-'
                                        : _capitalize(h.status),
                                    style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w800,
                                        color: callColor),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 9, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.c3.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isOutgoing
                                        ? Icons.call_made_rounded
                                        : Icons.call_received_rounded,
                                    size: 12,
                                    color: AppColors.c3,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    h.callType ?? 'Outgoing',
                                    style: const TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.c3),
                                  ),
                                ],
                              ),
                            ),
                            if (h.duration != null && h.duration!.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 9, vertical: 5),
                                decoration: BoxDecoration(
                                  color: AppColors.cxl,
                                  borderRadius: BorderRadius.circular(9),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.timer_outlined,
                                        size: 12,
                                        color:
                                            AppColors.ctext.withOpacity(0.6)),
                                    const SizedBox(width: 5),
                                    Text(
                                      h.duration!,
                                      style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.ctext
                                              .withOpacity(0.75)),
                                    ),
                                  ],
                                ),
                              ),
                            if (h.callDate != null && h.callDate!.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 9, vertical: 5),
                                decoration: BoxDecoration(
                                  color: AppColors.cxl,
                                  borderRadius: BorderRadius.circular(9),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.event_rounded,
                                        size: 12,
                                        color:
                                            AppColors.ctext.withOpacity(0.6)),
                                    const SizedBox(width: 5),
                                    Text(
                                      h.callDate!,
                                      style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.ctext
                                              .withOpacity(0.75)),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatFollowUpDateApi(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _formatDateDDMMYYYY(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year.toString().padLeft(4, '0')}';

  // Small label used above each editable section in the detail sheet.
  Widget _sectionLabel(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 13, color: AppColors.c1),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.cdark,
              letterSpacing: 0.1),
        ),
      ],
    );
  }

  // Read-only info row used for Date & Time / Duration / Call ID.
  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.ctext.withOpacity(0.75))),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.cdark),
            ),
          ),
        ],
      ),
    );
  }

  // ── Read-only "Call Details" sheet — Call Information, Status, Type,
  // Lead Stage, and Notes are all DISPLAY ONLY here. No editable status
  // chips, no follow-up date picker, no notes field, no Save action —
  // just what's already on record for this call.
  void _showHistoryDetail(BuildContext context, CallHistoryItemModel h) {
    final callColor = _callStatusColor(h.status);
    final callIcon = _callStatusIcon(h.status);
    final stageColor = _leadStageColor(h.stage);
    final dateTimeParts = [h.callDate, h.callTime]
        .where((e) => e != null && e.isNotEmpty)
        .toList();
    final dateTime = dateTimeParts.isEmpty ? '-' : dateTimeParts.join('  ·  ');
    final hasNotes = h.notes != null && h.notes!.trim().isNotEmpty;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.92,
          expand: false,
          builder: (_, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Call Details',
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.cdark),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(sheetCtx),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: AppColors.cborder.withOpacity(0.35),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const Icon(Icons.close_rounded,
                                color: AppColors.ctext, size: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Identity row
                          Row(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: AppColors.c1.withOpacity(0.10),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Icon(Icons.person_rounded,
                                    size: 22, color: AppColors.c1),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(h.name.isEmpty ? 'Unknown' : h.name,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.cdark)),
                                    const SizedBox(height: 2),
                                    Text(h.phone.isEmpty ? '-' : h.phone,
                                        style: TextStyle(
                                            fontSize: 12.5,
                                            color: AppColors.ctext
                                                .withOpacity(0.7))),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(sheetCtx);
                                  _startCallWithLead(
                                      context, _leadFromHistory(h));
                                },
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.c1,
                                        AppColors.c1.withOpacity(0.8)
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.c1.withOpacity(0.28),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(Icons.call_rounded,
                                      size: 18, color: AppColors.white),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // ── Status / type / stage — display only.
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: callColor.withOpacity(0.10),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: callColor.withOpacity(0.3)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(callIcon, size: 12, color: callColor),
                                    const SizedBox(width: 5),
                                    Text(
                                      h.status.isEmpty
                                          ? '-'
                                          : _capitalize(h.status),
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: callColor),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: AppColors.cxl,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppColors.cborder),
                                ),
                                child: Text(
                                  (h.callType ?? 'Outgoing').toLowerCase(),
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.cdark),
                                ),
                              ),
                              if (h.stage.isNotEmpty && h.stage != '-')
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: stageColor.withOpacity(0.10),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: stageColor.withOpacity(0.3)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.flag_rounded,
                                          size: 11, color: stageColor),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Lead: ${_capitalize(h.stage)}',
                                        style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                            color: stageColor),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // ── Call Information
                          _sectionLabel(
                              'Call Information', Icons.info_outline_rounded),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.cxl,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                _infoRow('Date & Time', dateTime),
                                Divider(
                                    height: 1,
                                    color: AppColors.cborder.withOpacity(0.6)),
                                _infoRow('Duration', h.duration ?? '-'),
                                Divider(
                                    height: 1,
                                    color: AppColors.cborder.withOpacity(0.6)),
                                _infoRow(
                                    'Call ID', h.id == null ? '-' : '${h.id}'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          // ── Call Notes — read-only.
                          _sectionLabel(
                              'Call Notes', Icons.sticky_note_2_rounded),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.cxl,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.cborder),
                            ),
                            child: Text(
                              hasNotes ? h.notes!.trim() : 'No notes added.',
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.4,
                                color: hasNotes
                                    ? AppColors.cdark
                                    : AppColors.ctext.withOpacity(0.5),
                                fontStyle: hasNotes
                                    ? FontStyle.normal
                                    : FontStyle.italic,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                  // ── Single Close action — nothing to save here.
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      border: Border(
                          top: BorderSide(
                              color: AppColors.cborder.withOpacity(0.6))),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.cborder),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => Navigator.pop(sheetCtx),
                        child: const Text('Close',
                            style: TextStyle(
                                color: AppColors.cdark,
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// Small value type describing one selectable "Update Status" option — the
// real, confirmed-working call-outcome values, label, and chip color.
class _StatusOption {
  final String label;
  final String value;
  final Color color;

  const _StatusOption({
    required this.label,
    required this.value,
    required this.color,
  });
}
