import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pokakbilling/ERP_UI_KIT.dart';
import 'package:pokakbilling/models/data-models/lead_model.dart';
import 'package:pokakbilling/models/data-models/reminder_model.dart';
import 'package:pokakbilling/viewmodels/lead_viewmodel.dart';
import 'package:pokakbilling/viewmodels/meeting_viewmodel.dart';
import 'package:pokakbilling/viewmodels/reminder/reminder_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/followup_viewmodel.dart';
import 'package:pokakbilling/views/Screens/leads/lead_screens/myactivityscreen.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

// ─── ERP data maps (API value → label) ───────────────────────────────────────
const Map<String, String> _kFollowupTypes = {
  'call': 'Phone Call',
  'meeting': 'Meeting',
  'email': 'Email',
  'whatsapp': 'WhatsApp',
};

const Map<String, String> _kReminderModes = {
  'call': 'Phone Call',
};

const Map<String, String> _kMeetingStatuses = {
  'scheduled': 'Scheduled',
  'completed': 'Completed',
};

// Icon + colour for every option label used on this screen.
// ErpIcons.whatsapp renders the real WhatsApp logo.
(IconData, Color) _optionStyle(String label) {
  switch (label) {
    case 'Meeting':
      return (Icons.videocam_rounded, ErpColors.blue);
    case 'Email':
      return (Icons.email_rounded, ErpColors.violet);
    case 'Call':
    case 'Phone Call':
      return (Icons.call_rounded, ErpColors.cyan);
    case 'WhatsApp':
      return (ErpIcons.whatsapp, ErpColors.whatsapp);
    case 'Follow-up':
      return (Icons.event_repeat_rounded, ErpColors.orange);
    case 'Reminder':
      return (Icons.notifications_active_rounded, ErpColors.pink);
    case 'Scheduled':
      return (Icons.event_available_rounded, ErpColors.blue);
    case 'Completed':
      return (Icons.check_circle_rounded, ErpColors.green);
    default:
      return (Icons.event_note_rounded, ErpColors.cyan);
  }
}

class NewActivityScreen extends StatefulWidget {
  const NewActivityScreen({super.key});
  @override
  State<NewActivityScreen> createState() => _NewActivityScreenState();
}

