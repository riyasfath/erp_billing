import 'package:flutter/material.dart';
import 'package:pokakbilling/views/call_activity/call_activity_helpers.dart';
import 'package:provider/provider.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/models/call_activity/dashboard_model.dart';
import 'package:pokakbilling/models/call_activity/call_lead_model.dart';
import 'package:pokakbilling/viewmodels/call_activity/dashboard_viewmodel.dart';
import 'package:pokakbilling/views/call_activity/active_call_screen.dart';

/// "Today's Tasks" tab — split out of CallActivityScreen without changes.
class TodayTasksTab extends StatelessWidget {
  /// Called after returning from a call / after any update that should
  /// reset the dashboard filters — mirrors the parent's
  /// `_resetFilters(refresh: true)` call from the original file.
  final VoidCallback onAfterCall;

  const TodayTasksTab({super.key, required this.onAfterCall});

  // ── "Change Call Status" options — each with its own icon + color so the
  // picker reads clearly at a glance instead of a plain text dropdown.
  // Display label -> API value sent as `status` in the PATCH body.
  // Colors now pull strictly from the real AppColors palette (c1/c2/c3,
  // tagGreen, tagRed, amber) instead of arbitrary hex values.
  static const List<_StatusOption> _statusOptions = [
    _StatusOption(
      label: 'Completed',
      value: 'completed',
      icon: Icons.check_circle_rounded,
      color: AppColors.tagGreen,
    ),
    _StatusOption(
      label: 'Busy',
      value: 'busy',
      icon: Icons.phone_paused_rounded,
      color: AppColors.amber,
    ),
    _StatusOption(
      label: 'No Answered',
      value: 'no_answer',
      icon: Icons.phone_missed_rounded,
      color: AppColors.c3,
    ),
    _StatusOption(
      label: 'Failed',
      value: 'failed',
      icon: Icons.cancel_rounded,
      color: AppColors.tagRed,
    ),
  ];

  // Use the task's `leadId` (parsed from `lead_id`), not `id` (the
  // task id). The live API returns both and they are different numbers
  // (e.g. id: 61, lead_id: 228) — calling with `id` would dial/patch the
  // wrong lead.
  CallLeadModel _leadFromTask(CallTaskModel t) => CallLeadModel(
        leadId: t.leadId ?? t.id ?? 0,
        name: t.name,
        phone: t.phone,
        status: t.status,
        source: t.source,
      );

  // Shared call launcher — pushes ActiveCallScreen with a CallLeadModel
  // built from whatever item was tapped, then resets filters on return —
  // identical pattern to _openStartNewCall in the dashboard file.
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

