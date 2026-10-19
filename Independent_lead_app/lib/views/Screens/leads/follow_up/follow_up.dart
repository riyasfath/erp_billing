import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pokakbilling/viewmodels/setup/followup_viewmodel.dart';
import 'package:pokakbilling/views/Screens/leads/follow_up/add_followup_screen.dart';
import 'package:pokakbilling/views/Screens/leads/lead_screens/leads_bottomBar.dart';
import 'package:pokakbilling/views/Screens/leads/lead_screens/leadsviewscreen.dart';
import 'package:provider/provider.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/lead_viewmodel.dart';
import 'package:pokakbilling/models/data-models/followup_model.dart';
import 'package:pokakbilling/models/data-models/lead_model.dart';
import 'package:url_launcher/url_launcher.dart';

// ─── WhatsApp SVG (matches home screen exactly) ───────────────────────────────
const String _kWhatsAppSvg = '''
<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
  <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347z"/>
  <path d="M12 0C5.373 0 0 5.373 0 12c0 2.125.558 4.122 1.528 5.855L.057 23.885a.5.5 0 00.611.611l6.101-1.459A11.945 11.945 0 0012 24c6.627 0 12-5.373 12-12S18.627 0 12 0zm0 21.818a9.818 9.818 0 01-5.012-1.378l-.36-.214-3.724.89.908-3.64-.235-.374A9.818 9.818 0 0112 2.182c5.428 0 9.818 4.39 9.818 9.818 0 5.429-4.39 9.818-9.818 9.818z"/>
</svg>
''';

class FollowUp extends StatefulWidget {
  const FollowUp({super.key});

  @override
  State<FollowUp> createState() => _FollowUpState();
}

class _FollowUpState extends State<FollowUp> with TickerProviderStateMixin {
  int _selectedTab = 0;
  String _search = '';
  DateTime? _filterDateFrom;
  DateTime? _filterDateTo;

  late final AnimationController _headerCtrl;
  late final AnimationController _bodyCtrl;
  late final Animation<double> _headerFade;
  late final Animation<Offset> _headerSlide;
  late final Animation<double> _bodyFade;
  late final Animation<Offset> _bodySlide;

  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    _selectedTab = 0;
    _search = '';
    _filterDateFrom = null;
    _filterDateTo = null;

