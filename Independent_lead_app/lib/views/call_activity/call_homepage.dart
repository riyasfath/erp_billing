import 'package:flutter/material.dart';
import 'package:pokakbilling/models/call_activity/dashboard_model.dart';
import 'package:pokakbilling/viewmodels/call_activity/add_callLog_viewmodel.dart';
import 'package:pokakbilling/viewmodels/call_activity/call_recording_viewmodel.dart';
import 'package:pokakbilling/viewmodels/call_activity/dashboard_viewmodel.dart';
import 'package:pokakbilling/views/call_activity/add_callLog_screen.dart';
import 'package:pokakbilling/views/call_activity/call_activity_helpers.dart';
import 'package:pokakbilling/views/call_activity/call_followups_tab.dart';
import 'package:pokakbilling/views/call_activity/call_recording_screen.dart';
import 'package:pokakbilling/views/call_activity/select_lead_callScreen.dart';
import 'package:pokakbilling/views/call_activity/today_task_tab.dart';
import 'package:provider/provider.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/views/call_activity/call_history_tab.dart';

class CallActivityScreen extends StatefulWidget {
  const CallActivityScreen({super.key});

  @override
  State<CallActivityScreen> createState() => _CallActivityScreenState();
}

class _CallActivityScreenState extends State<CallActivityScreen>
    with TickerProviderStateMixin {
  int _tabIndex = 0;

  // ── Default filter values (kept in one place so reset logic can't drift) ─
  static const String _defaultDateFilter = 'All Day';
  static const String _defaultStatusFilter = 'All Status';
  static const String _defaultStageFilter = 'All Stages';

  String _dateFilter = _defaultDateFilter;
  String _statusFilter = _defaultStatusFilter;
  String _stageFilter = _defaultStageFilter;

  late final AnimationController _headerCtrl;
  late final AnimationController _bodyCtrl;
  late final Animation<double> _headerFade;
  late final Animation<Offset> _headerSlide;
  late final Animation<double> _bodyFade;
  late final Animation<Offset> _bodySlide;

  final List<_TabSpec> _tabs = const [
    _TabSpec('Dashboard', Icons.grid_view_rounded),
    _TabSpec("Today's Tasks", Icons.today_rounded),
    _TabSpec('Follow-ups', Icons.event_repeat_rounded),
    _TabSpec('Call History', Icons.history_rounded),
  ];

  static const List<Color> _breakdownPalette = [
    AppColors.c1,
    AppColors.tagGreen,
    AppColors.tagRed,
    AppColors.amber,
    AppColors.c3,
    AppColors.ctext,
  ];

  // True whenever any filter is away from its default — drives the
  // "Clear Filters" pill's visibility.
  bool get _hasActiveFilters =>
      _dateFilter != _defaultDateFilter ||
      _statusFilter != _defaultStatusFilter ||
      _stageFilter != _defaultStageFilter;

  @override
  void initState() {
    super.initState();
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
      final vm = context.read<CallActivityViewmodel>();
      vm.getDashboardStats();
      vm.getPerformanceSummary();
    });
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  // ── Filter → API param mapping (dashboard tab) ──────────────────────────
  String? _periodParam(String v) {
    switch (v) {
      case 'Today':
        return 'today';
      case 'Yesterday':
        return 'yesterday';
      case 'Last 7 Days':
        return 'last_7_days';
      case 'Last 30 Days':
        return 'last_30_days';
      case 'This Month':
        return 'month';
      default:
        // 'All Day'
        return null;
    }
  }

  String? _statusParam(String v) {
    switch (v) {
      case 'Answered':
        return 'answered';
      case 'No Answer':
        return 'no_answer';
      case 'Busy':
        return 'busy';
      case 'Failed':
        return 'failed';
      default:
        return null;
    }
  }

  String? _stageParam(String v) {
    switch (v) {
      case 'New':
        return 'new';
      case 'Contacted':
        return 'contacted';
      case 'Qualified':
        return 'qualified';
      case 'Converted':
        return 'converted';
      default:
        return null;
    }
  }

  // Single source of truth for re-fetching the dashboard using whatever
  // the CURRENT filter state is. Called after every filter change.
  void _fetchDashboardWithCurrentFilters() {
    context.read<CallActivityViewmodel>().getDashboardStats(
          period: _periodParam(_dateFilter),
          clearPeriod: _periodParam(_dateFilter) == null,
          status: _statusParam(_statusFilter),
          clearStatus: _statusParam(_statusFilter) == null,
          stage: _stageParam(_stageFilter),
          clearStage: _stageParam(_stageFilter) == null,
        );
  }

  // Resets all 3 filters back to defaults. Pass refresh:true to also
  // immediately re-fetch unfiltered dashboard data.
  void _resetFilters({bool refresh = false}) {
    if (!mounted) return;
    setState(() {
      _dateFilter = _defaultDateFilter;
      _statusFilter = _defaultStatusFilter;
      _stageFilter = _defaultStageFilter;
    });
    if (refresh) {
      context.read<CallActivityViewmodel>().getDashboardStats(
            clearPeriod: true,
            clearStatus: true,
            clearStage: true,
          );
    }
  }

  void _onTabChanged(int i) {
    final prevIndex = _tabIndex;
    setState(() => _tabIndex = i);
    final vm = context.read<CallActivityViewmodel>();

    // Coming back to the Dashboard tab from another tab resets filters.
    if (i == 0 && prevIndex != 0) {
      _resetFilters(refresh: true);
      return;
    }

    switch (i) {
      case 1:
        vm.getTodayTasks();
        break;
      case 2:
        vm.getFollowUps();
        break;
      case 3:
        vm.getCallHistory();
        break;
    }
  }

  Future<void> _openRecordings() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => CallRecordingsViewmodel(),
          child: const CallRecordingsScreen(),
        ),
      ),
    );
    if (mounted) {
      _resetFilters(refresh: true);
    }
  }

  Future<void> _openAddCallLog() async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => AddCallLogViewmodel(),
          child: const AddCallLogScreen(),
        ),
      ),
    );

    if (mounted) {
      _resetFilters(refresh: true);
    }
  }

  // Pushes the full-page lead picker instead of showing a popup.
  // Uses the SAME CallActivityViewmodel instance (via context.read /
  // Provider ancestor lookup) rather than creating a new one, so the
  // dashboard refreshes correctly if a call gets logged.
  // Reused for BOTH the header "New Call" pill AND the "Start New Call"
  // quick-action button so their behaviour is identical.
  Future<void> _openStartNewCall() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SelectLeadForCallScreen(),
      ),
    );
    if (mounted) {
      _resetFilters(refresh: true);
    }
  }

  // ── Small shared utility: initials from a name ──────────────────────────
  String _initials(String name) => initialsFromName(name);

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;
    final topPad = mq.padding.top;
    final botPad = mq.padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          FadeTransition(
            opacity: _headerFade,
            child: SlideTransition(
              position: _headerSlide,
              child: _buildHeader(context, topPad, sw),
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
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.cdark.withOpacity(0.05),
                        blurRadius: 16,
                        offset: const Offset(0, -4),
                      ),
                    ],
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
                          margin: const EdgeInsets.only(top: 12, bottom: 6),
                          decoration: BoxDecoration(
                            color: AppColors.c1.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        _buildTabs(sw),
                        Expanded(
                          child: RefreshIndicator(
                            color: AppColors.c1,
                            onRefresh: () => context
                                .read<CallActivityViewmodel>()
                                .refreshTab(_tabIndex),
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(
                                  parent: BouncingScrollPhysics()),
                              padding:
                                  EdgeInsets.fromLTRB(16, 10, 16, botPad + 24),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 280),
                                switchInCurve: Curves.easeOut,
                                switchOutCurve: Curves.easeIn,
                                transitionBuilder: (child, anim) =>
                                    FadeTransition(
                                  opacity: anim,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0, 0.03),
                                      end: Offset.zero,
                                    ).animate(anim),
                                    child: child,
                                  ),
                                ),
                                child: _buildTabBody(context),
                              ),
                            ),
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
  }

  Widget _buildTabBody(BuildContext context) {
    switch (_tabIndex) {
      case 0:
        return KeyedSubtree(
          key: const ValueKey('dashboard'),
          child: _buildDashboardBody(context),
        );
      case 1:
        return KeyedSubtree(
          key: const ValueKey('tasks'),
          child: TodayTasksTab(
            onAfterCall: () => _resetFilters(refresh: true),
          ),
        );
      case 2:
        return KeyedSubtree(
          key: const ValueKey('followups'),
          child: FollowUpsTab(
            onAfterCall: () => _resetFilters(refresh: true),
          ),
        );
      case 3:
        return KeyedSubtree(
          key: const ValueKey('history'),
          child: CallHistoryTab(
            onAfterCall: () => _resetFilters(refresh: true),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  // ── Header (stat tiles removed — just title + New Call action) ─────────
  Widget _buildHeader(BuildContext context, double topPad, double sw) {
    return Consumer<CallActivityViewmodel>(
      builder: (context, vm, _) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            top: topPad + 14,
            bottom: 20,
            left: sw * 0.05,
            right: sw * 0.05,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.white,
                AppColors.c1.withOpacity(0.045),
              ],
            ),
            border: const Border(
              bottom: BorderSide(color: AppColors.cborder, width: 1.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Container(
                      width: 36,
                      height: 36,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.cborder),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.cdark.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.arrow_back_rounded,
                          color: AppColors.c1, size: 17),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'My Call Activity',
                          style: TextStyle(
                            color: AppColors.cdark,
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              margin: const EdgeInsets.only(right: 6),
                              decoration: const BoxDecoration(
                                color: AppColors.tagGreen,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const Text(
                              'Track and manage your calls',
                              style: TextStyle(
                                  color: AppColors.ctext,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Header "New Call" pill uses the SAME navigation as the
                  // "Start New Call" quick-action button.
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _openStartNewCall,
                      borderRadius: BorderRadius.circular(22),
                      child: Ink(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.c1,
                              AppColors.c1.withOpacity(0.82),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.c1.withOpacity(0.30),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.call_rounded,
                                color: AppColors.white, size: 15),
                            SizedBox(width: 6),
                            Text(
                              'New Call',
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
                  ),
                ],
              ),
              if (vm.getDashboardLoader) ...[
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: const LinearProgressIndicator(
                    minHeight: 3,
                    backgroundColor: AppColors.cxl,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.c1),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // ── Segmented tab bar (shows LIVE counts, full labels) ──────────────────
  Widget _buildTabs(double sw) {
    return Consumer<CallActivityViewmodel>(
      builder: (context, vm, _) {
        final counts = [
          0,
          vm.todayTasksData.todayTasksCount,
          vm.followUpsData.count,
          vm.historyData.count,
        ];
        return Container(
          color: AppColors.cxl,
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
          child: Container(
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.cborder),
              boxShadow: [
                BoxShadow(
                  color: AppColors.cdark.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: List.generate(_tabs.length, (i) {
                final isSelected = i == _tabIndex;
                final tab = _tabs[i];
                return Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _onTabChanged(i),
                      borderRadius: BorderRadius.circular(20),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOut,
                        padding: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 2),
                        decoration: isSelected
                            ? BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.c1,
                                    AppColors.c1.withOpacity(0.85),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.c1.withOpacity(0.28),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              )
                            : null,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    tab.icon,
                                    size: 15,
                                    color: isSelected
                                        ? AppColors.white
                                        : AppColors.ctext.withOpacity(0.55),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    tab.label,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 8.3,
                                      fontWeight: FontWeight.w700,
                                      height: 1.1,
                                      color: isSelected
                                          ? AppColors.white
                                          : AppColors.ctext,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            if (counts[i] > 0)
                              Positioned(
                                top: -2,
                                right: 6,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.white
                                        : AppColors.c1,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: AppColors.white,
                                      width: 1.4,
                                    ),
                                  ),
                                  child: Text(
                                    '${counts[i]}',
                                    style: TextStyle(
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w800,
                                      color: isSelected
                                          ? AppColors.c1
                                          : AppColors.white,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }

  // ── DASHBOARD TAB ────────────────────────────────────────────────────
  Widget _buildDashboardBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildActionButtons(),
        const SizedBox(height: 16),
        _buildFilters(),
        const SizedBox(height: 18),
        _sectionLabel('MY TOTAL CALLS', icon: Icons.dashboard_rounded),
        const SizedBox(height: 10),
        _buildStatsGrid(),
        const SizedBox(height: 22),
        // Filtered call details — reflects whatever the 3 filter chips
        // above are currently set to.
        _buildFilteredCallDetails(context),
        const SizedBox(height: 22),
        _sectionLabel('MY PERFORMANCE SUMMARY', icon: Icons.insights_rounded),
        const SizedBox(height: 10),
        _buildPerformanceSummary(context),
      ],
    );
  }

  Widget _sectionLabel(String text, {IconData? icon}) => Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: AppColors.c1.withOpacity(0.7)),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: AppColors.cdark,
                letterSpacing: 1.1),
          ),
        ],
      );

  Widget _buildActionButtons() {
    // "Start New Call" pushes SelectLeadForCallScreen — identical to the
    // header "New Call" pill.
    final actions = <_ActionSpec>[
      _ActionSpec(Icons.call_rounded, 'Start New Call', _openStartNewCall),
      _ActionSpec(Icons.add_rounded, 'Add Call Log', _openAddCallLog),
      _ActionSpec(Icons.mic_rounded, 'Recordings', _openRecordings),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: actions.map((a) {
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Material(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: a.onTap,
                borderRadius: BorderRadius.circular(14),
                child: Ink(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.c1.withOpacity(0.18)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.c1.withOpacity(0.07),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: AppColors.c1.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(a.icon, size: 14, color: AppColors.c1),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        a.label,
                        style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.cdark),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Filters (search bar removed — filter chips + clear-filters pill) ───
  Widget _buildFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _filterChip(
              Icons.calendar_today_rounded,
              _dateFilter,
              const [
                'All Day',
                'Today',
                'Yesterday',
                'Last 7 Days',
                'Last 30 Days',
                'This Month',
              ],
              (v) {
                setState(() => _dateFilter = v);
                _fetchDashboardWithCurrentFilters();
              },
            ),
            const SizedBox(width: 8),
            _filterChip(
              Icons.filter_alt_rounded,
              _statusFilter,
              const ['All Status', 'Answered', 'No Answer', 'Busy', 'Failed'],
              (v) {
                setState(() => _statusFilter = v);
                _fetchDashboardWithCurrentFilters();
              },
            ),
            const SizedBox(width: 8),
            _filterChip(
              Icons.stairs_rounded,
              _stageFilter,
              const [
                'All Stages',
                'New',
                'Contacted',
                'Qualified',
                'Converted',
              ],
              (v) {
                setState(() => _stageFilter = v);
                _fetchDashboardWithCurrentFilters();
              },
            ),
          ],
        ),
        // Only shows once a non-default filter is picked.
        if (_hasActiveFilters) ...[
          const SizedBox(height: 10),
          _buildClearFiltersButton(),
        ],
      ],
    );
  }

  Widget _buildClearFiltersButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _resetFilters(refresh: true),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.tagRed.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.tagRed.withOpacity(0.25)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.close_rounded, size: 12, color: AppColors.tagRed),
                const SizedBox(width: 5),
                Text(
                  'Clear Filters',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.tagRed,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _filterChip(IconData icon, String value, List<String> options,
      ValueChanged<String> onSelect) {
    final isDefault = value == options.first;
    return Expanded(
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(11),
        child: InkWell(
          onTap: () => _showFilterSheet(icon, value, options, onSelect),
          borderRadius: BorderRadius.circular(11),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: isDefault
                    ? AppColors.cborder
                    : AppColors.c1.withOpacity(0.45),
              ),
            ),
            child: Row(
              children: [
                Icon(icon,
                    size: 12,
                    color: isDefault
                        ? AppColors.ctext.withOpacity(0.55)
                        : AppColors.c1),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                        fontSize: 10.2,
                        fontWeight: FontWeight.w700,
                        color: isDefault ? AppColors.cdark : AppColors.c1),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.keyboard_arrow_down_rounded,
                    size: 13, color: AppColors.ctext.withOpacity(0.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFilterSheet(IconData icon, String current, List<String> options,
      ValueChanged<String> onSelect) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.cborder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.c1.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 14, color: AppColors.c1),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Filter',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.cdark),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ...options.map((o) {
              final selected = o == current;
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    onSelect(o);
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.c1.withOpacity(0.08)
                          : AppColors.cxl,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected
                            ? AppColors.c1.withOpacity(0.35)
                            : AppColors.cborder,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(o,
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: selected
                                      ? FontWeight.w800
                                      : FontWeight.w500,
                                  color: selected
                                      ? AppColors.c1
                                      : AppColors.cdark)),
                        ),
                        if (selected)
                          const Icon(Icons.check_circle_rounded,
                              color: AppColors.c1, size: 18),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ── Stats: a hero "Total Calls" card + a clean 2x2 grid for the rest ────
  Widget _buildStatsGrid() {
    return Consumer<CallActivityViewmodel>(
      builder: (context, vm, _) {
        final d = vm.dashboard;

        final secondaryStats = [
          {
            'icon': Icons.call_received_rounded,
            'value': '${d.answeredCalls}',
            'label': 'ANSWERED',
            'color': AppColors.tagGreen,
          },
          {
            'icon': Icons.call_end_rounded,
            'value': '${d.missedNoAnswer}',
            'label': 'MISSED',
            'color': AppColors.tagRed,
          },
          {
            'icon': Icons.timer_rounded,
            'value': d.totalCallDuration,
            'label': 'TOTAL DURATION',
            'color': AppColors.c3,
          },
          {
            'icon': Icons.speed_rounded,
            'value': d.averageCallTime,
            'label': 'AVG CALL TIME',
            'color': AppColors.amber,
          },
        ];

        return Column(
          children: [
            _buildHeroTotalCard(d.totalCalls),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: secondaryStats.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.62,
              ),
              itemBuilder: (_, i) {
                final s = secondaryStats[i];
                final color = s['color'] as Color;
                return _StatTile(
                  icon: s['icon'] as IconData,
                  value: s['value'] as String,
                  label: s['label'] as String,
                  color: color,
                );
              },
            ),
          ],
        );
      },
    );
  }

  // Big, impressive hero card for the headline "Total Calls" number.
  Widget _buildHeroTotalCard(int totalCalls) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.c1, AppColors.c1.withOpacity(0.78)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.c1.withOpacity(0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.call_rounded,
                color: AppColors.white, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$totalCalls',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'MY TOTAL CALLS',
                  style: TextStyle(
                    color: AppColors.white.withOpacity(0.88),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.trending_up_rounded,
                    color: AppColors.white, size: 13),
                SizedBox(width: 4),
                Text(
                  'Overview',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Filtered Call Details ────────────────────────────────────────────
  // Shows the individual call records that match the 3 active filters
  // (Date / Status / Stage). This reads `vm.dashboard.callDetails`.
  //
  // TODO (backend/viewmodel wiring):
  // If `CallActivityDashboardModel` doesn't yet have a `callDetails` list,
  // add one and make sure `getDashboardStats(period:, status:, stage:, ...)`
  // populates it from the API response using the SAME period/status/stage
  // query params it already sends for the stat tiles above. Once that field
  // exists, this widget will "just work" — nothing else in this file needs
  // to change.
  Widget _buildFilteredCallDetails(BuildContext context) {
    return Consumer<CallActivityViewmodel>(
      builder: (context, vm, _) {
        // TEMPORARY: `CallActivityDashboardModel` doesn't expose a
        // per-call list yet, so this stays empty (compiles safely) until
        // that field is added. See the TODO comment above this method for
        // exactly what to add to the model/viewmodel.
        final List calls = const [];
        final loading = vm.getDashboardLoader;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabelWithBadge(
              'FILTERED CALL DETAILS',
              calls.length,
              AppColors.c1,
              Icons.list_alt_rounded,
            ),
            const SizedBox(height: 10),
            if (loading && calls.isEmpty)
              callActivityLoadingState()
            else if (calls.isEmpty)
              callActivityEmptyState(
                icon: Icons.filter_list_off_rounded,
                title: _hasActiveFilters
                    ? 'No calls match these filters'
                    : 'No calls recorded yet',
                subtitle: _hasActiveFilters
                    ? 'Try changing or clearing the filters above.'
                    : 'Calls matching your filters will show up here.',
                compact: true,
              )
            else
              ...calls.map((c) => _filteredCallCard(c)),
          ],
        );
      },
    );
  }

  Widget _filteredCallCard(dynamic call) {
    final String status = (call.status ?? '').toString();
    final bool isAnswered = status.toLowerCase().contains('answer') &&
        !status.toLowerCase().contains('no');
    final Color color = isAnswered ? AppColors.tagGreen : AppColors.tagRed;
    final String name = (call.name ?? '').toString();
    final String phone = (call.phone ?? '').toString();
    final String? callTime =
        (call.callTime as String?) ?? (call.scheduledTime as String?);
    final String? duration = call.duration as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.14)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 3, color: color.withOpacity(0.6)),
              Padding(
                padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.10),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _initials(name.isEmpty ? '?' : name),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name.isEmpty ? 'Unknown' : name,
                            style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.cdark),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(Icons.phone_rounded,
                                  size: 11,
                                  color: AppColors.ctext.withOpacity(0.5)),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  phone,
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.ctext.withOpacity(0.65)),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (callTime != null)
                          Text(callTime,
                              style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.cdark)),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            status.isEmpty ? '--' : status,
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: color),
                          ),
                        ),
                        if (duration != null) ...[
                          const SizedBox(height: 3),
                          Text(
                            duration,
                            style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.ctext.withOpacity(0.6)),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Performance Summary (live, dynamic keys) ────────────────────────────
  Widget _buildPerformanceSummary(BuildContext context) {
    return Consumer<CallActivityViewmodel>(
      builder: (context, vm, _) {
        if (vm.getPerformanceSummaryLoader && !vm.performanceSummaryLoaded) {
          return callActivityLoadingState();
        }

        final s = vm.performanceSummary;
        final hasAnyData = s.callStatusBreakdown.isNotEmpty ||
            s.callsByLeadStage.isNotEmpty ||
            s.callsBySource.isNotEmpty;

        if (!hasAnyData) {
          return callActivityEmptyState(
            icon: Icons.insights_rounded,
            title: 'No performance data yet',
            subtitle: 'Breakdown by status, stage, and source will show here.',
            compact: true,
          );
        }

        return Column(
          children: [
            if (s.callStatusBreakdown.isNotEmpty) ...[
              _buildBreakdownCard('Call Status Breakdown',
                  Icons.pie_chart_rounded, s.callStatusBreakdown),
              const SizedBox(height: 12),
            ],
            if (s.callsByLeadStage.isNotEmpty) ...[
              _buildBreakdownCard('Calls by Lead Stage',
                  Icons.stacked_line_chart_rounded, s.callsByLeadStage),
              const SizedBox(height: 12),
            ],
            if (s.callsBySource.isNotEmpty)
              _buildBreakdownCard(
                  'Calls by Source', Icons.share_rounded, s.callsBySource),
          ],
        );
      },
    );
  }

  Widget _buildBreakdownCard(
      String title, IconData icon, List<BreakdownItem> items) {
    final total = items.fold<int>(0, (p, e) => p + e.value);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cborder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.c1.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 3,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.c1, AppColors.c1.withOpacity(0.4)],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 14, 15, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: AppColors.c1.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Icon(icon, size: 15, color: AppColors.c1),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(title,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.cdark)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.cxl,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('$total total',
                          style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ctext.withOpacity(0.7))),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (total == 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      'No calls recorded yet',
                      style: TextStyle(
                          fontSize: 11,
                          color: AppColors.ctext.withOpacity(0.55),
                          fontWeight: FontWeight.w500),
                    ),
                  )
                else
                  ...items.asMap().entries.map((entry) {
                    final i = entry.key;
                    final item = entry.value;
                    final pct = total == 0 ? 0.0 : item.value / total;
                    final color =
                        _breakdownPalette[i % _breakdownPalette.length];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 11),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                      color: color, shape: BoxShape.circle),
                                ),
                                const SizedBox(width: 7),
                                Text(item.label,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.cdark)),
                              ]),
                              Text(
                                  '${item.value}  ·  ${(pct * 100).toStringAsFixed(0)}%',
                                  style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                      color: color)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Stack(
                              children: [
                                Container(
                                  height: 7,
                                  color: AppColors.cxl,
                                ),
                                FractionallySizedBox(
                                  widthFactor: pct.clamp(0.0, 1.0),
                                  child: Container(
                                    height: 7,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          color,
                                          color.withOpacity(0.7),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Shared: section header with live count badge (dashboard-local
  // wrapper around the shared helper, kept for call-site parity) ─────────
  Widget _sectionLabelWithBadge(
          String text, int count, Color color, IconData icon) =>
      sectionLabelWithBadge(text, count, color, icon);
}

/// Small immutable spec for a tab: label + icon (used by the pill tab bar).
class _TabSpec {
  final String label;
  final IconData icon;
  const _TabSpec(this.label, this.icon);
}

/// Small immutable spec for a dashboard quick-action button.
class _ActionSpec {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionSpec(this.icon, this.label, this.onTap);
}

/// Clean, evenly-proportioned stat card used in the secondary 2x2 grid
/// (Answered / Missed / Total Duration / Avg Call Time).
class _StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cborder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.cdark,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9.2,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ctext.withOpacity(0.65),
                    letterSpacing: .3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