  // ── Shared PATCH call for status / notes / follow-up date ───────────────
  // Uses the viewmodel's existing updateCallDetails(), which hits
  // call-activity/call-details/<id>/ with { status, follow_up_date, notes }.
  //
  // ✅ CONFIRMED VIA TESTING: despite the endpoint's `lead_id` naming, the
  // id it actually expects here is the Today's Task's own `id` (e.g. 239),
  // NOT the `lead_id` field. Passing `lead_id` (or falling back to it)
  // produced a 404 "Call not found" from the backend. So `task.id` is now
  // the primary id used for this call, with `leadId` only as a fallback
  // for the rare case `id` is missing.
  //
  // NOTE: this is specific to the update/PATCH flow. `_leadFromTask` above
  // (used by the "Call Now" button to start a live call) still prefers
  // `leadId` — that's a different backend flow and hasn't been confirmed
  // to need the same swap. If "Call Now" turns out to have the same
  // problem, it needs the same fix but in active_call_screen.dart /
  // call_lead_model.dart, which we'd need to check first.
  Future<void> _updateTaskDetails(
    BuildContext context,
    CallTaskModel task, {
    String? leadStatus,
    String? followUpDate,
    String? notes,
    required String successTitle,
    String? successSubtitle,
  }) async {
    final recordId = task.id ?? task.leadId;
    if (recordId == null) {
      debugPrint(
          '[_updateTaskDetails] BLOCKED: no id or leadId for task name=${task.name} '
          '— cannot update safely.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Missing id for this task — cannot update safely. Please refresh and try again.'),
        ),
      );
      return;
    }

    debugPrint(
        '[_updateTaskDetails] using recordId=$recordId (task.id=${task.id}, task.leadId=${task.leadId}) '
        'status=$leadStatus followUpDate=$followUpDate notes=${notes != null ? '"$notes"' : null}');

    final vm = context.read<CallActivityViewmodel>();
    final ok = await vm.updateCallDetails(
      leadId: recordId,
      leadStatus: leadStatus,
      followUpDate: followUpDate,
      notes: notes,
    );

    if (!context.mounted) return;

    _showResultSnackbar(
      context,
      ok,
      title: ok ? successTitle : 'Failed to update',
      subtitle:
          ok ? successSubtitle : 'Something went wrong. Please try again.',
    );

    if (ok) {
      // Refresh whichever list is currently on screen so the change
      // (status / follow-up date) is reflected immediately.
      vm.getTodayTasks(force: true);
    }
  }

  // Polished result snackbar — icon + title/subtitle in a rounded floating
  // card, rather than the default flat SnackBar. Accepts a contextual
  // title/subtitle so the user sees exactly what changed (e.g. "Status
  // updated" / "Marked as Completed") instead of a generic message.
  // Uses the real tagGreen / tagRed from AppColors.
  void _showResultSnackbar(
    BuildContext context,
    bool ok, {
    required String title,
    String? subtitle,
  }) {
    final color = ok ? AppColors.tagGreen : AppColors.tagRed;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
          duration: const Duration(seconds: 2, milliseconds: 600),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          padding: EdgeInsets.zero,
          content: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.22)),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.22),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.75)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    ok ? Icons.check_rounded : Icons.priority_high_rounded,
                    size: 19,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.cdark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle != null && subtitle.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.ctext.withOpacity(0.85),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }

  String _formatDateDDMMYYYY(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year.toString().padLeft(4, '0')}';

  // ✅ CONFIRMED VIA TESTING: the backend actually wants a bare
  // "YYYY-MM-DD" date for `follow_up_date` (e.g. "2026-07-15"). The
  // previous full ISO-8601 datetime format ("2026-07-15T10:00:00Z") was an
  // earlier, unconfirmed assumption and was the actual cause of follow-up
  // date updates failing — status/notes worked because they don't go
  // through this formatter.
  String _formatFollowUpDateApi(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // Short display form for a date coming back from the API, used on the
  // task card, e.g. "2026-07-15T10:00:00Z" -> "15 Jul 2026".
  String _shortDate(String raw) {
    final dt = DateTime.tryParse(raw);
    if (dt == null) return raw;
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  DateTime? _tryParseDate(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  // Reusable sheet header — icon chip + title + close button. Used by all
  // three bottom sheets so they share one consistent, polished look.
  Widget _sheetHeader(
      BuildContext sheetCtx, String title, IconData icon, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.75)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.32),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 17, color: Colors.white),
            ),
            const SizedBox(width: 11),
            Text(
              title,
              style: const TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.cdark),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => Navigator.pop(sheetCtx),
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: AppColors.cborder.withOpacity(0.35),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.close_rounded,
                color: AppColors.ctext, size: 17),
          ),
        ),
      ],
    );
  }

  Widget _sheetActions(
    BuildContext sheetCtx, {
    required VoidCallback? onConfirm,
    required String confirmLabel,
    required Color accent,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.cborder),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () => Navigator.pop(sheetCtx),
          child: const Text('Cancel', style: TextStyle(color: AppColors.cdark)),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: accent,
            disabledBackgroundColor: accent.withOpacity(0.4),
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: onConfirm,
          child: Text(confirmLabel,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }

  // ── "Change Call Status" bottom sheet — a colorful selectable list
  // (each option carries its own icon + color) instead of a plain text
  // dropdown, so the current choice is unmistakable at a glance. The sheet
  // header itself uses the app's primary cyan (c1) since this is the
  // "select one option" / dropdown-style action.
  void _showChangeStatusSheet(BuildContext context, CallTaskModel task) {
    _StatusOption? selected;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (sheetCtx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetCtx).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sheetHeader(sheetCtx, 'Change Call Status',
                        Icons.published_with_changes_rounded, AppColors.c1),
                    const SizedBox(height: 6),
                    Text(
                      'Select the outcome of this call',
                      style: TextStyle(
                          fontSize: 12.5,
                          color: AppColors.ctext.withOpacity(0.7)),
                    ),
                    const SizedBox(height: 16),
                    ..._statusOptions.map((opt) {
                      final isSelected = selected?.value == opt.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () => setSheetState(() => selected = opt),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 13, vertical: 11),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? opt.color.withOpacity(0.10)
                                    : AppColors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected
                                      ? opt.color
                                      : AppColors.cborder,
                                  width: isSelected ? 1.6 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          opt.color,
                                          opt.color.withOpacity(0.75),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    alignment: Alignment.center,
                                    child: Icon(opt.icon,
                                        size: 17, color: Colors.white),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      opt.label,
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                        color: isSelected
                                            ? opt.color
                                            : AppColors.cdark,
                                      ),
                                    ),
                                  ),
                                  // "Dropdown" style selection indicator —
                                  // unselected state uses primary cyan at
                                  // low opacity so the whole list reads as
                                  // one consistent selector control.
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 150),
                                    child: isSelected
                                        ? Icon(Icons.check_circle_rounded,
                                            key: const ValueKey('sel'),
                                            size: 20,
                                            color: opt.color)
                                        : Icon(
                                            Icons
                                                .radio_button_unchecked_rounded,
                                            key: const ValueKey('unsel'),
                                            size: 20,
                                            color:
                                                AppColors.c1.withOpacity(0.35),
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 10),
                    _sheetActions(
                      sheetCtx,
                      accent: selected?.color ?? AppColors.c1,
                      confirmLabel: 'Update Status',
                      onConfirm: selected == null
                          ? null
                          : () {
                              final opt = selected!;
                              Navigator.pop(sheetCtx);
                              _updateTaskDetails(
                                context,
                                task,
                                leadStatus: opt.value,
                                successTitle: 'Status updated',
                                successSubtitle: 'Marked as "${opt.label}"',
                              );
                            },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ── "Update Task Notes" bottom sheet (matches web modal) ────────────────
  // Accent is the app's primary cyan (c1) — keeps every "single field / no
  // options" sheet visually consistent with the primary brand color.
  void _showUpdateNotesSheet(BuildContext context, CallTaskModel task) {
    final controller = TextEditingController(text: task.notes ?? '');
    const accent = AppColors.c1;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetCtx).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sheetHeader(sheetCtx, 'Update Task Notes',
                    Icons.sticky_note_2_rounded, accent),
                const SizedBox(height: 16),
                const Text(
                  'Notes',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ctext),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: controller,
                  maxLines: 5,
                  minLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Enter notes...',
                    contentPadding: const EdgeInsets.all(12),
                    filled: true,
                    fillColor: accent.withOpacity(0.04),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.cborder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.cborder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: accent, width: 1.6),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                _sheetActions(
                  sheetCtx,
                  accent: accent,
                  confirmLabel: 'Save Note',
                  onConfirm: () {
                    final text = controller.text.trim();
                    Navigator.pop(sheetCtx);
                    _updateTaskDetails(
                      context,
                      task,
                      notes: text,
                      successTitle: 'Notes saved',
                      successSubtitle: text.isEmpty
                          ? 'Notes cleared for ${task.name}'
                          : 'Your note has been saved',
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── "Set Next Follow-up Date" bottom sheet (matches web modal) ──────────
  // Accent is the app's primary cyan (c1); the date field's dropdown-style
  // chevron also uses primary so it reads as a selector control.
  void _showFollowUpDateSheet(BuildContext context, CallTaskModel task) {
    DateTime? selectedDate =
        _tryParseDate(task.scheduledDate) ?? DateTime.now();
    const accent = AppColors.c1;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (sheetCtx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetCtx).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sheetHeader(sheetCtx, 'Set Next Follow-up Date',
                        Icons.calendar_month_rounded, accent),
                    const SizedBox(height: 16),
                    const Text(
                      'Follow-up Date',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ctext),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: sheetCtx,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                          builder: (ctx, child) => Theme(
                            data: Theme.of(ctx).copyWith(
                              colorScheme: Theme.of(ctx)
                                  .colorScheme
                                  .copyWith(primary: accent),
                            ),
                            child: child!,
                          ),
                        );
                        if (picked != null) {
                          setSheetState(() => selectedDate = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 13, vertical: 13),
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.05),
                          border: Border.all(color: accent.withOpacity(0.35)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.event_rounded,
                                    size: 17, color: accent),
                                const SizedBox(width: 8),
                                Text(
                                  selectedDate == null
                                      ? 'Select date'
                                      : _formatDateDDMMYYYY(selectedDate!),
                                  style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.cdark),
                                ),
                              ],
                            ),
                            Icon(Icons.keyboard_arrow_down_rounded,
                                size: 18, color: accent),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    _sheetActions(
                      sheetCtx,
                      accent: accent,
                      confirmLabel: 'Save Date',
                      onConfirm: selectedDate == null
                          ? null
                          : () {
                              final apiDate =
                                  _formatFollowUpDateApi(selectedDate!);
                              final displayDate =
                                  _formatDateDDMMYYYY(selectedDate!);
                              Navigator.pop(sheetCtx);
                              _updateTaskDetails(
                                context,
                                task,
                                followUpDate: apiDate,
                                successTitle: 'Follow-up date set',
                                successSubtitle: 'Scheduled for $displayDate',
                              );
                            },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CallActivityViewmodel>(
      builder: (context, vm, _) {
        if (vm.getTodayTasksLoader && !vm.todayTasksLoaded) {
          return callActivityLoadingState();
        }

        final data = vm.todayTasksData;
        if (data.todayTasks.isEmpty && data.overdueTasks.isEmpty) {
          return callActivityEmptyState(
            icon: Icons.task_alt_rounded,
            title: 'No tasks for today',
            subtitle: 'You\'re all caught up. New tasks will show up here.',
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (data.overdueTasks.isNotEmpty) ...[
              sectionLabelWithBadge('OVERDUE', data.overdueTasksCount,
                  AppColors.tagRed, Icons.warning_amber_rounded),
              const SizedBox(height: 10),
              ...data.overdueTasks
                  .map((t) => _taskCard(context, t, overdue: true)),
              const SizedBox(height: 18),
            ],
            sectionLabelWithBadge("TODAY'S TASKS", data.todayTasksCount,
                AppColors.c1, Icons.today_rounded),
            const SizedBox(height: 10),
            if (data.todayTasks.isEmpty)
              callActivityEmptyState(
                icon: Icons.event_available_rounded,
                title: 'Nothing scheduled today',
                subtitle: 'Tasks assigned for today will appear here.',
                compact: true,
              )
            else
              ...data.todayTasks.map((t) => _taskCard(context, t)),
          ],
        );
      },
    );
  }

  // Solid, fully-colored action button used in the task-card action row
  // (calendar / notes / status). Each action gets its own bold color +
  // standard Material icon with a white glyph, so the row reads clearly
  // and looks vivid instead of three flat grey squares. Colors are drawn
  // strictly from the real AppColors cyan family + amber.
  Widget _taskIconButton(IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: 40,
          height: 38,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.35),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 17, color: Colors.white),
        ),
      ),
    );
  }

  Widget _taskCard(BuildContext context, CallTaskModel task,
      {bool overdue = false}) {
    final color = overdue ? AppColors.tagRed : AppColors.c1;
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.16)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 3, color: color.withOpacity(0.65)),
              Padding(
                padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.10),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                initialsFromName(task.name),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: color,
                                ),
                              ),
                            ),
                            Positioned(
                              right: -1,
                              bottom: -1,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: AppColors.white, width: 1.6),
                                ),
                                child: Icon(
                                  overdue
                                      ? Icons.warning_amber_rounded
                                      : Icons.schedule_rounded,
                                  size: 9,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(task.name,
                                  style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.cdark),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  Icon(
                                    task.phone.isNotEmpty
                                        ? Icons.phone_rounded
                                        : Icons.label_outline_rounded,
                                    size: 11,
                                    color: AppColors.ctext.withOpacity(0.5),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      task.phone.isNotEmpty
                                          ? task.phone
                                          : task.stage,
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.ctext
                                              .withOpacity(0.65)),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              // ✅ shows the follow-up / scheduled date on
                              // the card itself, and updates as soon as
                              // getTodayTasks() refetches after a save.
                              if (task.scheduledDate != null &&
                                  task.scheduledDate!.isNotEmpty) ...[
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    Icon(Icons.event_rounded,
                                        size: 11,
                                        color: color.withOpacity(0.7)),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Follow-up: ${_shortDate(task.scheduledDate!)}',
                                      style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w600,
                                          color: color.withOpacity(0.9)),
                                    ),
                                  ],
                                ),
                              ],
                              if (task.source != null &&
                                  task.source!.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.c3.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    task.source!,
                                    style: const TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.c3),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (task.scheduledTime != null)
                              Text(task.scheduledTime!,
                                  style: const TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.cdark)),
                            const SizedBox(height: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.10),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(task.status,
                                  style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: color)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Action row — Call Now pill + 3 solid colorful icon
                    // buttons (calendar -> follow-up date, notes -> notes,
                    // status -> change status). Matches the web app's
                    // Today's Tasks card actions but with bolder, standard
                    // Material icons and each action's color pulled from
                    // the real AppColors cyan family (c2/c3) + amber, so
                    // it stays "fully colorful" while remaining on-brand.
                    Row(
                      children: [
                        Expanded(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => _startCallWithLead(
                                  context, _leadFromTask(task)),
                              child: Ink(
                                height: 38,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.c1,
                                      AppColors.c1.withOpacity(0.85)
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
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.call_rounded,
                                        size: 14, color: AppColors.white),
                                    SizedBox(width: 6),
                                    Text(
                                      'Call Now',
                                      style: TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _taskIconButton(
                            Icons.calendar_month_rounded,
                            AppColors.c3,
                            () => _showFollowUpDateSheet(context, task)),
                        const SizedBox(width: 8),
                        _taskIconButton(
                            Icons.sticky_note_2_rounded,
                            AppColors.c2,
                            () => _showUpdateNotesSheet(context, task)),
                        const SizedBox(width: 8),
                        _taskIconButton(
                            Icons.published_with_changes_rounded,
                            AppColors.amber,
                            () => _showChangeStatusSheet(context, task)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Small value type describing one selectable "Change Call Status" option —
// its display label, the API value sent in the PATCH body, and the
// icon/color used to render it in the picker.
class _StatusOption {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatusOption({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
}
