import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/meeting_viewmodel.dart';

class MeetingSheet extends StatefulWidget {
  final String leadName;
  final int leadId;

  const MeetingSheet({
    super.key,
    required this.leadName,
    required this.leadId,
  });

  @override
  State<MeetingSheet> createState() => _MeetingSheetState();
}

class _MeetingSheetState extends State<MeetingSheet> {
  final meetingTypes = ['Video Call', 'Phone Call', 'In Person'];
  String selectedMeetingType = 'Video Call';

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  final TextEditingController _title = TextEditingController();
  final TextEditingController _desc = TextEditingController();
  final TextEditingController _location = TextEditingController();

  final formKey = GlobalKey<FormState>();
  bool submitting = false;
  bool _submitted = false;

  // Shared styles
  static const TextStyle _textStyle = TextStyle(
    fontSize: 14,
    color: AppColors.cdark,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle _hintStyle = TextStyle(
    fontSize: 13,
    color: AppColors.ctext,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle _errorStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.red,
    height: 1.4,
  );

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _location.dispose();
    super.dispose();
  }

  Future<void> pickDate() async {
    final now = DateTime.now();
    final res = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (res != null) setState(() => selectedDate = res);
  }

  Future<void> pickTime() async {
    final res = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (res != null) setState(() => selectedTime = res);
  }

