import 'package:flutter/material.dart';
import 'package:pokakbilling/ERP_UI_KIT.dart';
import 'package:pokakbilling/models/data-models/followup_model.dart';
import 'package:pokakbilling/models/data-models/meeting_model.dart';
import 'package:pokakbilling/models/data-models/reminder_model.dart';
import 'package:pokakbilling/models/data-models/lead_model.dart';
import 'package:pokakbilling/viewmodels/setup/followup_viewmodel.dart';
import 'package:pokakbilling/viewmodels/meeting_viewmodel.dart';
import 'package:pokakbilling/viewmodels/reminder/reminder_viewmodel.dart';
import 'package:pokakbilling/viewmodels/lead_viewmodel.dart';
import 'package:pokakbilling/views/Screens/leads/lead_screens/leadsviewscreen.dart';
import 'package:pokakbilling/views/Screens/leads/lead_screens/newActivityScreen.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

// ══════════════════════════════════════════════════════════════════════════
// STATIC FILTER PERSISTENCE (mirrors CRM _ActivityFilterState)
// ══════════════════════════════════════════════════════════════════════════
class _OrganizerFilterState {
  static int tab = 0;
  static String search = '';
  static String typeFilter = 'All Types';
  static DateTime? dateFilter;
  static int currentPage = 0;
}

const int _kPageSize = 10;

