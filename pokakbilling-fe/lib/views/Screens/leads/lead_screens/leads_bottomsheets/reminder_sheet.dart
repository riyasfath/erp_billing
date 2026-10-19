import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pokakbilling/ERP_UI_KIT.dart';
import 'package:pokakbilling/viewmodels/reminder/reminder_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:pokakbilling/models/data-models/reminder_model.dart';
import 'package:pokakbilling/models/data-models/lead_model.dart';
import 'package:pokakbilling/viewmodels/lead_viewmodel.dart';

class ReminderSheet extends StatefulWidget {
  final int? leadId;
  final String? leadName;

  const ReminderSheet({super.key, this.leadId, this.leadName});

  @override
  State<ReminderSheet> createState() => _ReminderSheetState();
}

class _ReminderSheetState extends State<ReminderSheet> {
  static const Color _accent = ErpColors.amber;

  static const List<ErpChoice> _reminderTypes = [
    ErpChoice('Phone Call', Icons.call_rounded, ErpColors.cyan),
    ErpChoice('WhatsApp', ErpIcons.whatsapp, ErpColors.whatsapp),
    ErpChoice('Email', Icons.email_rounded, ErpColors.violet),
    ErpChoice('Message', Icons.sms_rounded, ErpColors.pink),
    ErpChoice('Follow-up', Icons.event_repeat_rounded, ErpColors.orange),
  ];
  String selectedReminderType = 'Phone Call';

  DateTime selectedDate = DateTime.now();
  String selectedTimeIso = '';
  String selectedTimeDisplay = '';

  final TextEditingController _title = TextEditingController();
  final TextEditingController _details = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final FocusNode _titleFocus = FocusNode();
  bool submitting = false;
  LeadModel? _selectedLead;

  // ── Per-field touch tracking ──────────────────────────────────────────────
  final Map<String, bool> _touched = {};

  void _touch(String field) {
    if (_touched[field] != true) setState(() => _touched[field] = true);
  }

  // ── Validators ────────────────────────────────────────────────────────────
  String? _validateTitle(String? v) {
    if (v == null || v.trim().isEmpty) return 'Reminder subject is required';
    return null;
  }

  bool get _titleHasError =>
      _touched['title'] == true && _validateTitle(_title.text) != null;
  bool get _timeHasError => _touched['time'] == true && selectedTimeIso.isEmpty;
  bool get _leadHasError => _touched['lead'] == true && _selectedLead == null;

  /// Lead is fixed when the sheet is opened from a lead's detail page.
  bool get _leadLocked => widget.leadId != null && widget.leadId != 0;

  @override
  void initState() {
    super.initState();
    if (_leadLocked) {
      _selectedLead = LeadModel(
        leadId: widget.leadId!,
        name: widget.leadName ?? '',
        phone: '',
        enquiry: '',
        leadNumber: '',
        leadStatus: '',
        notes: '',
        createdAt: '',
        date: '',
      );
    }

    _titleFocus.addListener(() {
      if (!_titleFocus.hasFocus && _title.text.isEmpty) {
        setState(() => _touched['title'] = true);
      }
    });
    _title.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _title.dispose();
    _details.dispose();
    _titleFocus.dispose();
    super.dispose();
  }

