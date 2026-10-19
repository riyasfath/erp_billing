import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/models/data-models/lead_model.dart';
import 'package:pokakbilling/viewmodels/lead_viewmodel.dart';
import 'package:pokakbilling/viewmodels/reminder/reminder_viewmodel.dart';

class ReminderSheet extends StatefulWidget {
  final int? leadId;
  final String? leadName;

  const ReminderSheet({super.key, this.leadId, this.leadName});

  @override
  State<ReminderSheet> createState() => _ReminderSheetState();
}

class _ReminderSheetState extends State<ReminderSheet>
    with SingleTickerProviderStateMixin {
  final reminderTypes = ['Email', 'Call', 'WhatsApp', 'Message', 'Follow-up'];
  String selectedReminderType = 'Email';

  DateTime? selectedDate; // ← null means not selected (shows hint)
  String selectedTimeIso = '';
  String selectedTimeDisplay = '';

  final TextEditingController _title = TextEditingController();
  final TextEditingController _details = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool submitting = false;
  bool _submitted = false;
  bool _leadError = false;
  bool _timeError = false;
  bool _dateError = false; // ← new

  LeadModel? _selectedLead;

  static const Color _border = AppColors.cborder;
  static const Color _bg = AppColors.cxl;

  // ─── unified hint style (same size, same colour everywhere) ───────────────
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
    if (widget.leadId != null && widget.leadId != 0) {
      _selectedLead = LeadModel(
        id: widget.leadId!,
        leadId: widget.leadId!.toString(),
        name: widget.leadName ?? '',
        company: '',
        email: '',
        phone: '',
        status: 'NEW',
        createdAt: '',
        updatedAt: '',
      );
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _details.dispose();
    super.dispose();
  }

  // ─── helpers ──────────────────────────────────────────────────────────────

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
      // No labelText — hint stays visible and turns red on error
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

  /// Generic boxed tappable field (date / time / dropdown).
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
        _dateError = false; // ← clear error on pick
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

  Future<void> _openSelectLeadSheet() async {
    final leadVm = Provider.of<LeadViewmodel>(context, listen: false);
    if (leadVm.leadList.isEmpty) {
      try {
        await leadVm.getAllLeads();
      } catch (_) {}
    }

    final lead = await showModalBottomSheet<LeadModel>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        final leads = leadVm.leadList;
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      const Text('Select Lead',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: leads.isEmpty
                      ? const Center(child: Text('No leads available'))
                      : ListView.separated(
                          controller: controller,
                          itemCount: leads.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final l = leads[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFF6A1B9A),
                                child: Text(
                                  l.name.isNotEmpty
                                      ? l.name[0].toUpperCase()
                                      : 'L',
                                  style:
                                      const TextStyle(color: AppColors.white),
                                ),
                              ),
                              title: Text(l.name),
                              subtitle:
                                  Text(l.email.isNotEmpty ? l.email : l.phone),
                              onTap: () => Navigator.of(ctx).pop(l),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );

    if (lead != null) {
      setState(() {
        _selectedLead = lead;
        _leadError = false;
      });
    }
  }

  Future<void> _submitReminder() async {
    setState(() {
      _submitted = true;
      _leadError = _selectedLead == null;
      _timeError = selectedTimeIso.isEmpty;
      _dateError = selectedDate == null; // ← validate date
    });

    final valid = formKey.currentState?.validate() ?? false;
    if (!valid || _leadError || _timeError || _dateError) {
      setState(() {});
      return;
    }

    final vm = Provider.of<ReminderViewmodel>(context, listen: false);
    setState(() => submitting = true);

    try {
      final dateStr =
          DateFormat('yyyy-MM-dd').format(selectedDate!); // non-null here
      final success = await vm.createReminder(
        lead: _selectedLead!.id.toString(),
        title: _title.text.trim(),
        subtype: selectedReminderType,
        date: dateStr,
        time: selectedTimeIso,
        description:
            _details.text.trim().isNotEmpty ? _details.text.trim() : null,
      );

      if (!mounted) return;

      if (success) {
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create reminder')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to set reminder: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => submitting = false);
    }
  }

  // ─── build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // ← date shows hint when not yet picked, turns red on error
    final bool dateNotPicked = selectedDate == null;
    final String dateText = dateNotPicked
        ? 'Select Date'
        : DateFormat('yyyy-MM-dd').format(selectedDate!);

    // ← time shows hint when not yet picked, turns red on error
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
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── header ──────────────────────────────────────────────────
                Row(
                  children: [
                    const Text(
                      'Set Reminder',
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

                // ── lead picker ─────────────────────────────────────────────
                GestureDetector(
                  onTap: _openSelectLeadSheet,
                  child: DottedBorder(
                    dashPattern: const [6, 6],
                    strokeWidth: 1.2,
                    color:
                        _leadError ? AppColors.red.withOpacity(0.60) : _border,
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(8),
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color:
                            _leadError ? AppColors.red.withOpacity(0.04) : _bg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _selectedLead == null
                          ? Row(
                              children: [
                                Icon(
                                  Icons.person_add_alt_1_rounded,
                                  size: 16,
                                  color: _leadError
                                      ? AppColors.red
                                      : Colors.black54,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Choose a lead',
                                    style: _hintStyle.copyWith(
                                      fontSize: 13,
                                      color: _leadError
                                          ? AppColors.red
                                          : AppColors.ctext,
                                    ),
                                  ),
                                ),
                                _requiredMark(),
                              ],
                            )
                          : Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: const Color(0xFFF2EAFB),
                                  child: Text(
                                    _selectedLead!.name.isNotEmpty
                                        ? _selectedLead!.name[0].toUpperCase()
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _selectedLead!.name,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _selectedLead!.email.isNotEmpty
                                            ? _selectedLead!.email
                                            : _selectedLead!.phone,
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
                ),
                if (_leadError) _errorRow('Please select a lead'),
                const SizedBox(height: 10),

                // ── title ───────────────────────────────────────────────────
                TextFormField(
                  controller: _title,
                  maxLines: 1,
                  textAlignVertical: TextAlignVertical.center,
                  style: const TextStyle(fontSize: 14, color: AppColors.cdark),
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

                // ── details (optional) ───────────────────────────────────────
                _boxedField(
                  child: TextFormField(
                    controller: _details,
                    maxLines: 1,
                    textAlignVertical: TextAlignVertical.center,
                    style:
                        const TextStyle(fontSize: 14, color: AppColors.cdark),
                    decoration: const InputDecoration(
                      hintText: 'Add additional details (optional)',
                      hintStyle: _hintStyle, // ← same hint style
                      border: InputBorder.none,
                      isCollapsed: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // ── reminder type dropdown ──────────────────────────────────
                _boxedField(
                  isRequired: true,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedReminderType,
                      itemHeight: 48,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded,
                          color: AppColors.c1, size: 20),
                      style: _textStyle,
                      dropdownColor: AppColors.white,
                      items: reminderTypes
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(e, style: _textStyle),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setState(() => selectedReminderType = v);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // ── date picker ─────────────────────────────────────────────
                // Same validation pattern as time: hint → error state → value
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
                              fontSize: 13, // ← same 13 as other hints
                              color: _dateError
                                  ? AppColors.red
                                  : dateNotPicked
                                      ? AppColors.ctext // hint colour
                                      : AppColors.cdark, // value colour
                              fontWeight: dateNotPicked
                                  ? FontWeight.w400 // hint weight
                                  : FontWeight.w500, // value weight
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

                // ── time picker ─────────────────────────────────────────────
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
                              fontSize: 13, // ← same 13 as date hint
                              color: _timeError
                                  ? AppColors.red
                                  : timeNotPicked
                                      ? AppColors.ctext // hint colour
                                      : AppColors.cdark, // value colour
                              fontWeight: timeNotPicked
                                  ? FontWeight.w400 // hint weight
                                  : FontWeight.w500, // value weight
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

                // ── submit ──────────────────────────────────────────────────
                _clientStyleButton(
                  text: 'Set Reminder',
                  icon: Icons.check_rounded,
                  loading: submitting,
                  onPressed: submitting ? null : _submitReminder,
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
        ),
      ),
    );
  }

  // ─── reusable button ──────────────────────────────────────────────────────

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
