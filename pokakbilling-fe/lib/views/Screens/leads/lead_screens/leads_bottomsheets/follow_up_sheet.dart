import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pokakbilling/ERP_UI_KIT.dart';
import 'package:pokakbilling/viewmodels/setup/followup_viewmodel.dart';
import 'package:provider/provider.dart';

class FollowupSheet extends StatefulWidget {
  final String preselectType;
  final int leadId;

  const FollowupSheet({
    super.key,
    this.preselectType = 'Phone Call',
    required this.leadId,
  });

  @override
  State<FollowupSheet> createState() => _FollowupSheetState();
}

class _FollowupSheetState extends State<FollowupSheet> {
  static const Color _accent = ErpColors.orange;

  static const List<ErpChoice> _types = [
    ErpChoice('Phone Call', Icons.call_rounded, ErpColors.cyan),
    ErpChoice('Meeting', Icons.handshake_rounded, ErpColors.amber),
    ErpChoice('Email', Icons.email_rounded, ErpColors.violet),
    ErpChoice('WhatsApp', ErpIcons.whatsapp, ErpColors.whatsapp),
    ErpChoice('Video Call', Icons.videocam_rounded, ErpColors.blue),
    ErpChoice('SMS', Icons.sms_rounded, ErpColors.pink),
  ];

  late String selectedType;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  final TextEditingController _desc = TextEditingController();
  final TextEditingController _title = TextEditingController();

  final formKey = GlobalKey<FormState>();
  bool submitting = false;

  // ── Per-field touch tracking ──────────────────────────────────────────────
  final Map<String, bool> _touched = {};

  void _touch(String field) {
    if (_touched[field] != true) setState(() => _touched[field] = true);
  }

  // ── Validators ────────────────────────────────────────────────────────────
  String? _validateTitle(String? v) {
    if (v == null || v.trim().isEmpty) return 'Follow-up title is required';
    if (v.trim().length < 3) return 'Title must be at least 3 characters';
    if (v.trim().length > 100) return 'Title must be under 100 characters';
    return null;
  }

  String? _validateDesc(String? v) {
    if (v == null || v.trim().isEmpty) return 'Description is required';
    if (v.trim().length > 500) {
      return 'Description must be under 500 characters';
    }
    return null;
  }

  bool get _titleHasError =>
      _touched['title'] == true && _validateTitle(_title.text) != null;
  bool get _descHasError =>
      _touched['desc'] == true && _validateDesc(_desc.text) != null;
  bool get _dateHasError => _touched['date'] == true && selectedDate == null;
  bool get _timeHasError => _touched['time'] == true && selectedTime == null;

  @override
  void initState() {
    super.initState();
    // Fall back to Phone Call if an unknown type is passed in.
    selectedType = _types.any((t) => t.label == widget.preselectType)
        ? widget.preselectType
        : 'Phone Call';
    _title.addListener(() => setState(() {}));
    _desc.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _desc.dispose();
    _title.dispose();
    super.dispose();
  }