class _NewActivityScreenState extends State<NewActivityScreen>
    with SingleTickerProviderStateMixin {
  String selectedActivity = 'Meeting';

  final List<String> _activityTypes = [
    'Meeting',
    'Email',
    'Call',
    'WhatsApp',
    'Follow-up',
    'Reminder',
  ];

  // ── Selected lead (ERP LeadModel fields) ──────────────────────────────────
  int? _selectedLeadId;
  String _selectedLeadName = '';
  String _selectedLeadCompany = '';
  String _selectedLeadStatus = '';
  String _selectedLeadPhone = '';
  String _selectedLeadEmail = '';
  final TextEditingController _leadSearchCtrl = TextEditingController();
  String _leadSearch = '';
  String? _errLead;

  // ── Meeting ────────────────────────────────────────────────────────────────
  final _meetingTitleCtrl = TextEditingController();
  final _meetingDescCtrl = TextEditingController();
  final _meetingLocationCtrl = TextEditingController();
  final _meetingSubtypeCtrl = TextEditingController();
  String _meetingStatus = 'scheduled';
  DateTime? _selectedMeetingDate;
  TimeOfDay? _selectedMeetingTime;
  bool _meetingSubmitting = false;
  String? _errMeetingTitle, _errLocation, _errMeetingDate, _errMeetingTime;

  // ── Email ──────────────────────────────────────────────────────────────────
  final _emailSubjectCtrl = TextEditingController();
  final _emailMessageCtrl = TextEditingController();
  String? _errEmailSubject;

  // ── WhatsApp ───────────────────────────────────────────────────────────────
  final _waMessageCtrl = TextEditingController();

  // ── Follow-up ──────────────────────────────────────────────────────────────
  String _followupType = 'call';
  final _followupTitleCtrl = TextEditingController();
  final _followupDescCtrl = TextEditingController();
  DateTime? _followupDate;
  TimeOfDay? _followupTime;
  bool _followupSubmitting = false;
  String? _errFollowTitle, _errFollowupDate, _errFollowupTime;

  // ── Reminder ───────────────────────────────────────────────────────────────
  final _reminderTitleCtrl = TextEditingController();
  final _reminderDetailsCtrl = TextEditingController();
  final _reminderLocationCtrl = TextEditingController();
  String _reminderMode = 'call';
  DateTime? _reminderDate;
  TimeOfDay? _reminderTime;
  bool _reminderSaving = false;
  String? _errReminderTitle, _errReminderDate, _errReminderTime;

  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 550));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final lv = context.read<LeadViewmodel>();
      if (lv.leadList.isEmpty) lv.getAllLeads();
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _meetingTitleCtrl.dispose();
    _meetingDescCtrl.dispose();
    _meetingLocationCtrl.dispose();
    _meetingSubtypeCtrl.dispose();
    _emailSubjectCtrl.dispose();
    _emailMessageCtrl.dispose();
    _waMessageCtrl.dispose();
    _followupTitleCtrl.dispose();
    _followupDescCtrl.dispose();
    _reminderTitleCtrl.dispose();
    _reminderDetailsCtrl.dispose();
    _reminderLocationCtrl.dispose();
    _leadSearchCtrl.dispose();
    super.dispose();
  }

  // ── URL / location validation (ERP) ────────────────────────────────────────
  bool _isValidLocationInput(String input) {
    if (input.isEmpty) return true;
    final looksLikeUrl =
        input.contains('://') || input.toLowerCase().startsWith('www.');
    if (!looksLikeUrl) return true;
    final normalised =
        input.toLowerCase().startsWith('www.') ? 'https://$input' : input;
    final uri = Uri.tryParse(normalised);
    if (uri == null || !uri.hasAuthority) return false;
    const allowedSchemes = {
      'https',
      'http',
      'meet',
      'zoom',
      'msteams',
      'webex'
    };
    if (!allowedSchemes.contains(uri.scheme)) return false;
    if (uri.host.isEmpty || !uri.host.contains('.')) return false;
    return true;
  }

  // ── Launchers ──────────────────────────────────────────────────────────────
  Future<void> _openDialer(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _openEmail(
      {required String to, String subject = '', String body = ''}) async {
    final uri = Uri(
      scheme: 'mailto',
      path: to,
      queryParameters: {
        if (subject.isNotEmpty) 'subject': subject,
        if (body.isNotEmpty) 'body': body,
      },
    );
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _launchWhatsApp(
      {required String phone, String message = ''}) async {
    final cleaned = phone.replaceAll(RegExp(r'\D'), '');
    final encoded = Uri.encodeComponent(message);
    final url =
        'https://wa.me/$cleaned${message.isNotEmpty ? '?text=$encoded' : ''}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  // ── General helpers ────────────────────────────────────────────────────────
  void _snack(String msg, {bool isError = false}) {
    erpToast(
      context,
      msg,
      color: isError ? ErpColors.red : ErpColors.cyanDeep,
      icon: isError ? Icons.error_outline_rounded : Icons.check_circle_rounded,
    );
  }

  void _goOrganizer() => Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MyOrganizerScreen()),
        (route) => route.isFirst,
      );

  String _fmtApi(DateTime d) => DateFormat('yyyy-MM-dd').format(d);
  String _fmtDisplay(DateTime d) => DateFormat('dd-MM-yyyy').format(d);

  String? _dateLabel(DateTime? d) => d == null ? null : _fmtDisplay(d);
  String? _timeLabel(TimeOfDay? t) => t == null ? null : t.format(context);

  Color get _activityColor => _optionStyle(selectedActivity).$2;

  // ── Generic date/time pickers ──────────────────────────────────────────────
  Future<DateTime?> _pickDateGeneric(DateTime? initial) => showDatePicker(
        context: context,
        initialDate: initial ?? DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime(2100),
        builder: (ctx, child) =>
            erpPickerTheme(ctx, child, color: _activityColor),
      );

  Future<TimeOfDay?> _pickTimeGeneric(TimeOfDay? initial) => showTimePicker(
        context: context,
        initialTime: initial ?? TimeOfDay.now(),
        builder: (ctx, child) =>
            erpPickerTheme(ctx, child, color: _activityColor),
      );

  Future<void> _pickMeetingDate() async {
    final p = await _pickDateGeneric(_selectedMeetingDate);
    if (p != null) {
      setState(() {
        _selectedMeetingDate = p;
        _errMeetingDate = null;
      });
    }
  }

  Future<void> _pickMeetingTime() async {
    final p = await _pickTimeGeneric(_selectedMeetingTime);
    if (p != null) {
      setState(() {
        _selectedMeetingTime = p;
        _errMeetingTime = null;
      });
    }
  }

  Future<void> _pickFollowupDate() async {
    final p = await _pickDateGeneric(_followupDate);
    if (p != null) {
      setState(() {
        _followupDate = p;
        _errFollowupDate = null;
      });
    }
  }

  Future<void> _pickFollowupTime() async {
    final p = await _pickTimeGeneric(_followupTime);
    if (p != null) {
      setState(() {
        _followupTime = p;
        _errFollowupTime = null;
      });
    }
  }

  Future<void> _pickReminderDate() async {
    final p = await _pickDateGeneric(_reminderDate);
    if (p != null) {
      setState(() {
        _reminderDate = p;
        _errReminderDate = null;
      });
    }
  }

  Future<void> _pickReminderTime() async {
    final p = await _pickTimeGeneric(_reminderTime);
    if (p != null) {
      setState(() {
        _reminderTime = p;
        _errReminderTime = null;
      });
    }
  }

  // ══════════════════════════════════════════════════════════════════════
  // SUBMIT HANDLERS (ERP logic, unchanged behavior)
  // ══════════════════════════════════════════════════════════════════════

  Future<void> _scheduleMeeting() async {
    final leadErr =
        _selectedLeadId == null ? 'Please choose a lead first' : null;
    final titleErr = _meetingTitleCtrl.text.trim().isEmpty
        ? 'Meeting title is required'
        : null;
    final locationErr = !_isValidLocationInput(_meetingLocationCtrl.text.trim())
        ? 'Enter a valid URL (e.g. https://meet.google.com/abc-xyz)'
        : null;
    final dateErr =
        _selectedMeetingDate == null ? 'Please choose a date' : null;
    final timeErr =
        _selectedMeetingTime == null ? 'Please choose a time' : null;

    setState(() {
      _errLead = leadErr;
      _errMeetingTitle = titleErr;
      _errLocation = locationErr;
      _errMeetingDate = dateErr;
      _errMeetingTime = timeErr;
    });

    if (leadErr != null ||
        titleErr != null ||
        locationErr != null ||
        dateErr != null ||
        timeErr != null) {
      return;
    }

    setState(() => _meetingSubmitting = true);
    try {
      final vm = context.read<MeetingViewmodel>();
      final timeIso =
          '${_selectedMeetingTime!.hour.toString().padLeft(2, '0')}:${_selectedMeetingTime!.minute.toString().padLeft(2, '0')}:00';
      await vm.createMeetingSchedule(
        _selectedLeadId!,
        _fmtApi(_selectedMeetingDate!),
        timeIso,
        _meetingStatus,
        _meetingTitleCtrl.text.trim(),
        context,
        meetingPlace: _meetingLocationCtrl.text.trim().isNotEmpty
            ? _meetingLocationCtrl.text.trim()
            : null,
        description: _meetingDescCtrl.text.trim().isNotEmpty
            ? _meetingDescCtrl.text.trim()
            : null,
      );
      if (mounted) {
        _snack('📅 Meeting scheduled!');
        _goOrganizer();
      }
    } catch (e) {
      if (mounted) _snack('Failed: $e', isError: true);
    } finally {
      if (mounted) setState(() => _meetingSubmitting = false);
    }
  }

  Future<void> _composeEmail() async {
    final leadErr =
        _selectedLeadId == null ? 'Please choose a lead first' : null;
    final subjectErr = _emailSubjectCtrl.text.trim().isEmpty
        ? 'Email subject is required'
        : null;

    setState(() {
      _errLead = leadErr;
      _errEmailSubject = subjectErr;
    });

    if (leadErr != null || subjectErr != null) return;
    if (_selectedLeadEmail.isEmpty) {
      _snack('No email for this lead', isError: true);
      return;
    }
    await _openEmail(
      to: _selectedLeadEmail,
      subject: _emailSubjectCtrl.text.trim(),
      body: _emailMessageCtrl.text.trim(),
    );
    if (mounted) {
      _snack('Email opened!');
      _goOrganizer();
    }
  }

  Future<void> _callNow() async {
    if (_selectedLeadId == null) {
      setState(() => _errLead = 'Please choose a lead first');
      return;
    }
    final cleaned = _selectedLeadPhone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleaned.isEmpty) {
      _snack('No phone for this lead', isError: true);
      return;
    }
    await _openDialer(cleaned);
    if (mounted) _goOrganizer();
  }

  Future<void> _openWhatsApp() async {
    if (_selectedLeadId == null) {
      setState(() => _errLead = 'Please choose a lead first');
      return;
    }
    final cleaned = _selectedLeadPhone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleaned.isEmpty) {
      _snack('No phone for this lead', isError: true);
      return;
    }
    await _launchWhatsApp(phone: cleaned, message: _waMessageCtrl.text.trim());
    if (mounted) _goOrganizer();
  }

  Future<void> _scheduleFollowup() async {
    final leadErr =
        _selectedLeadId == null ? 'Please choose a lead first' : null;
    final titleErr = _followupTitleCtrl.text.trim().isEmpty
        ? 'Follow-up title is required'
        : null;
    final dateErr = _followupDate == null ? 'Please choose a date' : null;
    final timeErr = _followupTime == null ? 'Please choose a time' : null;

    setState(() {
      _errLead = leadErr;
      _errFollowTitle = titleErr;
      _errFollowupDate = dateErr;
      _errFollowupTime = timeErr;
    });

    if (leadErr != null ||
        titleErr != null ||
        dateErr != null ||
        timeErr != null) {
      return;
    }

    setState(() => _followupSubmitting = true);
    final vm = context.read<FollowupViewmodel>();
    final error = await vm.createFollowup(
      lead: _selectedLeadId!,
      title: _followupTitleCtrl.text.trim(),
      date: _fmtApi(_followupDate!),
      time: '${_followupTime!.hour.toString().padLeft(2, '0')}'
          ':${_followupTime!.minute.toString().padLeft(2, '0')}',
      status: 'new',
      type: _followupType,
      notes: _followupDescCtrl.text.trim(),
    );
    setState(() => _followupSubmitting = false);
    if (!mounted) return;
    if (error == null) {
      _snack('🔁 Follow-up scheduled!');
      _goOrganizer();
    } else {
      _snack(error, isError: true);
    }
  }

  Future<void> _saveReminder() async {
    final leadErr =
        _selectedLeadId == null ? 'Please choose a lead first' : null;
    final titleErr = _reminderTitleCtrl.text.trim().isEmpty
        ? 'Reminder title is required'
        : null;
    final dateErr = _reminderDate == null ? 'Please choose a date' : null;
    final timeErr = _reminderTime == null ? 'Please choose a time' : null;

    setState(() {
      _errLead = leadErr;
      _errReminderTitle = titleErr;
      _errReminderDate = dateErr;
      _errReminderTime = timeErr;
    });

    if (leadErr != null ||
        titleErr != null ||
        dateErr != null ||
        timeErr != null) {
      return;
    }

    setState(() => _reminderSaving = true);
    try {
      final vm = context.read<ReminderViewmodel>();
      await vm.addReminder(ReminderModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        leadId: _selectedLeadId!.toString(),
        leadName: _selectedLeadName,
        subject: _reminderTitleCtrl.text.trim(),
        type: _reminderMode,
        date: _fmtApi(_reminderDate!),
        time:
            '${_reminderTime!.hour.toString().padLeft(2, '0')}:${_reminderTime!.minute.toString().padLeft(2, '0')}:00',
        notes: _reminderDetailsCtrl.text.trim(),
        status: 'scheduled',
        completed: false,
        phone: _selectedLeadPhone,
        email: _selectedLeadEmail,
      ));
      if (!mounted) return;
      _snack('🔔 Reminder set!');
      _goOrganizer();
    } catch (e) {
      if (mounted) _snack('Failed: $e', isError: true);
    } finally {
      if (mounted) setState(() => _reminderSaving = false);
    }
  }

  // ══════════════════════════════════════════════════════════════════════
  // LEAD SHEET
  // ══════════════════════════════════════════════════════════════════════
  Color _leadStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'CONVERTED':
        return ErpColors.green;
      case 'LOST':
        return ErpColors.red;
      case 'NEW':
        return ErpColors.cyan;
      default:
        return ErpColors.amber;
    }
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
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: size * 0.4),
        ),
      ),
    );
  }

  void _openLeadSheet() {
    _leadSearch = '';
    _leadSearchCtrl.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(builder: (ctx, setSheet) {
        return Consumer<LeadViewmodel>(builder: (_, lvm, __) {
          final q = _leadSearch.toLowerCase();
          final leads = q.isEmpty
              ? lvm.leadList
              : lvm.leadList.where((l) {
                  return l.name.toLowerCase().contains(q) ||
                      (l.company ?? '').toLowerCase().contains(q) ||
                      l.phone.toLowerCase().contains(q);
                }).toList();

          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetCtx).viewInsets.bottom),
            child: Container(
              height: MediaQuery.of(context).size.height * .78,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(children: [
                Container(
                  width: 44,
                  height: 5,
                  margin: const EdgeInsets.only(top: 10, bottom: 14),
                  decoration: BoxDecoration(
                      color: ErpColors.line,
                      borderRadius: BorderRadius.circular(3)),
                ),
                // ── Sheet header ──────────────────────────────────────
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
                    child: Row(children: [
                      const ErpGradientTile(
                          icon: Icons.person_search_rounded,
                          color: ErpColors.cyan,
                          size: 44),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Choose a Lead',
                                style: TextStyle(
                                    color: ErpColors.ink,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900)),
                            Text('${lvm.leadList.length} leads',
                                style: const TextStyle(
                                    color: ErpColors.slate, fontSize: 13)),
                          ],
                        ),
                      ),
                      if (lvm.getLeadLoader)
                        const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  color: ErpColors.cyan, strokeWidth: 2)),
                        ),
                      ErpPressable(
                        onTap: () => Navigator.pop(sheetCtx),
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
                    ]),
                  ),
                ),
                const SizedBox(height: 12),
                // ── Search ────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: TextField(
                    controller: _leadSearchCtrl,
                    cursorColor: ErpColors.cyan,
                    style: const TextStyle(
                        color: ErpColors.ink,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                    decoration: erpInputDecoration(
                        hint: 'Search by name, company, phone…',
                        icon: Icons.search_rounded),
                    onChanged: (v) => setSheet(() => _leadSearch = v),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: leads.isEmpty
                      ? Center(
                          child: ErpEmptyState(
                            icon: lvm.getLeadLoader
                                ? Icons.hourglass_top_rounded
                                : Icons.inbox_rounded,
                            title: lvm.getLeadLoader
                                ? 'Loading leads…'
                                : 'No leads found',
                            subtitle: lvm.getLeadLoader
                                ? 'Please wait a moment'
                                : 'Try a different search',
                          ),
                        )
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(18, 6, 18, 20),
                          itemCount: leads.length,
                          itemBuilder: (_, i) => _leadTile(leads[i], sheetCtx),
                        ),
                ),
              ]),
            ),
          );
        });
      }),
    );
  }

  Widget _leadTile(LeadModel lead, BuildContext sheetCtx) {
    final isSelected = _selectedLeadId == lead.leadId;
    final statusColor = _leadStatusColor(lead.leadStatus);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ErpPressable(
        scale: 0.98,
        onTap: () {
          setState(() {
            _selectedLeadId = lead.leadId;
            _selectedLeadName = lead.name;
            _selectedLeadCompany = lead.company ?? '';
            _selectedLeadStatus = lead.leadStatus;
            _selectedLeadPhone = lead.phone;
            _selectedLeadEmail = lead.emailId ?? '';
            _errLead = null;
          });
          Navigator.pop(sheetCtx);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isSelected
                ? ErpColors.cyan.withValues(alpha: .08)
                : ErpColors.pageBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: isSelected
                    ? ErpColors.cyan.withValues(alpha: .6)
                    : ErpColors.line,
                width: isSelected ? 1.4 : 1),
          ),
          child: Row(children: [
            _avatar(lead.name, 42),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(lead.name,
                        style: TextStyle(
                            color: isSelected
                                ? ErpColors.cyanDeep
                                : ErpColors.ink,
                            fontWeight: FontWeight.w800,
                            fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    if ((lead.company ?? '').isNotEmpty) ...[
                      const SizedBox(height: 1),
                      Text(lead.company!,
                          style: const TextStyle(
                              color: ErpColors.slate,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                    if (lead.phone.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Row(children: [
                        const Icon(Icons.call_rounded,
                            size: 11, color: ErpColors.cyan),
                        const SizedBox(width: 4),
                        Text(lead.phone,
                            style: const TextStyle(
                                color: ErpColors.slate, fontSize: 11.5)),
                      ]),
                    ],
                    if ((lead.emailId ?? '').isNotEmpty) ...[
                      const SizedBox(height: 1),
                      Row(children: [
                        const Icon(Icons.email_rounded,
                            size: 11, color: ErpColors.violet),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(lead.emailId!,
                              style: const TextStyle(
                                  color: ErpColors.slate, fontSize: 11.5),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ]),
                    ],
                  ]),
            ),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (lead.leadStatus.isNotEmpty)
                  ErpStatusChip(
                      label: erpTitleCase(lead.leadStatus),
                      color: statusColor),
                if (isSelected) ...[
                  const SizedBox(height: 6),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      gradient: ErpColors.headerGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_rounded,
                        color: Colors.white, size: 15),
                  ),
                ],
              ],
            ),
          ]),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final top = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: ErpColors.pageBg,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(children: [
          _buildHeader(context, sw, top),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(sw * .04, 18, sw * .04,
                      MediaQuery.of(context).padding.bottom + 24),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ErpFadeIn(index: 0, child: _buildTypeSection()),
                        const SizedBox(height: 14),
                        ErpFadeIn(index: 1, child: _buildLeadSection()),
                        const SizedBox(height: 14),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 260),
                          switchInCurve: Curves.easeOut,
                          transitionBuilder: (child, anim) => FadeTransition(
                            opacity: anim,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                      begin: const Offset(0, 0.04),
                                      end: Offset.zero)
                                  .animate(anim),
                              child: child,
                            ),
                          ),
                          child: KeyedSubtree(
                            key: ValueKey(selectedActivity),
                            child: _buildDynamicForm(),
                          ),
                        ),
                      ]),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // HEADER
  // ─────────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, double sw, double top) {
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
      child: Stack(children: [
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
          top: top + 6,
          child: Transform.rotate(
            angle: -0.25,
            child: Icon(Icons.edit_calendar_rounded,
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
              top: top + 12, bottom: 26, left: sw * .045, right: sw * .045),
          child: Row(children: [
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
                    const Text('New Organizer Task',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900)),
                    const SizedBox(height: 2),
                    Text('Schedule & log tasks',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14)),
                  ]),
            ),
          ]),
        ),
      ]),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // SECTION CARD
  // ─────────────────────────────────────────────────────────────────────
  Widget _buildSection({
    required IconData icon,
    required String title,
    String? subtitle,
    Color color = ErpColors.cyan,
    required List<Widget> children,
    Widget? trailing,
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
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          ErpGradientTile(icon: icon, color: color, size: 40),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w900,
                        color: ErpColors.ink)),
                if ((subtitle ?? '').isNotEmpty)
                  Text(subtitle!,
                      style: const TextStyle(
                          fontSize: 12, color: ErpColors.slate)),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ]),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 14),
          child: Divider(height: 1, thickness: 1, color: ErpColors.line),
        ),
        ...children,
      ]),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // TEXT FIELD (label above + kit decoration)
  // ─────────────────────────────────────────────────────────────────────
  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isRequired = false,
    bool isOptional = false,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? error,
    void Function(String)? onChanged,
    String? hint,
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
            cursorColor: _activityColor,
            onChanged: onChanged,
            style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: hasError ? ErpColors.red : ErpColors.ink),
            decoration: erpInputDecoration(
              hint: hint ?? 'Enter ${label.toLowerCase()}',
              icon: icon,
              hasError: hasError,
              color: _activityColor,
            ),
          ),
          if (hasError) ErpErrorText(error),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // CHOICE FIELD (replaces dropdowns — same value maps)
  // ─────────────────────────────────────────────────────────────────────
  Widget _choiceField({
    required String label,
    required String value,
    required Map<String, String> items,
    required ValueChanged<String?> onChanged,
    int columns = 2,
  }) {
    final choices = items.values.map((l) {
      final (icon, color) = _optionStyle(l);
      return ErpChoice(l, icon, color);
    }).toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ErpFieldLabel(label),
          ErpChoiceGrid(
            columns: columns,
            options: choices,
            selected: items[value] ?? '',
            onSelect: (lbl) {
              final key = items.entries
                  .firstWhere((e) => e.value == lbl,
                      orElse: () => MapEntry(value, lbl))
                  .key;
              onChanged(key);
            },
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // READ-ONLY CONTACT INFO TILE
  // ─────────────────────────────────────────────────────────────────────
  Widget _contactInfoTile({
    required String label,
    required IconData icon,
    required Color color,
    required String value,
    required String emptyLabel,
  }) {
    final hasValue = value.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ErpFieldLabel(label),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: hasValue ? color.withValues(alpha: 0.06) : ErpColors.pageBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: hasValue
                      ? color.withValues(alpha: .55)
                      : ErpColors.line,
                  width: hasValue ? 1.4 : 1),
            ),
            child: Row(children: [
              hasValue
                  ? ErpGradientTile(icon: icon, color: color, size: 32)
                  : Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: ErpColors.slate.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: erpIcon(icon,
                            size: 16,
                            color: ErpColors.slate.withValues(alpha: .5)),
                      ),
                    ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  hasValue ? value : emptyLabel,
                  style: TextStyle(
                      fontSize: 14.5,
                      color: hasValue
                          ? ErpColors.ink
                          : ErpColors.slate.withValues(alpha: 0.75),
                      fontWeight: hasValue ? FontWeight.w700 : FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (!hasValue)
                Text('Select lead first',
                    style: TextStyle(
                        color: ErpColors.slate.withValues(alpha: .6),
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
            ]),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // DATE / TIME ROW
  // ─────────────────────────────────────────────────────────────────────
  Widget _dateTimeRow({
    required String? dateValue,
    required String? timeValue,
    required VoidCallback onDateTap,
    required VoidCallback onTimeTap,
    String? dateError,
    String? timeError,
  }) {
    final color = _activityColor;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ErpFieldLabel('Date & Time', isRequired: true),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ErpPickerTile(
                    icon: Icons.calendar_today_rounded,
                    placeholder: 'Select Date',
                    value: dateValue,
                    hasError: dateError != null && dateError.isNotEmpty,
                    color: color,
                    onTap: onDateTap,
                  ),
                  if (dateError != null && dateError.isNotEmpty)
                    ErpErrorText(dateError),
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
                    placeholder: 'Select Time',
                    value: timeValue,
                    hasError: timeError != null && timeError.isNotEmpty,
                    color: color,
                    onTap: onTimeTap,
                  ),
                  if (timeError != null && timeError.isNotEmpty)
                    ErpErrorText(timeError),
                ],
              ),
            ),
          ]),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // SAVE / SUBMIT BUTTON (supports the real WhatsApp logo)
  // ─────────────────────────────────────────────────────────────────────
  Widget _saveBar({
    required String label,
    required IconData icon,
    required bool loading,
    required VoidCallback onTap,
  }) {
    final color = _activityColor;
    return ErpPressable(
      onTap: loading ? null : onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: loading ? 0.75 : 1,
        child: Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [ErpColors.tint(color, 0.18), color],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.38),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.2))
                : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    erpIcon(icon, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(label,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.3)),
                  ]),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // TYPE SELECTOR SECTION
  // ─────────────────────────────────────────────────────────────────────
  Widget _buildTypeSection() {
    return _buildSection(
      icon: Icons.category_rounded,
      title: 'Task Type',
      subtitle: 'What do you want to do?',
      children: [
        ErpChoiceGrid(
          columns: 3,
          options: _activityTypes.map((t) {
            final (icon, color) = _optionStyle(t);
            return ErpChoice(t, icon, color);
          }).toList(),
          selected: selectedActivity,
          onSelect: (type) => setState(() => selectedActivity = type),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // LEAD SELECTOR SECTION
  // ─────────────────────────────────────────────────────────────────────
  Widget _buildLeadSection() {
    final hasLeadError = _errLead != null && _errLead!.isNotEmpty;

    return _buildSection(
      icon: Icons.person_rounded,
      title: 'Lead',
      subtitle: 'Who is this task for?',
      color: ErpColors.cyan,
      trailing: const Padding(
        padding: EdgeInsets.only(right: 2),
        child: Icon(Icons.circle, size: 7, color: ErpColors.red),
      ),
      children: [
        _selectedLeadId != null
            ? _selectedLeadCard()
            : ErpPickerTile(
                icon: Icons.person_add_alt_1_rounded,
                placeholder: 'Choose a Lead',
                value: null,
                hasError: hasLeadError,
                onTap: _openLeadSheet,
              ),
        if (hasLeadError) ErpErrorText(_errLead!),
      ],
    );
  }

  Widget _selectedLeadCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ErpColors.cyan.withValues(alpha: .10),
            ErpColors.cyan.withValues(alpha: .03),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: ErpColors.cyan.withValues(alpha: .35), width: 1.2),
      ),
      child: Row(children: [
        _avatar(_selectedLeadName, 46),
        const SizedBox(width: 12),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Flexible(
                child: Text(_selectedLeadName,
                    style: const TextStyle(
                        color: ErpColors.ink,
                        fontWeight: FontWeight.w900,
                        fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
              if (_selectedLeadStatus.isNotEmpty) ...[
                const SizedBox(width: 6),
                ErpStatusChip(
                    label: erpTitleCase(_selectedLeadStatus),
                    color: _leadStatusColor(_selectedLeadStatus)),
              ],
            ]),
            if (_selectedLeadCompany.isNotEmpty)
              Text(_selectedLeadCompany,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: ErpColors.slate,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            if (_selectedLeadPhone.isNotEmpty) ...[
              const SizedBox(height: 3),
              Row(children: [
                const Icon(Icons.call_rounded, size: 12, color: ErpColors.cyan),
                const SizedBox(width: 4),
                Text(_selectedLeadPhone,
                    style: const TextStyle(
                        color: ErpColors.slate, fontSize: 12)),
              ]),
            ],
            if (_selectedLeadEmail.isNotEmpty) ...[
              const SizedBox(height: 2),
              Row(children: [
                const Icon(Icons.email_rounded,
                    size: 12, color: ErpColors.violet),
                const SizedBox(width: 4),
                Expanded(
                    child: Text(_selectedLeadEmail,
                        style: const TextStyle(
                            color: ErpColors.slate, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis)),
              ]),
            ],
          ]),
        ),
        const SizedBox(width: 6),
        Column(children: [
          ErpPressable(
            onTap: _openLeadSheet,
            child: Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                  gradient: ErpColors.headerGradient, shape: BoxShape.circle),
              child:
                  const Icon(Icons.edit_rounded, color: Colors.white, size: 15),
            ),
          ),
          const SizedBox(height: 6),
          ErpPressable(
            onTap: () => setState(() {
              _selectedLeadId = null;
              _selectedLeadName = '';
              _selectedLeadCompany = '';
              _selectedLeadStatus = '';
              _selectedLeadPhone = '';
              _selectedLeadEmail = '';
            }),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                  color: ErpColors.red.withValues(alpha: .12),
                  shape: BoxShape.circle),
              child: const Icon(Icons.close_rounded,
                  color: ErpColors.red, size: 16),
            ),
          ),
        ]),
      ]),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  // DYNAMIC FORM ROUTER
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildDynamicForm() {
    switch (selectedActivity) {
      case 'Meeting':
        return _meetingForm();
      case 'Email':
        return _emailForm();
      case 'Call':
        return _callForm();
      case 'WhatsApp':
        return _whatsappForm();
      case 'Follow-up':
        return _followUpForm();
      case 'Reminder':
        return _reminderForm();
      default:
        return const SizedBox();
    }
  }

  // ─────────────────────────────────────────────────────────────────────
  // MEETING FORM
  // ─────────────────────────────────────────────────────────────────────
  Widget _meetingForm() {
    return _buildSection(
      icon: Icons.videocam_rounded,
      color: ErpColors.blue,
      title: 'Schedule Meeting',
      subtitle: 'Title, place and time',
      children: [
        _field(
          _meetingTitleCtrl,
          'Meeting Title',
          Icons.title_rounded,
          isRequired: true,
          hint: 'Enter meeting title',
          error: _errMeetingTitle,
          onChanged: (_) {
            if (_errMeetingTitle != null) {
              setState(() => _errMeetingTitle = null);
            }
          },
        ),
        _field(_meetingDescCtrl, 'Description', Icons.notes_rounded,
            isOptional: true, hint: 'What is this meeting about?', maxLines: 3),
        _field(_meetingSubtypeCtrl, 'Meet Type', Icons.category_rounded,
            isOptional: true, hint: 'e.g. Video Call'),
        _choiceField(
          label: 'Status',
          value: _meetingStatus,
          items: _kMeetingStatuses,
          onChanged: (v) {
            if (v != null) setState(() => _meetingStatus = v);
          },
        ),
        _field(
          _meetingLocationCtrl,
          'Address or Video Link',
          Icons.link_rounded,
          isOptional: true,
          hint: 'Enter address or link',
          error: _errLocation,
          onChanged: (_) {
            if (_errLocation != null) setState(() => _errLocation = null);
          },
        ),
        _dateTimeRow(
          dateValue: _dateLabel(_selectedMeetingDate),
          timeValue: _timeLabel(_selectedMeetingTime),
          onDateTap: _pickMeetingDate,
          onTimeTap: _pickMeetingTime,
          dateError: _errMeetingDate,
          timeError: _errMeetingTime,
        ),
        const SizedBox(height: 4),
        _saveBar(
          label: 'Schedule Meeting',
          icon: Icons.videocam_rounded,
          loading: _meetingSubmitting,
          onTap: _scheduleMeeting,
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // EMAIL FORM
  // ─────────────────────────────────────────────────────────────────────
  Widget _emailForm() {
    return _buildSection(
      icon: Icons.email_rounded,
      color: ErpColors.violet,
      title: 'Log Email',
      subtitle: 'Opens your mail app',
      children: [
        _contactInfoTile(
          label: 'To',
          icon: Icons.email_rounded,
          color: ErpColors.violet,
          value: _selectedLeadEmail,
          emptyLabel: 'Lead email',
        ),
        _field(
          _emailSubjectCtrl,
          'Subject',
          Icons.subject_rounded,
          isRequired: true,
          hint: 'Enter email subject',
          error: _errEmailSubject,
          onChanged: (_) {
            if (_errEmailSubject != null) {
              setState(() => _errEmailSubject = null);
            }
          },
        ),
        _field(_emailMessageCtrl, 'Message', Icons.message_rounded,
            isOptional: true, hint: 'Write your message', maxLines: 4),
        const SizedBox(height: 4),
        _saveBar(
          label: 'Log & Open Gmail',
          icon: Icons.email_rounded,
          loading: false,
          onTap: _composeEmail,
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // CALL FORM
  // ─────────────────────────────────────────────────────────────────────
  Widget _callForm() {
    return _buildSection(
      icon: Icons.call_rounded,
      color: ErpColors.cyan,
      title: 'Log Call',
      subtitle: 'Opens your phone dialer',
      children: [
        _contactInfoTile(
          label: 'Calling',
          icon: Icons.call_rounded,
          color: ErpColors.cyan,
          value: _selectedLeadPhone,
          emptyLabel: 'Lead phone',
        ),
        const SizedBox(height: 4),
        _saveBar(
          label: 'Log & Call Now',
          icon: Icons.call_rounded,
          loading: false,
          onTap: _callNow,
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // WHATSAPP FORM
  // ─────────────────────────────────────────────────────────────────────
  Widget _whatsappForm() {
    return _buildSection(
      icon: ErpIcons.whatsapp,
      color: ErpColors.whatsapp,
      title: 'Log WhatsApp',
      subtitle: 'Opens a WhatsApp chat',
      children: [
        _contactInfoTile(
          label: 'Sending To',
          icon: ErpIcons.whatsapp,
          color: ErpColors.whatsapp,
          value: _selectedLeadPhone,
          emptyLabel: 'Lead phone',
        ),
        _field(_waMessageCtrl, 'Message', Icons.message_rounded,
            isOptional: true, hint: 'Type a message', maxLines: 3),
        const SizedBox(height: 4),
        _saveBar(
          label: 'Log & Open WhatsApp',
          icon: ErpIcons.whatsapp,
          loading: false,
          onTap: _openWhatsApp,
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // FOLLOW-UP FORM
  // ─────────────────────────────────────────────────────────────────────
  Widget _followUpForm() {
    return _buildSection(
      icon: Icons.event_repeat_rounded,
      color: ErpColors.orange,
      title: 'Schedule Follow-up',
      subtitle: 'Title, type and time',
      children: [
        _field(
          _followupTitleCtrl,
          'Follow-up Title',
          Icons.title_rounded,
          isRequired: true,
          hint: 'Enter follow-up title',
          error: _errFollowTitle,
          onChanged: (_) {
            if (_errFollowTitle != null) setState(() => _errFollowTitle = null);
          },
        ),
        _choiceField(
          label: 'Type',
          value: _followupType,
          items: _kFollowupTypes,
          onChanged: (v) {
            if (v != null) setState(() => _followupType = v);
          },
        ),
        _field(_followupDescCtrl, 'Notes', Icons.notes_rounded,
            isOptional: true, hint: 'Any additional notes', maxLines: 3),
        _dateTimeRow(
          dateValue: _dateLabel(_followupDate),
          timeValue: _timeLabel(_followupTime),
          onDateTap: _pickFollowupDate,
          onTimeTap: _pickFollowupTime,
          dateError: _errFollowupDate,
          timeError: _errFollowupTime,
        ),
        const SizedBox(height: 4),
        _saveBar(
          label: 'Schedule Follow-up',
          icon: Icons.event_repeat_rounded,
          loading: _followupSubmitting,
          onTap: _scheduleFollowup,
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // REMINDER FORM
  // ─────────────────────────────────────────────────────────────────────
  Widget _reminderForm() {
    return _buildSection(
      icon: Icons.notifications_active_rounded,
      color: ErpColors.pink,
      title: 'Set Reminder',
      subtitle: 'Get notified at the right time',
      children: [
        _field(
          _reminderTitleCtrl,
          'What to be reminded?',
          Icons.notifications_rounded,
          isRequired: true,
          hint: 'Enter reminder title',
          error: _errReminderTitle,
          onChanged: (_) {
            if (_errReminderTitle != null) {
              setState(() => _errReminderTitle = null);
            }
          },
        ),
        _field(_reminderDetailsCtrl, 'Additional Details', Icons.notes_rounded,
            isOptional: true, hint: 'Any extra details', maxLines: 3),
        _choiceField(
          label: 'Reminder Type',
          value: _reminderMode,
          items: _kReminderModes,
          columns: 2,
          onChanged: (v) {
            if (v != null) setState(() => _reminderMode = v);
          },
        ),
        _field(_reminderLocationCtrl, 'Address / Video Link',
            Icons.link_rounded,
            isOptional: true, hint: 'Enter address or link'),
        _dateTimeRow(
          dateValue: _dateLabel(_reminderDate),
          timeValue: _timeLabel(_reminderTime),
          onDateTap: _pickReminderDate,
          onTimeTap: _pickReminderTime,
          dateError: _errReminderDate,
          timeError: _errReminderTime,
        ),
        const SizedBox(height: 4),
        _saveBar(
          label: 'Set Reminder',
          icon: Icons.notifications_active_rounded,
          loading: _reminderSaving,
          onTap: _saveReminder,
        ),
      ],
    );
  }
}