  Future<void> pickDate() async {
    final now = DateTime.now();
    final res = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
      builder: (ctx, child) => erpPickerTheme(ctx, child, color: _accent),
    );
    if (res != null) setState(() => selectedDate = res);
  }

  String _timeOfDayToIso(TimeOfDay t) {
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    return '$hh:$mm:00';
  }

  Future<void> pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (ctx, child) => erpPickerTheme(ctx, child, color: _accent),
    );
    if (!mounted) return;
    setState(() {
      _touched['time'] = true;
      if (picked != null) {
        selectedTimeIso = _timeOfDayToIso(picked);
        selectedTimeDisplay = picked.format(context);
      }
    });
  }

  String _backendTypeFromLabel(String label) {
    switch (label) {
      case 'Phone Call':
        return 'call';
      case 'WhatsApp':
        return 'whatsapp';
      case 'Email':
        return 'email';
      case 'Message':
        return 'message';
      case 'Follow-up':
        return 'followup';
      default:
        return 'call';
    }
  }

  String _leadSub(LeadModel l) {
    final email = l.emailId ?? '';
    if (email.isNotEmpty) return email;
    return l.phone ?? '';
  }

  // ── Lead picker sheet (with search) ───────────────────────────────────────
  Future<void> _openSelectLeadSheet() async {
    LeadViewmodel? leadVm;
    try {
      leadVm = Provider.of<LeadViewmodel>(context, listen: false);
    } catch (_) {
      leadVm = null;
    }

    if (leadVm == null) {
      erpToast(context, 'Lead data not available',
          color: ErpColors.red, icon: Icons.error_outline_rounded);
      return;
    }

    try {
      if (leadVm.leadList.isEmpty) {
        final dyn = leadVm as dynamic;
        final res = dyn.fetchLeads();
        if (res is Future) await res;
      }
    } catch (_) {}

    if (!mounted) return;

    final lead = await showModalBottomSheet<LeadModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _LeadPickerSheet(
        leads: leadVm!.leadList,
        selectedId: _selectedLead?.leadId,
        subtitleOf: _leadSub,
      ),
    );

    if (lead != null) {
      setState(() {
        _selectedLead = lead;
        _touched['lead'] = true;
      });
    }
  }

  Future<void> _submitReminder() async {
    setState(() {
      _touched['title'] = true;
      _touched['time'] = true;
      _touched['lead'] = true;
    });

    if (!(formKey.currentState?.validate() ?? false)) return;
    if (selectedTimeIso.isEmpty) return;
    if (_selectedLead == null) return;

    FocusScope.of(context).unfocus();

    ReminderViewmodel? vm;
    try {
      vm = Provider.of<ReminderViewmodel>(context, listen: false);
    } catch (_) {
      vm = null;
    }

    if (vm == null) {
      erpToast(context, 'Reminder service not available',
          color: ErpColors.red, icon: Icons.error_outline_rounded);
      return;
    }

    setState(() => submitting = true);

    try {
      final parts = selectedTimeIso.split(':');
      final int hh = int.tryParse(parts[0]) ?? 0;
      final int mm = int.tryParse(parts[1]) ?? 0;
      final dt = DateTime(
          selectedDate.year, selectedDate.month, selectedDate.day, hh, mm);

      final dateStr = DateFormat('yyyy-MM-dd').format(dt);

      final reminder = ReminderModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        leadId: _selectedLead!.leadId.toString(),
        leadName: _selectedLead!.name,
        subject: _title.text.trim(),
        type: _backendTypeFromLabel(selectedReminderType),
        date: dateStr,
        time: selectedTimeIso,
        notes: _details.text.trim(),
        status: 'scheduled',
        completed: false,
        phone: _selectedLead!.phone,
        email: _selectedLead!.emailId,
      );

      await vm.addReminder(reminder);

      if (!mounted) return;
      erpToast(context,
          'Reminder set for ${DateFormat('dd MMM, hh:mm a').format(dt)}',
          icon: Icons.alarm_on_rounded);
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        erpToast(context, 'Failed to set reminder: $e',
            color: ErpColors.red, icon: Icons.error_outline_rounded);
      }
    } finally {
      if (mounted) setState(() => submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateText = DateFormat('EEE, dd MMM yyyy').format(selectedDate);
    final timeText = selectedTimeDisplay.isEmpty ? null : selectedTimeDisplay;

    const fieldStyle = TextStyle(
        fontSize: 14.5, color: ErpColors.ink, fontWeight: FontWeight.w600);

    final lead = _selectedLead;

    return ErpSheet(
      title: 'Set Reminder',
      subtitle: _leadLocked && (widget.leadName ?? '').isNotEmpty
          ? 'for ${widget.leadName}'
          : 'Never miss a follow-through',
      icon: Icons.alarm_add_rounded,
      color: _accent,
      children: [
        Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Lead ───────────────────────────────────────────────
              const ErpFieldLabel('Lead', isRequired: true),
              ErpPickerTile(
                icon: Icons.person_add_alt_1_rounded,
                placeholder: 'Choose a lead',
                value: lead?.name,
                subValue: lead != null ? _leadSub(lead) : null,
                hasError: _leadHasError,
                color: ErpColors.cyan,
                leading: lead == null
                    ? null
                    : ErpGradientTile(
                        icon: Icons.person_rounded,
                        color: ErpColors.cyan,
                        size: 34,
                        circle: true,
                      ),
                onTap: _openSelectLeadSheet,
              ),
              if (lead != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Text('Tap to change lead',
                      style: const TextStyle(
                          fontSize: 11.5,
                          color: ErpColors.slate,
                          fontWeight: FontWeight.w600)),
                ),
              if (_leadHasError) const ErpErrorText('Please choose a lead'),
              const SizedBox(height: 14),

              // ── Type ───────────────────────────────────────────────
              const ErpFieldLabel('Reminder Type', isRequired: true),
              ErpChoiceGrid(
                options: _reminderTypes,
                selected: selectedReminderType,
                onSelect: (v) => setState(() => selectedReminderType = v),
              ),
              const SizedBox(height: 16),

              // ── Subject ────────────────────────────────────────────
              const ErpFieldLabel('Reminder Subject', isRequired: true),
              TextFormField(
                controller: _title,
                focusNode: _titleFocus,
                cursorColor: _accent,
                textInputAction: TextInputAction.next,
                style: fieldStyle,
                autovalidateMode: _touched['title'] == true
                    ? AutovalidateMode.onUserInteraction
                    : AutovalidateMode.disabled,
                onChanged: (_) => _touch('title'),
                onEditingComplete: () {
                  _touch('title');
                  FocusScope.of(context).nextFocus();
                },
                validator: _validateTitle,
                decoration: erpInputDecoration(
                  hint: 'e.g. Follow up call with client',
                  icon: Icons.title_rounded,
                  hasError: _titleHasError,
                  color: _accent,
                ),
              ),
              if (_titleHasError)
                const ErpErrorText('Reminder subject is required'),
              const SizedBox(height: 14),

              // ── Date & time ────────────────────────────────────────
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ErpFieldLabel('Date', isRequired: true),
                      ErpPickerTile(
                        icon: Icons.calendar_month_rounded,
                        placeholder: 'Pick date',
                        value: dateText,
                        color: _accent,
                        onTap: pickDate,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ErpFieldLabel('Time', isRequired: true),
                      ErpPickerTile(
                        icon: Icons.schedule_rounded,
                        placeholder: 'Set time',
                        value: timeText,
                        hasError: _timeHasError,
                        color: ErpColors.violet,
                        onTap: pickTime,
                      ),
                      if (_timeHasError)
                        const ErpErrorText('Please set a time'),
                    ],
                  ),
                ),
              ]),
              const SizedBox(height: 14),

              // ── Details ────────────────────────────────────────────
              const ErpFieldLabel('Additional Details', isOptional: true),
              TextFormField(
                controller: _details,
                cursorColor: _accent,
                minLines: 2,
                maxLines: 3,
                style: fieldStyle,
                decoration: erpInputDecoration(
                  hint: 'Any notes or context',
                  icon: Icons.notes_rounded,
                  color: _accent,
                ),
              ),
              const SizedBox(height: 22),

              // ── Buttons ────────────────────────────────────────────
              ErpPrimaryButton(
                text: 'Set Reminder',
                icon: Icons.alarm_on_rounded,
                loading: submitting,
                color: _accent,
                onTap: _submitReminder,
              ),
              const SizedBox(height: 10),
              ErpSecondaryButton(
                text: 'Cancel',
                onTap: submitting ? null : () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Lead picker sheet (searchable)
// ═════════════════════════════════════════════════════════════════════════════
class _LeadPickerSheet extends StatefulWidget {
  final List<LeadModel> leads;
  final int? selectedId;
  final String Function(LeadModel) subtitleOf;

  const _LeadPickerSheet({
    required this.leads,
    required this.selectedId,
    required this.subtitleOf,
  });

  @override
  State<_LeadPickerSheet> createState() => _LeadPickerSheetState();
}

class _LeadPickerSheetState extends State<_LeadPickerSheet> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final q = _q.trim().toLowerCase();
    final list = q.isEmpty
        ? widget.leads
        : widget.leads
            .where((l) =>
                l.name.toLowerCase().contains(q) ||
                widget.subtitleOf(l).toLowerCase().contains(q))
            .toList();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(children: [
          Container(
            width: 44,
            height: 5,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: ErpColors.line,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 14, 12),
            child: Row(children: [
              const ErpGradientTile(
                  icon: Icons.people_alt_rounded,
                  color: ErpColors.cyan,
                  size: 42),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Select Lead',
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: ErpColors.ink)),
                    Text('${widget.leads.length} leads',
                        style: const TextStyle(
                            fontSize: 12.5, color: ErpColors.slate)),
                  ],
                ),
              ),
              ErpPressable(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                      color: ErpColors.pageBg, shape: BoxShape.circle),
                  child: const Icon(Icons.close_rounded,
                      color: ErpColors.slate, size: 18),
                ),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: TextField(
              cursorColor: ErpColors.cyan,
              onChanged: (v) => setState(() => _q = v),
              style: const TextStyle(
                  fontSize: 14.5,
                  color: ErpColors.ink,
                  fontWeight: FontWeight.w600),
              decoration: erpInputDecoration(
                hint: 'Search by name, email or phone',
                icon: Icons.search_rounded,
              ),
            ),
          ),
          const Divider(height: 1, color: ErpColors.line),
          Expanded(
            child: list.isEmpty
                ? ListView(controller: controller, children: const [
                    SizedBox(height: 40),
                    ErpEmptyState(
                      icon: Icons.person_search_rounded,
                      title: 'No leads found',
                      subtitle: 'Try a different search term',
                    ),
                  ])
                : ListView.builder(
                    controller: controller,
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 20),
                    itemCount: list.length,
                    itemBuilder: (context, i) {
                      final l = list[i];
                      final sel = l.leadId == widget.selectedId;
                      final c =
                          ErpColors.rotation[i % ErpColors.rotation.length];
                      final sub = widget.subtitleOf(l);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: ErpPressable(
                          onTap: () => Navigator.of(context).pop(l),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: sel
                                  ? ErpColors.cyan.withValues(alpha: 0.08)
                                  : ErpColors.pageBg,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: sel ? ErpColors.cyan : ErpColors.line,
                                  width: sel ? 1.5 : 1),
                            ),
                            child: Row(children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [ErpColors.tint(c, 0.22), c],
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    l.name.isNotEmpty
                                        ? l.name[0].toUpperCase()
                                        : 'L',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 17),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(l.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 14.5,
                                            fontWeight: FontWeight.w800,
                                            color: ErpColors.ink)),
                                    if (sub.isNotEmpty)
                                      Text(sub,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontSize: 12.5,
                                              color: ErpColors.slate)),
                                  ],
                                ),
                              ),
                              if (sel)
                                const ErpGradientTile(
                                    icon: Icons.check_rounded,
                                    color: ErpColors.cyan,
                                    size: 24,
                                    circle: true)
                              else
                                const Icon(Icons.chevron_right_rounded,
                                    color: ErpColors.slate),
                            ]),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ]),
      ),
    );
  }
}