  Future<void> submit() async {
    setState(() => _submitted = true);

    final formValid = formKey.currentState?.validate() ?? false;
    final dateValid = selectedDate != null;
    final timeValid = selectedTime != null;

    if (!formValid || !dateValid || !timeValid) return;

    setState(() => submitting = true);

    final dt = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    final meetingProv = Provider.of<MeetingViewmodel>(context, listen: false);
    meetingProv.updateDate(dt);
    meetingProv.selectedTime =
        "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}";

    final titleText = _title.text.trim();
    final locationText =
        _location.text.trim().isNotEmpty ? _location.text.trim() : null;
    final descText = _desc.text.trim().isNotEmpty ? _desc.text.trim() : null;

    try {
      final success = await meetingProv.createMeeting(
        leadId: widget.leadId,
        title: titleText,
        subtype: selectedMeetingType.toLowerCase().replaceAll(' ', '_'),
        location: locationText,
        description: descText,
      );

      if (!mounted) return;

      if (success) {
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create meeting')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => submitting = false);
    }
  }

  Widget _errorRow(String msg) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, left: 4),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 13, color: AppColors.red),
          const SizedBox(width: 4),
          Flexible(child: Text(msg, style: _errorStyle)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final titleHasError = _submitted && _title.text.trim().isEmpty;
    final dateError = _submitted && selectedDate == null;
    final timeError = _submitted && selectedTime == null;

    final dateText = selectedDate == null
        ? 'Select Date'
        : DateFormat('yyyy-MM-dd').format(selectedDate!);
    final timeText =
        selectedTime == null ? 'Select Time' : selectedTime!.format(context);

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Schedule Meeting with ${widget.leadName}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 13,
                        height: 13,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black),
                        ),
                        child: const Icon(Icons.close, size: 11),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ── Title field ───────────────────────────────────────────
                TextFormField(
                  controller: _title,
                  maxLines: 1,
                  textAlignVertical: TextAlignVertical.center,
                  style: const TextStyle(fontSize: 14, color: AppColors.cdark),
                  autovalidateMode: _submitted
                      ? AutovalidateMode.onUserInteraction
                      : AutovalidateMode.disabled,
                  onChanged: (_) {
                    // Rebuild so hint/border update as the user types
                    if (_submitted) setState(() {});
                  },
                  validator: (v) =>
                      (v ?? '').trim().isEmpty ? 'Title is required' : null,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    // ✅ Hint colour matches the time/date picker error colour
                    hintText: 'Enter Meeting Title',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: titleHasError
                          ? AppColors.red
                          : AppColors.ctext.withOpacity(0.55),
                    ),
                    labelStyle: TextStyle(
                      fontSize: 13,
                      color: titleHasError
                          ? AppColors.red
                          : AppColors.ctext.withOpacity(0.75),
                    ),
                    prefixIcon: Icon(
                      Icons.badge_outlined,
                      size: 18,
                      color: titleHasError ? AppColors.red : AppColors.c1,
                    ),
                    filled: true,
                    fillColor: titleHasError
                        ? AppColors.red.withOpacity(0.00)
                        : AppColors.cxl,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: titleHasError
                            ? AppColors.red.withOpacity(0.00)
                            : AppColors.cborder,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: titleHasError
                            ? AppColors.red.withOpacity(0.00)
                            : AppColors.cborder,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: titleHasError ? AppColors.red : AppColors.c1,
                        width: 1.5,
                      ),
                    ),
                    errorStyle: const TextStyle(fontSize: 0, height: 0),
                    isDense: true,
                  ),
                ),
                if (titleHasError) _errorRow('Title is required'),

                const SizedBox(height: 10),

                // Description field
                TextFormField(
                  controller: _desc,
                  maxLines: 1,
                  decoration: InputDecoration(
                    hintText: 'Description (optional)',
                    hintStyle: _hintStyle,
                    border: InputBorder.none,
                    filled: true,
                    fillColor: AppColors.cxl,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                  ),
                ),

                const SizedBox(height: 10),

                // Meeting Type
                DropdownButtonFormField<String>(
                  value: selectedMeetingType,
                  items: meetingTypes
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e, style: _textStyle),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => selectedMeetingType = v);
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.cxl,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.cborder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.cborder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.c1),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Date picker
                InkWell(
                  onTap: pickDate,
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: dateError
                          ? AppColors.red.withOpacity(0.04)
                          : AppColors.cxl,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: dateError
                            ? AppColors.red.withOpacity(0.60)
                            : AppColors.cborder,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            dateText,
                            style: _textStyle.copyWith(
                              color:
                                  dateError ? AppColors.red : AppColors.cdark,
                            ),
                          ),
                        ),
                        Icon(Icons.calendar_today,
                            color: dateError ? AppColors.red : AppColors.c1,
                            size: 13),
                      ],
                    ),
                  ),
                ),
                if (dateError) _errorRow('Please select a date'),

                const SizedBox(height: 10),

                // Time picker
                InkWell(
                  onTap: pickTime,
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: timeError
                          ? AppColors.red.withOpacity(0.04)
                          : AppColors.cxl,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: timeError
                            ? AppColors.red.withOpacity(0.60)
                            : AppColors.cborder,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            timeText,
                            style: _textStyle.copyWith(
                              color: timeError
                                  ? AppColors.red
                                  : selectedTime == null
                                      ? AppColors.ctext
                                      : AppColors.cdark,
                            ),
                          ),
                        ),
                        Icon(Icons.schedule,
                            color: timeError ? AppColors.red : AppColors.c1,
                            size: 13),
                      ],
                    ),
                  ),
                ),
                if (timeError) _errorRow('Please set a time'),

                const SizedBox(height: 10),

                // Location field (only for video/in-person)
                if (selectedMeetingType == 'Video Call' ||
                    selectedMeetingType == 'In Person') ...[
                  TextFormField(
                    controller: _location,
                    maxLines: 1,
                    textAlignVertical: TextAlignVertical.center,
                    style:
                        const TextStyle(fontSize: 14, color: AppColors.cdark),
                    decoration: InputDecoration(
                      hintText: 'Address or Video call link (optional)',
                      hintStyle: _hintStyle,
                      border: InputBorder.none,
                      filled: true,
                      fillColor: AppColors.cxl,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                const SizedBox(height: 16),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: submitting ? null : submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.c1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: submitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: AppColors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.check_rounded,
                                  color: AppColors.white, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Schedule Meeting',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 8),

                // Cancel button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed:
                        submitting ? null : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.c1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: AppColors.c1,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
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
}
