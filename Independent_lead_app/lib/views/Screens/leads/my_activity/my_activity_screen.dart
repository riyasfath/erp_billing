import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pokakbilling/core/navigations.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/activity/all_activityviewmodel.dart';
import 'package:pokakbilling/viewmodels/lead_viewmodel.dart';
import 'package:pokakbilling/models/data-models/activity-model/activity_model.dart';
import 'package:pokakbilling/views/Screens/leads/my_activity/new_activity.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

const String _kWhatsAppSvg = '''
<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
  <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347z"/>
  <path d="M12 0C5.373 0 0 5.373 0 12c0 2.125.558 4.122 1.528 5.855L.057 23.885a.5.5 0 00.611.611l6.101-1.459A11.945 11.945 0 0012 24c6.627 0 12-5.373 12-12S18.627 0 12 0zm0 21.818a9.818 9.818 0 01-5.012-1.378l-.36-.214-3.724.89.908-3.64-.235-.374A9.818 9.818 0 0112 2.182c5.428 0 9.818 4.39 9.818 9.818 0 5.429-4.39 9.818-9.818 9.818z"/>
</svg>
''';

class _ActivityFilterState {
  static int tab = 0;
  static String search = '';
  static String typeFilter = 'All Types';
  static DateTime? dateFilter;
  static int currentPage = 0;
}

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});
  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen>
    with TickerProviderStateMixin {
  late int _tab;
  late String _search;
  late String _typeFilter;
  late DateTime? _dateFilter;
  late int _currentPage;

  final _searchCtrl = TextEditingController();

  static const int _pageSize = 10;

  static const _tabs = [
    (label: 'All', key: null),
    (label: 'Pending', key: 'PENDING'),
    (label: 'Done', key: 'COMPLETED'),
    (label: 'Overdue', key: 'OVERDUE'),
  ];

  static const _typeOptions = [
    'All Types',
    'Meeting',
    'Call',
    'Email',
    'WhatsApp',
    'Follow-up',
    'Reminder',
  ];

  static const _typeApiMap = {
    'Meeting': 'MEETING',
    'Call': 'CALL',
    'Email': 'EMAIL',
    'WhatsApp': 'WHATSAPP',
    'Follow-up': 'FOLLOW_UP',
    'Reminder': 'REMINDER',
  };

  static const _monthAbbreviations = [
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

  late final AnimationController _hCtrl, _bCtrl;
  late final Animation<double> _hFade, _bFade;
  late final Animation<Offset> _hSlide, _bSlide;

  @override
  void initState() {
    super.initState();

    _tab = _ActivityFilterState.tab;
    _search = _ActivityFilterState.search;
    _typeFilter = _ActivityFilterState.typeFilter;
    _dateFilter = _ActivityFilterState.dateFilter;
    _currentPage = _ActivityFilterState.currentPage;

    _searchCtrl.text = _search;
    _searchCtrl.addListener(() {
      final v = _searchCtrl.text.toLowerCase();
      setState(() {
        _search = v;
        _currentPage = 0;
        _ActivityFilterState.search = v;
        _ActivityFilterState.currentPage = 0;
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
      Provider.of<AllActivityViewModel>(context, listen: false)
          .fetchActivities();
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
        _ActivityFilterState.tab = t;
        _ActivityFilterState.currentPage = 0;
      });

  void _setTypeFilter(String v) => setState(() {
        _typeFilter = v;
        _currentPage = 0;
        _ActivityFilterState.typeFilter = v;
        _ActivityFilterState.currentPage = 0;
      });

  void _setDateFilter(DateTime? d) => setState(() {
        _dateFilter = d;
        _currentPage = 0;
        _ActivityFilterState.dateFilter = d;
        _ActivityFilterState.currentPage = 0;
      });

  void _setPage(int p) => setState(() {
        _currentPage = p;
        _ActivityFilterState.currentPage = p;
      });

  // ── Snackbar ───────────────────────────────────────────────────────────────
  void _snack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red.shade400 : AppColors.c1,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  // ── Launchers ──────────────────────────────────────────────────────────────
  Future<void> _launchCall(String phone) async {
    final cleaned = phone.trim();
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
    final cleaned = phone.replaceAll(RegExp(r'\D'), '');
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
    if (location.trim().isNotEmpty) {
      final raw = location.trim();
      final normalised =
          raw.toLowerCase().startsWith('www.') ? 'https://$raw' : raw;
      final uri = Uri.tryParse(normalised);
      if (uri != null && uri.hasScheme && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }
    }
    await launchUrl(Uri.parse('https://meet.google.com'),
        mode: LaunchMode.externalApplication);
  }

  // ── Type helpers ───────────────────────────────────────────────────────────
  Color _typeColor(String t) {
    switch (t.toUpperCase()) {
      case 'MEETING':
        return Colors.teal;
      case 'CALL':
        return Colors.orange;
      case 'EMAIL':
        return Colors.blue;
      case 'WHATSAPP':
        return Colors.green;
      case 'FOLLOW_UP':
        return Colors.purple;
      case 'REMINDER':
        return Colors.red;
      default:
        return AppColors.c1;
    }
  }

  IconData? _typeIcon(String t) {
    switch (t.toUpperCase()) {
      case 'MEETING':
        return Icons.videocam_rounded;
      case 'CALL':
        return Icons.call_rounded;
      case 'EMAIL':
        return Icons.email_rounded;
      case 'WHATSAPP':
        return null;
      case 'FOLLOW_UP':
        return Icons.replay_rounded;
      case 'REMINDER':
        return Icons.notifications_rounded;
      default:
        return Icons.event_note_rounded;
    }
  }

  String _typeLabel(String t) {
    const m = {
      'MEETING': 'Meeting',
      'CALL': 'Call',
      'EMAIL': 'Email',
      'WHATSAPP': 'WhatsApp',
      'FOLLOW_UP': 'Follow-up',
      'REMINDER': 'Reminder',
    };
    return m[t.toUpperCase()] ?? t;
  }

  Color _statusColor(String s) {
    switch (s.toUpperCase()) {
      case 'COMPLETED':
        return Colors.green;
      case 'OVERDUE':
        return Colors.red;
      case 'PENDING':
        return Colors.orange;
      case 'CANCELLED':
        return Colors.amber;
      default:
        return AppColors.c1;
    }
  }

  IconData _statusIcon(String s) {
    switch (s.toUpperCase()) {
      case 'COMPLETED':
        return Icons.check_circle_rounded;
      case 'OVERDUE':
        return Icons.warning_rounded;
      case 'PENDING':
        return Icons.hourglass_empty_rounded;
      case 'CANCELLED':
        return Icons.cancel_rounded;
      default:
        return Icons.schedule_rounded;
    }
  }

  bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _fullDateLabel(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')} ${_monthAbbreviations[d.month - 1]} ${d.year}';

  // ══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final top = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.white,
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
      padding: EdgeInsets.only(
          top: top + 12, bottom: 20, left: sw * .045, right: sw * .045),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border:
            Border(bottom: BorderSide(color: AppColors.cborder, width: 1.5)),
      ),
      child: Row(children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.cxl,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.cborder),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.c1, size: 15),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Consumer<AllActivityViewModel>(
            builder: (_, vm, __) {
              final total = vm.activities.length;
              final pending = vm.activities
                  .where((a) => a.status.toUpperCase() == 'PENDING')
                  .length;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('My Organizer',
                      style: TextStyle(
                          color: AppColors.cdark,
                          fontSize: 20,
                          fontWeight: FontWeight.w800)),
                  Row(children: [
                    Text('$total tasks',
                        style: const TextStyle(
                            color: AppColors.ctext, fontSize: 12)),
                    if (pending > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: Colors.orange.withOpacity(0.30)),
                        ),
                        child: Text('$pending pending',
                            style: const TextStyle(
                                color: Colors.orange,
                                fontSize: 10,
                                fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ]),
                ],
              );
            },
          ),
        ),
        GestureDetector(
          onTap: () => pushNavigation(context, const NewActivityScreen()),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: AppColors.c1,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.c1.withOpacity(0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, color: AppColors.white, size: 15),
                SizedBox(width: 4),
                Text('New',
                    style: TextStyle(
                        color: AppColors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  // ── Filter card ────────────────────────────────────────────────────────────
  Widget _buildFilterCard() {
    return Consumer<AllActivityViewModel>(builder: (_, vm, __) {
      final all = vm.activities.length;
      final pending = vm.activities
          .where((a) => a.status.toUpperCase() == 'PENDING')
          .length;
      final done = vm.activities
          .where((a) => a.status.toUpperCase() == 'COMPLETED')
          .length;
      final overdue = vm.activities
          .where((a) => a.status.toUpperCase() == 'OVERDUE')
          .length;
      final counts = [all, pending, done, overdue];

      return Container(
        margin: const EdgeInsets.fromLTRB(14, 14, 14, 0),
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        decoration: BoxDecoration(
          color: AppColors.cxl,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.cborder),
          boxShadow: [
            BoxShadow(
              color: AppColors.c1.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
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
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppColors.cborder),
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
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cborder),
        ),
        child: Row(children: [
          const Icon(Icons.search_rounded, size: 16, color: AppColors.ctext),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              textAlignVertical: TextAlignVertical.center,
              style: const TextStyle(color: AppColors.cdark, fontSize: 13),
              decoration: const InputDecoration(
                hintText: 'Search tasks…',
                hintStyle: TextStyle(color: AppColors.ctext, fontSize: 13),
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
                  _ActivityFilterState.search = '';
                  _ActivityFilterState.currentPage = 0;
                });
              },
              child: const Icon(Icons.close_rounded,
                  size: 14, color: AppColors.c1),
            ),
        ]),
      );

  Widget _typePill() => GestureDetector(
        onTap: _showTypeSheet,
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: _typeFilter != 'All Types'
                ? AppColors.c1.withOpacity(0.10)
                : AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _typeFilter != 'All Types'
                  ? AppColors.c1.withOpacity(0.40)
                  : AppColors.cborder,
            ),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.tune_rounded,
                size: 14,
                color: _typeFilter != 'All Types'
                    ? AppColors.c1
                    : AppColors.ctext),
            const SizedBox(width: 4),
            Text(
              _typeFilter == 'All Types' ? 'Type' : _typeFilter,
              style: TextStyle(
                  color: _typeFilter != 'All Types'
                      ? AppColors.c1
                      : AppColors.ctext,
                  fontSize: 11,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 2),
            Icon(Icons.keyboard_arrow_down_rounded,
                size: 14,
                color: _typeFilter != 'All Types'
                    ? AppColors.c1
                    : AppColors.ctext),
          ]),
        ),
      );

  // ── Date pill — close button stops tap propagation ─────────────────────────
  Widget _datePill() {
    final isActive = _dateFilter != null;
    return GestureDetector(
      onTap: () async {
        // Only open picker if not tapping the X (handled separately below)
        final picked = await showDatePicker(
          context: context,
          initialDate: _dateFilter ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
          builder: (ctx, child) => Theme(
            data: ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(
                primary: AppColors.c1,
                onPrimary: AppColors.white,
                surface: AppColors.white,
              ),
            ),
            child: child!,
          ),
        );
        if (picked != null) _setDateFilter(picked);
      },
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.c1.withOpacity(0.10) : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isActive ? AppColors.c1.withOpacity(0.40) : AppColors.cborder,
          ),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.calendar_month_rounded,
              size: 14, color: isActive ? AppColors.c1 : AppColors.ctext),
          const SizedBox(width: 4),
          Text(
            isActive ? _fullDateLabel(_dateFilter!) : 'Date',
            style: TextStyle(
                color: isActive ? AppColors.c1 : AppColors.ctext,
                fontSize: 11,
                fontWeight: FontWeight.w600),
          ),
          if (isActive) ...[
            const SizedBox(width: 4),
            // ── GestureDetector with onTap absorbs the tap so the
            //    parent picker-open handler is NOT triggered ──────────
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                _setDateFilter(null); // clear filter
              },
              child: const Icon(Icons.close_rounded,
                  size: 12, color: AppColors.c1),
            ),
          ],
        ]),
      ),
    );
  }

  Widget _tabChip(int index, String label, int count) {
    final active = _tab == index;
    final Color activeColor = index == 1
        ? Colors.orange
        : index == 2
            ? Colors.green
            : index == 3
                ? Colors.red
                : AppColors.c1;

    return GestureDetector(
      onTap: () => _setTab(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          color: active ? activeColor.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: active ? activeColor : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label,
                style: TextStyle(
                    color: active ? activeColor : AppColors.ctext,
                    fontWeight: FontWeight.w700,
                    fontSize: 10)),
            const SizedBox(height: 1),
            Text('$count',
                style: TextStyle(
                    color: active ? activeColor : AppColors.ctext,
                    fontWeight: FontWeight.w800,
                    fontSize: 12)),
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
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                  color: AppColors.cborder,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 20, bottom: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Filter by Type',
                    style: TextStyle(
                        color: AppColors.cdark,
                        fontSize: 15,
                        fontWeight: FontWeight.w700)),
              ),
            ),
            ..._typeOptions.map((type) {
              final isSelected = _typeFilter == type;
              final isWA = type == 'WhatsApp';
              return ListTile(
                leading: Radio<String>(
                  value: type,
                  groupValue: _typeFilter,
                  activeColor: AppColors.c1,
                  onChanged: (v) {
                    _setTypeFilter(v!);
                    Navigator.pop(context);
                  },
                ),
                title: Row(children: [
                  if (isWA) ...[
                    SvgPicture.string(
                      _kWhatsAppSvg,
                      width: 14,
                      height: 14,
                      colorFilter: ColorFilter.mode(
                        isSelected ? AppColors.c1 : Colors.green,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(type,
                      style: TextStyle(
                          color: isSelected ? AppColors.c1 : AppColors.cdark,
                          fontWeight:
                              isSelected ? FontWeight.w800 : FontWeight.w500,
                          fontSize: 14)),
                ]),
              );
            }),
            const SizedBox(height: 20),
          ]),
        ),
      ),
    );
  }

  // ── List ───────────────────────────────────────────────────────────────────
  Widget _buildList() {
    return Consumer2<AllActivityViewModel, LeadViewmodel>(
      builder: (_, vm, leadVm, __) {
        if (vm.isLoading) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.c1));
        }
        if (vm.error != null) {
          return Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.cloud_off_rounded,
                  color: AppColors.c1.withOpacity(.5), size: 52),
              const SizedBox(height: 12),
              Text('Could not load tasks',
                  style: TextStyle(
                      color: AppColors.ctext.withOpacity(.75), fontSize: 14)),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: vm.fetchActivities,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.c1,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Retry',
                      style: TextStyle(
                          color: AppColors.white, fontWeight: FontWeight.w700)),
                ),
              ),
            ]),
          );
        }

        final statusKey = _tabs[_tab].key;
        final apiType = _typeApiMap[_typeFilter];

        final filtered = vm.activities.where((a) {
          if (statusKey != null && a.status.toUpperCase() != statusKey) {
            return false;
          }
          if (apiType != null && a.activityType.toUpperCase() != apiType) {
            return false;
          }
          if (_dateFilter != null && !_isSameDate(a.dueDate, _dateFilter!)) {
            return false;
          }
          if (_search.isNotEmpty) {
            return a.title.toLowerCase().contains(_search) ||
                a.assignedToName.toLowerCase().contains(_search);
          }
          return true;
        }).toList();

        if (filtered.isEmpty) {
          return Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.c1.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.event_available_rounded,
                    color: AppColors.c1.withOpacity(.50), size: 32),
              ),
              const SizedBox(height: 14),
              const Text('No tasks found',
                  style: TextStyle(
                      color: AppColors.cdark,
                      fontSize: 15,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text('Try adjusting your filters',
                  style: TextStyle(
                      color: AppColors.ctext.withOpacity(.60), fontSize: 13)),
            ]),
          );
        }

        final totalPages = (filtered.length / _pageSize).ceil();
        final safePage = _currentPage.clamp(0, totalPages - 1);
        final start = safePage * _pageSize;
        final end = (start + _pageSize).clamp(0, filtered.length);
        final pageItems = filtered.sublist(start, end);

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
                itemCount: pageItems.length,
                itemBuilder: (_, i) {
                  final item = pageItems[i];

                  // ── Resolve phone & email from LeadViewmodel ──────────────
                  final lead = leadVm.leadList.where((l) {
                    final lid = l.id;
                    return lid == item.lead;
                  }).firstOrNull;

                  final phone = lead?.phone.trim() ?? '';
                  final email = lead?.email.trim() ?? '';
                  final location = item.location?.trim() ?? '';

                  return _AnimatedTaskCard(
                    key: ValueKey(item.id),
                    item: item,
                    phone: phone,
                    email: email,
                    location: location,
                    delay: Duration(milliseconds: 40 + i * 50),
                    typeColor: _typeColor(item.activityType),
                    typeIcon: _typeIcon(item.activityType),
                    typeLabel: _typeLabel(item.activityType),
                    statusColor: _statusColor(item.status),
                    statusIcon: _statusIcon(item.status),
                    onCall: _launchCall,
                    onEmail: _launchEmail,
                    onWhatsApp: _launchWhatsApp,
                    onMeet: _launchMeet,
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
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.cborder, width: 1)),
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
                      width: isActive ? 34 : 28,
                      height: 28,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.c1 : AppColors.cxl,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isActive ? AppColors.c1 : AppColors.cborder,
                        ),
                      ),
                      child: Center(
                        child: Text('${i + 1}',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isActive
                                    ? AppColors.white
                                    : AppColors.ctext)),
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
            '${page * _pageSize + 1}–${(page * _pageSize + _pageSize).clamp(0, totalCount)} of $totalCount',
            style: TextStyle(
                fontSize: 10,
                color: AppColors.ctext.withOpacity(0.60),
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _pageBtn(
      {required IconData icon,
      required bool enabled,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: enabled ? AppColors.c1.withOpacity(0.10) : AppColors.cxl,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color:
                  enabled ? AppColors.c1.withOpacity(0.30) : AppColors.cborder),
        ),
        child: Icon(icon,
            size: 18,
            color: enabled ? AppColors.c1 : AppColors.ctext.withOpacity(0.30)),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ANIMATED TASK CARD
// ══════════════════════════════════════════════════════════════════════════════
class _AnimatedTaskCard extends StatefulWidget {
  final AllActivityModel item;
  final String phone;
  final String email;
  final String location;
  final Duration delay;
  final Color typeColor;
  final IconData? typeIcon;
  final String typeLabel;
  final Color statusColor;
  final IconData statusIcon;
  final void Function(String) onCall;
  final void Function(String) onEmail;
  final void Function(String) onWhatsApp;
  final void Function(String) onMeet;

  const _AnimatedTaskCard({
    super.key,
    required this.item,
    required this.phone,
    required this.email,
    required this.location,
    required this.delay,
    required this.typeColor,
    required this.typeIcon,
    required this.typeLabel,
    required this.statusColor,
    required this.statusIcon,
    required this.onCall,
    required this.onEmail,
    required this.onWhatsApp,
    required this.onMeet,
  });

  @override
  State<_AnimatedTaskCard> createState() => _AnimatedTaskCardState();
}

class _AnimatedTaskCardState extends State<_AnimatedTaskCard>
    with TickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  late final Animation<double> _scale;

  late final AnimationController _pressCtrl;
  late final Animation<double> _pressScale;

  static const _months = [
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

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 420));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _scale = Tween<double>(begin: 0.96, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));

    _pressCtrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 80),
        lowerBound: 0,
        upperBound: 1);
    _pressScale = Tween<double>(begin: 1.0, end: 0.97).animate(_pressCtrl);

    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _pressCtrl.dispose();
    super.dispose();
  }

  Widget _typeIconWidget({required double size}) {
    if (widget.typeIcon == null) {
      return SvgPicture.string(
        _kWhatsAppSvg,
        width: size,
        height: size,
        colorFilter: ColorFilter.mode(widget.typeColor, BlendMode.srcIn),
      );
    }
    return Icon(widget.typeIcon, color: widget.typeColor, size: size);
  }

  List<_CardAction> _buildActions() {
    final type = widget.item.activityType.toUpperCase();
    final phone = widget.phone;
    final email = widget.email;
    final location = widget.location;

    switch (type) {
      case 'MEETING':
        return [
          _CardAction(
            label: 'Join Meet',
            icon: Icons.videocam_rounded,
            color: Colors.teal,
            onTap: () => widget.onMeet(location),
          ),
          _CardAction(
            label: 'Email',
            icon: Icons.email_rounded,
            color: Colors.blue,
            onTap: () => widget.onEmail(email),
          ),
        ];
      case 'CALL':
        return [
          _CardAction(
            label: 'Call Now',
            icon: Icons.call_rounded,
            color: Colors.orange,
            onTap: () => widget.onCall(phone),
          ),
        ];
      case 'EMAIL':
        return [
          _CardAction(
            label: 'Send Email',
            icon: Icons.email_rounded,
            color: Colors.blue,
            onTap: () => widget.onEmail(email),
          ),
        ];
      case 'WHATSAPP':
        return [
          _CardAction(
            label: 'WhatsApp',
            icon: null,
            svgAsset: _kWhatsAppSvg,
            color: Colors.green,
            onTap: () => widget.onWhatsApp(phone),
          ),
        ];
      case 'FOLLOW_UP':
        return [
          _CardAction(
            label: 'Call',
            icon: Icons.call_rounded,
            color: Colors.orange,
            onTap: () => widget.onCall(phone),
          ),
          _CardAction(
            label: 'WhatsApp',
            icon: null,
            svgAsset: _kWhatsAppSvg,
            color: Colors.green,
            onTap: () => widget.onWhatsApp(phone),
          ),
        ];
      case 'REMINDER':
        return [
          _CardAction(
            label: 'Call',
            icon: Icons.call_rounded,
            color: Colors.orange,
            onTap: () => widget.onCall(phone),
          ),
          _CardAction(
            label: 'Email',
            icon: Icons.email_rounded,
            color: Colors.blue,
            onTap: () => widget.onEmail(email),
          ),
        ];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final due = item.dueDate;
    final now = DateTime.now();
    final isToday =
        due.year == now.year && due.month == now.month && due.day == now.day;

    final dueStr = isToday
        ? 'Today  ${due.hour.toString().padLeft(2, '0')}:${due.minute.toString().padLeft(2, '0')}'
        : '${due.day.toString().padLeft(2, '0')} ${_months[due.month - 1]} ${due.year}  '
            '${due.hour.toString().padLeft(2, '0')}:${due.minute.toString().padLeft(2, '0')}';

    final actions = _buildActions();

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: ScaleTransition(
          scale: _scale,
          child: GestureDetector(
            onTapDown: (_) => _pressCtrl.forward(),
            onTapUp: (_) => _pressCtrl.reverse(),
            onTapCancel: () => _pressCtrl.reverse(),
            child: ScaleTransition(
              scale: _pressScale,
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.cborder),
                  boxShadow: [
                    BoxShadow(
                      color: widget.typeColor.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Colour accent bar
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            widget.typeColor,
                            widget.typeColor.withOpacity(0.3),
                          ]),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title row
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: widget.typeColor.withOpacity(.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child:
                                      Center(child: _typeIconWidget(size: 20)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                          color: AppColors.cdark,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Row(children: [
                                        const Icon(Icons.person_outline_rounded,
                                            size: 11, color: AppColors.ctext),
                                        const SizedBox(width: 3),
                                        Expanded(
                                          child: Text(
                                            item.assignedToName,
                                            style: const TextStyle(
                                                fontSize: 11,
                                                color: AppColors.ctext),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ]),
                                      // Show phone if available
                                      if (widget.phone.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Row(children: [
                                          const Icon(Icons.call_rounded,
                                              size: 11, color: AppColors.ctext),
                                          const SizedBox(width: 3),
                                          Text(
                                            widget.phone,
                                            style: const TextStyle(
                                                fontSize: 11,
                                                color: AppColors.ctext),
                                          ),
                                        ]),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Type badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: widget.typeColor.withOpacity(.10),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color:
                                            widget.typeColor.withOpacity(.30),
                                        width: .8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (widget.typeIcon == null) ...[
                                        SvgPicture.string(
                                          _kWhatsAppSvg,
                                          width: 10,
                                          height: 10,
                                          colorFilter: ColorFilter.mode(
                                              widget.typeColor,
                                              BlendMode.srcIn),
                                        ),
                                        const SizedBox(width: 4),
                                      ],
                                      Text(widget.typeLabel,
                                          style: TextStyle(
                                              color: widget.typeColor,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700)),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),
                            Divider(
                                height: 1,
                                color: AppColors.cborder.withOpacity(0.6)),
                            const SizedBox(height: 12),

                            // Date + status row
                            Row(children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: isToday
                                      ? AppColors.c1.withOpacity(0.08)
                                      : AppColors.cxl,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isToday
                                        ? AppColors.c1.withOpacity(0.25)
                                        : AppColors.cborder,
                                  ),
                                ),
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.schedule_rounded,
                                          size: 12,
                                          color: isToday
                                              ? AppColors.c1
                                              : AppColors.ctext),
                                      const SizedBox(width: 5),
                                      Text(dueStr,
                                          style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: isToday
                                                  ? AppColors.c1
                                                  : AppColors.ctext)),
                                    ]),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: widget.statusColor.withOpacity(.10),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color:
                                          widget.statusColor.withOpacity(.30),
                                      width: .8),
                                ),
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(widget.statusIcon,
                                          size: 11, color: widget.statusColor),
                                      const SizedBox(width: 4),
                                      Text(
                                        item.status[0].toUpperCase() +
                                            item.status
                                                .substring(1)
                                                .toLowerCase(),
                                        style: TextStyle(
                                            color: widget.statusColor,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ]),
                              ),
                            ]),

                            // Action buttons
                            if (actions.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Row(
                                children: actions
                                    .map((a) => Padding(
                                          padding:
                                              const EdgeInsets.only(right: 8),
                                          child: _actionBtn(a),
                                        ))
                                    .toList(),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _actionBtn(_CardAction a) => GestureDetector(
        onTap: a.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: a.color.withOpacity(.10),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: a.color.withOpacity(.35), width: .8),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (a.svgAsset != null)
              SvgPicture.string(
                a.svgAsset!,
                width: 13,
                height: 13,
                colorFilter: ColorFilter.mode(a.color, BlendMode.srcIn),
              )
            else
              Icon(a.icon, color: a.color, size: 13),
            const SizedBox(width: 5),
            Text(a.label,
                style: TextStyle(
                    color: a.color, fontSize: 11, fontWeight: FontWeight.w700)),
          ]),
        ),
      );
}

// ── Card action model ──────────────────────────────────────────────────────────
class _CardAction {
  final String label;
  final IconData? icon;
  final String? svgAsset;
  final Color color;
  final VoidCallback onTap;

  const _CardAction({
    required this.label,
    required this.icon,
    this.svgAsset,
    required this.color,
    required this.onTap,
  });
}
