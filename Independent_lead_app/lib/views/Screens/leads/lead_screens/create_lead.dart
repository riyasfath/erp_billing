// lib/views/Screens/leads/lead_screens/create_lead.dart
// UPDATED: priority (HOT / WARM / COOL) picker, source quick-chips,
// sends `priority` to POST /leads/ and PATCH /leads/{id}/.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pokakbilling/views/Screens/leads/lead_screens/lead_widgets.dart';
import 'package:provider/provider.dart';
import 'package:pokakbilling/viewmodels/lead_viewmodel.dart';
import 'package:pokakbilling/models/data-models/lead_model.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';

class CreateLead extends StatefulWidget {
  final bool isEdit;
  final LeadModel? lead;

  const CreateLead({super.key, required this.isEdit, this.lead});

  @override
  State<CreateLead> createState() => _CreateLeadState();
}

class _CreateLeadState extends State<CreateLead>
    with SingleTickerProviderStateMixin {
  static const List<String> _sourceSuggestions = [
    'WEBSITE',
    'FACEBOOK',
    'MAILCHIMP',
    'SOCIAL_MEDIA',
    'EMAIL_CAMPAIGN',
    'REFERRAL',
  ];

  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  late TextEditingController leadIdController;
  late TextEditingController nameController;
  late TextEditingController companyController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController locationController;
  late TextEditingController enquiryController;
  late TextEditingController projectRequirementsController;
  late TextEditingController additionalNotesController;
  late TextEditingController leadSourceController;
  late TextEditingController receivedDateController;
  late TextEditingController reasonController;

  DateTime? _selectedReceivedDate;
  String _priority = 'WARM'; // HOT | WARM | COOL

  String? _errName;
  String? _errEmail;
  String? _errPhone;
  String? _errSource;
  String? _errStatus;
  String? _errReason;
  String? _errReceivedDate;
  String? _errEmailDuplicate;
  String? _errPhoneDuplicate;

  @override
  void initState() {
    super.initState();

    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim =
        Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
            .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();

    final l = widget.lead;

    leadIdController = TextEditingController(text: l?.leadId ?? '');
    nameController = TextEditingController(text: l?.name ?? '');
    companyController = TextEditingController(text: l?.company ?? '');
    emailController = TextEditingController(text: l?.email ?? '');
    phoneController = TextEditingController(text: l?.phone ?? '');
    addressController = TextEditingController(text: l?.address ?? '');
    locationController = TextEditingController(text: l?.location ?? '');
    enquiryController = TextEditingController(text: l?.enquiry ?? '');
    projectRequirementsController =
        TextEditingController(text: l?.projectRequirements ?? '');
    additionalNotesController =
        TextEditingController(text: l?.additionalNotes ?? '');
    leadSourceController = TextEditingController(text: l?.source ?? '');
    reasonController = TextEditingController(text: l?.reason ?? '');

    if (l != null && l.priorityKey.isNotEmpty) _priority = l.priorityKey;

    if (l?.receivedDate != null && l!.receivedDate!.isNotEmpty) {
      _selectedReceivedDate = DateTime.tryParse(l.receivedDate!);
    }
    receivedDateController = TextEditingController(
      text: _selectedReceivedDate != null
          ? _formatDate(_selectedReceivedDate!)
          : '',
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<LeadViewmodel>();

      if (widget.isEdit && l != null) {
        const knownStatuses = ["New", "Contacted", "Qualified", "Converted", "Lost"];
        final rawStatus = l.status.toUpperCase();

        if (rawStatus == 'OTHER') {
          provider.selectLeadStatus("Other");
          reasonController.text = l.reason ?? '';
        } else {
          final label = _statusKeyToLabel(rawStatus);
          if (knownStatuses.contains(label)) {
            provider.selectLeadStatus(label);
          } else {
            provider.selectLeadStatus("Other");
            reasonController.text = l.reason ?? '';
          }
        }
        leadIdController.text = l.leadId;
      } else {
        provider.selectLeadStatus('New');
        final id = await provider.generateUniqueLeadId();
        if (!mounted) return;
        setState(() => leadIdController.text = id);
      }
    });
  }

  String _statusKeyToLabel(String key) {
    switch (key.toUpperCase()) {
      case 'NEW':
        return 'New';
      case 'CONTACTED':
        return 'Contacted';
      case 'QUALIFIED':
        return 'Qualified';
      case 'CONVERTED':
        return 'Converted';
      case 'LOST':
        return 'Lost';
      default:
        return 'Other';
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    leadIdController.dispose();
    nameController.dispose();
    companyController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    locationController.dispose();
    enquiryController.dispose();
    projectRequirementsController.dispose();
    additionalNotesController.dispose();
    leadSourceController.dispose();
    receivedDateController.dispose();
    reasonController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _toApiDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedReceivedDate ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 5),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.c1,
            onPrimary: AppColors.white,
            surface: AppColors.white,
            onSurface: AppColors.cdark,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedReceivedDate = picked;
        receivedDateController.text = _formatDate(picked);
        _errReceivedDate = null;
      });
    }
  }

  // ─── validators ───────────────────────────────────────────────────────────
  String? _validateName(String v) {
    if (v.trim().isEmpty) return 'Name is required';
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(v.trim())) {
      return 'Name should contain only letters';
    }
    return null;
  }

  String? _validateEmail(String v) {
    if (v.trim().isEmpty) return null; // optional
    if (!RegExp(r'^[\w.-]+@[\w.-]+\.[a-zA-Z]{2,}$').hasMatch(v.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePhone(String v) {
    if (v.trim().isEmpty) return 'Phone number is required';
    if (!RegExp(r'^\d{10}$').hasMatch(v.trim())) {
      return 'Enter a valid 10-digit phone number';
    }
    if (!RegExp(r'^[6-9]').hasMatch(v.trim())) return 'Enter a valid phone number';
    return null;
  }

  String? _validateSource(String v) =>
      v.trim().isEmpty ? 'Lead source is required' : null;

  String? _validateReason(String v) =>
      v.trim().isEmpty ? 'Please enter a reason' : null;

  bool _checkDuplicates(List<LeadModel> allLeads) {
    final enteredEmail = emailController.text.trim().toLowerCase();
    final enteredPhone = phoneController.text.trim();
    final currentId = widget.isEdit ? widget.lead?.id : null;

    String? emailErr;
    String? phoneErr;

    for (final lead in allLeads) {
      if (currentId != null && lead.id == currentId) continue;
      if (enteredEmail.isNotEmpty &&
          lead.email.trim().toLowerCase() == enteredEmail) {
        emailErr = 'This email is already used by another lead';
      }
      if (enteredPhone.isNotEmpty && lead.phone.trim() == enteredPhone) {
        phoneErr = 'This phone number is already used by another lead';
      }
    }

    setState(() {
      _errEmailDuplicate = emailErr;
      _errPhoneDuplicate = phoneErr;
    });
    return emailErr != null || phoneErr != null;
  }

  String? _nullIfEmpty(TextEditingController c) =>
      c.text.trim().isEmpty ? null : c.text.trim();

  void _handleSubmit() {
    final provider = Provider.of<LeadViewmodel>(context, listen: false);

    final nameErr = _validateName(nameController.text);
    final emailErr = _validateEmail(emailController.text);
    final phoneErr = _validatePhone(phoneController.text);
    final sourceErr = _validateSource(leadSourceController.text);
    final receivedDateErr =
        _selectedReceivedDate == null ? 'Please select a lead date' : null;

    String? statusErr;
    String? reasonErr;
    if (provider.selectedLeadStatus.isEmpty) {
      statusErr = 'Please select a status';
    } else if (provider.isLeadStatusOther) {
      reasonErr = _validateReason(reasonController.text);
    }

    setState(() {
      _errName = nameErr;
      _errEmail = emailErr;
      _errPhone = phoneErr;
      _errSource = sourceErr;
      _errStatus = statusErr;
      _errReason = reasonErr;
      _errReceivedDate = receivedDateErr;
      _errEmailDuplicate = null;
      _errPhoneDuplicate = null;
    });

    if (nameErr != null ||
        emailErr != null ||
        phoneErr != null ||
        sourceErr != null ||
        statusErr != null ||
        reasonErr != null ||
        receivedDateErr != null) {
      return;
    }

    if (_checkDuplicates(provider.leadList)) return;

    final receivedDateStr =
        _selectedReceivedDate != null ? _toApiDate(_selectedReceivedDate!) : null;
    final String? reasonValue =
        provider.isLeadStatusOther ? reasonController.text.trim() : null;

    if (widget.isEdit && widget.lead != null) {
      provider.editLead(
        leadId: widget.lead!.id,
        name: nameController.text.trim(),
        company: companyController.text.trim(),
        email: _nullIfEmpty(emailController),
        phone: phoneController.text.trim(),
        location: _nullIfEmpty(locationController),
        enquiry: _nullIfEmpty(enquiryController),
        address: _nullIfEmpty(addressController),
        projectRequirements: _nullIfEmpty(projectRequirementsController),
        additionalNotes: _nullIfEmpty(additionalNotesController),
        source: _nullIfEmpty(leadSourceController),
        status: provider.selectedLeadStatusKey,
        priority: _priority,
        receivedDate: receivedDateStr,
        reason: reasonValue,
        assignedTo: widget.lead!.assignedTo,
        context: context,
      );
    } else {
      provider.createLead(
        leadId: null,
        name: nameController.text.trim(),
        company: companyController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        location: _nullIfEmpty(locationController),
        enquiry: _nullIfEmpty(enquiryController),
        address: _nullIfEmpty(addressController),
        projectRequirements: _nullIfEmpty(projectRequirementsController),
        additionalNotes: _nullIfEmpty(additionalNotesController),
        source: _nullIfEmpty(leadSourceController),
        status: provider.selectedLeadStatusKey,
        priority: _priority,
        receivedDate: receivedDateStr,
        reason: reasonValue,
        assignedTo: null,
        context: context,
      );
    }
  }

  // ─── BUILD ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FC),
      body: Column(children: [
        AppHeader(
          title: widget.isEdit ? 'Edit Lead' : 'Create Lead',
          subtitle: widget.isEdit
              ? (widget.lead?.leadId ?? 'Update lead details')
              : 'Fill in the details below',
          onBack: () => Navigator.pop(context),
          trailing: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.c1.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              widget.isEdit ? Icons.edit_rounded : Icons.person_add_alt_1_rounded,
              color: AppColors.c1,
              size: 18,
            ),
          ),
        ),
        Expanded(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 32),
                child: Column(children: [
                  _section(
                    icon: Icons.badge_outlined,
                    title: 'Lead Identity',
                    children: [
                      _field(
                        controller: nameController,
                        label: 'Full Name',
                        icon: Icons.person_outline_rounded,
                        hint: 'Enter full name',
                        isRequired: true,
                        error: _errName,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                        ],
                        onChanged: (_) {
                          if (_errName != null) setState(() => _errName = null);
                        },
                      ),
                      _field(
                        controller: companyController,
                        label: 'Company Name',
                        icon: Icons.business_outlined,
                        hint: 'Enter company name',
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _section(
                    icon: Icons.contact_phone_outlined,
                    title: 'Contact Details',
                    children: [
                      _field(
                        controller: emailController,
                        label: 'Email Address',
                        icon: Icons.email_outlined,
                        hint: 'Enter email address (optional)',
                        keyboardType: TextInputType.emailAddress,
                        error: _errEmail ?? _errEmailDuplicate,
                        onChanged: (_) {
                          if (_errEmail != null || _errEmailDuplicate != null) {
                            setState(() {
                              _errEmail = null;
                              _errEmailDuplicate = null;
                            });
                          }
                        },
                      ),
                      _field(
                        controller: phoneController,
                        label: 'Phone Number',
                        icon: Icons.phone_outlined,
                        hint: '10-digit phone number',
                        isRequired: true,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        error: _errPhone ?? _errPhoneDuplicate,
                        onChanged: (_) {
                          if (_errPhone != null || _errPhoneDuplicate != null) {
                            setState(() {
                              _errPhone = null;
                              _errPhoneDuplicate = null;
                            });
                          }
                        },
                      ),
                      _field(
                        controller: locationController,
                        label: 'Location',
                        icon: Icons.location_on_outlined,
                        hint: 'e.g. Infopark, Kochi',
                      ),
                      _field(
                        controller: addressController,
                        label: 'Address',
                        icon: Icons.home_outlined,
                        hint: 'Enter full address',
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _section(
                    icon: Icons.analytics_outlined,
                    title: 'Lead Information',
                    children: [
                      _priorityPicker(),
                      _buildStatusDropdown(),
                      _field(
                        controller: leadSourceController,
                        label: 'Lead Source',
                        icon: Icons.public_rounded,
                        hint: 'e.g. WEBSITE, REFERRAL',
                        isRequired: true,
                        error: _errSource,
                        onChanged: (_) {
                          if (_errSource != null) setState(() => _errSource = null);
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: _sourceSuggestions.map((s) {
                            final sel =
                                leadSourceController.text.trim().toUpperCase() == s;
                            return GestureDetector(
                              onTap: () => setState(() {
                                leadSourceController.text = s;
                                _errSource = null;
                              }),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 160),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: sel
                                      ? AppColors.c1.withOpacity(0.14)
                                      : AppColors.cxl,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: sel
                                          ? AppColors.c1
                                          : AppColors.cborder),
                                ),
                                child: Text(s,
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color:
                                            sel ? AppColors.c1 : AppColors.ctext)),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      _field(
                        controller: enquiryController,
                        label: 'Enquiry',
                        icon: Icons.help_outline_rounded,
                        hint: 'Enquiry type',
                      ),
                      _buildDatePickerField(),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _section(
                    icon: Icons.notes_rounded,
                    title: 'Notes & Requirements',
                    children: [
                      _field(
                        controller: projectRequirementsController,
                        label: 'Project Requirements',
                        icon: Icons.checklist_rounded,
                        hint: 'Describe project needs',
                        maxLines: 3,
                      ),
                      _field(
                        controller: additionalNotesController,
                        label: 'Additional Notes',
                        icon: Icons.sticky_note_2_outlined,
                        hint: 'Any other notes',
                        maxLines: 2,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildActionButtons(),
                ]),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  // ─── priority picker ──────────────────────────────────────────────────────
  Widget _priorityPicker() {
    const keys = ['HOT', 'WARM', 'COOL'];
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Priority',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.ctext)),
        const SizedBox(height: 8),
        Row(
          children: List.generate(keys.length, (i) {
            final k = keys[i];
            final sel = _priority == k;
            final c = LeadUi.priorityColor(k);
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _priority = k),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: EdgeInsets.only(right: i == keys.length - 1 ? 0 : 8),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    color: sel ? c.withOpacity(0.12) : AppColors.cxl,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: sel ? c : AppColors.cborder, width: sel ? 1.6 : 1),
                  ),
                  child: Column(children: [
                    Icon(Icons.star_rounded,
                        size: 18, color: sel ? c : AppColors.ctext.withOpacity(0.4)),
                    const SizedBox(height: 3),
                    Text(LeadUi.priorityName(k),
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: sel ? c : AppColors.ctext)),
                    Text(LeadUi.priorityLevel(k),
                        style: TextStyle(
                            fontSize: 9,
                            color: (sel ? c : AppColors.ctext).withOpacity(0.7))),
                  ]),
                ),
              ),
            );
          }),
        ),
      ]),
    );
  }

  // ─── status dropdown ──────────────────────────────────────────────────────
  Widget _buildStatusDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Consumer<LeadViewmodel>(
        builder: (context, provider, child) {
          final hasError = _errStatus != null && _errStatus!.isNotEmpty;
          final String? dropdownValue =
              provider.selectedLeadStatus.isEmpty ? null : provider.selectedLeadStatus;

          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            DropdownButtonFormField<String>(
              value: dropdownValue,
              isExpanded: true,
              dropdownColor: AppColors.white,
              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                  color: AppColors.c1, size: 20),
              style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.cdark,
                  fontWeight: FontWeight.w500),
              hint: Text('Select status',
                  style: TextStyle(
                      fontSize: 13,
                      color: hasError
                          ? AppColors.red
                          : AppColors.ctext.withOpacity(0.55))),
              decoration: _decoration(
                  label: 'Status', icon: Icons.flag_outlined, hasError: hasError),
              items: provider.leadStatusList
                  .map((s) => DropdownMenuItem<String>(
                        value: s,
                        child: Text(s,
                            style: TextStyle(
                                color: s == 'Other' ? AppColors.c1 : AppColors.cdark,
                                fontSize: 14,
                                fontWeight: s == 'Other'
                                    ? FontWeight.w600
                                    : FontWeight.w400)),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  provider.selectLeadStatus(value);
                  if (value != 'Other') {
                    reasonController.clear();
                    setState(() => _errReason = null);
                  }
                  if (_errStatus != null) setState(() => _errStatus = null);
                }
              },
            ),
            if (hasError) _errorRow(_errStatus!),
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: provider.isLeadStatusOther
                  ? Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: _field(
                        controller: reasonController,
                        label: 'Reason',
                        icon: Icons.edit_note_rounded,
                        hint: 'e.g. Client postponed project',
                        isRequired: true,
                        error: _errReason,
                        onChanged: (_) {
                          if (_errReason != null) setState(() => _errReason = null);
                        },
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ]);
        },
      ),
    );
  }

  // ─── date picker tile ─────────────────────────────────────────────────────
  Widget _buildDatePickerField() {
    final hasError = _errReceivedDate != null && _errReceivedDate!.isNotEmpty;
    final isSet = _selectedReceivedDate != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        GestureDetector(
          onTap: _pickDate,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: hasError ? AppColors.red.withOpacity(0.04) : AppColors.cxl,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: hasError
                    ? AppColors.red.withOpacity(0.60)
                    : (isSet ? AppColors.c1 : AppColors.cborder),
                width: hasError || isSet ? 1.5 : 1.0,
              ),
            ),
            child: Row(children: [
              Icon(Icons.calendar_today_outlined,
                  size: 18, color: hasError ? AppColors.red : AppColors.c1),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isSet
                      ? _formatDate(_selectedReceivedDate!)
                      : 'Select lead received date',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSet ? FontWeight.w500 : FontWeight.w400,
                    color: hasError
                        ? AppColors.red
                        : (isSet ? AppColors.cdark : AppColors.ctext.withOpacity(0.55)),
                  ),
                ),
              ),
              if (!isSet)
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Icon(Icons.circle, size: 6, color: AppColors.red),
                )
              else
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                      color: AppColors.c1.withOpacity(0.12), shape: BoxShape.circle),
                  child: const Icon(Icons.check_rounded, size: 14, color: AppColors.c1),
                ),
            ]),
          ),
        ),
        if (hasError) _errorRow(_errReceivedDate!),
      ]),
    );
  }

  // ─── section + field helpers ──────────────────────────────────────────────
  Widget _section({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return AppCard(
      accent: AppColors.c1,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SectionTitle(icon: icon, title: title),
        Divider(height: 22, thickness: 1, color: AppColors.c1.withOpacity(0.10)),
        ...children,
      ]),
    );
  }

  Widget _errorRow(String msg) => Padding(
        padding: const EdgeInsets.only(top: 5, left: 4),
        child: Row(children: [
          const Icon(Icons.error_outline_rounded, size: 13, color: AppColors.red),
          const SizedBox(width: 4),
          Flexible(
            child: Text(msg,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.red,
                    height: 1.4)),
          ),
        ]),
      );

  InputDecoration _decoration({
    required String label,
    required IconData icon,
    required bool hasError,
    String? hint,
    Widget? suffix,
  }) {
    OutlineInputBorder b(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: c, width: w),
        );
    final base = hasError ? AppColors.red.withOpacity(0.60) : AppColors.cborder;
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
          fontSize: 13,
          color: hasError ? AppColors.red : AppColors.ctext.withOpacity(0.75)),
      floatingLabelStyle:
          TextStyle(fontSize: 13, color: hasError ? AppColors.red : AppColors.c1),
      hintText: hint,
      hintStyle: TextStyle(
          fontSize: 12,
          color: hasError
              ? AppColors.red.withOpacity(0.70)
              : AppColors.ctext.withOpacity(0.45)),
      prefixIcon:
          Icon(icon, size: 18, color: hasError ? AppColors.red : AppColors.c1),
      suffixIcon: suffix,
      suffixIconConstraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      filled: true,
      fillColor: hasError ? AppColors.red.withOpacity(0.04) : AppColors.cxl,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: b(base),
      enabledBorder: b(base),
      focusedBorder: b(hasError ? AppColors.red : AppColors.c1, 1.5),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    bool isRequired = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    void Function(String)? onChanged,
    int maxLines = 1,
    String? error,
  }) {
    final hasError = error != null && error.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          cursorColor: AppColors.c1,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          maxLines: maxLines,
          style: const TextStyle(
              fontSize: 14, color: AppColors.cdark, fontWeight: FontWeight.w500),
          decoration: _decoration(
            label: label,
            icon: icon,
            hint: hint,
            hasError: hasError,
            suffix: isRequired
                ? const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(Icons.circle, size: 6, color: AppColors.red),
                  )
                : null,
          ),
        ),
        if (hasError) _errorRow(error),
      ]),
    );
  }

  // ─── action buttons ───────────────────────────────────────────────────────
  Widget _buildActionButtons() {
    return Consumer<LeadViewmodel>(
      builder: (context, provider, child) {
        final isLoading =
            widget.isEdit ? provider.editLoading : provider.addLeadLoader;
        return Column(children: [
          GradientButton(
            label: widget.isEdit ? 'Update Lead' : 'Create Lead',
            icon: widget.isEdit ? Icons.check_rounded : Icons.person_add_alt_1_rounded,
            loading: isLoading,
            height: 52,
            onTap: _handleSubmit,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.cborder, width: 1.5),
                foregroundColor: AppColors.ctext,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
              ),
              child: const Text('Cancel',
                  style: TextStyle(
                      color: AppColors.ctext,
                      fontSize: 15,
                      fontWeight: FontWeight.w600)),
            ),
          ),
        ]);
      },
    );
  }
}