  Future<void> pickDate() async {
    final now = DateTime.now();
    final res = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
      builder: (ctx, child) => erpPickerTheme(ctx, child, color: _accent),
    );
    setState(() {
      _touched['date'] = true;
      if (res != null) selectedDate = res;
    });
  }

  Future<void> pickTime() async {
    final res = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
      builder: (ctx, child) => erpPickerTheme(ctx, child, color: _accent),
    );
    setState(() {
      _touched['time'] = true;
      if (res != null) selectedTime = res;
    });
  }

  /// Quick date shortcuts: Today / Tomorrow / Next week.
  void _quickDate(int addDays) {
    final now = DateTime.now();
    setState(() {
      selectedDate = DateTime(now.year, now.month, now.day + addDays);
      _touched['date'] = true;
    });
  }

  Future<void> submit() async {
    setState(() {
      _touched['title'] = true;
      _touched['desc'] = true;
      _touched['date'] = true;
      _touched['time'] = true;
    });

    final formValid = formKey.currentState?.validate() ?? false;
    final dateTimeValid = selectedDate != null && selectedTime != null;
    if (!formValid || !dateTimeValid) return;

    FocusScope.of(context).unfocus();
    setState(() => submitting = true);

    final dt = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    final dateStr = DateFormat('yyyy-MM-dd').format(dt);
    final timeStr =
        '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}';

    final followupVm = Provider.of<FollowupViewmodel>(context, listen: false);

    final error = await followupVm.createFollowup(
      lead: widget.leadId,
      title: _title.text.trim(),
      date: dateStr,
      time: timeStr,
      status: 'new',
      type: selectedType.toLowerCase(),
      notes: _desc.text.trim(),
    );

    if (!mounted) return;
    setState(() => submitting = false);

    if (error == null) {
      erpToast(context,
          'Follow-up scheduled on ${DateFormat('dd MMM, hh:mm a').format(dt)}',
          icon: Icons.event_available_rounded);
      Navigator.of(context).pop(true);
    } else {
      erpToast(context, error,
          color: ErpColors.red, icon: Icons.error_outline_rounded);
    }
  }

  Widget _quickChip(String label, int days) {
    final now = DateTime.now();
    final target = DateTime(now.year, now.month, now.day + days);
    final active = selectedDate != null &&
        selectedDate!.year == target.year &&
        selectedDate!.month == target.month &&
        selectedDate!.day == target.day;

    return ErpPressable(
      onTap: () => _quickDate(days),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? _accent : _accent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: active ? _accent : _accent.withValues(alpha: 0.25)),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: active ? Colors.white : ErpColors.shade(_accent, 0.15))),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateText = selectedDate == null
        ? null
        : DateFormat('EEE, dd MMM yyyy').format(selectedDate!);
    final timeText = selectedTime?.format(context);

    final titleError =
        _touched['title'] == true ? _validateTitle(_title.text) : null;
    final descError =
        _touched['desc'] == true ? _validateDesc(_desc.text) : null;

    const fieldStyle = TextStyle(
        fontSize: 14.5, color: ErpColors.ink, fontWeight: FontWeight.w600);

    return ErpSheet(
      title: 'Schedule Follow-up',
      subtitle: 'Plan your next touchpoint',
      icon: Icons.event_repeat_rounded,
      color: _accent,
      children: [
        Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Type ───────────────────────────────────────────────
              const ErpFieldLabel('Follow-up Type', isRequired: true),
              ErpChoiceGrid(
                options: _types,
                selected: selectedType,
                onSelect: (v) => setState(() => selectedType = v),
              ),
              const SizedBox(height: 16),

              // ── Title ──────────────────────────────────────────────
              const ErpFieldLabel('Title', isRequired: true),
              TextFormField(
                controller: _title,
                cursorColor: _accent,
                textInputAction: TextInputAction.next,
                style: fieldStyle,
                autovalidateMode: _touched['title'] == true
                    ? AutovalidateMode.onUserInteraction
                    : AutovalidateMode.disabled,
                onChanged: (_) => _touch('title'),
                validator: _validateTitle,
                decoration: erpInputDecoration(
                  hint: 'e.g. Product demo follow-up',
                  icon: Icons.title_rounded,
                  hasError: _titleHasError,
                  color: _accent,
                ),
              ),
              if (titleError != null) ErpErrorText(titleError),
              const SizedBox(height: 14),

              // ── Description ────────────────────────────────────────
              Row(children: [
                const Expanded(
                    child: ErpFieldLabel('Description', isRequired: true)),
                Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: Text('${_desc.text.trim().length}/500',
                      style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: _desc.text.trim().length > 500
                              ? ErpColors.red
                              : ErpColors.slate)),
                ),
              ]),
              TextFormField(
                controller: _desc,
                cursorColor: _accent,
                minLines: 2,
                maxLines: 4,
                style: fieldStyle,
                autovalidateMode: _touched['desc'] == true
                    ? AutovalidateMode.onUserInteraction
                    : AutovalidateMode.disabled,
                onChanged: (_) => _touch('desc'),
                validator: _validateDesc,
                decoration: erpInputDecoration(
                  hint: 'What should be discussed?',
                  icon: Icons.notes_rounded,
                  hasError: _descHasError,
                  color: _accent,
                ),
              ),
              if (descError != null) ErpErrorText(descError),
              const SizedBox(height: 14),

              // ── Date & time ────────────────────────────────────────
              Row(children: [
                const Expanded(
                    child: ErpFieldLabel('When', isRequired: true)),
                Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: Wrap(spacing: 6, children: [
                    _quickChip('Today', 0),
                    _quickChip('Tomorrow', 1),
                    _quickChip('+1 week', 7),
                  ]),
                ),
              ]),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ErpPickerTile(
                        icon: Icons.calendar_month_rounded,
                        placeholder: 'Pick date',
                        value: dateText,
                        hasError: _dateHasError,
                        color: _accent,
                        onTap: pickDate,
                      ),
                      if (_dateHasError)
                        const ErpErrorText('Date is required'),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ErpPickerTile(
                        icon: Icons.schedule_rounded,
                        placeholder: 'Set time',
                        value: timeText,
                        hasError: _timeHasError,
                        color: ErpColors.violet,
                        onTap: pickTime,
                      ),
                      if (_timeHasError)
                        const ErpErrorText('Time is required'),
                    ],
                  ),
                ),
              ]),
              const SizedBox(height: 22),

              // ── Buttons ────────────────────────────────────────────
              ErpPrimaryButton(
                text: 'Schedule Follow-up',
                icon: Icons.event_available_rounded,
                loading: submitting,
                color: _accent,
                onTap: submit,
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