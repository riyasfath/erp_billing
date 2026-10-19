import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pokakbilling/ERP_UI_KIT.dart';
import 'package:provider/provider.dart';
import 'package:pokakbilling/models/data-models/lead_model.dart';
import 'package:pokakbilling/models/data-models/reminder_model.dart';
import 'package:pokakbilling/viewmodels/lead_viewmodel.dart';
import 'package:pokakbilling/viewmodels/reminder/reminder_viewmodel.dart';

// ── Reminder subtype option ────────────────────────────────────────────────
// Only "call" is supported for now. Other types removed.
class _SubtypeOption {
  final String value;
  final String label;
  final IconData icon;

  const _SubtypeOption(this.value, this.label, {required this.icon});
}

const _SubtypeOption _kCallSubtype =
    _SubtypeOption('call', 'Phone Call', icon: Icons.call_rounded);

// ── Main Screen ────────────────────────────────────────────────────────────
class AddReminderScreen extends StatefulWidget {
  const AddReminderScreen({super.key});

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen>
    with SingleTickerProviderStateMixin {
  // ── Animation ─────────────────────────────────────────────────────────────
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  // ── State ─────────────────────────────────────────────────────────────────
  LeadModel? _selectedLead;

  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();

  // Only one reminder type is supported, so it's fixed (no picker needed).
  final String _selectedSubtype = _kCallSubtype.value;

  DateTime selectedDate = DateTime.now();
  String selectedTimeIso = '';
  String selectedTimeDisplay = '';

  bool _hasPickedDate = false;
  bool _hasPickedTime = false;
  bool _saving = false;

  // ── Validation errors ─────────────────────────────────────────────────────
  String? _errTitle;
  String? _errLead;
  String? _errDate;
  String? _errTime;

  // ── Lifecycle ─────────────────────────────────────────────────────────────
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
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  String _formatDateDisplay(DateTime d) => DateFormat('dd MMM yyyy').format(d);
  String _formatDateApi(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  String _timeOfDayToIso(TimeOfDay t) => '${t.hour.toString().padLeft(2, '0')}:'
      '${t.minute.toString().padLeft(2, '0')}:00';

  Color _avatarColor(String seed) =>
      ErpColors.rotation[seed.hashCode.abs() % ErpColors.rotation.length];

  Widget _avatar(String name, double size) {
    final c = _avatarColor(name);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [ErpColors.tint(c, 0.22), c],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: c.withValues(alpha: 0.30),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'L',
          style: TextStyle(
            fontSize: size * 0.4,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // ── Lead picker bottom sheet ───────────────────────────────────────────────
  Future<void> _openSelectLeadSheet() async {
    final leadVm = context.read<LeadViewmodel>();
    final leads = leadVm.leadList;

    final lead = await showModalBottomSheet<LeadModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.70,
          minChildSize: 0.40,
          maxChildSize: 0.95,
          builder: (_, controller) => Column(
            children: [
              Container(
                width: 44,
                height: 5,
                margin: const EdgeInsets.only(top: 10, bottom: 14),
                decoration: BoxDecoration(
                  color: ErpColors.line,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        ErpColors.pink.withValues(alpha: 0.12),
                        ErpColors.pink.withValues(alpha: 0.03),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: ErpColors.pink.withValues(alpha: 0.18)),
                  ),
                  child: Row(
                    children: [
                      const ErpGradientTile(
                          icon: Icons.person_search_rounded,
                          color: ErpColors.pink,
                          size: 44),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Select Lead',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: ErpColors.ink,
                              ),
                            ),
                            Text(
                              '${leads.length} leads',
                              style: const TextStyle(
                                  fontSize: 13, color: ErpColors.slate),
                            ),
                          ],
                        ),
                      ),
                      ErpPressable(
                        onTap: () => Navigator.of(ctx).pop(),
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: ErpColors.line),
                          ),
                          child: const Icon(Icons.close_rounded,
                              size: 18, color: ErpColors.slate),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: leads.isEmpty
                    ? const Center(
                        child: ErpEmptyState(
                          icon: Icons.inbox_rounded,
                          title: 'No leads available',
                          subtitle: 'Add a lead first, then set a reminder.',
                          color: ErpColors.pink,
                        ),
                      )
                    : ListView.builder(
                        controller: controller,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(18, 4, 18, 20),
                        itemCount: leads.length,
                        itemBuilder: (_, i) {
                          final l = leads[i];
                          // ERP LeadModel uses leadId (int) not id
                          final isSelected = _selectedLead?.leadId == l.leadId;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: ErpPressable(
                              scale: 0.98,
                              onTap: () => Navigator.of(ctx).pop(l),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? ErpColors.pink.withValues(alpha: 0.08)
                                      : ErpColors.pageBg,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? ErpColors.pink.withValues(alpha: 0.6)
                                        : ErpColors.line,
                                    width: isSelected ? 1.4 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    _avatar(l.name, 40),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            l.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w800,
                                              color: isSelected
                                                  ? ErpColors.shade(
                                                      ErpColors.pink, 0.15)
                                                  : ErpColors.ink,
                                            ),
                                          ),
                                          const SizedBox(height: 1),
                                          Text(
                                            // ERP LeadModel uses emailId and phone
                                            (l.emailId != null &&
                                                    l.emailId!.isNotEmpty)
                                                ? l.emailId!
                                                : l.phone,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: ErpColors.slate,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isSelected)
                                      Container(
                                        width: 26,
                                        height: 26,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(colors: [
                                            ErpColors.tint(ErpColors.pink, 0.2),
                                            ErpColors.pink
                                          ]),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.check_rounded,
                                            color: Colors.white, size: 15),
                                      )
                                    else
                                      const Icon(Icons.chevron_right_rounded,
                                          color: ErpColors.slate, size: 20),
                                  ],
                                ),
                              ),
                            ),
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

  // ── Date / Time pickers ───────────────────────────────────────────────────
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
      builder: (context, child) =>
          erpPickerTheme(context, child, color: ErpColors.pink),
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
      builder: (context, child) =>
          erpPickerTheme(context, child, color: ErpColors.pink),
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

  // ── Save (ERP logic) ──────────────────────────────────────────────────────
  Future<void> _saveReminder() async {
    // Validate all fields first
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
        timeErr != null) {
      return;
    }

    // Collect all values before any async gap
    // ERP LeadModel uses leadId (int)
    final String leadId = _selectedLead!.leadId.toString();
    final String leadName = _selectedLead!.name;
    final String dateStr = _formatDateApi(selectedDate);
    final String timeStr = selectedTimeIso;
    final String subtype = _selectedSubtype;
    final String title = _titleCtrl.text.trim();
    final String? desc =
        _descCtrl.text.trim().isNotEmpty ? _descCtrl.text.trim() : null;

    final vm = context.read<ReminderViewmodel>();

    setState(() => _saving = true);

    try {
      // ✅ ERP ReminderViewmodel uses addReminder(ReminderModel)
      await vm.addReminder(ReminderModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        leadId: leadId,
        leadName: leadName,
        subject: title,
        type: subtype,
        date: dateStr,
        time: timeStr,
        notes: desc,
        status: 'scheduled',
        completed: false,
        phone: _selectedLead!.phone,
        email: _selectedLead!.emailId,
      ));

      if (!mounted) return;
      setState(() => _saving = false);
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      erpToast(context, 'Failed to create reminder: $e',
          color: ErpColors.red, icon: Icons.error_outline_rounded);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: ErpColors.pageBg,
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
                  padding: EdgeInsets.fromLTRB(sw * 0.04, 18, sw * 0.04,
                      MediaQuery.of(context).padding.bottom + 28),
                  child: Column(
                    children: [
                      // ── Select Lead ──────────────────────────────────────
                      ErpFadeIn(
                        index: 0,
                        child: _buildSection(
                          icon: Icons.person_rounded,
                          color: ErpColors.cyan,
                          title: 'Select Lead',
                          subtitle: 'Who should you be reminded about?',
                          children: [_buildLeadSelector()],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // ── Reminder Details ─────────────────────────────────
                      ErpFadeIn(
                        index: 1,
                        child: _buildSection(
                          icon: Icons.notifications_active_rounded,
                          color: ErpColors.pink,
                          title: 'Reminder Details',
                          subtitle: 'Title, type and description',
                          children: [_buildDetailsForm()],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // ── Schedule ─────────────────────────────────────────
                      ErpFadeIn(
                        index: 2,
                        child: _buildSection(
                          icon: Icons.schedule_rounded,
                          color: ErpColors.orange,
                          title: 'Schedule',
                          subtitle: 'When should we remind you?',
                          children: [_buildScheduleForm()],
                        ),
                      ),
                      const SizedBox(height: 22),

                      ErpFadeIn(index: 3, child: _buildActionButtons()),
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

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, double sw, double topPad) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: ErpColors.headerGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: ErpColors.cyan.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -34,
            top: -44,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 24,
            top: topPad + 6,
            child: Transform.rotate(
              angle: -0.25,
              child: Icon(Icons.notifications_active_rounded,
                  size: 86, color: Colors.white.withValues(alpha: 0.13)),
            ),
          ),
          Positioned(
            left: -26,
            bottom: -34,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: topPad + 12,
              bottom: 26,
              left: sw * 0.045,
              right: sw * 0.045,
            ),
            child: Row(
              children: [
                ErpPressable(
                  onTap: () => Navigator.pop(context),
                  child: const ErpGlassCircle(
                      icon: Icons.arrow_back_ios_new_rounded, iconSize: 19),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Add Reminder',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Set a reminder for a lead',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Section card ──────────────────────────────────────────────────────────
  Widget _buildSection({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: ErpColors.line),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ErpGradientTile(icon: icon, color: color, size: 40),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w900,
                        color: ErpColors.ink,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: ErpColors.slate),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, thickness: 1, color: ErpColors.line),
          ),
          ...children,
        ],
      ),
    );
  }

  // ── Text field widget ─────────────────────────────────────────────────────
  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isRequired = false,
    bool isOptional = false,
    String? hint,
    int maxLines = 1,
    String? error,
    void Function(String)? onChanged,
  }) {
    final hasError = error != null && error.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ErpFieldLabel(label, isRequired: isRequired, isOptional: isOptional),
          TextField(
            controller: controller,
            minLines: 1,
            maxLines: maxLines,
            cursorColor: ErpColors.pink,
            onChanged: onChanged,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: hasError ? ErpColors.red : ErpColors.ink,
            ),
            decoration: erpInputDecoration(
              hint: hint ?? 'Enter ${label.toLowerCase()}',
              icon: icon,
              hasError: hasError,
              color: ErpColors.pink,
            ),
          ),
          if (hasError) ErpErrorText(error),
        ],
      ),
    );
  }

  // ── Lead selector ─────────────────────────────────────────────────────────
  Widget _buildLeadSelector() {
    final hasError = _errLead != null && _errLead!.isNotEmpty;
    final lead = _selectedLead;
    final subValue = lead == null
        ? null
        : ((lead.emailId != null && lead.emailId!.isNotEmpty)
            ? lead.emailId!
            : lead.phone);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ErpPickerTile(
          icon: Icons.person_search_rounded,
          placeholder: 'Choose a lead',
          value: lead?.name,
          subValue: subValue,
          hasError: hasError,
          leading: lead != null ? _avatar(lead.name, 38) : null,
          onTap: _openSelectLeadSheet,
        ),
        if (hasError) ErpErrorText(_errLead!),
      ],
    );
  }

  // ── Details form (title, type, description) ───────────────────────────────
  Widget _buildDetailsForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Reminder Title
        _field(
          _titleCtrl,
          'Reminder Title',
          Icons.title_rounded,
          isRequired: true,
          hint: 'e.g. Call back about pricing',
          error: _errTitle,
          onChanged: (_) {
            if (_errTitle != null) setState(() => _errTitle = null);
          },
        ),

        // Reminder Type — fixed to "call" only (shown selected, not tappable)
        const ErpFieldLabel('Reminder Type'),
        IgnorePointer(
          child: ErpChoiceGrid(
            columns: 2,
            options: [
              ErpChoice(
                  _kCallSubtype.label, _kCallSubtype.icon, ErpColors.cyan),
            ],
            selected: _kCallSubtype.label,
            onSelect: (_) {},
          ),
        ),
        const SizedBox(height: 14),

        // Description (optional)
        _field(
          _descCtrl,
          'Description',
          Icons.notes_rounded,
          isOptional: true,
          hint: 'Any extra details',
          maxLines: 3,
        ),
      ],
    );
  }

  // ── Schedule form (date, time) ────────────────────────────────────────────
  Widget _buildScheduleForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ErpFieldLabel('Date & Time', isRequired: true),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ErpPickerTile(
                    icon: Icons.calendar_today_rounded,
                    placeholder: 'Pick a date',
                    value: _hasPickedDate
                        ? _formatDateDisplay(selectedDate)
                        : null,
                    hasError: _errDate != null,
                    color: ErpColors.orange,
                    onTap: _pickDate,
                  ),
                  if (_errDate != null) ErpErrorText(_errDate!),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ErpPickerTile(
                    icon: Icons.access_time_rounded,
                    placeholder: 'Pick a time',
                    value: _hasPickedTime && selectedTimeDisplay.isNotEmpty
                        ? selectedTimeDisplay
                        : null,
                    hasError: _errTime != null,
                    color: ErpColors.orange,
                    onTap: _pickTime,
                  ),
                  if (_errTime != null) ErpErrorText(_errTime!),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Action buttons ────────────────────────────────────────────────────────
  Widget _buildActionButtons() {
    return Column(
      children: [
        ErpPrimaryButton(
          text: 'Create Reminder',
          icon: Icons.notifications_active_rounded,
          loading: _saving,
          onTap: _saveReminder,
        ),
        const SizedBox(height: 12),
        ErpSecondaryButton(
          text: 'Cancel',
          onTap: () => Navigator.pop(context),
        ),
      ],
    );
  }
}