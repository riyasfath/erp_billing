import 'package:flutter/material.dart';
import 'package:pokakbilling/ERP_UI_KIT.dart';
import 'package:pokakbilling/models/data-models/lead_model.dart';
import 'package:pokakbilling/viewmodels/lead_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/followup_viewmodel.dart';
import 'package:provider/provider.dart';

class AddFollowUp extends StatefulWidget {
  const AddFollowUp({super.key});

  @override
  State<AddFollowUp> createState() => _AddFollowUpState();
}

class _AddFollowUpState extends State<AddFollowUp>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  LeadModel? _selectedLead;
  String _followupType = 'call';
  DateTime? _date;
  TimeOfDay? _time;
  bool _submitting = false;

  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _notesCtrl = TextEditingController();

  // ── Manual field errors — only shown on submit ────────────────────────────
  String? _errLead;
  String? _errTitle;
  String? _errDate;
  String? _errTime;

  // value sent to the API → chip shown in the UI.
  // ErpIcons.whatsapp renders the real WhatsApp logo.
  static const _typeOptions = [
    _TypeOption('call',
        ErpChoice('Phone Call', Icons.call_rounded, ErpColors.cyan)),
    _TypeOption('meeting',
        ErpChoice('Meeting', Icons.handshake_rounded, ErpColors.amber)),
    _TypeOption(
        'email', ErpChoice('Email', Icons.email_rounded, ErpColors.violet)),
    _TypeOption('whatsapp',
        ErpChoice('WhatsApp', ErpIcons.whatsapp, ErpColors.whatsapp)),
  ];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 550));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _titleCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) {
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
      'Dec'
    ];
    return '${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]} ${d.year}';
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Color _avatarColor(LeadModel l) =>
      ErpColors.rotation[l.leadId.hashCode.abs() % ErpColors.rotation.length];

  // ── Lead selector sheet ───────────────────────────────────────────────────
  Future<void> _openSelectLeadSheet() async {
    final vm = Provider.of<LeadViewmodel>(context, listen: false);

    final lead = await showModalBottomSheet<LeadModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.70,
            minChildSize: 0.40,
            maxChildSize: 0.95,
            builder: (_, controller) {
              return Column(
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
                  // ── Sheet header ─────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            ErpColors.cyan.withValues(alpha: 0.12),
                            ErpColors.cyan.withValues(alpha: 0.03),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: ErpColors.cyan.withValues(alpha: 0.18)),
                      ),
                      child: Row(
                        children: [
                          const ErpGradientTile(
                            icon: Icons.person_search_rounded,
                            color: ErpColors.cyan,
                            size: 44,
                          ),
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
                  // ── Lead list ────────────────────────────────────────
                  Expanded(
                    child: ListView.builder(
                      controller: controller,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(18, 4, 18, 20),
                      itemCount: vm.leadList.length,
                      itemBuilder: (_, i) {
                        final l = vm.leadList[i];
                        final isSelected = _selectedLead?.leadId == l.leadId;
                        final c = _avatarColor(l);
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
                                    ? ErpColors.cyan.withValues(alpha: 0.08)
                                    : ErpColors.pageBg,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? ErpColors.cyan.withValues(alpha: 0.6)
                                      : ErpColors.line,
                                  width: isSelected ? 1.4 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  _avatar(l, c, 40),
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
                                                ? ErpColors.cyanDeep
                                                : ErpColors.ink,
                                          ),
                                        ),
                                        const SizedBox(height: 1),
                                        Text(
                                          l.emailId?.isNotEmpty == true
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
                                      decoration: const BoxDecoration(
                                        gradient: ErpColors.headerGradient,
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
              );
            },
          ),
        );
      },
    );

    if (lead != null) {
      setState(() {
        _selectedLead = lead;
        if (_errLead != null) _errLead = null;
      });
    }
  }

  Widget _avatar(LeadModel l, Color c, double size) => Container(
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
            l.name.isNotEmpty ? l.name[0].toUpperCase() : 'L',
            style: TextStyle(
              fontSize: size * 0.4,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ),
      );

  // ── Date / Time pickers ───────────────────────────────────────────────────
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) => erpPickerTheme(context, child),
    );
    if (picked != null) {
      setState(() {
        _date = picked;
        if (_errDate != null) _errDate = null;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
      builder: (context, child) => erpPickerTheme(context, child),
    );
    if (picked != null) {
      setState(() {
        _time = picked;
        if (_errTime != null) _errTime = null;
      });
    }
  }

  // ── Submit ────────────────────────────────────────────────────────────────
  Future<void> _handleSubmit() async {
    final leadErr = _selectedLead == null ? 'Please select a lead' : null;
    final titleErr =
        _titleCtrl.text.trim().isEmpty ? 'Follow-up title is required' : null;
    final dateErr = _date == null ? 'Please choose a date' : null;
    final timeErr = _time == null ? 'Please choose a time' : null;

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
    setState(() => _submitting = true);

    try {
      final vm = Provider.of<FollowupViewmodel>(context, listen: false);

      final dateStr =
          '${_date!.year}-${_date!.month.toString().padLeft(2, '0')}-${_date!.day.toString().padLeft(2, '0')}';
      final timeStr =
          '${_time!.hour.toString().padLeft(2, '0')}:${_time!.minute.toString().padLeft(2, '0')}';

      final error = await vm.createFollowup(
        lead: _selectedLead!.leadId,
        title: _titleCtrl.text.trim(),
        date: dateStr,
        time: timeStr,
        status: 'new',
        type: _followupType,
        notes: _notesCtrl.text.trim(),
      );

      if (!mounted) return;
      setState(() => _submitting = false);

      if (error == null) {
        erpToast(context, 'Follow-up scheduled!', color: ErpColors.green);
        Navigator.of(context).pop(true);
      } else {
        erpToast(context, error,
            color: ErpColors.red, icon: Icons.error_outline_rounded);
      }
    } catch (e) {
      if (mounted) setState(() => _submitting = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: ErpColors.pageBg,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
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
                        MediaQuery.of(context).padding.bottom + 24),
                    child: Column(
                      children: [
                        // ── Select Lead ───────────────────────────────────
                        ErpFadeIn(
                          index: 0,
                          child: _buildSection(
                            icon: Icons.person_rounded,
                            color: ErpColors.cyan,
                            title: 'Select Lead',
                            subtitle: 'Who is this follow-up for?',
                            children: [_buildLeadSelector()],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // ── Follow-up Details ─────────────────────────────
                        ErpFadeIn(
                          index: 1,
                          child: _buildSection(
                            icon: Icons.event_note_rounded,
                            color: ErpColors.violet,
                            title: 'Follow-up Details',
                            subtitle: 'Title, type and notes',
                            children: [
                              const ErpFieldLabel('Follow-up Title',
                                  isRequired: true),
                              _field(
                                _titleCtrl,
                                'e.g. Discuss pricing',
                                Icons.title_rounded,
                                error: _errTitle,
                                onChanged: (_) {
                                  if (_errTitle != null) {
                                    setState(() => _errTitle = null);
                                  }
                                },
                              ),
                              const SizedBox(height: 14),
                              const ErpFieldLabel('Type'),
                              _buildTypeSelector(),
                              const SizedBox(height: 14),
                              const ErpFieldLabel('Notes', isOptional: true),
                              _field(
                                _notesCtrl,
                                'Any additional notes',
                                Icons.notes_rounded,
                                maxLines: 3,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // ── Schedule ──────────────────────────────────────
                        ErpFadeIn(
                          index: 2,
                          child: _buildSection(
                            icon: Icons.schedule_rounded,
                            color: ErpColors.orange,
                            title: 'Schedule',
                            subtitle: 'When should you follow up?',
                            children: [
                              const ErpFieldLabel('Date', isRequired: true),
                              ErpPickerTile(
                                icon: Icons.calendar_today_rounded,
                                placeholder: 'Pick a date',
                                value:
                                    _date != null ? _formatDate(_date!) : null,
                                hasError: _errDate != null,
                                color: ErpColors.orange,
                                onTap: _pickDate,
                              ),
                              if (_errDate != null) ErpErrorText(_errDate!),
                              const SizedBox(height: 14),
                              const ErpFieldLabel('Time', isRequired: true),
                              ErpPickerTile(
                                icon: Icons.access_time_rounded,
                                placeholder: 'Pick a time',
                                value:
                                    _time != null ? _formatTime(_time!) : null,
                                hasError: _errTime != null,
                                color: ErpColors.orange,
                                onTap: _pickTime,
                              ),
                              if (_errTime != null) ErpErrorText(_errTime!),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),
                        ErpFadeIn(
                          index: 3,
                          child: ErpPrimaryButton(
                            text: 'Create Follow-up',
                            icon: Icons.event_available_rounded,
                            loading: _submitting,
                            onTap: _handleSubmit,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
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
              child: Icon(Icons.event_repeat_rounded,
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
                        'Add Follow-up',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Schedule a follow-up activity',
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
    String hint,
    IconData icon, {
    String? error,
    int maxLines = 1,
    void Function(String)? onChanged,
  }) {
    final hasError = error != null && error.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          cursorColor: ErpColors.cyan,
          onChanged: onChanged,
          minLines: 1,
          maxLines: maxLines,
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
            color: hasError ? ErpColors.red : ErpColors.ink,
          ),
          decoration:
              erpInputDecoration(hint: hint, icon: icon, hasError: hasError),
        ),
        if (hasError) ErpErrorText(error),
      ],
    );
  }

  // ── Type selector grid ────────────────────────────────────────────────────
  Widget _buildTypeSelector() {
    final selectedLabel = _typeOptions
        .firstWhere((o) => o.value == _followupType,
            orElse: () => _typeOptions.first)
        .choice
        .label;

    return ErpChoiceGrid(
      columns: 2,
      options: _typeOptions.map((o) => o.choice).toList(),
      selected: selectedLabel,
      onSelect: (label) {
        final opt = _typeOptions.firstWhere((o) => o.choice.label == label);
        setState(() => _followupType = opt.value);
      },
    );
  }

  // ── Lead selector ─────────────────────────────────────────────────────────
  Widget _buildLeadSelector() {
    final hasError = _errLead != null && _errLead!.isNotEmpty;
    final lead = _selectedLead;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ErpPickerTile(
          icon: Icons.person_search_rounded,
          placeholder: 'Choose a lead',
          value: lead?.name,
          subValue: lead?.phone,
          hasError: hasError,
          onTap: _openSelectLeadSheet,
          leading: lead != null ? _avatar(lead, _avatarColor(lead), 38) : null,
        ),
        if (hasError) ErpErrorText(_errLead!),
      ],
    );
  }
}

class _TypeOption {
  final String value;
  final ErpChoice choice;
  const _TypeOption(this.value, this.choice);
}