
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pokakbilling/views/Screens/leads/reminder/lead_reminder.dart';
import 'package:provider/provider.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/models/data-models/lead_model.dart';
import 'package:pokakbilling/notification/notification_service.dart';
import 'package:pokakbilling/viewmodels/lead_viewmodel.dart';
import 'package:pokakbilling/viewmodels/reminder/reminder_viewmodel.dart';

class AddReminderScreen extends StatefulWidget {
  const AddReminderScreen({super.key});

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  LeadModel? _selectedLead;

  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  final TextEditingController _locationCtrl = TextEditingController();

  String _selectedSubtype = 'Email';
  DateTime selectedDate = DateTime.now();
  String selectedTimeIso = '';
  String selectedTimeDisplay = '';

  bool _hasPickedDate = false;
  bool _hasPickedTime = false;
  bool _saving = false;

  String? _errTitle;
  String? _errLead;
  String? _errDate;
  String? _errTime;

  static const _subtypes = [
    _SubtypeOption('Email', Icons.email_rounded),
    _SubtypeOption('Call', Icons.call_rounded),
    _SubtypeOption('WhatsApp', Icons.message_rounded),
    _SubtypeOption('Message', Icons.sms_rounded),
    _SubtypeOption('Follow-up', Icons.repeat_rounded),
  ];

