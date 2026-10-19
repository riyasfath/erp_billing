
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/setup/followup_viewmodel.dart';
import 'package:pokakbilling/viewmodels/lead_viewmodel.dart';
import 'package:pokakbilling/models/data-models/lead_model.dart';

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
  final followupTypes = ['Phone Call', 'Meeting', 'Email', 'Follow-up'];
  String selectedFollowupType = 'Phone Call';

  DateTime? selectedDate;
  String selectedTimeIso = '';
  String selectedTimeDisplay = '';

  final TextEditingController _title = TextEditingController();
  final TextEditingController _desc = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool submitting = false;

  bool _submitted = false;
  bool _dateError = false;
  bool _timeError = false;

  static const Color _border = AppColors.cborder;
  static const Color _bg = AppColors.cxl;

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
  void initState() {
    super.initState();
    selectedFollowupType = widget.preselectType;
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }

  Widget _requiredMark() => const Padding(
        padding: EdgeInsets.only(left: 4),
        child: Icon(Icons.circle, size: 6, color: AppColors.red),
      );

  Widget _errorRow(String msg) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, left: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 13, color: AppColors.red),
          const SizedBox(width: 4),
          Flexible(child: Text(msg, style: _errorStyle)),
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required String hint,
    required bool hasError,
    required bool isRequired,
    IconData? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: hasError ? AppColors.red : AppColors.ctext,
      ),
      prefixIcon: prefixIcon == null
          ? null
          : Icon(prefixIcon,
              size: 18, color: hasError ? AppColors.red : AppColors.c1),
      prefixIconConstraints: const BoxConstraints(minWidth: 42, minHeight: 32),
      suffixIcon: isRequired ? _requiredMark() : null,
      suffixIconConstraints: const BoxConstraints(minWidth: 24, minHeight: 24),
      filled: true,
      fillColor: hasError ? AppColors.red.withOpacity(0.04) : _bg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: hasError ? AppColors.red.withOpacity(0.60) : _border,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: hasError ? AppColors.red.withOpacity(0.60) : _border,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: hasError ? AppColors.red : AppColors.c1,
          width: 1.5,
        ),
      ),
      errorStyle: const TextStyle(fontSize: 0, height: 0),
      isDense: true,
    );
  }

  Widget _boxedField({
    required Widget child,
    bool hasError = false,
    bool isRequired = false,
  }) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: hasError ? AppColors.red.withOpacity(0.04) : _bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: hasError ? AppColors.red.withOpacity(0.60) : _border,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Expanded(child: child),
          if (isRequired) _requiredMark(),
        ],
      ),
    );
  }

  String _timeOfDayToIso(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';

  Future<void> pickDate() async {
    final now = DateTime.now();
    final res = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (res != null) {
      setState(() {
        selectedDate = res;
        _dateError = false;
      });
    }
  }

  Future<void> pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        selectedTimeIso = _timeOfDayToIso(picked);
        selectedTimeDisplay = picked.format(context);
        _timeError = false;
      });
    }
  }

  String _mapTypeToActivity(String type) {
    switch (type.toLowerCase()) {
      case 'phone call':
      case 'call':
        return 'CALL';
      case 'meeting':
        return 'MEETING';
      case 'email':
        return 'EMAIL';
      default:
        return 'FOLLOW_UP';
    }
  }

  Future<void> _submit() async {
    setState(() {
      _submitted = true;
      _dateError = selectedDate == null;
      _timeError = selectedTimeIso.isEmpty;
    });

    final formValid = formKey.currentState?.validate() ?? false;
    if (!formValid || _dateError || _timeError) return;

    setState(() => submitting = true);

    final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate!);

    final followupVm = Provider.of<FollowupViewmodel>(context, listen: false);

    final success = await followupVm.createFollowup(
      lead: widget.leadId,
      title: _title.text.trim(),
      date: dateStr,
      time: selectedTimeIso,
      status: 'PENDING',
      activityType: _mapTypeToActivity(selectedFollowupType),
      description: _desc.text.trim().isNotEmpty ? _desc.text.trim() : null,
    );

    if (!mounted) return;
    setState(() => submitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Follow-up "${_title.text.trim()}" scheduled')),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to schedule follow-up')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool dateNotPicked = selectedDate == null;
    final String dateText = dateNotPicked
        ? 'Select Date'
        : DateFormat('yyyy-MM-dd').format(selectedDate!);

    final bool timeNotPicked = selectedTimeDisplay.isEmpty;
    final String timeText = timeNotPicked ? 'Select Time' : selectedTimeDisplay;

    final bool titleHasError = _submitted && _title.text.trim().isEmpty;

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
        child: Consumer<LeadViewmodel>(
          builder: (context, leadVm, _) {
            LeadModel lead;
            try {
              lead = leadVm.leadList.firstWhere(
                (l) =>
                    l.id == widget.leadId ||
                    l.leadId == widget.leadId.toString(),
              );
            } catch (_) {
              lead = LeadModel(
                id: widget.leadId,
                leadId: widget.leadId.toString(),
                name: 'Lead #${widget.leadId}',
                company: '',
                email: '',
                phone: '',
                status: 'NEW',
                createdAt: '',
                updatedAt: '',
              );
            }

            return SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Schedule Follow-up',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.black,
                          ),
                        ),
                        const Spacer(),
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
                    DottedBorder(
                      dashPattern: const [6, 6],
                      strokeWidth: 1.2,
                      color: _border,
                      borderType: BorderType.RRect,
                      radius: const Radius.circular(8),
                      child: Container(
                        width: double.infinity,
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: _bg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: const Color(0xFFF2EAFB),
                              child: Text(
                                lead.name.isNotEmpty
                                    ? lead.name[0].toUpperCase()
                                    : 'L',
                                style: const TextStyle(
                                  color: AppColors.violetblue,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    lead.name.isNotEmpty
                                        ? lead.name
                                        : 'Lead #${widget.leadId}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    lead.email.isNotEmpty
                                        ? lead.email
                                        : lead.phone,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _boxedField(
                      isRequired: true,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: selectedFollowupType,
                          itemHeight: 48,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded,
                              color: AppColors.c1, size: 20),
                          style: _textStyle,
                          dropdownColor: AppColors.white,
                          items: followupTypes
                              .map(
                                (e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e, style: _textStyle),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            if (v != null) {
                              setState(() => selectedFollowupType = v);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _title,
                      maxLines: 1,
                      textAlignVertical: TextAlignVertical.center,
                      style:
                          const TextStyle(fontSize: 14, color: AppColors.cdark),
                      autovalidateMode: _submitted
                          ? AutovalidateMode.onUserInteraction
                          : AutovalidateMode.disabled,
                      validator: (v) =>
                          (v ?? '').trim().isEmpty ? 'Title is required' : null,
                      onChanged: (_) {
                        if (_submitted) setState(() {});
                      },
                      decoration: _fieldDecoration(
                        hint: 'Title',
                        hasError: titleHasError,
                        isRequired: true,
                        prefixIcon: Icons.badge_outlined,
                      ),
                    ),
                    if (titleHasError) _errorRow('Title is required'),
                    const SizedBox(height: 10),
                    _boxedField(
                      child: TextFormField(
                        controller: _desc,
                        maxLines: 1,
                        textAlignVertical: TextAlignVertical.center,
                        style: const TextStyle(
                            fontSize: 14, color: AppColors.cdark),
                        decoration: const InputDecoration(
                          hintText: 'Add additional details (optional)',
                          hintStyle: _hintStyle,
                          border: InputBorder.none,
                          isCollapsed: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: pickDate,
                      child: _boxedField(
                        hasError: _dateError,
                        isRequired: true,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                dateText,
                                style: _textStyle.copyWith(
                                  fontSize: 13,
                                  color: _dateError
                                      ? AppColors.red
                                      : dateNotPicked
                                          ? AppColors.ctext
                                          : AppColors.cdark,
                                  fontWeight: dateNotPicked
                                      ? FontWeight.w400
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.calendar_today,
                              color: _dateError ? AppColors.red : AppColors.c1,
                              size: 13,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_dateError) _errorRow('Please select a date'),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: pickTime,
                      child: _boxedField(
                        hasError: _timeError,
                        isRequired: true,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                timeText,
                                style: _textStyle.copyWith(
                                  fontSize: 13,
                                  color: _timeError
                                      ? AppColors.red
                                      : timeNotPicked
                                          ? AppColors.ctext
                                          : AppColors.cdark,
                                  fontWeight: timeNotPicked
                                      ? FontWeight.w400
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.schedule,
                              color: _timeError ? AppColors.red : AppColors.c1,
                              size: 13,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_timeError) _errorRow('Please set a time'),
                    const SizedBox(height: 16),
                    _clientStyleButton(
                      text: 'Schedule Follow-up',
                      icon: Icons.check_rounded,
                      loading: submitting,
                      onPressed: submitting ? null : _submit,
                      backgroundColor: AppColors.c1,
                    ),
                    const SizedBox(height: 8),
                    _clientStyleButton(
                      text: 'Cancel',
                      onPressed:
                          submitting ? null : () => Navigator.of(context).pop(),
                      backgroundColor: AppColors.white,
                      textColor: AppColors.c1,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _clientStyleButton({
    required String text,
    required VoidCallback? onPressed,
    bool loading = false,
    IconData? icon,
    Color backgroundColor = AppColors.c1,
    Color borderColor = AppColors.cborder,
    Color textColor = AppColors.white,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withOpacity(0.30),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: loading
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
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: textColor, size: 18),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      text,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
