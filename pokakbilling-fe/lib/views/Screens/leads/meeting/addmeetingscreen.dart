import 'package:flutter/material.dart';
import 'package:pokakbilling/ERP_UI_KIT.dart';
import 'package:provider/provider.dart';
import 'package:pokakbilling/viewmodels/lead_viewmodel.dart';
import 'package:pokakbilling/viewmodels/meeting_viewmodel.dart';
import 'package:pokakbilling/models/data-models/lead_model.dart';

class AddMeetingScreen extends StatefulWidget {
  const AddMeetingScreen({super.key});

  @override
  State<AddMeetingScreen> createState() => _AddMeetingScreenState();
}

class _AddMeetingScreenState extends State<AddMeetingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  LeadModel? _selectedLead;

  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  final TextEditingController _locationCtrl = TextEditingController();

  bool _hasPickedDate = false;
  bool _hasPickedTime = false;
  String _meetingType = 'Video Call';

  // ── Manual field errors ───────────────────────────────────────────────────
  String? _errLead;
  String? _errTitle;
  String? _errDate;
  String? _errTime;

  static const _meetingTypes = [
    ErpChoice('Video Call', Icons.videocam_rounded, ErpColors.blue),
    ErpChoice('In-Person', Icons.handshake_rounded, ErpColors.amber),
    ErpChoice('Phone Call', Icons.call_rounded, ErpColors.cyan),
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
      final pv = Provider.of<MeetingViewmodel>(context, listen: false);
      pv.selectedDate = DateTime.now();
      if (pv.timeSlots.isNotEmpty) {
        pv.selectedTime = pv.timeSlots[0];
      }
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

  // ── Lead picker sheet ─────────────────────────────────────────────────────
  Future<void> _openSelectLeadSheet() async {
    final vm = Provider.of<LeadViewmodel>(context, listen: false);

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

              // Sheet header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        ErpColors.blue.withValues(alpha: 0.12),
                        ErpColors.blue.withValues(alpha: 0.03),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: ErpColors.blue.withValues(alpha: 0.18)),
                  ),
                  child: Row(
                    children: [
                      const ErpGradientTile(
                          icon: Icons.person_search_rounded,
                          color: ErpColors.blue,
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
                              '${vm.leadList.length} leads',
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

              // Lead list — uses ERP's leadId + emailId
              Expanded(
                child: ListView.builder(
                  controller: controller,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 4, 18, 20),
                  itemCount: vm.leadList.length,
                  itemBuilder: (_, i) {
                    final l = vm.leadList[i];
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
                                ? ErpColors.blue.withValues(alpha: 0.08)
                                : ErpColors.pageBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? ErpColors.blue.withValues(alpha: 0.6)
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                                ErpColors.blue, 0.15)
                                            : ErpColors.ink,
                                      ),
                                    ),
                                    const SizedBox(height: 1),
                                    // ERP uses emailId not email
                                    Text(
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
                                      ErpColors.tint(ErpColors.blue, 0.2),
                                      ErpColors.blue
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
  Future<void> _pickDate(MeetingViewmodel pv) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: pv.selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
      builder: (context, child) =>
          erpPickerTheme(context, child, color: ErpColors.blue),
    );
    if (picked != null) {
      pv.updateDate(picked);
      setState(() {
        _hasPickedDate = true;
        if (_errDate != null) _errDate = null;
      });
    }
  }

  Future<void> _pickTime(MeetingViewmodel pv) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) =>
          erpPickerTheme(context, child, color: ErpColors.blue),
    );
    if (picked != null) {
      final hh = picked.hour.toString().padLeft(2, '0');
      final mm = picked.minute.toString().padLeft(2, '0');
      pv.updateTimeIndex('$hh:$mm', 0);
      setState(() {
        _hasPickedTime = true;
        if (_errTime != null) _errTime = null;
      });
    }
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')} ${_monthAbbr(d.month)} ${d.year}';

  String _monthAbbr(int m) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[m - 1];
  }

  // ── Submit — wires to ERP's createMeetingSchedule ─────────────────────────
  void _scheduleMeeting() async {
    final pv = Provider.of<MeetingViewmodel>(context, listen: false);
    if (pv.createLoading) return;

    final leadErr = _selectedLead == null ? 'Please select a lead' : null;
    final titleErr =
        _titleCtrl.text.trim().isEmpty ? 'Meeting title is required' : null;
    final dateErr = !_hasPickedDate ? 'Please choose a date' : null;
    final timeErr = !_hasPickedTime ? 'Please choose a time' : null;

    setState(() {
      _errLead = leadErr;
      _errTitle = titleErr;
      _errDate = dateErr;
      _errTime = timeErr;
    });

    if (leadErr != null ||
        titleErr != null ||
        dateErr != null ||
        timeErr != null) {
      return;
    }

    FocusScope.of(context).unfocus();

    // Format date and time for ERP's API
    final dateIso = pv.selectedDate.toIso8601String().substring(0, 10);
    final raw = pv.selectedTime;
    String apiTime;
    if (RegExp(r'^\d{2}:\d{2}:\d{2}$').hasMatch(raw)) {
      apiTime = raw;
    } else if (RegExp(r'^\d{2}:\d{2}$').hasMatch(raw)) {
      apiTime = '$raw:00';
    } else {
      apiTime = '$raw:00';
    }

    // ERP's createMeetingSchedule uses leadId (int), not lead.id
    await pv.createMeetingSchedule(
      _selectedLead!.leadId,
      dateIso,
      apiTime,
      pv.selectedStatusKey.isEmpty ? 'scheduled' : pv.selectedStatusKey,
      _titleCtrl.text.trim(),
      context,
      meetingPlace: _locationCtrl.text.trim().isNotEmpty
          ? _locationCtrl.text.trim()
          : null,
      description:
          _descCtrl.text.trim().isNotEmpty ? _descCtrl.text.trim() : null,
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final topPad = MediaQuery.of(context).padding.top;

    return Consumer2<MeetingViewmodel, LeadViewmodel>(
      builder: (context, pv, leadProv, child) {
        final dateText = _hasPickedDate ? _formatDate(pv.selectedDate) : null;
        final timeText = _hasPickedTime ? pv.selectedTime : null;

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
                          ErpFadeIn(
                            index: 0,
                            child: _buildSection(
                              icon: Icons.person_rounded,
                              color: ErpColors.cyan,
                              title: 'Select Lead',
                              subtitle: 'Who are you meeting?',
                              children: [_buildLeadSelector(leadProv)],
                            ),
                          ),
                          const SizedBox(height: 14),
                          ErpFadeIn(
                            index: 1,
                            child: _buildSection(
                              icon: Icons.event_note_rounded,
                              color: ErpColors.violet,
                              title: 'Meeting Details',
                              subtitle: 'Title, type and agenda',
                              children: [_buildDetailsForm(pv)],
                            ),
                          ),
                          const SizedBox(height: 14),
                          ErpFadeIn(
                            index: 2,
                            child: _buildSection(
                              icon: Icons.schedule_rounded,
                              color: ErpColors.orange,
                              title: 'Schedule',
                              subtitle: 'When and where',
                              children: [
                                _buildScheduleForm(pv, dateText, timeText)
                              ],
                            ),
                          ),
                          const SizedBox(height: 22),
                          ErpFadeIn(
                            index: 3,
                            child: _buildActionButtons(pv),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
              child: Icon(Icons.video_camera_front_rounded,
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
                        'Add Meeting',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Schedule a new meeting',
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

  // ── Text field ────────────────────────────────────────────────────────────
  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isRequired = false,
    bool isOptional = false,
    String? hint,
    TextInputType? keyboardType,
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
            keyboardType: keyboardType,
            minLines: 1,
            maxLines: maxLines,
            cursorColor: ErpColors.blue,
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
              color: ErpColors.blue,
            ),
          ),
          if (hasError) ErpErrorText(error),
        ],
      ),
    );
  }

  // ── Lead selector ─────────────────────────────────────────────────────────
  Widget _buildLeadSelector(LeadViewmodel leadProv) {
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
          onTap: leadProv.leadList.isEmpty
              ? () => erpToast(context, 'No leads available',
                  color: ErpColors.red, icon: Icons.error_outline_rounded)
              : _openSelectLeadSheet,
        ),
        if (hasError) ErpErrorText(_errLead!),
      ],
    );
  }

  // ── Details form ──────────────────────────────────────────────────────────
  Widget _buildDetailsForm(MeetingViewmodel pv) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _field(
          _titleCtrl,
          'Meeting Title',
          Icons.title_rounded,
          isRequired: true,
          hint: 'e.g. Product demo',
          error: _errTitle,
          onChanged: (_) {
            if (_errTitle != null) setState(() => _errTitle = null);
          },
        ),

        // Meeting type
        const ErpFieldLabel('Meeting Type'),
        ErpChoiceGrid(
          columns: 3,
          options: _meetingTypes,
          selected: _meetingType,
          onSelect: (v) => setState(() => _meetingType = v),
        ),
        const SizedBox(height: 14),

        // Description
        _field(
          _descCtrl,
          'Description / Agenda',
          Icons.notes_rounded,
          isOptional: true,
          hint: 'What will you discuss?',
          maxLines: 3,
        ),
      ],
    );
  }

  // ── Schedule form ─────────────────────────────────────────────────────────
  Widget _buildScheduleForm(
      MeetingViewmodel pv, String? dateText, String? timeText) {
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
                    value: dateText,
                    hasError: _errDate != null,
                    color: ErpColors.orange,
                    onTap: () => _pickDate(pv),
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
                    value: timeText,
                    hasError: _errTime != null,
                    color: ErpColors.orange,
                    onTap: () => _pickTime(pv),
                  ),
                  if (_errTime != null) ErpErrorText(_errTime!),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _field(
          _locationCtrl,
          'Location / Meeting Link',
          Icons.location_on_rounded,
          isOptional: true,
          hint: 'Address or https://meet.google.com/…',
        ),
      ],
    );
  }

  // ── Action buttons ────────────────────────────────────────────────────────
  Widget _buildActionButtons(MeetingViewmodel pv) {
    final isLoading = pv.createLoading;

    return Column(
      children: [
        ErpPrimaryButton(
          text: 'Schedule Meeting',
          icon: Icons.event_available_rounded,
          loading: isLoading,
          onTap: _scheduleMeeting,
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