const _kMonths = [
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

class MyOrganizerScreen extends StatefulWidget {
  const MyOrganizerScreen({super.key});
  @override
  State<MyOrganizerScreen> createState() => _MyOrganizerScreenState();
}

class _MyOrganizerScreenState extends State<MyOrganizerScreen>
    with TickerProviderStateMixin {
  late int _tab;
  late String _search;
  late String _typeFilter;
  late DateTime? _dateFilter;
  late int _currentPage;

  final _searchCtrl = TextEditingController();

  static const _tabs = [
    (label: 'All', key: 'all'),
    (label: 'Upcoming', key: 'upcoming'),
    (label: 'Completed', key: 'completed'),
    (label: 'Overdue', key: 'overdue'),
  ];

  static const _tabColors = [
    ErpColors.cyan,
    ErpColors.amber,
    ErpColors.green,
    ErpColors.red,
  ];

  static const _typeOptions = ['All Types', 'Meeting', 'Follow-up', 'Reminder'];
  static const _typeApiMap = {
    'Meeting': 'meeting',
    'Follow-up': 'followup',
    'Reminder': 'reminder',
  };

  late final AnimationController _hCtrl, _bCtrl;
  late final Animation<double> _hFade, _bFade;
  late final Animation<Offset> _hSlide, _bSlide;

  @override
  void initState() {
    super.initState();

    _tab = _OrganizerFilterState.tab;
    _search = _OrganizerFilterState.search;
    _typeFilter = _OrganizerFilterState.typeFilter;
    _dateFilter = _OrganizerFilterState.dateFilter;
    _currentPage = _OrganizerFilterState.currentPage;

    _searchCtrl.text = _search;
    _searchCtrl.addListener(() {
      final v = _searchCtrl.text.toLowerCase();
      setState(() {
        _search = v;
        _currentPage = 0;
        _OrganizerFilterState.search = v;
        _OrganizerFilterState.currentPage = 0;
      });
    });

    _hCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 550));
    _hFade = CurvedAnimation(parent: _hCtrl, curve: Curves.easeOut);
    _hSlide = Tween<Offset>(begin: const Offset(0, -0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: _hCtrl, curve: Curves.easeOut));

    _bCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 550));
    _bFade = CurvedAnimation(parent: _bCtrl, curve: Curves.easeOut);
    _bSlide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _bCtrl, curve: Curves.easeOut));

    _hCtrl.forward();
    Future.delayed(const Duration(milliseconds: 160), () => _bCtrl.forward());

    Future.microtask(() {
      Provider.of<FollowupViewmodel>(context, listen: false).fetchFollowups();
      Provider.of<MeetingViewmodel>(context, listen: false).getAllMeetings();
      final reminderVm = Provider.of<ReminderViewmodel>(context, listen: false);
      if (reminderVm.reminders.isEmpty) reminderVm.fetchReminders();
      final leadVm = Provider.of<LeadViewmodel>(context, listen: false);
      if (leadVm.leadList.isEmpty) leadVm.getAllLeads();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _hCtrl.dispose();
    _bCtrl.dispose();
    super.dispose();
  }

  void _setTab(int t) => setState(() {
        _tab = t;
        _currentPage = 0;
        _OrganizerFilterState.tab = t;
        _OrganizerFilterState.currentPage = 0;
      });

  void _setTypeFilter(String v) => setState(() {
        _typeFilter = v;
        _currentPage = 0;
        _OrganizerFilterState.typeFilter = v;
        _OrganizerFilterState.currentPage = 0;
      });

  void _setDateFilter(DateTime? d) => setState(() {
        _dateFilter = d;
        _currentPage = 0;
        _OrganizerFilterState.dateFilter = d;
        _OrganizerFilterState.currentPage = 0;
      });

  void _setPage(int p) => setState(() {
        _currentPage = p;
        _OrganizerFilterState.currentPage = p;
      });

  void _resetFilters() {
    _searchCtrl.clear();
    setState(() {
      _search = '';
      _typeFilter = 'All Types';
      _dateFilter = null;
      _tab = 0;
      _currentPage = 0;
      _OrganizerFilterState.search = '';
      _OrganizerFilterState.typeFilter = 'All Types';
      _OrganizerFilterState.dateFilter = null;
      _OrganizerFilterState.tab = 0;
      _OrganizerFilterState.currentPage = 0;
    });
  }

  // ── Snackbar ───────────────────────────────────────────────────────────────
  void _snack(String msg, {bool isError = false}) {
    if (!mounted) return;
    erpToast(
      context,
      msg,
      color: isError ? ErpColors.red : ErpColors.cyanDeep,
      icon: isError ? Icons.error_outline_rounded : Icons.check_circle_rounded,
    );
  }

  // ── Launchers ──────────────────────────────────────────────────────────────
  Future<void> _launchCall(String phone) async {
    final cleaned = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleaned.isEmpty) {
      _snack('No phone number available', isError: true);
      return;
    }
    final uri = Uri(scheme: 'tel', path: cleaned);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _snack('Could not open dialer', isError: true);
    }
  }

  Future<void> _launchEmail(String email) async {
    final cleaned = email.trim();
    if (cleaned.isEmpty) {
      _snack('No email address available', isError: true);
      return;
    }
    final uri = Uri(scheme: 'mailto', path: cleaned);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _snack('Could not open email app', isError: true);
    }
  }

  Future<void> _launchWhatsApp(String phone) async {
    final cleaned = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleaned.isEmpty) {
      _snack('No phone number available', isError: true);
      return;
    }
    final uri = Uri.parse('https://wa.me/$cleaned');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _snack('Could not open WhatsApp', isError: true);
    }
  }

  Future<void> _launchMeet(String location) async {
    final loc = location.trim();
    final hasLink = loc.startsWith('http') || loc.startsWith('www.');
    if (hasLink) {
      final uri = Uri.parse(loc.startsWith('http') ? loc : 'https://$loc');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }
    }
    await launchUrl(Uri.parse('https://meet.google.com'),
        mode: LaunchMode.externalApplication);
  }

  // ── Kind helpers (kind = 'meeting' | 'followup' | 'reminder') ──────────────
  Color _kindColor(String k) {
    switch (k) {
      case 'meeting':
        return ErpColors.blue;
      case 'followup':
        return ErpColors.violet;
      case 'reminder':
        return ErpColors.pink;
      default:
        return ErpColors.cyan;
    }
  }

  IconData _kindIcon(String k) {
    switch (k) {
      case 'meeting':
        return Icons.videocam_rounded;
      case 'followup':
        return Icons.event_repeat_rounded;
      case 'reminder':
        return Icons.notifications_active_rounded;
      default:
        return Icons.event_note_rounded;
    }
  }

  String _kindLabel(String k) {
    switch (k) {
      case 'meeting':
        return 'Meeting';
      case 'followup':
        return 'Follow-up';
      case 'reminder':
        return 'Reminder';
      default:
        return k;
    }
  }

  Color _typeOptionColor(String t) {
    switch (t) {
      case 'Meeting':
        return ErpColors.blue;
      case 'Follow-up':
        return ErpColors.violet;
      case 'Reminder':
        return ErpColors.pink;
      default:
        return ErpColors.cyan;
    }
  }

  IconData _typeOptionIcon(String t) {
    switch (t) {
      case 'Meeting':
        return Icons.videocam_rounded;
      case 'Follow-up':
        return Icons.event_repeat_rounded;
      case 'Reminder':
        return Icons.notifications_active_rounded;
      default:
        return Icons.apps_rounded;
    }
  }

  Color _statusColor(bool completed, bool overdue) {
    if (completed) return ErpColors.green;
    if (overdue) return ErpColors.red;
    return ErpColors.amber;
  }

  IconData _statusIcon(bool completed, bool overdue) {
    if (completed) return Icons.check_circle_rounded;
    if (overdue) return Icons.warning_rounded;
    return Icons.hourglass_empty_rounded;
  }

  String _statusLabel(bool completed, bool overdue) {
    if (completed) return 'Completed';
    if (overdue) return 'Overdue';
    return 'Pending';
  }

  bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _fullDateLabel(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')} ${_kMonths[d.month - 1]} ${d.year}';

  // ── Date parsing ─────────────────────────────────────────────────────────
  DateTime? _parseDate(String? s) {
    if (s == null || s.trim().isEmpty) return null;
    try {
      return DateTime.parse(s);
    } catch (_) {
      try {
        final parts = s.split(RegExp(r'[-/\s]'));
        if (parts.length == 3) {
          if (parts[0].length == 4) {
            return DateTime(int.tryParse(parts[0]) ?? 1970,
                int.tryParse(parts[1]) ?? 1, int.tryParse(parts[2]) ?? 1);
          } else {
            return DateTime(int.tryParse(parts[2]) ?? 1970,
                int.tryParse(parts[1]) ?? 1, int.tryParse(parts[0]) ?? 1);
          }
        }
      } catch (_) {}
    }
    return null;
  }

  String _prettyDate(String? s) {
    final d = _parseDate(s);
    if (d == null) return s ?? '';
    return '${d.day.toString().padLeft(2, '0')} ${_kMonths[d.month - 1]} ${d.year}';
  }

  // ── Build merged items from the three ERP sources ──────────────────────────
  List<Map<String, dynamic>> _buildAllItems(
    List<FollowupModel> followups,
    List<MeetingModel> meetings,
    List<ReminderModel> reminders,
    List<LeadModel> leads,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final list = <Map<String, dynamic>>[];

    for (final f in followups) {
      final date = _parseDate(f.date);
      final isCompleted = f.status.toLowerCase() == 'completed';
      final isOverdue = !isCompleted && date != null && date.isBefore(today);
      final isToday = !isCompleted && date != null && _isSameDate(date, today);
      final isUpcoming =
          !isCompleted && date != null && date.isAfter(today) && !isToday;
      final lead = leads.firstWhere(
        (l) => l.leadId == f.lead,
        orElse: () => LeadModel(
          leadId: 0,
          name: '',
          phone: '',
          enquiry: '',
          leadNumber: '',
          leadStatus: '',
          notes: '',
          createdAt: '',
          date: '',
        ),
      );
      list.add({
        'kind': 'followup',
        'date': f.date,
        'time': f.time ?? '',
        'isCompleted': isCompleted,
        'isOverdue': isOverdue,
        'isUpcoming': isUpcoming,
        'title': f.title.isNotEmpty ? f.title : 'Follow-up',
        'leadName': lead.name.isNotEmpty ? lead.name : 'Lead #${f.lead}',
        'phone': lead.phone,
        'email': lead.emailId ?? '',
        'location': '',
        'description': f.notes,
        'item': f,
        'lead': lead,
      });
    }

    for (final m in meetings) {
      final date = _parseDate(m.date);
      final isCompleted = m.status.toLowerCase() == 'completed';
      final isOverdue = !isCompleted && date != null && date.isBefore(today);
      final isToday = !isCompleted && date != null && _isSameDate(date, today);
      final isUpcoming =
          !isCompleted && date != null && date.isAfter(today) && !isToday;
      LeadModel? lead;
      for (final l in leads) {
        if (l.leadId == m.leadId) {
          lead = l;
          break;
        }
      }
      if (lead == null && m.leadName.isNotEmpty) {
        for (final l in leads) {
          if (l.name == m.leadName) {
            lead = l;
            break;
          }
        }
      }
      list.add({
        'kind': 'meeting',
        'date': m.date,
        'time': m.time,
        'isCompleted': isCompleted,
        'isOverdue': isOverdue,
        'isUpcoming': isUpcoming,
        'title': m.title.isNotEmpty ? m.title : 'Meeting',
        'leadName': m.leadName.isNotEmpty ? m.leadName : (lead?.name ?? 'Lead'),
        'phone': m.phone.isNotEmpty ? m.phone : (lead?.phone ?? ''),
        'email': lead?.emailId ?? '',
        'location': m.meetingPlace ?? '',
        'description': m.description ?? '',
        'item': m,
        'lead': lead,
      });
    }

    for (final r in reminders) {
      final date = _parseDate(r.date);
      final isCompleted = r.completed;
      final isOverdue = !isCompleted && date != null && date.isBefore(today);
      final isToday = !isCompleted && date != null && _isSameDate(date, today);
      final isUpcoming =
          !isCompleted && date != null && date.isAfter(today) && !isToday;
      final leadIdInt = int.tryParse(r.leadId?.trim() ?? '');
      LeadModel? lead;
      if (leadIdInt != null) {
        for (final l in leads) {
          if (l.leadId == leadIdInt) {
            lead = l;
            break;
          }
        }
      }
      final leadName = (r.leadName != null &&
              r.leadName!.trim().isNotEmpty &&
              int.tryParse(r.leadName!.trim()) == null)
          ? r.leadName!
          : (lead?.name ?? 'Lead #${r.leadId}');
      list.add({
        'kind': 'reminder',
        'date': r.date ?? '',
        'time': r.time ?? '',
        'isCompleted': isCompleted,
        'isOverdue': isOverdue,
        'isUpcoming': isUpcoming,
        'title': (r.subject?.isNotEmpty == true) ? r.subject! : 'Reminder',
        'leadName': leadName,
        'phone': r.phone?.isNotEmpty == true ? r.phone! : (lead?.phone ?? ''),
        'email': r.email?.isNotEmpty == true ? r.email! : (lead?.emailId ?? ''),
        'location': '',
        'description': r.notes ?? '',
        'item': r,
        'lead': lead,
      });
    }

    list.sort((a, b) {
      final da = _parseDate(a['date'] as String?) ?? DateTime(2100);
      final db = _parseDate(b['date'] as String?) ?? DateTime(2100);
      return da.compareTo(db);
    });
    return list;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final top = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: ErpColors.pageBg,
      body: Column(children: [
        FadeTransition(
          opacity: _hFade,
          child: SlideTransition(
            position: _hSlide,
            child: _buildHeader(context, sw, top),
          ),
        ),
        Expanded(
          child: FadeTransition(
            opacity: _bFade,
            child: SlideTransition(
              position: _bSlide,
              child: Column(children: [
                _buildFilterCard(),
                Expanded(child: _buildList()),
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
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
          right: 104,
          top: top + 4,
          child: Transform.rotate(
            angle: -0.25,
            child: Icon(Icons.event_note_rounded,
                size: 86, color: Colors.white.withValues(alpha: 0.12)),
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
              top: top + 12, bottom: 24, left: sw * .045, right: sw * .045),
          child: Row(children: [
            ErpPressable(
              onTap: () {
                _resetFilters();
                Navigator.pop(context);
              },
              child: const ErpGlassCircle(
                  icon: Icons.arrow_back_ios_new_rounded, iconSize: 19),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Consumer3<FollowupViewmodel, MeetingViewmodel,
                  ReminderViewmodel>(
                builder: (_, fVm, mVm, rVm, __) {
                  final leadVm = Provider.of<LeadViewmodel>(context);
                  final all = _buildAllItems(fVm.followups, mVm.meetingList,
                      rVm.reminders, leadVm.leadList);
                  final total = all.length;
                  final overdue =
                      all.where((a) => a['isOverdue'] == true).length;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('My Organizer',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w900)),
                      const SizedBox(height: 3),
                      Row(children: [
                        Text('$total tasks',
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 14)),
                        if (overdue > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              const Icon(Icons.warning_amber_rounded,
                                  size: 12, color: ErpColors.red),
                              const SizedBox(width: 3),
                              Text('$overdue overdue',
                                  style: const TextStyle(
                                      color: ErpColors.red,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800)),
                            ]),
                          ),
                        ],
                      ]),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            ErpPressable(
              onTap: () async {
                _resetFilters();
                await Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const NewActivityScreen()));
                if (mounted) {
                  Provider.of<FollowupViewmodel>(context, listen: false)
                      .fetchFollowups();
                  Provider.of<MeetingViewmodel>(context, listen: false)
                      .getAllMeetings();
                  Provider.of<ReminderViewmodel>(context, listen: false)
                      .fetchReminders();
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: ErpColors.cyanDeep.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, color: ErpColors.cyanDeep, size: 18),
                    SizedBox(width: 4),
                    Text('New',
                        style: TextStyle(
                            color: ErpColors.cyanDeep,
                            fontSize: 13,
                            fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  // ── Filter card ────────────────────────────────────────────────────────────
  Widget _buildFilterCard() {
    return Consumer3<FollowupViewmodel, MeetingViewmodel, ReminderViewmodel>(
        builder: (_, fVm, mVm, rVm, __) {
      final leadVm = Provider.of<LeadViewmodel>(context);
      final all = _buildAllItems(
          fVm.followups, mVm.meetingList, rVm.reminders, leadVm.leadList);

      final allCount = all.length;
      final upcoming = all.where((a) => a['isUpcoming'] == true).length;
      final completed = all.where((a) => a['isCompleted'] == true).length;
      final overdue = all.where((a) => a['isOverdue'] == true).length;
      final counts = [allCount, upcoming, completed, overdue];
      final sw = MediaQuery.of(context).size.width;

      return Container(
        margin: EdgeInsets.fromLTRB(sw * .04, 16, sw * .04, 0),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: ErpColors.line),
          boxShadow: [
            BoxShadow(
              color: ErpColors.cyan.withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(children: [
          Row(children: [
            Expanded(child: _searchBar()),
            const SizedBox(width: 8),
            _typePill(),
            const SizedBox(width: 8),
            _datePill(),
          ]),
          const SizedBox(height: 12),
          Container(
            height: 52,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: ErpColors.pageBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: ErpColors.line),
            ),
            child: Row(
              children: List.generate(
                  _tabs.length,
                  (i) =>
                      Expanded(child: _tabChip(i, _tabs[i].label, counts[i]))),
            ),
          ),
        ]),
      );
    });
  }

  Widget _searchBar() => Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 7),
        decoration: BoxDecoration(
          color: ErpColors.pageBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ErpColors.line),
        ),
        child: Row(children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: ErpColors.cyan.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(Icons.search_rounded,
                size: 16, color: ErpColors.cyanDeep),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              cursorColor: ErpColors.cyan,
              textAlignVertical: TextAlignVertical.center,
              style: const TextStyle(
                  color: ErpColors.ink,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: 'Search tasks…',
                hintStyle: TextStyle(
                    color: ErpColors.slate.withValues(alpha: 0.7),
                    fontSize: 13),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_search.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchCtrl.clear();
                setState(() {
                  _search = '';
                  _currentPage = 0;
                  _OrganizerFilterState.search = '';
                  _OrganizerFilterState.currentPage = 0;
                });
              },
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: ErpColors.slate.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded,
                    size: 13, color: ErpColors.slate),
              ),
            ),
          const SizedBox(width: 3),
        ]),
      );

  Widget _filterPill({
    required bool active,
    required Color color,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return ErpPressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          gradient: active
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [ErpColors.tint(color, 0.2), color],
                )
              : null,
          color: active ? null : ErpColors.pageBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: active ? Colors.transparent : ErpColors.line),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.30),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : const [],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon,
              size: 15, color: active ? Colors.white : ErpColors.cyanDeep),
          const SizedBox(width: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 82),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: active ? Colors.white : ErpColors.cyanDeep,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800),
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 3), trailing],
        ]),
      ),
    );
  }

  Widget _typePill() {
    final active = _typeFilter != 'All Types';
    return _filterPill(
      active: active,
      color: _typeOptionColor(_typeFilter),
      icon: Icons.tune_rounded,
      label: active ? _typeFilter : 'Type',
      onTap: _showTypeSheet,
      trailing: Icon(Icons.keyboard_arrow_down_rounded,
          size: 15, color: active ? Colors.white : ErpColors.cyanDeep),
    );
  }

  Widget _datePill() {
    final isActive = _dateFilter != null;
    return _filterPill(
      active: isActive,
      color: ErpColors.cyan,
      icon: Icons.calendar_month_rounded,
      label: isActive ? _fullDateLabel(_dateFilter!) : 'Date',
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _dateFilter ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
          builder: (ctx, child) => erpPickerTheme(ctx, child),
        );
        if (picked != null) _setDateFilter(picked);
      },
      trailing: isActive
          ? GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _setDateFilter(null),
              child: const Icon(Icons.close_rounded,
                  size: 14, color: Colors.white),
            )
          : null,
    );
  }

  Widget _tabChip(int index, String label, int count) {
    final active = _tab == index;
    final Color activeColor = _tabColors[index];

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _setTab(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        decoration: active
            ? BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [ErpColors.tint(activeColor, 0.2), activeColor],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              )
            : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: active ? Colors.white : ErpColors.slate,
                    fontWeight: FontWeight.w800,
                    fontSize: 10.5)),
            Text('$count',
                style: TextStyle(
                    color: active
                        ? Colors.white
                        : ErpColors.shade(activeColor, 0.1),
                    fontWeight: FontWeight.w900,
                    fontSize: 12.5)),
          ],
        ),
      ),
    );
  }

  void _showTypeSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                    color: ErpColors.line,
                    borderRadius: BorderRadius.circular(3)),
              ),
              const SizedBox(height: 14),
              Row(children: [
                const ErpGradientTile(
                    icon: Icons.tune_rounded, color: ErpColors.cyan, size: 42),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Filter by Type',
                          style: TextStyle(
                              color: ErpColors.ink,
                              fontSize: 18,
                              fontWeight: FontWeight.w900)),
                      Text('Show only one kind of task',
                          style:
                              TextStyle(color: ErpColors.slate, fontSize: 13)),
                    ],
                  ),
                ),
                ErpPressable(
                  onTap: () => Navigator.pop(context),
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
              const SizedBox(height: 16),
              ..._typeOptions.map((type) {
                final isSelected = _typeFilter == type;
                final c = _typeOptionColor(type);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ErpPressable(
                    scale: 0.98,
                    onTap: () {
                      _setTypeFilter(type);
                      Navigator.pop(context);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? c.withValues(alpha: 0.08)
                            : ErpColors.pageBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color:
                              isSelected ? c.withValues(alpha: 0.6) : ErpColors.line,
                          width: isSelected ? 1.4 : 1,
                        ),
                      ),
                      child: Row(children: [
                        ErpGradientTile(
                            icon: _typeOptionIcon(type), color: c, size: 36),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(type,
                              style: TextStyle(
                                  color: isSelected
                                      ? ErpColors.shade(c, 0.15)
                                      : ErpColors.ink,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14.5)),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? LinearGradient(
                                    colors: [ErpColors.tint(c, 0.2), c])
                                : null,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? null
                                : Border.all(color: ErpColors.line, width: 1.5),
                          ),
                          child: isSelected
                              ? const Icon(Icons.check_rounded,
                                  size: 15, color: Colors.white)
                              : null,
                        ),
                      ]),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
            ]),
          ),
        ),
      ),
    );
  }

  // ── List ───────────────────────────────────────────────────────────────────
  Widget _buildList() {
    return Consumer4<FollowupViewmodel, MeetingViewmodel, ReminderViewmodel,
        LeadViewmodel>(
      builder: (_, fVm, mVm, rVm, leadVm, __) {
        final isLoading = fVm.loading || mVm.getMeetingLoader || rVm.loading;

        if (isLoading) {
          return const Center(
            child: SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                  color: ErpColors.cyan, strokeWidth: 2.5),
            ),
          );
        }

        final allItems = _buildAllItems(
            fVm.followups, mVm.meetingList, rVm.reminders, leadVm.leadList);

        final apiType = _typeApiMap[_typeFilter];

        final filtered = allItems.where((a) {
          final tabKey = _tabs[_tab].key;
          if (tabKey == 'upcoming' && a['isUpcoming'] != true) return false;
          if (tabKey == 'completed' && a['isCompleted'] != true) return false;
          if (tabKey == 'overdue' && a['isOverdue'] != true) return false;
          if (apiType != null && a['kind'] != apiType) return false;
          if (_dateFilter != null) {
            final d = _parseDate(a['date'] as String?);
            if (d == null || !_isSameDate(d, _dateFilter!)) return false;
          }
          if (_search.isNotEmpty) {
            final title = (a['title'] as String).toLowerCase();
            final leadName = (a['leadName'] as String).toLowerCase();
            return title.contains(_search) || leadName.contains(_search);
          }
          return true;
        }).toList();

        if (filtered.isEmpty) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.only(top: 50, bottom: 30),
              child: ErpEmptyState(
                icon: Icons.event_available_rounded,
                title: 'No tasks found',
                subtitle: 'Try adjusting your filters',
                color: _tabColors[_tab],
                actionLabel: 'Reset filters',
                onAction: _resetFilters,
              ),
            ),
          );
        }

        final totalPages = (filtered.length / _kPageSize).ceil();
        final safePage = _currentPage.clamp(0, totalPages - 1);
        final start = safePage * _kPageSize;
        final end = (start + _kPageSize).clamp(0, filtered.length);
        final pageItems = filtered.sublist(start, end);
        final sw = MediaQuery.of(context).size.width;

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(sw * .04, 14, sw * .04, 12),
                itemCount: pageItems.length,
                itemBuilder: (_, i) {
                  final row = pageItems[i];
                  final kind = row['kind'] as String;
                  return ErpFadeIn(
                    key: ValueKey('${kind}_${safePage}_${i}_${row['title']}'),
                    index: i,
                    child: _TaskCard(
                      row: row,
                      kindColor: _kindColor(kind),
                      kindIcon: _kindIcon(kind),
                      kindLabel: _kindLabel(kind),
                      statusColor: _statusColor(
                          row['isCompleted'] as bool, row['isOverdue'] as bool),
                      statusIcon: _statusIcon(
                          row['isCompleted'] as bool, row['isOverdue'] as bool),
                      statusLabel: _statusLabel(
                          row['isCompleted'] as bool, row['isOverdue'] as bool),
                      prettyDate: _prettyDate(row['date'] as String?),
                      onCall: _launchCall,
                      onEmail: _launchEmail,
                      onWhatsApp: _launchWhatsApp,
                      onMeet: _launchMeet,
                      onMarkMeetingDone: (m) async {
                        final vm = Provider.of<MeetingViewmodel>(context,
                            listen: false);
                        await vm
                            .updateMeeting(m.meetingId, {'status': 'completed'});
                        _snack('Marked completed');
                      },
                      onMarkReminderDone: (r) async {
                        final vm = Provider.of<ReminderViewmodel>(context,
                            listen: false);
                        await vm.markCompleted(r.id);
                        _snack('Reminder marked completed');
                      },
                      onMarkFollowupDone: () => _snack('Follow-up marked done'),
                      onViewLead: (lead) {
                        if (lead == null || lead.leadId == 0) return;
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => LeadsViewScreen(lead: lead)));
                      },
                    ),
                  );
                },
              ),
            ),
            if (totalPages > 1)
              SafeArea(
                top: false,
                child:
                    _buildPaginationBar(safePage, totalPages, filtered.length),
              ),
          ],
        );
      },
    );
  }

  Widget _buildPaginationBar(int page, int totalPages, int totalCount) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
        border: const Border(top: BorderSide(color: ErpColors.line, width: 1)),
        boxShadow: [
          BoxShadow(
            color: ErpColors.cyan.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          _pageBtn(
            icon: Icons.chevron_left_rounded,
            enabled: page > 0,
            onTap: () => _setPage(page - 1),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(totalPages, (i) {
                  final isActive = i == page;
                  return GestureDetector(
                    onTap: () => _setPage(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: isActive ? 36 : 30,
                      height: 30,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        gradient: isActive ? ErpColors.headerGradient : null,
                        color: isActive ? null : ErpColors.pageBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isActive ? Colors.transparent : ErpColors.line,
                        ),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: ErpColors.cyan.withValues(alpha: 0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : const [],
                      ),
                      child: Center(
                        child: Text('${i + 1}',
                            style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w900,
                                color: isActive
                                    ? Colors.white
                                    : ErpColors.slate)),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _pageBtn(
            icon: Icons.chevron_right_rounded,
            enabled: page < totalPages - 1,
            onTap: () => _setPage(page + 1),
          ),
          const SizedBox(width: 10),
          Text(
            '${page * _kPageSize + 1}–${(page * _kPageSize + _kPageSize).clamp(0, totalCount)} of $totalCount',
            style: const TextStyle(
                fontSize: 10.5,
                color: ErpColors.slate,
                fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _pageBtn(
      {required IconData icon,
      required bool enabled,
      required VoidCallback onTap}) {
    return ErpPressable(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: enabled
              ? ErpColors.cyan.withValues(alpha: 0.12)
              : ErpColors.pageBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: enabled
                  ? ErpColors.cyan.withValues(alpha: 0.30)
                  : ErpColors.line),
        ),
        child: Icon(icon,
            size: 19,
            color: enabled
                ? ErpColors.cyanDeep
                : ErpColors.slate.withValues(alpha: 0.35)),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// TASK CARD
// ══════════════════════════════════════════════════════════════════════════════
class _TaskCard extends StatelessWidget {
  final Map<String, dynamic> row;
  final Color kindColor;
  final IconData kindIcon;
  final String kindLabel;
  final Color statusColor;
  final IconData statusIcon;
  final String statusLabel;
  final String prettyDate;
  final void Function(String) onCall;
  final void Function(String) onEmail;
  final void Function(String) onWhatsApp;
  final void Function(String) onMeet;
  final Future<void> Function(MeetingModel) onMarkMeetingDone;
  final Future<void> Function(ReminderModel) onMarkReminderDone;
  final VoidCallback onMarkFollowupDone;
  final void Function(LeadModel?) onViewLead;

  const _TaskCard({
    required this.row,
    required this.kindColor,
    required this.kindIcon,
    required this.kindLabel,
    required this.statusColor,
    required this.statusIcon,
    required this.statusLabel,
    required this.prettyDate,
    required this.onCall,
    required this.onEmail,
    required this.onWhatsApp,
    required this.onMeet,
    required this.onMarkMeetingDone,
    required this.onMarkReminderDone,
    required this.onMarkFollowupDone,
    required this.onViewLead,
  });

  List<_CardAction> _buildActions() {
    final kind = row['kind'] as String;
    final phone = row['phone'] as String;
    final email = row['email'] as String;
    final location = row['location'] as String;
    final isCompleted = row['isCompleted'] as bool;

    switch (kind) {
      case 'meeting':
        final m = row['item'] as MeetingModel;
        return [
          _CardAction(
            label: 'Join Meet',
            icon: Icons.videocam_rounded,
            color: ErpColors.blue,
            onTap: () => onMeet(location),
          ),
          if (email.isNotEmpty)
            _CardAction(
              label: 'Email',
              icon: Icons.email_rounded,
              color: ErpColors.violet,
              onTap: () => onEmail(email),
            ),
          _CardAction(
            label: isCompleted ? 'Completed' : 'Mark Done',
            icon: Icons.check_rounded,
            color: ErpColors.green,
            filled: !isCompleted,
            onTap: () async {
              if (!isCompleted) await onMarkMeetingDone(m);
            },
          ),
        ];
      case 'followup':
        return [
          _CardAction(
            label: 'Call',
            icon: Icons.call_rounded,
            color: ErpColors.cyan,
            onTap: () => onCall(phone),
          ),
          _CardAction(
            label: 'WhatsApp',
            icon: ErpIcons.whatsapp,
            color: ErpColors.whatsapp,
            onTap: () => onWhatsApp(phone),
          ),
          _CardAction(
            label: isCompleted ? 'Completed' : 'Mark Done',
            icon: Icons.check_rounded,
            color: ErpColors.green,
            filled: !isCompleted,
            onTap: () {
              if (!isCompleted) onMarkFollowupDone();
            },
          ),
        ];
      case 'reminder':
        final r = row['item'] as ReminderModel;
        return [
          _CardAction(
            label: 'Call',
            icon: Icons.call_rounded,
            color: ErpColors.cyan,
            onTap: () => onCall(phone),
          ),
          _CardAction(
            label: 'WhatsApp',
            icon: ErpIcons.whatsapp,
            color: ErpColors.whatsapp,
            onTap: () => onWhatsApp(phone),
          ),
          _CardAction(
            label: isCompleted ? 'Completed' : 'Mark Done',
            icon: Icons.check_rounded,
            color: ErpColors.green,
            filled: !isCompleted,
            onTap: () async {
              if (!isCompleted) await onMarkReminderDone(r);
            },
          ),
        ];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = row['title'] as String;
    final leadName = row['leadName'] as String;
    final phone = row['phone'] as String;
    final time = row['time'] as String;
    final isOverdue = row['isOverdue'] as bool;
    final lead = row['lead'] as LeadModel?;

    final dateStr = isOverdue ? '' : prettyDate;
    final timeStr = isOverdue ? '' : time;
    final actions = _buildActions();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: ErpColors.line),
        boxShadow: [
          BoxShadow(
            color: kindColor.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                ErpColors.tint(kindColor, 0.3),
                kindColor,
              ]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 13, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Title row ─────────────────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ErpGradientTile(icon: kindIcon, color: kindColor, size: 44),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: ErpColors.ink,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(children: [
                            const Icon(Icons.person_rounded,
                                size: 13, color: ErpColors.slate),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                leadName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: ErpColors.slate),
                              ),
                            ),
                          ]),
                          if (phone.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Row(children: [
                              const Icon(Icons.call_rounded,
                                  size: 12, color: ErpColors.slate),
                              const SizedBox(width: 4),
                              Text(
                                phone,
                                style: const TextStyle(
                                    fontSize: 12, color: ErpColors.slate),
                              ),
                            ]),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: kindColor.withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(kindLabel,
                          style: TextStyle(
                              color: ErpColors.shade(kindColor, 0.15),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // ── Date + status strip ───────────────────────────────────
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: ErpColors.pageBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: ErpColors.line),
                  ),
                  child: Row(children: [
                    if (dateStr.isNotEmpty || timeStr.isNotEmpty)
                      Flexible(
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.schedule_rounded,
                              size: 14, color: ErpColors.cyanDeep),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                                [dateStr, timeStr]
                                    .where((s) => s.isNotEmpty)
                                    .join('  ·  '),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: ErpColors.ink)),
                          ),
                        ]),
                      ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(statusIcon, size: 12, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          statusLabel,
                          style: TextStyle(
                              color: ErpColors.shade(statusColor, 0.1),
                              fontSize: 11,
                              fontWeight: FontWeight.w800),
                        ),
                      ]),
                    ),
                  ]),
                ),

                // ── Actions ───────────────────────────────────────────────
                if (actions.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        ...actions.map((a) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: _actionBtn(a),
                            )),
                        _actionBtn(_CardAction(
                          label: 'View Lead',
                          icon: Icons.visibility_rounded,
                          color: ErpColors.cyanDeep,
                          onTap: () => onViewLead(lead),
                        )),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(_CardAction a) => ErpPressable(
        onTap: a.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: a.filled
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [ErpColors.tint(a.color, 0.2), a.color],
                  )
                : null,
            color: a.filled ? null : a.color.withValues(alpha: .10),
            borderRadius: BorderRadius.circular(20),
            border: a.filled
                ? null
                : Border.all(color: a.color.withValues(alpha: .28)),
            boxShadow: a.filled
                ? [
                    BoxShadow(
                      color: a.color.withValues(alpha: 0.32),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : const [],
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            erpIcon(a.icon,
                size: 14, color: a.filled ? Colors.white : a.color),
            const SizedBox(width: 5),
            Text(a.label,
                style: TextStyle(
                    color: a.filled
                        ? Colors.white
                        : ErpColors.shade(a.color, 0.12),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800)),
          ]),
        ),
      );
}

// ── Card action model ──────────────────────────────────────────────────────────
class _CardAction {
  final String label;
  final IconData icon;
  final Color color;
  final bool filled;
  final VoidCallback onTap;

  const _CardAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.filled = false,
  });
}