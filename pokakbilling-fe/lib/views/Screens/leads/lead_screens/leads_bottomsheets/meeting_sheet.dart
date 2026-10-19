import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pokakbilling/ERP_UI_KIT.dart';
import 'package:pokakbilling/viewmodels/meeting_viewmodel.dart';
import 'package:provider/provider.dart';

class MeetingSheet extends StatefulWidget {
  final String leadName;
  final int leadId;

  const MeetingSheet({super.key, required this.leadName, required this.leadId});

  @override
  State<MeetingSheet> createState() => _MeetingSheetState();
}

class _MeetingSheetState extends State<MeetingSheet> {
  static const Color _accent = ErpColors.blue;

  static const List<ErpChoice> _meetingTypes = [
    ErpChoice('Video Call', Icons.videocam_rounded, ErpColors.blue),
    ErpChoice('Phone Call', Icons.call_rounded, ErpColors.cyan),
    ErpChoice('In-person', Icons.handshake_rounded, ErpColors.amber),
  ];

  String selectedMeetingType = 'Video Call';
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  final TextEditingController _title = TextEditingController();
  final TextEditingController _desc = TextEditingController();
  final TextEditingController _location = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final FocusNode _titleFocus = FocusNode();
  bool submitting = false;

  // ── Per-field touch tracking ──────────────────────────────────────────────
  final Map<String, bool> _touched = {};

  void _touch(String field) {
    if (_touched[field] != true) setState(() => _touched[field] = true);
  }

  // ── Validators ────────────────────────────────────────────────────────────
  String? _validateTitle(String? v) {
    if (v == null || v.trim().isEmpty) return 'Meeting title is required';
    return null;
  }

  bool get _titleHasError =>
      _touched['title'] == true && _validateTitle(_title.text) != null;
  bool get _dateHasError => _touched['date'] == true && selectedDate == null;
  bool get _timeHasError => _touched['time'] == true && selectedTime == null;

  @override
  void initState() {
    super.initState();
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
    _desc.dispose();
    _location.dispose();
    _titleFocus.dispose();
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

  Future<void> submit() async {
    setState(() {
      _touched['title'] = true;
      _touched['date'] = true;
      _touched['time'] = true;
    });

    if (!(formKey.currentState?.validate() ?? false)) return;
    if (selectedDate == null || selectedTime == null) return;

    FocusScope.of(context).unfocus();
    setState(() => submitting = true);

    final dt = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    final dateIso = DateFormat('yyyy-MM-dd').format(dt);
    final hh = selectedTime!.hour.toString().padLeft(2, '0');
    final mm = selectedTime!.minute.toString().padLeft(2, '0');
    final timeToSend = '$hh:$mm:00';

    try {
      final meetingProv = Provider.of<MeetingViewmodel>(context, listen: false);
      final statusKey = meetingProv.selectedStatusKey.isNotEmpty
          ? meetingProv.selectedStatusKey
          : 'scheduled';

      await meetingProv.createMeetingSchedule(
        widget.leadId,
        dateIso,
        timeToSend,
        statusKey,
        _title.text.trim(),
        context,
        meetingPlace: _location.text.isNotEmpty ? _location.text.trim() : null,
        description: _desc.text.isNotEmpty ? _desc.text.trim() : null,
      );

      if (!mounted) return;
      erpToast(context,
          'Meeting scheduled on ${DateFormat('dd MMM, hh:mm a').format(dt)}',
          icon: Icons.event_available_rounded);
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        erpToast(context, e.toString(),
            color: ErpColors.red, icon: Icons.error_outline_rounded);
      }
    } finally {
      if (mounted) setState(() => submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateText = selectedDate == null
        ? null
        : DateFormat('EEE, dd MMM yyyy').format(selectedDate!);
    final timeText = selectedTime?.format(context);

    final isVideo = selectedMeetingType == 'Video Call';
    final showLocationField =
        isVideo || selectedMeetingType == 'In-person';

    return ErpSheet(
      title: 'Schedule Meeting',
      subtitle: widget.leadName.isNotEmpty ? 'with ${widget.leadName}' : null,
      icon: Icons.video_camera_front_rounded,
      color: _accent,
      children: [
        Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Meeting type ───────────────────────────────────────
              const ErpFieldLabel('Meeting Type', isRequired: true),
              ErpChoiceGrid(
                options: _meetingTypes,
                selected: selectedMeetingType,
                onSelect: (v) => setState(() => selectedMeetingType = v),
              ),
              const SizedBox(height: 16),

              // ── Title ──────────────────────────────────────────────
              const ErpFieldLabel('Meeting Title', isRequired: true),
              TextFormField(
                controller: _title,
                focusNode: _titleFocus,
                cursorColor: _accent,
                textInputAction: TextInputAction.next,
                style: const TextStyle(
                    fontSize: 14.5,
                    color: ErpColors.ink,
                    fontWeight: FontWeight.w600),
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
                  hint: 'e.g. Product Demo Call',
                  icon: Icons.title_rounded,
                  hasError: _titleHasError,
                  color: _accent,
                ),
              ),
              if (_titleHasError)
                const ErpErrorText('Meeting title is required'),
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
                        hasError: _dateHasError,
                        color: _accent,
                        onTap: pickDate,
                      ),
                      if (_dateHasError) const ErpErrorText('Select a date'),
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
                      if (_timeHasError) const ErpErrorText('Set a time'),
                    ],
                  ),
                ),
              ]),
              const SizedBox(height: 14),

              // ── Location / link (conditional) ──────────────────────
              AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                child: showLocationField
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ErpFieldLabel(
                                isVideo ? 'Video Call Link' : 'Meeting Address',
                                isOptional: true),
                            TextFormField(
                              controller: _location,
                              cursorColor: _accent,
                              keyboardType: isVideo
                                  ? TextInputType.url
                                  : TextInputType.streetAddress,
                              textInputAction: TextInputAction.next,
                              style: const TextStyle(
                                  fontSize: 14.5,
                                  color: ErpColors.ink,
                                  fontWeight: FontWeight.w600),
                              decoration: erpInputDecoration(
                                hint: isVideo
                                    ? 'https://meet.google.com/...'
                                    : 'e.g. Office, Cafe name',
                                icon: isVideo
                                    ? Icons.link_rounded
                                    : Icons.place_rounded,
                                color: _accent,
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox(width: double.infinity),
              ),

              // ── Description ────────────────────────────────────────
              const ErpFieldLabel('Description', isOptional: true),
              TextFormField(
                controller: _desc,
                cursorColor: _accent,
                minLines: 2,
                maxLines: 3,
                textInputAction: TextInputAction.done,
                style: const TextStyle(
                    fontSize: 14.5,
                    color: ErpColors.ink,
                    fontWeight: FontWeight.w600),
                decoration: erpInputDecoration(
                  hint: 'Brief agenda or notes',
                  icon: Icons.notes_rounded,
                  color: _accent,
                ),
              ),
              const SizedBox(height: 22),

              // ── Buttons ────────────────────────────────────────────
              ErpPrimaryButton(
                text: 'Schedule Meeting',
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