  @override
  void initState() {
    super.initState();

    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 550));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final lv = context.read<LeadViewmodel>();
      if (lv.leadList.isEmpty) lv.getAllLeads();
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  String _formatDateDisplay(DateTime d) => DateFormat('dd MMM yyyy').format(d);
  String _formatDateApi(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  String _timeOfDayToIso(TimeOfDay t) => '${t.hour.toString().padLeft(2, '0')}:'
      '${t.minute.toString().padLeft(2, '0')}:00';

  IconData get _subtypeIcon =>
      _subtypes.firstWhere((s) => s.value == _selectedSubtype).icon;

  Future<void> _openSelectLeadSheet() async {
    final leadVm = context.read<LeadViewmodel>();
    final leads = leadVm.leadList;

    final lead = await showModalBottomSheet<LeadModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.70,
          minChildSize: 0.40,
          maxChildSize: 0.95,
          builder: (_, controller) => Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: AppColors.c1.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 8, 12),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.c1.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.person_search_rounded,
                          color: AppColors.c1, size: 16),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Select Lead',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.cdark,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      icon: Icon(Icons.close_rounded,
                          color: AppColors.ctext.withOpacity(0.55), size: 20),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: AppColors.c1.withOpacity(0.10)),
              const SizedBox(height: 6),
              Expanded(
                child: leads.isEmpty
                    ? Center(
                        child: Text(
                          'No leads available',
                          style: TextStyle(
                              color: AppColors.ctext.withOpacity(0.45)),
                        ),
                      )
                    : ListView.separated(
                        controller: controller,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: leads.length,
                        separatorBuilder: (_, __) => Divider(
                            height: 1, color: AppColors.c1.withOpacity(0.08)),
                        itemBuilder: (_, i) {
                          final l = leads[i];
                          final isSelected = _selectedLead?.id == l.id;
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 4),
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.c1.withOpacity(0.12)
                                    : AppColors.cxl,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.c1.withOpacity(0.30)
                                      : AppColors.cborder,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  l.name.isNotEmpty
                                      ? l.name[0].toUpperCase()
                                      : 'L',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: isSelected
                                        ? AppColors.c1
                                        : AppColors.ctext,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              l.name,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color:
                                    isSelected ? AppColors.c1 : AppColors.cdark,
                              ),
                            ),
                            subtitle: Text(
                              l.email.isNotEmpty ? l.email : l.phone,
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.ctext.withOpacity(0.55),
                              ),
                            ),
                            trailing: isSelected
                                ? Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: AppColors.c1.withOpacity(0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.check_rounded,
                                        color: AppColors.c1, size: 14),
                                  )
                                : null,
                            onTap: () => Navigator.of(ctx).pop(l),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );

    if (lead != null) {
      setState(() {
        _selectedLead = lead;
        if (_errLead != null) _errLead = null;
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: ColorScheme.light(
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
        selectedDate = picked;
        _hasPickedDate = true;
        if (_errDate != null) _errDate = null;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: ColorScheme.light(
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
        selectedTimeIso = _timeOfDayToIso(picked);
        selectedTimeDisplay = picked.format(context);
        _hasPickedTime = true;
        if (_errTime != null) _errTime = null;
      });
    }
  }

  void _showSubtypeSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(ctx).size.height * 0.55,
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: AppColors.c1.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 8, 12),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.c1.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.tune_rounded,
                          color: AppColors.c1, size: 16),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Action Type',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.cdark,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: Icon(Icons.close_rounded,
                          color: AppColors.ctext.withOpacity(0.55), size: 20),
                    ),
                  ],
                ),
              ),
              Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.c1.withOpacity(0.10)),
              const SizedBox(height: 6),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  children: _subtypes.map((o) {
                    final isSelected = o.value == _selectedSubtype;
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.c1
                              : AppColors.c1.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Icon(o.icon, size: 16, color: AppColors.white),
                      ),
                      title: Text(
                        o.value,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? AppColors.cdark : AppColors.ctext,
                        ),
                      ),
                      trailing: isSelected
                          ? Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: AppColors.c1.withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.check_rounded,
                                  color: AppColors.c1, size: 14),
                            )
                          : null,
                      onTap: () {
                        setState(() => _selectedSubtype = o.value);
                        Navigator.pop(ctx);
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveReminder() async {
    final titleErr =
        _titleCtrl.text.trim().isEmpty ? 'Reminder title is required' : null;
    final leadErr = _selectedLead == null ? 'Please select a lead' : null;
    final dateErr = !_hasPickedDate ? 'Please select a date' : null;
    final timeErr = (!_hasPickedTime || selectedTimeIso.isEmpty)
        ? 'Please select a time'
        : null;

    setState(() {
      _errTitle = titleErr;
      _errLead = leadErr;
      _errDate = dateErr;
      _errTime = timeErr;
    });

    if (titleErr != null ||
        leadErr != null ||
        dateErr != null ||
        timeErr != null) return;

    final int leadId = _selectedLead!.id;
    final String leadName = _selectedLead!.name;
    final String dateStr = _formatDateApi(selectedDate);
    final String dateDisplay = _formatDateDisplay(selectedDate);
    final String timeStr = selectedTimeIso;
    final String timeDisplay = selectedTimeDisplay;
    final String subtype = _selectedSubtype;
    final String title = _titleCtrl.text.trim();
    final String? desc =
        _descCtrl.text.trim().isNotEmpty ? _descCtrl.text.trim() : null;
    final vm = context.read<ReminderViewmodel>();

    setState(() => _saving = true);

    bool success = false;
    try {
      success = await vm.createReminder(
        lead: leadId.toString(),
        title: title,
        subtype: subtype,
        date: dateStr,
        time: timeStr,
        description: desc,
      );
    } catch (_) {
      success = false;
    }

    if (!mounted) return;
    setState(() => _saving = false);

    if (success) {
      await NotificationService.instance.showReminderCreatedNotification(
        title: title,
        subtype: subtype,
        dateText: dateDisplay,
        timeText: timeDisplay,
        leadName: leadName,
      );

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => LeadReminder(),
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Failed to create reminder. Please try again.'),
        backgroundColor: AppColors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          _buildHeader(context, sw, topPad),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: Column(
                    children: [
                      _buildSection(
                        icon: Icons.person_outline_rounded,
                        title: 'Select Lead',
                        children: [_buildLeadSelector()],
                      ),
                      const SizedBox(height: 14),
                      _buildSection(
                        icon: Icons.notifications_active_outlined,
                        title: 'Reminder Details',
                        children: [_buildDetailsForm()],
                      ),
                      const SizedBox(height: 14),
                      _buildSection(
                        icon: Icons.schedule_rounded,
                        title: 'Schedule',
                        children: [_buildScheduleForm()],
                      ),
                      const SizedBox(height: 20),
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double sw, double topPad) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: topPad + 12,
        bottom: 28,
        left: sw * 0.03,
        right: sw * 0.04,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.cborder, width: 1.5),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.cxl,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cborder),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.c3,
                size: 15,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Reminder',
                style: TextStyle(
                  color: AppColors.cdark,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Set a reminder for a lead',
                style: TextStyle(color: AppColors.ctext, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required List<Widget> children,
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
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.cdark,
                ),
              ),
            ],
          ),
          const Divider(height: 20, thickness: 1, color: AppColors.cborder),
          ...children,
        ],
      ),
    );
  }

  // ── FIXED: label turns red on validation error ────────────────────────────
  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isRequired = false,
    int maxLines = 1,
    String? error,
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
            maxLines: maxLines,
            cursorColor: AppColors.c1,
            onChanged: onChanged,
            style: const TextStyle(fontSize: 14, color: AppColors.cdark),
            decoration: InputDecoration(
              labelText: label,
              // ✅ Label color turns red when there is a validation error
              labelStyle: TextStyle(
                fontSize: 13,
                color: hasError
                    ? AppColors.red
                    : AppColors.ctext.withOpacity(0.75),
              ),
              prefixIcon: Icon(
                icon,
                size: 18,
                color: hasError ? AppColors.red : AppColors.c1,
              ),
              suffixIcon: isRequired
                  ? Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(Icons.circle, size: 6, color: AppColors.red),
                    )
                  : null,
              suffixIconConstraints:
                  const BoxConstraints(minWidth: 32, minHeight: 32),
              filled: true,
              fillColor:
                  hasError ? AppColors.red.withOpacity(0.04) : AppColors.cxl,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: hasError
                      ? AppColors.red.withOpacity(0.60)
                      : AppColors.cborder,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: hasError
                      ? AppColors.red.withOpacity(0.60)
                      : AppColors.cborder,
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

  Widget _buildLeadSelector() {
    final hasError = _errLead != null && _errLead!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: _openSelectLeadSheet,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color:
                    hasError ? AppColors.red.withOpacity(0.04) : AppColors.cxl,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: hasError
                      ? AppColors.red.withOpacity(0.60)
                      : (_selectedLead != null
                          ? AppColors.c1
                          : AppColors.cborder),
                  width: hasError || _selectedLead != null ? 1.5 : 1.0,
                ),
              ),
              child: _selectedLead == null
                  ? Row(
                      children: [
                        Icon(
                          Icons.person_search_rounded,
                          size: 18,
                          color: hasError ? AppColors.red : AppColors.c1,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Choose a lead',
                            style: TextStyle(
                              fontSize: 13,
                              color: hasError
                                  ? AppColors.red
                                  : AppColors.ctext.withOpacity(0.55),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child:
                              Icon(Icons.circle, size: 6, color: AppColors.red),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.c1.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              _selectedLead!.name.isNotEmpty
                                  ? _selectedLead!.name[0].toUpperCase()
                                  : 'L',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.c1,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedLead!.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.cdark,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                _selectedLead!.email.isNotEmpty
                                    ? _selectedLead!.email
                                    : _selectedLead!.phone,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.ctext.withOpacity(0.65),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.c1.withOpacity(0.10),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit_rounded,
                              size: 13, color: AppColors.c1),
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

  Widget _buildDetailsForm() {
    return Column(
      children: [
        _field(
          _titleCtrl,
          'Reminder Title',
          Icons.title_rounded,
          isRequired: true,
          error: _errTitle,
          onChanged: (_) {
            if (_errTitle != null) setState(() => _errTitle = null);
          },
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: _showSubtypeSheet,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.cxl,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.cborder),
              ),
              child: Row(
                children: [
                  Icon(_subtypeIcon, color: AppColors.c1, size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Action Type',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.ctext.withOpacity(0.75),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _selectedSubtype,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.cdark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down_rounded,
                      size: 20, color: AppColors.c1),
                ],
              ),
            ),
          ),
        ),
        _field(
          _descCtrl,
          'Description',
          Icons.notes_rounded,
          maxLines: 2,
        ),
        _field(
          _locationCtrl,
          'Location / Link',
          Icons.location_on_outlined,
        ),
      ],
    );
  }

  Widget _buildScheduleForm() {
    return Column(
      children: [
        _pickerTile(
          icon: Icons.calendar_today_rounded,
          label: 'Date',
          value: _hasPickedDate ? _formatDateDisplay(selectedDate) : null,
          placeholder: 'Pick a date',
          onTap: _pickDate,
          isSet: _hasPickedDate,
          isRequired: true,
          error: _errDate,
        ),
        _pickerTile(
          icon: Icons.access_time_rounded,
          label: 'Time',
          value: _hasPickedTime && selectedTimeDisplay.isNotEmpty
              ? selectedTimeDisplay
              : null,
          placeholder: 'Pick a time',
          onTap: _pickTime,
          isSet: _hasPickedTime,
          isRequired: true,
          error: _errTime,
        ),
      ],
    );
  }

  Widget _pickerTile({
    required IconData icon,
    required String label,
    required String? value,
    required String placeholder,
    required VoidCallback onTap,
    required bool isSet,
    bool isRequired = false,
    String? error,
  }) {
    final hasError = error != null && error.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color:
                    hasError ? AppColors.red.withOpacity(0.04) : AppColors.cxl,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: hasError
                      ? AppColors.red.withOpacity(0.60)
                      : (isSet ? AppColors.c1 : AppColors.cborder),
                  width: hasError || isSet ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 18,
                    color: hasError ? AppColors.red : AppColors.c1,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      value ?? placeholder,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSet ? FontWeight.w500 : FontWeight.w400,
                        color: hasError
                            ? AppColors.red.withOpacity(0.70)
                            : (isSet
                                ? AppColors.cdark
                                : AppColors.ctext.withOpacity(0.55)),
                      ),
                    ),
                  ),
                  if (isRequired && !isSet)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(Icons.circle, size: 6, color: AppColors.red),
                    )
                  else if (isSet)
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.c1.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_rounded,
                          size: 14, color: AppColors.c1),
                    )
                  else
                    const Icon(Icons.keyboard_arrow_down_rounded,
                        size: 20, color: AppColors.c1),
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

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.c1,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: AppColors.c1.withOpacity(0.30),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _saving ? null : _saveReminder,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: AppColors.white, strokeWidth: 2),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_active_rounded,
                            color: AppColors.white, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Create Reminder',
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
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.cborder, width: 1.5),
              foregroundColor: AppColors.ctext,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25)),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.ctext,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SubtypeOption {
  final String value;
  final IconData icon;
  const _SubtypeOption(this.value, this.icon);
}
