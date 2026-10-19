import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pokakbilling/viewmodels/call_activity/add_callLog_viewmodel.dart';
import 'package:pokakbilling/viewmodels/lead_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/models/call_activity/call_log_model.dart';

import 'package:pokakbilling/models/data-models/lead_model.dart';

class AddCallLogScreen extends StatefulWidget {
  final int? initialLeadId;
  final String? initialCustomerNumber;

  const AddCallLogScreen({
    super.key,
    this.initialLeadId,
    this.initialCustomerNumber,
  });

  @override
  State<AddCallLogScreen> createState() => _AddCallLogScreenState();
}

class _StatusOption {
  final String value;
  final String label;
  const _StatusOption(this.value, this.label);
}

class _AddCallLogScreenState extends State<AddCallLogScreen> {
  final TextEditingController _phoneDisplayCtrl = TextEditingController();
  final TextEditingController _durationCtrl = TextEditingController();
  final TextEditingController _notesCtrl = TextEditingController();

  static const List<_StatusOption> _callStatusOptions = [
    _StatusOption('answered', 'Answered'),
    _StatusOption('no_answer', 'No Answer'),
    _StatusOption('busy', 'Busy'),
    _StatusOption('voicemail', 'Voicemail'),
  ];

  String? _callType;
  String? _status;

  String _leadStatus = CallLogOptions.leadStatuses[1]; // CONTACTED
  String _leadSource = CallLogOptions.leadSources.first; // WEBSITE
  DateTime? _followUpDate;

  LeadModel? _selectedLead;

  String? _errLead;
  String? _errCallType;
  String? _errCallStatus;
  String? _errDuration;

