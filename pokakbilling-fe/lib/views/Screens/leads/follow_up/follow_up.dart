import 'package:flutter/material.dart';
import 'package:pokakbilling/ERP_UI_KIT.dart';
import 'package:pokakbilling/viewmodels/setup/followup_viewmodel.dart';
import 'package:pokakbilling/views/Screens/leads/follow_up/add_followup_screen.dart';
import 'package:pokakbilling/views/Screens/leads/lead_screens/leads_bottomBar.dart';
import 'package:pokakbilling/views/Screens/leads/lead_screens/leadsviewscreen.dart';
import 'package:provider/provider.dart';
import 'package:pokakbilling/viewmodels/lead_viewmodel.dart';
import 'package:pokakbilling/models/data-models/followup_model.dart';
import 'package:pokakbilling/models/data-models/lead_model.dart';
import 'package:pokakbilling/core/api/dio_client.dart';
import 'package:pokakbilling/core/api/api_constants.dart';
import 'package:url_launcher/url_launcher.dart';

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

  // ── Track which IDs are currently being marked done ───────────────────────
  final Set<int> _markingDoneIds = {};

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
      Provider.of<FollowupViewmodel>(context, listen: false).fetchFollowups();
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
  LeadModel _emptyLead() => LeadModel(
        leadId: 0,
        name: '',
        phone: '',
        enquiry: '',
        leadNumber: '',
        leadStatus: '',
        notes: '',
        createdAt: '',
        date: '',
      );

  DateTime? _parseDate(String? s) {
    if (s == null || s.trim().isEmpty) return null;
    try {
      return DateTime.parse(s);
    } catch (_) {
      try {
        final parts = s.split(RegExp(r'[-/]'));
        if (parts.length >= 3) {
          return DateTime(int.tryParse(parts[0]) ?? 0,
              int.tryParse(parts[1]) ?? 1, int.tryParse(parts[2]) ?? 1);
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
    return '${d.day.toString().padLeft(2, '0')} ${_monthAbbr(d.month)} ${d.year}';
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

  bool _isCompleted(FollowupModel f) => f.status.toLowerCase() == 'completed';

  bool _isOverdue(FollowupModel f) {
    if (_isCompleted(f)) return false;
    final d = _parseDate(f.date);
    if (d == null) return false;
    final now = DateTime.now();
    return DateTime(d.year, d.month, d.day)
        .isBefore(DateTime(now.year, now.month, now.day));
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

  // ── Mark Done via PATCH API ───────────────────────────────────────────────
  Future<void> _onMarkDone(FollowupModel f) async {
    if (_isCompleted(f)) return;
    if (_markingDoneIds.contains(f.id)) return;

    setState(() => _markingDoneIds.add(f.id));

    try {
      final dio = await DioClient().getAuthorizedDio();
      final endpoint = '${ApiConstants.followupsEndpoint}${f.id}/';
      final response = await dio.patch(endpoint, data: {'status': 'completed'});

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          mounted) {
        final vm = Provider.of<FollowupViewmodel>(context, listen: false);

        final idx = vm.followups.indexWhere((x) => x.id == f.id);
        if (idx != -1) {
          final updated = FollowupModel(
            id: f.id,
            lead: f.lead,
            title: f.title,
            date: f.date,
            time: f.time,
            status: 'completed',
            type: f.type,
            notes: f.notes,
          );
          vm.followups[idx] = updated;
          vm.notifyListeners();
        }

        if (mounted) {
          erpToast(context, 'Follow-up marked as completed',
              color: ErpColors.green);
        }
      } else {
        if (mounted) {
          erpToast(context, 'Failed to update. Please try again.',
              color: ErpColors.red, icon: Icons.error_outline_rounded);
        }
      }
    } catch (e) {
      if (mounted) {
        erpToast(context, 'Error: ${e.toString()}',
            color: ErpColors.red, icon: Icons.error_outline_rounded);
      }
    } finally {
      if (mounted) setState(() => _markingDoneIds.remove(f.id));
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
      builder: (context, child) => erpPickerTheme(context, child),
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
          if (_isCompleted(f)) {
            completedCount++;
            continue;
          }
          final fd = _parseDate(f.date);
          if (fd == null) continue;
          final fOnly = DateTime(fd.year, fd.month, fd.day);
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
            final lead = leads.firstWhere(
              (l) => l.leadId == f.lead,
              orElse: () => _emptyLead(),
            );
            if (!lead.name.toLowerCase().contains(q) &&
                !f.title.toLowerCase().contains(q)) {
              return false;
            }
          }

          final fDate = _parseDate(f.date);
          final completed = _isCompleted(f);

          bool passesTab = false;
          if (_selectedTab == 0) {
            passesTab = true;
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
          backgroundColor: ErpColors.pageBg,
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
                    child: Column(
                      children: [
                        _buildFilterBar(
                          context,
                          todayCount,
                          upcomingCount,
                          completedCount,
                          overdueCount,
                          hasDateFilter,
                          followups.length,
                        ),
                        Expanded(
                          child: followupVm.loading
                              ? const Center(
                                  child: SizedBox(
                                    width: 28,
                                    height: 28,
                                    child: CircularProgressIndicator(
                                      color: ErpColors.cyan,
                                      strokeWidth: 2.5,
                                    ),
                                  ),
                                )
                              : filtered.isEmpty
                                  ? _buildEmptyState()
                                  : ListView.builder(
                                      physics: const BouncingScrollPhysics(),
                                      padding: EdgeInsets.fromLTRB(
                                          sw * 0.04, 6, sw * 0.04, 32),
                                      itemCount: filtered.length,
                                      itemBuilder: (_, i) {
                                        final f = filtered[i];
                                        final lead = leads.firstWhere(
                                          (l) => l.leadId == f.lead,
                                          orElse: () => _emptyLead(),
                                        );
                                        final followupCount = followupVm
                                            .followups
                                            .where(
                                                (item) => item.lead == f.lead)
                                            .length;
                                        return ErpFadeIn(
                                          key: ValueKey('${f.id}_${f.status}'),
                                          index: i < 10 ? i : 10,
                                          child: _FollowCard(
                                            followup: f,
                                            lead: lead,
                                            isDone: _isCompleted(f),
                                            isOverdue: _isOverdue(f),
                                            isMarkingDone:
                                                _markingDoneIds.contains(f.id),
                                            followupCount: followupCount,
                                            prettyDate: _prettyDate(f.date),
                                            onViewLead: () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    LeadsViewScreen(lead: lead),
                                              ),
                                            ),
                                            onMarkDone: () => _onMarkDone(f),
                                            onWhatsApp: () =>
                                                _launchWhatsApp(lead.phone),
                                            onCall: () =>
                                                _launchCall(lead.phone),
                                            onEmail: () => _launchEmail(
                                                lead.emailId ?? ''),
                                          ),
                                        );
                                      },
                                    ),
                        ),
                      ],
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
          // Decorative bubbles + watermark
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
            right: 110,
            top: topPad + 4,
            child: Transform.rotate(
              angle: -0.25,
              child: Icon(Icons.event_repeat_rounded,
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
              top: topPad + 14,
              bottom: 20,
              left: sw * 0.045,
              right: sw * 0.045,
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
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$total total follow-ups',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ErpPressable(
                      onTap: () async {
                        setState(() {
                          _search = '';
                          _searchCtrl.clear();
                          _filterDateFrom = null;
                          _filterDateTo = null;
                        });
                        final res = await Navigator.of(context).push<bool>(
                          MaterialPageRoute(
                              builder: (_) => const AddFollowUp()),
                        );
                        if (res == true) followupVm.fetchFollowups();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
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
                            Icon(Icons.add_rounded,
                                color: ErpColors.cyanDeep, size: 18),
                            SizedBox(width: 4),
                            Text(
                              'Add New',
                              style: TextStyle(
                                color: ErpColors.cyanDeep,
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
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
                    _headerStat('All', total, Icons.layers_rounded),
                    const SizedBox(width: 7),
                    _headerStat('Today', todayCount, Icons.today_rounded),
                    const SizedBox(width: 7),
                    _headerStat(
                        'Upcoming', upcomingCount, Icons.upcoming_rounded),
                    const SizedBox(width: 7),
                    _headerStat('Overdue', overdueCount,
                        Icons.warning_amber_rounded),
                    const SizedBox(width: 7),
                    _headerStat(
                        'Done', completedCount, Icons.check_circle_rounded),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerStat(String label, int count, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.9)),
            const SizedBox(height: 3),
            Text(
              '$count',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w900),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.88),
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
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
    int allCount,
  ) {
    final tabs = [
      _TabData('All', allCount, ErpColors.cyan),
      _TabData('Today', todayCount, ErpColors.blue),
      _TabData('Upcoming', upcomingCount, ErpColors.violet),
      _TabData('Done', completedCount, ErpColors.green),
      _TabData('Overdue', overdueCount, ErpColors.red),
    ];
    final sw = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.fromLTRB(sw * 0.04, 16, sw * 0.04, 10),
      child: Column(
        children: [
          // ── Segmented tabs ──────────────────────────────────────────────
          Container(
            height: 52,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: ErpColors.line),
              boxShadow: [
                BoxShadow(
                  color: ErpColors.cyan.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: tabs.asMap().entries.map((e) {
                final i = e.key;
                final tab = e.value;
                final isSelected = _selectedTab == i;
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() {
                      _selectedTab = i;
                      _filterDateFrom = null;
                      _filterDateTo = null;
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                      decoration: isSelected
                          ? BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  ErpColors.tint(tab.color, 0.2),
                                  tab.color
                                ],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: tab.color.withValues(alpha: 0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
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
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: isSelected
                                    ? Colors.white
                                    : ErpColors.slate,
                              ),
                            ),
                            Text(
                              '${tab.count}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: isSelected
                                    ? Colors.white
                                    : ErpColors.shade(tab.color, 0.1),
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

          // ── Search + date ───────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: ErpColors.line),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: ErpColors.cyan.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: const Icon(Icons.search_rounded,
                            size: 17, color: ErpColors.cyanDeep),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchCtrl,
                          cursorColor: ErpColors.cyan,
                          onChanged: (v) => setState(() => _search = v),
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: ErpColors.ink),
                          decoration: InputDecoration(
                            hintText: 'Search follow-ups…',
                            hintStyle: TextStyle(
                              fontSize: 13.5,
                              color: ErpColors.slate.withValues(alpha: 0.7),
                            ),
                            border: InputBorder.none,
                            isCollapsed: true,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 0),
                          ),
                        ),
                      ),
                      if (_search.isNotEmpty)
                        ErpPressable(
                          onTap: () {
                            _searchCtrl.clear();
                            setState(() => _search = '');
                          },
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: ErpColors.slate.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close_rounded,
                                size: 14, color: ErpColors.slate),
                          ),
                        ),
                      const SizedBox(width: 4),
                    ],
                  ),
                ),
              ),
              if (_selectedTab != 0) ...[
                const SizedBox(width: 8),
                ErpPressable(
                  onTap: _pickDateRange,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 46,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      gradient:
                          hasDateFilter ? ErpColors.headerGradient : null,
                      color: hasDateFilter ? null : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color:
                            hasDateFilter ? Colors.transparent : ErpColors.line,
                      ),
                      boxShadow: hasDateFilter
                          ? [
                              BoxShadow(
                                color: ErpColors.cyan.withValues(alpha: 0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : const [],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.date_range_rounded,
                            size: 17,
                            color: hasDateFilter
                                ? Colors.white
                                : ErpColors.cyanDeep),
                        const SizedBox(width: 6),
                        Text(
                          hasDateFilter &&
                                  _filterDateFrom != null &&
                                  _filterDateTo != null
                              ? '${_fmtShortDate(_filterDateFrom!)}–${_fmtShortDate(_filterDateTo!)}'
                              : 'Date',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: hasDateFilter
                                ? Colors.white
                                : ErpColors.cyanDeep,
                          ),
                        ),
                        if (hasDateFilter) ...[
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: _clearDateFilter,
                            child: const Icon(Icons.close_rounded,
                                size: 14, color: Colors.white),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),

          // ── Active date range banner ────────────────────────────────────
          if (_selectedTab != 0 && hasDateFilter) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ErpColors.cyan.withValues(alpha: 0.12),
                    ErpColors.cyan.withValues(alpha: 0.04),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                border:
                    Border.all(color: ErpColors.cyan.withValues(alpha: 0.25)),
              ),
              child: Row(children: [
                const Icon(Icons.date_range_rounded,
                    size: 16, color: ErpColors.cyanDeep),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _filterDateFrom != null && _filterDateTo != null
                        ? '${_prettyDate(_filterDateFrom!.toIso8601String())}  →  ${_prettyDate(_filterDateTo!.toIso8601String())}'
                        : _filterDateFrom != null
                            ? 'From  ${_prettyDate(_filterDateFrom!.toIso8601String())}'
                            : 'To  ${_prettyDate(_filterDateTo!.toIso8601String())}',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: ErpColors.cyanDeep,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _clearDateFilter,
                  child: const Icon(Icons.close_rounded,
                      size: 17, color: ErpColors.cyanDeep),
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
    const labels = ['All', 'Today', 'Upcoming', 'Completed', 'Overdue'];
    const colors = [
      ErpColors.cyan,
      ErpColors.blue,
      ErpColors.violet,
      ErpColors.green,
      ErpColors.red,
    ];
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.only(top: 50, bottom: 30),
        child: ErpEmptyState(
          icon: Icons.event_note_rounded,
          title: 'No ${labels[_selectedTab]} Follow-ups',
          subtitle: 'Nothing scheduled for this filter',
          color: colors[_selectedTab],
        ),
      ),
    );
  }
}

// ─── Tab data model ───────────────────────────────────────────────────────────
class _TabData {
  final String label;
  final int count;
  final Color color;
  const _TabData(this.label, this.count, this.color);
}

// ─── Follow-up card ───────────────────────────────────────────────────────────
class _FollowCard extends StatelessWidget {
  final FollowupModel followup;
  final LeadModel lead;
  final bool isDone;
  final bool isOverdue;
  final bool isMarkingDone;
  final int followupCount;
  final String prettyDate;
  final VoidCallback onViewLead;
  final VoidCallback onMarkDone;
  final VoidCallback onWhatsApp;
  final VoidCallback onCall;
  final VoidCallback onEmail;

  const _FollowCard({
    required this.followup,
    required this.lead,
    required this.isDone,
    required this.isOverdue,
    required this.isMarkingDone,
    required this.followupCount,
    required this.prettyDate,
    required this.onViewLead,
    required this.onMarkDone,
    required this.onWhatsApp,
    required this.onCall,
    required this.onEmail,
  });

  @override
  Widget build(BuildContext context) {
    final f = followup;
    final leadName = lead.name.isNotEmpty ? lead.name : 'Lead #${f.lead}';
    final phone = lead.phone.isNotEmpty ? lead.phone : '—';
    final (typeIcon, typeColor) = erpTypeStyle(f.type);
    final typeLabel = f.type.trim().isNotEmpty ? erpTitleCase(f.type) : 'Other';
    final avatarColor =
        ErpColors.rotation[f.lead.hashCode.abs() % ErpColors.rotation.length];

    final Color accent = isDone
        ? ErpColors.green
        : isOverdue
            ? ErpColors.red
            : typeColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDone
              ? ErpColors.green.withValues(alpha: 0.35)
              : ErpColors.line,
          width: isDone ? 1.4 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top accent bar
          Container(
            height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [ErpColors.tint(accent, 0.25), accent],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Lead row ──────────────────────────────────────────────
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            ErpColors.tint(avatarColor, 0.22),
                            avatarColor
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: avatarColor.withValues(alpha: 0.32),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          leadName.isNotEmpty
                              ? leadName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            leadName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: ErpColors.ink,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.phone_rounded,
                                  size: 12, color: ErpColors.slate),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  phone,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    color: ErpColors.slate,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (isDone)
                          const ErpStatusChip(
                              label: 'Done', color: ErpColors.green)
                        else if (isOverdue)
                          const ErpStatusChip(
                              label: 'Overdue', color: ErpColors.red)
                        else
                          Text(
                            '$followupCount follow-up${followupCount != 1 ? 's' : ''}',
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: ErpColors.slate,
                            ),
                          ),
                        const SizedBox(height: 6),
                        ErpPressable(
                          onTap: onViewLead,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: ErpColors.cyan.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'View Lead',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: ErpColors.cyanDeep,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                SizedBox(width: 2),
                                Icon(Icons.arrow_forward_rounded,
                                    size: 12, color: ErpColors.cyanDeep),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ── Type + notes + date ───────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: typeColor.withValues(alpha: 0.16)),
                  ),
                  child: Row(
                    children: [
                      ErpGradientTile(icon: typeIcon, color: typeColor, size: 38),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              typeLabel,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: ErpColors.ink,
                              ),
                            ),
                            if (f.notes.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                f.notes,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: ErpColors.slate,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      ErpMetaChip(
                        icon: Icons.calendar_today_rounded,
                        text: prettyDate,
                        color: isOverdue ? ErpColors.red : ErpColors.cyanDeep,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ── Action buttons ────────────────────────────────────────
                Row(
                  children: [
                    _ActionBtn(
                      icon: ErpIcons.whatsapp,
                      label: 'WA',
                      color: ErpColors.whatsapp,
                      onTap: onWhatsApp,
                    ),
                    const SizedBox(width: 6),
                    _ActionBtn(
                      icon: Icons.call_rounded,
                      label: 'Call',
                      color: ErpColors.cyan,
                      onTap: onCall,
                    ),
                    const SizedBox(width: 6),
                    _ActionBtn(
                      icon: Icons.email_rounded,
                      label: 'Email',
                      color: ErpColors.violet,
                      onTap: onEmail,
                    ),
                    const Spacer(),
                    if (!isDone)
                      ErpPressable(
                        onTap: isMarkingDone ? null : onMarkDone,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                ErpColors.tint(ErpColors.green, 0.2),
                                ErpColors.green,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: isMarkingDone
                                ? const []
                                : [
                                    BoxShadow(
                                      color: ErpColors.green
                                          .withValues(alpha: 0.35),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    )
                                  ],
                          ),
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: isMarkingDone ? 0.7 : 1,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isMarkingDone)
                                  const SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.5,
                                      color: Colors.white,
                                    ),
                                  )
                                else
                                  const Icon(Icons.check_rounded,
                                      size: 14, color: Colors.white),
                                const SizedBox(width: 4),
                                Text(
                                  isMarkingDone ? 'Saving…' : 'Mark Done',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
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
    );
  }
}

// ─── Small action button (understands ErpIcons.whatsapp) ─────────────────────
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
    return ErpPressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            erpIcon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: ErpColors.shade(color, 0.12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}