    _headerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 650));
    _headerFade = CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(
            begin: const Offset(0, -0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut));

    _bodyCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 650));
    _bodyFade = CurvedAnimation(parent: _bodyCtrl, curve: Curves.easeOut);
    _bodySlide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _bodyCtrl, curve: Curves.easeOut));

    _headerCtrl.forward();
    Future.delayed(
        const Duration(milliseconds: 200), () => _bodyCtrl.forward());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = Provider.of<FollowupViewmodel>(context, listen: false);
      vm.fetchFollowups();
    });
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    _bodyCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  int _safeLeadId(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  LeadModel _emptyLeadModel() => LeadModel(
        id: 0,
        leadId: '0',
        name: 'Unknown Lead',
        company: '',
        email: '',
        phone: '',
        status: 'NEW',
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        assignedToName: null,
        title: null,
        description: null,
        address: null,
        city: null,
        state: null,
        country: null,
        location: null,
        enquiry: null,
        projectRequirements: null,
        additionalNotes: null,
        source: null,
        assignedTo: null,
      );

  LeadModel _findLead(int followupLeadId, List<LeadModel> leads) {
    try {
      return leads.firstWhere((l) =>
          _safeLeadId(l.leadId) == followupLeadId || l.id == followupLeadId);
    } catch (_) {
      return _emptyLeadModel();
    }
  }

  DateTime? _parseDate(String? s) {
    if (s == null || s.trim().isEmpty) return null;
    try {
      return DateTime.parse(s);
    } catch (_) {
      try {
        final parts = s.split(RegExp(r'[-/]'));
        if (parts.length >= 3) {
          return DateTime(
            int.tryParse(parts[0]) ?? 0,
            int.tryParse(parts[1]) ?? 1,
            int.tryParse(parts[2]) ?? 1,
          );
        }
      } catch (_) {}
    }
    return null;
  }

  bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isAfterOrSame(DateTime date, DateTime from) {
    final d = DateTime(date.year, date.month, date.day);
    final f = DateTime(from.year, from.month, from.day);
    return !d.isBefore(f);
  }

  bool _isBeforeOrSame(DateTime date, DateTime to) {
    final d = DateTime(date.year, date.month, date.day);
    final t = DateTime(to.year, to.month, to.day);
    return !d.isAfter(t);
  }

  String _prettyDate(String? s) {
    final d = _parseDate(s);
    if (d == null) return '—';
    return '${d.day.toString().padLeft(2, '0')} '
        '${_monthAbbr(d.month)} ${d.year}';
  }

  String _fmtShortDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';

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
      'Dec'
    ];
    return months[m - 1];
  }

  // ── URL launchers ─────────────────────────────────────────────────────────
  Future<void> _launchWhatsApp(String phone) async {
    final cleaned = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleaned.isEmpty) return;
    final uri = Uri.parse('https://wa.me/$cleaned');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchCall(String phone) async {
    final cleaned = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleaned.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: cleaned);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _launchEmail(String email) async {
    if (email.trim().isEmpty) return;
    final uri = Uri(scheme: 'mailto', path: email.trim());
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  // ── Mark Done: optimistic update + API call ───────────────────────────────
  Future<void> _onMarkDone(FollowupModel f, FollowupViewmodel vm) async {
    if (f.status.toUpperCase() == 'COMPLETED') return;

    vm.optimisticallyMarkCompleted(f.id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Follow-up marked as done'),
          backgroundColor: AppColors.c1,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }

    final success = await vm.markCompleted(f.id);
    if (!success && mounted) {
      await vm.fetchFollowups();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to update. Please try again.'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final initial = DateTimeRange(
      start: _filterDateFrom ?? now,
      end: _filterDateTo ?? now,
    );
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: initial,
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
        _filterDateFrom = picked.start;
        _filterDateTo = picked.end;
      });
    }
  }

  void _clearDateFilter() {
    setState(() {
      _filterDateFrom = null;
      _filterDateTo = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<FollowupViewmodel, LeadViewmodel>(
      builder: (context, followupVm, leadVm, child) {
        final leads = leadVm.leadList;
        final today = DateTime.now();
        final todayOnly = DateTime(today.year, today.month, today.day);
        final followups = followupVm.followups;

        int todayCount = 0,
            upcomingCount = 0,
            overdueCount = 0,
            completedCount = 0;

        for (final f in followups) {
          final completed = f.status.toUpperCase() == 'COMPLETED';
          if (completed) {
            completedCount++;
            continue;
          }

          final fDate = _parseDate(f.date);
          if (fDate == null) continue;
          final fOnly = DateTime(fDate.year, fDate.month, fDate.day);

          if (_isSameDate(fOnly, todayOnly)) {
            todayCount++;
          } else if (fOnly.isAfter(todayOnly)) {
            upcomingCount++;
          } else {
            overdueCount++;
          }
        }

        final hasDateFilter = _filterDateFrom != null || _filterDateTo != null;

        final filtered = followups.where((f) {
          final q = _search.trim().toLowerCase();
          if (q.isNotEmpty) {
            final lead = _findLead(f.lead, leads);
            if (!lead.name.toLowerCase().contains(q) &&
                !f.title.toLowerCase().contains(q)) return false;
          }

          final fDate = _parseDate(f.date);
          final completed = f.status.toUpperCase() == 'COMPLETED';

          // bool passesTab = false;
          // if (_selectedTab == 0) {
          //   passesTab =
          //       !completed && fDate != null && _isSameDate(fDate, todayOnly);
          // } else if (_selectedTab == 1) {
          //   passesTab = !completed && fDate != null && fDate.isAfter(todayOnly);
          // } else if (_selectedTab == 2) {
          //   passesTab = completed;
          // } else {
          //   passesTab =
          //       !completed && fDate != null && fDate.isBefore(todayOnly);
          // }
          bool passesTab = false;
          if (_selectedTab == 0) {
            passesTab = true; // All → show everything
          } else if (_selectedTab == 1) {
            passesTab =
                !completed && fDate != null && _isSameDate(fDate, todayOnly);
          } else if (_selectedTab == 2) {
            passesTab = !completed && fDate != null && fDate.isAfter(todayOnly);
          } else if (_selectedTab == 3) {
            passesTab = completed;
          } else if (_selectedTab == 4) {
            passesTab =
                !completed && fDate != null && fDate.isBefore(todayOnly);
          }

          if (!passesTab) return false;

          if (_selectedTab != 0 && hasDateFilter && fDate != null) {
            if (_filterDateFrom != null &&
                !_isAfterOrSame(fDate, _filterDateFrom!)) {
              return false;
            }
            if (_filterDateTo != null &&
                !_isBeforeOrSame(fDate, _filterDateTo!)) {
              return false;
            }
          }

          return true;
        }).toList();

        final sw = MediaQuery.of(context).size.width;
        final topPad = MediaQuery.of(context).padding.top;

        return Scaffold(
          backgroundColor: AppColors.white,
          bottomNavigationBar: const LeadsBottomBar(index: 3),
          body: Column(
            children: [
              FadeTransition(
                opacity: _headerFade,
                child: SlideTransition(
                  position: _headerSlide,
                  child: _buildHeader(
                    context,
                    topPad,
                    sw,
                    followupVm,
                    todayCount,
                    upcomingCount,
                    overdueCount,
                    completedCount,
                    followups.length,
                  ),
                ),
              ),
              Expanded(
                child: FadeTransition(
                  opacity: _bodyFade,
                  child: SlideTransition(
                    position: _bodySlide,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.cxl,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(28),
                          topRight: Radius.circular(28),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(28),
                          topRight: Radius.circular(28),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 40,
                              height: 4,
                              margin: const EdgeInsets.only(top: 12, bottom: 4),
                              decoration: BoxDecoration(
                                color: AppColors.c1.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            _buildFilterBar(
                              context,
                              todayCount,
                              upcomingCount,
                              completedCount,
                              overdueCount,
                              hasDateFilter,
                              followups.length, // NEW
                            ),
                            Expanded(
                              child: followupVm.loading
                                  ? Center(
                                      child: CircularProgressIndicator(
                                        color: AppColors.c1,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : filtered.isEmpty
                                      ? _buildEmptyState()
                                      : ListView.builder(
                                          physics:
                                              const BouncingScrollPhysics(),
                                          padding: const EdgeInsets.fromLTRB(
                                              16, 8, 16, 32),
                                          itemCount: filtered.length,
                                          itemBuilder: (_, i) {
                                            final f = filtered[i];
                                            final lead =
                                                _findLead(f.lead, leads);
                                            return _AnimatedFollowCard(
                                              key: ValueKey(
                                                  '${f.id}_${f.status}'),
                                              followup: f,
                                              lead: lead,
                                              delay: Duration(
                                                  milliseconds: 40 + i * 60),
                                              isDone: f.status.toUpperCase() ==
                                                  'COMPLETED',
                                              followupCount: followupVm
                                                  .followups
                                                  .where((item) =>
                                                      item.lead == lead.id)
                                                  .length,
                                              prettyDate: _prettyDate(f.date),
                                              onViewLead: () => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      LeadsViewScreen(
                                                          lead: lead),
                                                ),
                                              ),
                                              onMarkDone: () =>
                                                  _onMarkDone(f, followupVm),
                                              onWhatsApp: () =>
                                                  _launchWhatsApp(lead.phone),
                                              onCall: () =>
                                                  _launchCall(lead.phone),
                                              onEmail: () =>
                                                  _launchEmail(lead.email),
                                            );
                                          },
                                        ),
                            ),
                          ],
                        ),
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
  Widget _buildHeader(
    BuildContext context,
    double topPad,
    double sw,
    FollowupViewmodel followupVm,
    int todayCount,
    int upcomingCount,
    int overdueCount,
    int completedCount,
    int total,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: topPad + 14,
        bottom: 24,
        left: sw * 0.05,
        right: sw * 0.05,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: const Border(
          bottom: BorderSide(color: AppColors.cborder, width: 1.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Follow-ups',
                      style: TextStyle(
                        color: AppColors.cdark,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$total total follow-ups',
                      style: const TextStyle(
                        color: AppColors.ctext,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () async {
                  setState(() {
                    _search = '';
                    _searchCtrl.clear();
                    _filterDateFrom = null;
                    _filterDateTo = null;
                  });
                  final res = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(builder: (_) => const AddFollowUp()),
                  );
                  if (res == true) followupVm.fetchFollowups();
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: AppColors.c1,
                    borderRadius: BorderRadius.circular(22),
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
                      Icon(Icons.add_rounded, color: AppColors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Add New',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              // _headerStat('All', followups.length, AppColors.cdark),
              _headerStat('All', total, AppColors.cdark),

              const SizedBox(width: 8),
              _headerStat('Today', todayCount, AppColors.c1),
              const SizedBox(width: 8),
              _headerStat('Upcoming', upcomingCount, AppColors.ctext),
              const SizedBox(width: 8),
              _headerStat('Overdue', overdueCount, Colors.red.shade400),
              const SizedBox(width: 8),
              _headerStat('Done', completedCount, Colors.green.shade500),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerStat(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.20)),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: AppColors.ctext.withOpacity(0.70),
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Filter bar ────────────────────────────────────────────────────────────
  Widget _buildFilterBar(
    BuildContext context,
    int todayCount,
    int upcomingCount,
    int completedCount,
    int overdueCount,
    bool hasDateFilter,
    int allCount, // NEW
  ) {
    final tabs = [
      _TabData('All', allCount), // NEW
      _TabData('Today', todayCount),
      _TabData('Upcoming', upcomingCount),
      _TabData('Done', completedCount),
      _TabData('Overdue', overdueCount),
    ];

    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        children: [
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.cxl,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.cborder),
            ),
            padding: const EdgeInsets.all(3),
            child: Row(
              children: tabs.asMap().entries.map((e) {
                final i = e.key;
                final tab = e.value;
                final isSelected = _selectedTab == i;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _selectedTab = i;
                      _filterDateFrom = null;
                      _filterDateTo = null;
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      decoration: isSelected
                          ? BoxDecoration(
                              color: AppColors.c1,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.c1.withOpacity(0.25),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            )
                          : null,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              tab.label,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? AppColors.white
                                    : AppColors.ctext,
                              ),
                            ),
                            Text(
                              '${tab.count}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: isSelected
                                    ? AppColors.white
                                    : AppColors.ctext.withOpacity(0.60),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.cxl,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cborder),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Icon(Icons.search_rounded,
                          size: 16, color: AppColors.ctext),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchCtrl,
                          onChanged: (v) => setState(() => _search = v),
                          style:
                              TextStyle(fontSize: 13, color: AppColors.cdark),
                          decoration: InputDecoration(
                            hintText: 'Search follow-ups…',
                            hintStyle: TextStyle(
                              fontSize: 12,
                              color: AppColors.ctext.withOpacity(0.60),
                            ),
                            border: InputBorder.none,
                            isCollapsed: true,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 0),
                          ),
                        ),
                      ),
                      if (_search.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _searchCtrl.clear();
                            setState(() => _search = '');
                          },
                          child: Icon(Icons.close_rounded,
                              size: 14, color: AppColors.c1),
                        ),
                    ],
                  ),
                ),
              ),
              if (_selectedTab != 0) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _pickDateRange,
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: hasDateFilter
                          ? AppColors.c1.withOpacity(0.10)
                          : AppColors.cxl,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: hasDateFilter
                            ? AppColors.c1.withOpacity(0.40)
                            : AppColors.cborder,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.date_range_rounded,
                            size: 14,
                            color:
                                hasDateFilter ? AppColors.c1 : AppColors.ctext),
                        const SizedBox(width: 6),
                        Text(
                          hasDateFilter &&
                                  _filterDateFrom != null &&
                                  _filterDateTo != null
                              ? '${_fmtShortDate(_filterDateFrom!)}–${_fmtShortDate(_filterDateTo!)}'
                              : 'Date',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color:
                                hasDateFilter ? AppColors.c1 : AppColors.ctext,
                          ),
                        ),
                        if (hasDateFilter) ...[
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: _clearDateFilter,
                            child: Icon(Icons.close_rounded,
                                size: 12, color: AppColors.c1),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (_selectedTab != 0 && hasDateFilter) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.c1.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.c1.withOpacity(0.20)),
              ),
              child: Row(children: [
                Icon(Icons.date_range_rounded, size: 14, color: AppColors.c1),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _filterDateFrom != null && _filterDateTo != null
                        ? '${_prettyDate(_filterDateFrom!.toIso8601String())}  →  ${_prettyDate(_filterDateTo!.toIso8601String())}'
                        : _filterDateFrom != null
                            ? 'From  ${_prettyDate(_filterDateFrom!.toIso8601String())}'
                            : 'To  ${_prettyDate(_filterDateTo!.toIso8601String())}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.c1,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _clearDateFilter,
                  child:
                      Icon(Icons.close_rounded, size: 16, color: AppColors.c1),
                ),
              ]),
            ),
          ],
        ],
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    final labels = ['Today', 'Upcoming', 'Completed', 'Overdue'];
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.c1.withOpacity(0.08),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.cborder),
            ),
            child: Icon(Icons.event_note_rounded,
                color: AppColors.c1.withOpacity(0.55), size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            'No ${labels[_selectedTab]} Follow-ups',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.cdark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Nothing scheduled for this filter',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.ctext.withOpacity(0.60),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tab data model ───────────────────────────────────────────────────────────
class _TabData {
  final String label;
  final int count;
  const _TabData(this.label, this.count);
}

// ─── Animated follow-up card ──────────────────────────────────────────────────
class _AnimatedFollowCard extends StatefulWidget {
  final FollowupModel followup;
  final LeadModel lead;
  final Duration delay;
  final bool isDone;
  final int followupCount;
  final String prettyDate;
  final VoidCallback onViewLead;
  final VoidCallback onMarkDone;
  final VoidCallback onWhatsApp;
  final VoidCallback onCall;
  final VoidCallback onEmail;

  const _AnimatedFollowCard({
    super.key,
    required this.followup,
    required this.lead,
    required this.delay,
    required this.isDone,
    required this.followupCount,
    required this.prettyDate,
    required this.onViewLead,
    required this.onMarkDone,
    required this.onWhatsApp,
    required this.onCall,
    required this.onEmail,
  });

  @override
  State<_AnimatedFollowCard> createState() => _AnimatedFollowCardState();
}

class _AnimatedFollowCardState extends State<_AnimatedFollowCard>
    with TickerProviderStateMixin {
  late final AnimationController _entranceCtrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  late final Animation<double> _scale;

  late final AnimationController _pressCtrl;
  late final Animation<double> _pressScale;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 480));
    _fade = CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.10), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut));
    _scale = Tween<double>(begin: 0.95, end: 1.0).animate(
        CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOutBack));

    _pressCtrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 100),
        lowerBound: 0,
        upperBound: 1);
    _pressScale = Tween<double>(begin: 1.0, end: 0.97).animate(_pressCtrl);

    Future.delayed(widget.delay, () {
      if (mounted) _entranceCtrl.forward();
    });
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.followup;
    final lead = widget.lead;
    final leadName = lead.name.isNotEmpty ? lead.name : 'Lead #${f.lead}';
    final phone = lead.phone.isNotEmpty ? lead.phone : '—';
    final typeLower = f.type.toLowerCase();

    final IconData typeIcon = typeLower == 'call'
        ? Icons.call_rounded
        : typeLower == 'email'
            ? Icons.email_rounded
            : Icons.event_rounded;

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
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: widget.isDone
                        ? AppColors.c1.withOpacity(0.40)
                        : AppColors.c1.withOpacity(0.15),
                    width: widget.isDone ? 1.5 : 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.isDone
                          ? AppColors.c1.withOpacity(0.12)
                          : AppColors.c1.withOpacity(0.07),
                      blurRadius: widget.isDone ? 16 : 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Top accent bar
                    Container(
                      height: 3,
                      decoration: BoxDecoration(
                        color: widget.isDone
                            ? Colors.green.shade400
                            : AppColors.c1,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Lead name row
                          Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: AppColors.c1.withOpacity(0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    leadName.isNotEmpty
                                        ? leadName[0].toUpperCase()
                                        : '?',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.c1,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      leadName,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.cdark,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      phone,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color:
                                            AppColors.ctext.withOpacity(0.60),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (widget.isDone)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                            color: Colors.green.shade300),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.check_circle_rounded,
                                              size: 10,
                                              color: Colors.green.shade600),
                                          const SizedBox(width: 3),
                                          Text(
                                            'Done',
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.green.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  else
                                    Text(
                                      '${widget.followupCount} follow-up${widget.followupCount != 1 ? 's' : ''}',
                                      style: TextStyle(
                                        fontSize: 9,
                                        color:
                                            AppColors.ctext.withOpacity(0.50),
                                      ),
                                    ),
                                  const SizedBox(height: 4),
                                  GestureDetector(
                                    onTap: widget.onViewLead,
                                    child: Text(
                                      'View Lead →',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: AppColors.c1,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),
                          Divider(
                              height: 1, color: AppColors.c1.withOpacity(0.10)),
                          const SizedBox(height: 10),

                          // Follow-up type + title + date row
                          Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: AppColors.c1.withOpacity(0.10),
                                  borderRadius: BorderRadius.circular(9),
                                ),
                                child: Icon(typeIcon,
                                    size: 15, color: AppColors.c1),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      f.type[0].toUpperCase() +
                                          f.type.substring(1),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.cdark,
                                      ),
                                    ),
                                    if (f.notes.isNotEmpty)
                                      Text(
                                        f.notes,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color:
                                              AppColors.ctext.withOpacity(0.55),
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.cxl,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.cborder),
                                ),
                                child: Text(
                                  widget.prettyDate,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.ctext.withOpacity(0.70),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // ── Action buttons row ────────────────────────────
                          Row(
                            children: [
                              // WhatsApp — SVG icon (matches home screen exactly)
                              _WaActionBtn(onTap: widget.onWhatsApp),
                              const SizedBox(width: 6),
                              _ActionBtn(
                                icon: Icons.call_rounded,
                                label: 'Call',
                                color: AppColors.cdark,
                                onTap: widget.onCall,
                              ),
                              const SizedBox(width: 6),
                              _ActionBtn(
                                icon: Icons.email_rounded,
                                label: 'Email',
                                color: AppColors.c1,
                                onTap: widget.onEmail,
                              ),
                              const Spacer(),
                              if (!widget.isDone)
                                GestureDetector(
                                  onTap: widget.onMarkDone,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 7),
                                    decoration: BoxDecoration(
                                      color: AppColors.c1,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.c1.withOpacity(0.25),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        )
                                      ],
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.check_rounded,
                                            size: 12, color: AppColors.white),
                                        SizedBox(width: 4),
                                        Text(
                                          'Mark Done',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
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
    );
  }
}

// ─── WhatsApp action button (SVG icon, matches home screen style) ─────────────
class _WaActionBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _WaActionBtn({required this.onTap});

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF25D366); // WhatsApp green
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.20)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.string(
              _kWhatsAppSvg,
              width: 12,
              height: 12,
              colorFilter: const ColorFilter.mode(color, BlendMode.srcIn),
            ),
            const SizedBox(width: 4),
            const Text(
              'WA',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Small action button ──────────────────────────────────────────────────────
class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.20)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