  @override
  void initState() {
    super.initState();

    if (widget.initialLeadId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final vm = context.read<LeadViewmodel>();
        LeadModel? match;
        for (final lead in vm.leadList) {
          if (lead.id == widget.initialLeadId) {
            match = lead;
            break;
          }
        }
        if (match != null) {
          setState(() {
            _selectedLead = match;
            _phoneDisplayCtrl.text = match!.phone;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _phoneDisplayCtrl.dispose();
    _durationCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  String? _validateDuration(String v) {
    final t = v.trim();
    if (t.isEmpty) return 'Call duration is required';
    final n = int.tryParse(t);
    if (n == null) return 'Enter a valid number';
    if (n <= 0) return 'Duration must be greater than 0';
    return null;
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
          colorScheme: Theme.of(ctx).colorScheme.copyWith(
                primary: AppColors.c1,
              ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _followUpDate = picked);
    }
  }

  String _toDisplayLabel(String raw) {
    return raw
        .split(RegExp(r'[_\s]+'))
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');
  }

  String _formatDate(DateTime d) {
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '${d.year}-$mm-$dd';
  }

  Future<void> _openLeadPicker() async {
    final vm = context.read<LeadViewmodel>();

    if (vm.leadList.isEmpty && !vm.getLeadLoader) {
      await vm.getAllLeads();
    }

    if (!mounted) return;

    final LeadModel? picked = await showModalBottomSheet<LeadModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _LeadPickerSheet(),
    );

    if (picked != null) {
      setState(() {
        _selectedLead = picked;
        _phoneDisplayCtrl.text = picked.phone;
        if (_errLead != null) _errLead = null;
      });
    }
  }

  Future<void> _submit() async {
    final leadErr = _selectedLead == null ? 'Please select a lead' : null;
    final callTypeErr = (_callType == null || _callType!.isEmpty)
        ? 'Call type is required'
        : null;
    final callStatusErr = (_status == null || _status!.isEmpty)
        ? 'Call status is required'
        : null;
    final durationErr = _validateDuration(_durationCtrl.text);

    setState(() {
      _errLead = leadErr;
      _errCallType = callTypeErr;
      _errCallStatus = callStatusErr;
      _errDuration = durationErr;
    });

    if (leadErr != null ||
        callTypeErr != null ||
        callStatusErr != null ||
        durationErr != null) {
      return;
    }

    final payload = AddCallLogRequestModel(
      leadId: _selectedLead!.id,
      customerNumber: _selectedLead!.phone.trim(),
      callType: _callType!,
      status: _status!,
      leadStatus: _leadStatus,
      leadSource: _leadSource,
      durationSeconds: int.tryParse(_durationCtrl.text.trim()),
      nextFollowupDate:
          _followUpDate != null ? _formatDate(_followUpDate!) : null,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );

    final vm = context.read<AddCallLogViewmodel>();
    final ok = await vm.submit(payload);

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.lastCallLogId != null
              ? 'Call log added successfully (#${vm.lastCallLogId})'
              : 'Call log added successfully'),
          backgroundColor: AppColors.tagGreen,
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.errorMessage ?? 'Failed to add call log'),
          backgroundColor: AppColors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: AppColors.cxl,
      body: SafeArea(
        top: false,
        bottom: true,
        child: Column(
          children: [
            _buildHeader(context, mq.padding.top),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection(
                      icon: Icons.person_search_rounded,
                      title: 'Lead & Contact',
                      children: [
                        _leadPickerField(),
                        _field(
                          _phoneDisplayCtrl,
                          'Phone Number',
                          Icons.phone_outlined,
                          readOnly: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildSection(
                      icon: Icons.call_rounded,
                      title: 'Call Details',
                      children: [
                        _buildCallTypeDropdown(),
                        _buildCallStatusDropdown(),
                        _field(
                          _durationCtrl,
                          'Call Duration (seconds)',
                          Icons.timer_outlined,
                          isRequired: true,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          error: _errDuration,
                          onChanged: (_) {
                            if (_errDuration != null) {
                              setState(() => _errDuration = null);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildSection(
                      icon: Icons.update_rounded,
                      title: 'Lead Update',
                      children: [
                        _buildOptionDropdown(
                          label: 'Lead Status',
                          icon: Icons.stairs_rounded,
                          value: _leadStatus,
                          options: CallLogOptions.leadStatuses,
                          onChanged: (v) => setState(() => _leadStatus = v),
                        ),
                        _buildOptionDropdown(
                          label: 'Lead Source',
                          icon: Icons.share_rounded,
                          value: _leadSource,
                          options: CallLogOptions.leadSources,
                          onChanged: (v) => setState(() => _leadSource = v),
                        ),
                        _dateField(),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildSection(
                      icon: Icons.notes_rounded,
                      title: 'Notes',
                      children: [
                        _field(
                          _notesCtrl,
                          'Notes',
                          Icons.edit_note_rounded,
                          maxLines: 4,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _submitButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, double topPad) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, topPad + 14, 20, 16),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.cborder, width: 1.5),
        ),
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
          const Expanded(
            child: Text(
              'Add Call Log',
              style: TextStyle(
                color: AppColors.cdark,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Section card (icon header + divider). ───────────────────────────
  Widget _buildSection({
    required IconData icon,
    required String title,
    required List<Widget> children,
    Widget? trailing,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cborder),
        boxShadow: [
          BoxShadow(
            color: AppColors.c1.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.cxl,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.cborder),
                ),
                child: Icon(icon, color: AppColors.c1, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.cdark,
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const Divider(height: 20, thickness: 1, color: AppColors.cborder),
          ...children,
        ],
      ),
    );
  }

  TextStyle _hintTextStyle(bool hasError) {
    return TextStyle(
      fontSize: 13,
      color: hasError ? AppColors.red : AppColors.ctext.withOpacity(0.55),
    );
  }

  InputDecoration _fieldDecoration(
    String label,
    IconData icon, {
    bool isRequired = false,
    bool hasError = false,
    bool isDropdown = false,
    Widget? trailingOverride,
  }) {
    Widget? suffix;
    if (trailingOverride != null) {
      suffix = trailingOverride;
    } else if (isDropdown) {
      suffix = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.keyboard_arrow_down_rounded,
            color: hasError ? AppColors.red : AppColors.c1,
            size: 20,
          ),
          if (isRequired) ...[
            const SizedBox(width: 2),
            const Icon(Icons.circle, size: 6, color: AppColors.red),
          ],
          const SizedBox(width: 8),
        ],
      );
    } else if (isRequired) {
      suffix = const Padding(
        padding: EdgeInsets.only(right: 8),
        child: Icon(Icons.circle, size: 6, color: AppColors.red),
      );
    }

    return InputDecoration(
      labelText: label,
      hintText: label,
      labelStyle: TextStyle(
        fontSize: 13,
        color: hasError ? AppColors.red : AppColors.ctext.withOpacity(0.75),
      ),
      hintStyle: _hintTextStyle(hasError),
      prefixIcon: Icon(
        icon,
        size: 18,
        color: hasError ? AppColors.red : AppColors.c1,
      ),
      suffixIcon: suffix,
      suffixIconConstraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      filled: true,
      fillColor: hasError ? AppColors.red.withOpacity(0.04) : AppColors.cxl,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: hasError ? AppColors.red.withOpacity(0.60) : AppColors.cborder,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: hasError ? AppColors.red.withOpacity(0.60) : AppColors.cborder,
        ),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.cborder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: hasError ? AppColors.red : AppColors.c1,
          width: 1.5,
        ),
      ),
    );
  }

  // ── Text field — every text field on this screen goes through this one
  // builder, so width/height/hint/error styling are always identical.
  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isRequired = false,
    bool readOnly = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? error,
    int maxLines = 1,
    void Function(String)? onChanged,
  }) {
    final hasError = error != null && error.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            cursorColor: AppColors.c1,
            inputFormatters: inputFormatters,
            onChanged: onChanged,
            readOnly: readOnly,
            maxLines: maxLines,
            // No auto-capitalization anywhere on this screen.
            textCapitalization: TextCapitalization.none,
            style: const TextStyle(fontSize: 14, color: AppColors.cdark),
            decoration: _fieldDecoration(
              label,
              icon,
              isRequired: isRequired,
              hasError: hasError,
            ),
          ),
          if (hasError)
            Padding(
              padding: const EdgeInsets.only(top: 5, left: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded,
                      size: 13, color: AppColors.red),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      error,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.red,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ── Dropdown + error-below wrapper ──────────────────────────────────
  Widget _dropdownWithError({required Widget dropdown, String? error}) {
    final hasError = error != null && error.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          dropdown,
          if (hasError)
            Padding(
              padding: const EdgeInsets.only(top: 5, left: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded,
                      size: 13, color: AppColors.red),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      error,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.red,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Tappable field that opens the lead picker. Title reads "Select Lead".
  /// Shows a placeholder until a lead is chosen, then shows the lead's
  /// name / company / lead-id badge. The phone number is a SEPARATE
  /// auto-filled field right below (see `_field(_phoneDisplayCtrl, ...)`
  /// in `build()`), matching the "select lead, then phone auto-shows" flow.
  Widget _leadPickerField() {
    final hasError = _errLead != null && _errLead!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: _openLeadPicker,
            child: InputDecorator(
              decoration: _fieldDecoration(
                'Select Lead',
                Icons.person_search_rounded,
                isRequired: true,
                hasError: hasError,
                trailingOverride: Icon(
                  _selectedLead == null
                      ? Icons.search_rounded
                      : Icons.edit_rounded,
                  size: 18,
                  color: hasError ? AppColors.red : AppColors.c1,
                ),
              ),
              child: _selectedLead == null
                  ? Text(
                      'Tap to select a lead',
                      // Pulls from the SAME shared hint style as every
                      // other field, so the red matches exactly.
                      style: _hintTextStyle(hasError),
                    )
                  : Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.c1.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _selectedLead!.leadId,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.c1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _selectedLead!.name,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.cdark,
                                ),
                              ),
                              if (_selectedLead!.company.isNotEmpty)
                                Text(
                                  _selectedLead!.company,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.ctext.withOpacity(0.7),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          if (hasError)
            Padding(
              padding: const EdgeInsets.only(top: 5, left: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded,
                      size: 13, color: AppColors.red),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      _errLead!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.red,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ── Call Type dropdown — starts empty, hint "Select Call Type" ─────────
  Widget _buildCallTypeDropdown() {
    final hasError = _errCallType != null && _errCallType!.isNotEmpty;

    return _dropdownWithError(
      error: _errCallType,
      dropdown: DropdownButtonFormField<String>(
        value: _callType,
        isExpanded: true,
        dropdownColor: AppColors.white,
        icon: const SizedBox.shrink(),
        style: const TextStyle(
            fontSize: 14, color: AppColors.cdark, fontWeight: FontWeight.w500),
        hint: Text(
          'Select Call Type',
          style: _hintTextStyle(hasError),
        ),
        items: CallLogOptions.callTypes
            .map((t) => DropdownMenuItem(
                  value: t,
                  child: Text(t,
                      style: const TextStyle(
                          color: AppColors.cdark, fontSize: 14)),
                ))
            .toList(),
        onChanged: (v) {
          if (v == null) return;
          setState(() {
            _callType = v;
            if (_errCallType != null) _errCallType = null;
          });
        },
        decoration: _fieldDecoration(
          'Call Type',
          Icons.call_made_rounded,
          isRequired: true,
          hasError: hasError,
          isDropdown: true,
        ),
      ),
    );
  }

  // ── Call Status dropdown — Answered / No Answer / Busy / Voicemail,
  // starts empty, hint "Select Call Status" ───────────────────────────────
  Widget _buildCallStatusDropdown() {
    final hasError = _errCallStatus != null && _errCallStatus!.isNotEmpty;

    return _dropdownWithError(
      error: _errCallStatus,
      dropdown: DropdownButtonFormField<String>(
        value: _status,
        isExpanded: true,
        dropdownColor: AppColors.white,
        icon: const SizedBox.shrink(),
        style: const TextStyle(
            fontSize: 14, color: AppColors.cdark, fontWeight: FontWeight.w500),
        hint: Text(
          'Select Call Status',
          style: _hintTextStyle(hasError),
        ),
        items: _callStatusOptions
            .map((o) => DropdownMenuItem(
                  value: o.value,
                  child: Text(o.label,
                      style: const TextStyle(
                          color: AppColors.cdark, fontSize: 14)),
                ))
            .toList(),
        onChanged: (v) {
          if (v == null) return;
          setState(() {
            _status = v;
            if (_errCallStatus != null) _errCallStatus = null;
          });
        },
        decoration: _fieldDecoration(
          'Call Status',
          Icons.phone_in_talk_rounded,
          isRequired: true,
          hasError: hasError,
          isDropdown: true,
        ),
      ),
    );
  }

  // ── Generic (label == value) dropdown used for Lead Status / Lead
  // Source — same shared decoration as everything else. ──────────────────
  Widget _buildOptionDropdown({
    required String label,
    required IconData icon,
    required String value,
    required List<String> options,
    required ValueChanged<String> onChanged,
  }) {
    return _dropdownWithError(
      dropdown: DropdownButtonFormField<String>(
        value: options.contains(value) ? value : null,
        isExpanded: true,
        dropdownColor: AppColors.white,
        icon: const SizedBox.shrink(),
        style: const TextStyle(
            fontSize: 14, color: AppColors.cdark, fontWeight: FontWeight.w500),
        items: options
            .map((o) => DropdownMenuItem(
                  value: o,
                  // Display value is Title Case ("Contacted", "Cold Call")
                  // while the underlying `o` sent to the API stays exactly
                  // as defined in CallLogOptions.
                  child: Text(_toDisplayLabel(o),
                      style: const TextStyle(
                          color: AppColors.cdark, fontSize: 14)),
                ))
            .toList(),
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
        decoration: _fieldDecoration(
          label,
          icon,
          isRequired: true,
          isDropdown: true,
        ),
      ),
    );
  }

  // ── Follow-up date — same shared decoration as the dropdowns ───────────
  Widget _dateField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: _pickFollowUpDate,
        child: InputDecorator(
          decoration: _fieldDecoration(
            'Next Follow-up Date (optional)',
            Icons.calendar_month_rounded,
            trailingOverride: _followUpDate != null
                ? GestureDetector(
                    onTap: () => setState(() => _followUpDate = null),
                    child: const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Icon(Icons.close_rounded,
                          size: 16, color: AppColors.c1),
                    ),
                  )
                : const Icon(Icons.keyboard_arrow_down_rounded,
                    color: AppColors.c1),
          ),
          child: Text(
            _followUpDate != null
                ? _formatDate(_followUpDate!)
                : 'Select a date',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _followUpDate != null
                  ? AppColors.cdark
                  : AppColors.ctext.withOpacity(0.55),
            ),
          ),
        ),
      ),
    );
  }

  // ── Save button — pill style ────────────────────────────────────────
  Widget _submitButton() {
    return Consumer<AddCallLogViewmodel>(
      builder: (context, vm, _) {
        final isLoading = vm.submitting;
        return SizedBox(
          width: double.infinity,
          height: 50,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: isLoading ? AppColors.c1.withOpacity(0.45) : AppColors.c1,
              borderRadius: BorderRadius.circular(25),
              boxShadow: isLoading
                  ? []
                  : [
                      BoxShadow(
                        color: AppColors.c1.withOpacity(0.30),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
            ),
            child: ElevatedButton(
              onPressed: isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                disabledBackgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: AppColors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.save_rounded,
                            color: AppColors.white, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Save Call Log',
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
        );
      },
    );
  }
}

/// LEAD PICKER BOTTOM SHEET
/// Searchable list of leads (from LeadViewmodel.leadList) — filters by
/// name, company, lead id, or phone as the user types. Tapping a row pops
/// the sheet with that LeadModel.
/// ─────────────────────────────────────────────────────────────────────────
class _LeadPickerSheet extends StatefulWidget {
  const _LeadPickerSheet();

  @override
  State<_LeadPickerSheet> createState() => _LeadPickerSheetState();
}

class _LeadPickerSheetState extends State<_LeadPickerSheet> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<LeadModel> _filtered(List<LeadModel> leads) {
    if (_query.trim().isEmpty) return leads;
    final q = _query.trim().toLowerCase();
    return leads.where((lead) {
      return lead.name.toLowerCase().contains(q) ||
          lead.company.toLowerCase().contains(q) ||
          lead.leadId.toLowerCase().contains(q) ||
          lead.phone.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(bottom: mq.padding.bottom),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.cborder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Select Lead',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.cdark,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(Icons.close_rounded,
                          size: 20, color: AppColors.ctext),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.cxl,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.cborder),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _query = v),
                    textCapitalization: TextCapitalization.none,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Search by name, company, lead id or phone',
                      hintStyle: TextStyle(
                          fontSize: 12,
                          color: AppColors.ctext.withOpacity(0.55)),
                      isDense: true,
                      prefixIcon: const Icon(Icons.search_rounded,
                          size: 18, color: AppColors.ctext),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Consumer<LeadViewmodel>(
                  builder: (context, vm, _) {
                    if (vm.getLeadLoader && vm.leadList.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.c1,
                        ),
                      );
                    }

                    final results = _filtered(vm.leadList);

                    if (results.isEmpty) {
                      return Center(
                        child: Text(
                          vm.leadList.isEmpty
                              ? 'No leads found'
                              : 'No leads match your search',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.ctext.withOpacity(0.6),
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      itemCount: results.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final lead = results[index];
                        return GestureDetector(
                          onTap: () => Navigator.of(context).pop(lead),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.cxl,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.cborder),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.c1.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    lead.leadId,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.c1,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        lead.name,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.cdark,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        [
                                          if (lead.company.isNotEmpty)
                                            lead.company,
                                          lead.phone,
                                        ].join(' • '),
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          color:
                                              AppColors.ctext.withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right_rounded,
                                    size: 18, color: AppColors.ctext),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
