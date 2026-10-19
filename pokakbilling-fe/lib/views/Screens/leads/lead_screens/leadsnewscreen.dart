import 'package:flutter/material.dart';
import 'package:pokakbilling/views/Screens/leads/lead_screens/create_lead.dart';
import 'package:pokakbilling/views/Screens/leads/lead_screens/leads_bottomBar.dart';
import 'package:pokakbilling/views/Screens/leads/lead_screens/leadsviewscreen.dart';
import 'package:provider/provider.dart';
import 'package:pokakbilling/viewmodels/lead_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/source_viewmodel.dart';
import 'package:pokakbilling/viewmodels/course_viewmodel.dart';
import 'package:pokakbilling/models/data-models/lead_model.dart';

// ═════════════════════════════════════════════════════════════════════════════
// Colour scheme (same as Academy dashboard / ERP home)
// ═════════════════════════════════════════════════════════════════════════════
const Color _kPageBg = Color(0xFFF0FAFD);
const Color _kInk = Color(0xFF0F172A);
const Color _kSlate = Color(0xFF64748B);
const Color _kLine = Color(0xFFD9ECF2);

const Color _kCyan = Color(0xFF06B6D4);
const Color _kCyanLight = Color(0xFF67E8F9);
const Color _kCyanDeep = Color(0xFF0E7490);
const Color _kBlue = Color(0xFF3B82F6);
const Color _kOrange = Color(0xFFF97316);
const Color _kViolet = Color(0xFF8B5CF6);
const Color _kGreen = Color(0xFF16A34A);
const Color _kPink = Color(0xFFEC4899);
const Color _kAmber = Color(0xFFF59E0B);
const Color _kRed = Color(0xFFEF4444);

const LinearGradient _kHeaderGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [_kCyanDeep, _kCyan, _kCyanLight],
);

Color _shade(Color c, double amt) => Color.lerp(c, Colors.black, amt)!;
Color _tint(Color c, double amt) => Color.lerp(c, Colors.white, amt)!;

const List<Color> _kAvatarColors = [
  _kCyan, _kViolet, _kPink, _kGreen, _kAmber, _kBlue, _kOrange
];

Color _avatarColor(String name) {
  if (name.isEmpty) return _kCyan;
  final sum = name.codeUnits.fold<int>(0, (a, b) => a + b);
  return _kAvatarColors[sum % _kAvatarColors.length];
}

/// Default status shown for leads that have no status set.
const String _kDefaultStatus = 'New';

/// Colour per lead status — used for badges and card accents.
Color _statusColor(String status) {
  final s = status.toLowerCase();
  if (s.contains('convert') || s.contains('won')) return _kGreen;
  if (s.contains('lost') || s.contains('closed') || s.contains('reject')) {
    return _kRed;
  }
  if (s.contains('qualif')) return _kViolet;
  if (s.contains('contact')) return _kBlue;
  if (s.contains('follow') || s.contains('pending')) return _kOrange;
  if (s.contains('new')) return _kCyan;
  return _kAmber;
}

const int _kPageSize = 10;

// ── Fallback source names in case SourceViewmodel is empty ───────────────────
const Map<int, String> _kFallbackSources = {
  1: 'Event',
  2: 'Call',
  3: 'Online Form',
  4: 'Referral',
  5: 'Website',
  6: 'Other',
};

class LeadsNewScreen extends StatefulWidget {
  final String? initialStatus;
  final DateTime? preFilterFrom;
  final DateTime? preFilterTo;

  const LeadsNewScreen({
    super.key,
    this.initialStatus,
    this.preFilterFrom,
    this.preFilterTo,
  });

  @override
  State<LeadsNewScreen> createState() => _LeadsNewScreenState();
}

class _LeadsNewScreenState extends State<LeadsNewScreen> {
  // 0 = All, 1 = My Leads, 2 = Assigned
  late int _selectedTab;
  late String _searchTerm;
  late String? _selectedStatus;
  late String? _selectedCourse;
  late DateTime? _dateFrom;
  late DateTime? _dateTo;
  late int _currentPage;

  final TextEditingController _searchCtrl = TextEditingController();
  final ScrollController _listCtrl = ScrollController();

  @override
  void initState() {
    super.initState();

    _selectedTab = 0;
    _searchTerm = '';
    _selectedStatus = widget.initialStatus;
    _selectedCourse = null;
    _dateFrom = widget.preFilterFrom;
    _dateTo = widget.preFilterTo;
    _currentPage = 0;

    _searchCtrl.addListener(() {
      final v = _searchCtrl.text;
      if (v == _searchTerm) return;
      setState(() {
        _searchTerm = v;
        _currentPage = 0;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Provider.of<LeadViewmodel>(context, listen: false).getAllLeads();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _listCtrl.dispose();
    super.dispose();
  }

  // ── State mutators ────────────────────────────────────────────────────────
  void _setTab(int t) => setState(() {
        _selectedTab = t;
        _currentPage = 0;
      });

  void _setStatus(String? v) => setState(() {
        _selectedStatus = v;
        _currentPage = 0;
      });

  void _setCourse(String? v) => setState(() {
        _selectedCourse = v;
        _currentPage = 0;
      });

  void _setDateRange(DateTime? from, DateTime? to) => setState(() {
        _dateFrom = from;
        _dateTo = to;
        _currentPage = 0;
      });

  void _setPage(int p) {
    setState(() => _currentPage = p);
    if (_listCtrl.hasClients) {
      _listCtrl.animateTo(0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  DateTime? _parseDate(String? s) {
    if (s == null || s.trim().isEmpty) return null;
    try {
      return DateTime.parse(s.trim());
    } catch (_) {}
    try {
      final parts = s.trim().split(RegExp(r'[-/\s]'));
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
    return null;
  }

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

  String _fmtDate(DateTime d) => '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.year}';

  // ── Status helpers ────────────────────────────────────────────────────────
  /// Effective status of a lead. Leads with no status are shown as "New"
  /// on the card, so the filter treats them as "New" too.
  String _statusOf(LeadModel l) {
    final s = (l.leadStatusDisplay ?? '').trim();
    return s.isEmpty ? _kDefaultStatus : s;
  }

  /// Builds the status filter options:
  ///   1) every status defined in LeadViewmodel.leadStatusList
  ///      (the same list used while creating a lead — so "New" and all the
  ///      others always appear, even if no lead currently has that status)
  ///   2) plus any extra status found on existing leads
  /// Duplicates are removed case-insensitively.
  List<String> _buildStatusList(LeadViewmodel vm, List<LeadModel> leads) {
    final result = <String>[];
    final seen = <String>{};

    void add(String? raw) {
      final s = (raw ?? '').trim();
      if (s.isEmpty) return;
      if (seen.add(s.toLowerCase())) result.add(s);
    }

    for (final s in vm.leadStatusList) {
      add(s);
    }
    add(_kDefaultStatus); // safety net if the list is empty / not loaded
    for (final l in leads) {
      add(_statusOf(l));
    }

    return <String>['All', ...result];
  }

  // ── Newest-first sorting ──────────────────────────────────────────────────
  /// Lead id is auto-incremented by the backend, so a higher id means the
  /// lead was created later. Works whether leadId is an int or a String.
  int _leadIdOf(LeadModel l) => int.tryParse(l.leadId.toString()) ?? 0;

  /// Sort comparator: last created lead first.
  /// 1) higher leadId first, 2) tie-break on lead date / enquiry date.
  int _newestFirst(LeadModel a, LeadModel b) {
    final byId = _leadIdOf(b).compareTo(_leadIdOf(a));
    if (byId != 0) return byId;

    final da = _parseDate(a.date) ?? _parseDate(a.enquiry);
    final db = _parseDate(b.date) ?? _parseDate(b.enquiry);
    if (da == null && db == null) return 0;
    if (da == null) return 1;
    if (db == null) return -1;
    return db.compareTo(da);
  }

  String get _tabTitle {
    switch (_selectedTab) {
      case 1:
        return 'My Leads';
      case 2:
        return 'Assigned Leads';
      default:
        return 'All Leads';
    }
  }

  Map<int, String> _buildSourceNames(SourceViewmodel? sourceVm) {
    if (sourceVm != null && sourceVm.sources.isNotEmpty) {
      return {for (final s in sourceVm.sources) s.id: s.name};
    }
    return Map<int, String>.from(_kFallbackSources);
  }

  Map<int, String> _buildCourseNames(CourseViewmodel? courseVm) {
    if (courseVm != null && courseVm.courses.isNotEmpty) {
      return {for (final c in courseVm.courses) c.id: c.title};
    }
    return <int, String>{};
  }

  // ── Date range picker ─────────────────────────────────────────────────────
  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange:
          DateTimeRange(start: _dateFrom ?? now, end: _dateTo ?? now),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: _kCyan,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: _kInk,
            secondaryContainer: Color(0xFFCFFAFE),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) _setDateRange(picked.start, picked.end);
  }

  // ── Selection bottom sheet ────────────────────────────────────────────────
  void _showSelectionSheet({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required List<String> options,
    required String selected,
    required void Function(String) onSelect,
    bool colorByStatus = false,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 5,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _kLine,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 12, 12),
                child: Row(children: [
                  _GradientTile(icon: icon, color: color, size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(title,
                        style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: _kInk)),
                  ),
                  _Pressable(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: const BoxDecoration(
                          color: _kPageBg, shape: BoxShape.circle),
                      child: const Icon(Icons.close_rounded,
                          color: _kSlate, size: 18),
                    ),
                  ),
                ]),
              ),
              const Divider(height: 1, color: _kLine),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.45,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                  itemCount: options.length,
                  itemBuilder: (_, i) {
                    final o = options[i];
                    final isSelected = o.toLowerCase() == selected.toLowerCase();
                    final c = o == 'All'
                        ? _kCyan
                        : (colorByStatus ? _statusColor(o) : color);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _Pressable(
                        onTap: () {
                          onSelect(o);
                          Navigator.pop(ctx);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 13),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? c.withValues(alpha: 0.10)
                                : _kPageBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: isSelected
                                    ? c.withValues(alpha: 0.5)
                                    : _kLine,
                                width: isSelected ? 1.5 : 1),
                          ),
                          child: Row(children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                  color: c, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(o,
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: isSelected
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    color: isSelected ? _shade(c, 0.1) : _kInk,
                                  )),
                            ),
                            if (isSelected)
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                      colors: [_tint(c, 0.2), c]),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.check_rounded,
                                    color: Colors.white, size: 15),
                              ),
                          ]),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _openLeadDetail(BuildContext context, LeadModel lead) {
    final vm = Provider.of<LeadViewmodel>(context, listen: false);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LeadsViewScreen(lead: lead)),
    ).then((_) => vm.getAllLeads());
  }

  /// Opens Create Lead, then refreshes the list and jumps to page 1 so the
  /// newly created lead is visible at the top.
  void _openCreateLead(BuildContext context) {
    final vm = Provider.of<LeadViewmodel>(context, listen: false);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateLead(isEdit: false)),
    ).then((_) {
      if (!mounted) return;
      setState(() => _currentPage = 0);
      vm.getAllLeads();
    });
  }

  void _clearAllFilters() {
    _searchCtrl.clear();
    setState(() {
      _dateFrom = null;
      _dateTo = null;
      _selectedStatus = null;
      _selectedCourse = null;
      _searchTerm = '';
      _currentPage = 0;
    });
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final sourceNames = _buildSourceNames(Provider.of<SourceViewmodel?>(context));
    final courseNames = _buildCourseNames(Provider.of<CourseViewmodel?>(context));

    return Consumer<LeadViewmodel>(
      builder: (context, vm, child) {
        // Newest (last created) lead first
        final sortedLeads = List<LeadModel>.from(vm.leadList)
          ..sort(_newestFirst);

        final int? loggedUserId = sortedLeads.isNotEmpty
            ? sortedLeads
                .firstWhere((l) => l.customUser != null,
                    orElse: () => sortedLeads.first)
                .customUser
            : null;

        List<LeadModel> baseList;
        if (_selectedTab == 0 || loggedUserId == null) {
          baseList = sortedLeads;
        } else if (_selectedTab == 1) {
          baseList =
              sortedLeads.where((l) => l.customUser == loggedUserId).toList();
        } else {
          baseList =
              sortedLeads.where((l) => l.salesperson == loggedUserId).toList();
        }

        // ── Filter options ────────────────────────────────────────────────
        // Status list now comes from the view model (all statuses, including
        // "New") merged with whatever statuses exist on the leads.
        final statusList = _buildStatusList(vm, baseList);

        final distinctCourses = <String>{};
        for (final lead in baseList) {
          if (lead.course != null) {
            distinctCourses
                .add(courseNames[lead.course] ?? lead.course.toString());
          }
        }
        final courseList = <String>['All'] + (distinctCourses.toList()..sort());

        // ── Filter (keeps newest-first order) ─────────────────────────────
        final filteredList = baseList.where((lead) {
          if (_searchTerm.isNotEmpty) {
            final q = _searchTerm.trim().toLowerCase();
            final match = lead.name.toLowerCase().contains(q) ||
                (lead.company ?? '').toLowerCase().contains(q) ||
                lead.phone.toLowerCase().contains(q) ||
                lead.leadNumber.toLowerCase().contains(q);
            if (!match) return false;
          }

          if (_selectedStatus != null && _selectedStatus != 'All') {
            // Leads with an empty status count as "New"
            if (_statusOf(lead).toLowerCase() !=
                _selectedStatus!.trim().toLowerCase()) {
              return false;
            }
          }

          if (_selectedCourse != null && _selectedCourse != 'All') {
            final c = lead.course != null
                ? (courseNames[lead.course] ?? lead.course.toString())
                : '';
            if (c.toLowerCase() != _selectedCourse!.toLowerCase()) {
              return false;
            }
          }

          // Date filter — same order as LeadScreen counts: date, then enquiry
          if (_dateFrom != null || _dateTo != null) {
            final d = _parseDate(lead.date) ?? _parseDate(lead.enquiry);
            if (d == null) return false;
            if (_dateFrom != null && !_isAfterOrSame(d, _dateFrom!)) {
              return false;
            }
            if (_dateTo != null && !_isBeforeOrSame(d, _dateTo!)) {
              return false;
            }
          }
          return true;
        }).toList();

        // ── Pagination ────────────────────────────────────────────────────
        final totalPages = filteredList.isEmpty
            ? 1
            : (filteredList.length / _kPageSize).ceil();
        final safePage = _currentPage.clamp(0, totalPages - 1);
        final start = safePage * _kPageSize;
        final end = (start + _kPageSize).clamp(0, filteredList.length);
        final pageItems = filteredList.isEmpty
            ? <LeadModel>[]
            : filteredList.sublist(start, end);

        final sw = MediaQuery.of(context).size.width;

        return Scaffold(
          backgroundColor: _kPageBg,
          bottomNavigationBar: const LeadsBottomBar(index: 2),
          body: Column(
            children: [
              _buildHeader(context, filteredList.length),
              _buildFilterRow(context, statusList, courseList),
              Expanded(
                child: vm.getLeadLoader
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: _kCyan, strokeWidth: 2.5))
                    : filteredList.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            color: _kCyan,
                            onRefresh: () async =>
                                Future.sync(() => vm.getAllLeads()),
                            child: ListView.builder(
                              controller: _listCtrl,
                              padding: EdgeInsets.fromLTRB(
                                  sw * .04, 4, sw * .04, 16),
                              physics: const AlwaysScrollableScrollPhysics(
                                  parent: BouncingScrollPhysics()),
                              itemCount: pageItems.length +
                                  (totalPages > 1 ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == pageItems.length) {
                                  return _buildPaginationBar(safePage,
                                      totalPages, filteredList.length);
                                }
                                final lead = pageItems[index];
                                return _FadeIn(
                                  key: ValueKey(
                                      'lead_${lead.leadNumber}_${safePage}_$index'),
                                  index: index,
                                  child: _LeadCard(
                                    lead: lead,
                                    sourceNames: sourceNames,
                                    courseNames: courseNames,
                                    onTap: () =>
                                        _openLeadDetail(context, lead),
                                  ),
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Header (gradient + tabs + search) ─────────────────────────────────────
  Widget _buildHeader(BuildContext context, int count) {
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;
    final canPop = Navigator.of(context).canPop();
    final hasDate = _dateFrom != null || _dateTo != null;

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: _kHeaderGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: _kCyan.withValues(alpha: 0.35),
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
              top: mq.padding.top + 10,
              bottom: 18,
              left: sw * .045,
              right: sw * .045),
          child: Column(children: [
            Row(children: [
              if (canPop) ...[
                _Pressable(
                  onTap: () => Navigator.pop(context),
                  child: const _GlassCircle(
                      icon: Icons.arrow_back_ios_new_rounded, size: 19),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(_tabTitle,
                          key: ValueKey(_tabTitle),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w900)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasDate && _dateFrom != null && _dateTo != null
                          ? '${_fmtDate(_dateFrom!)} – ${_fmtDate(_dateTo!)} · $count lead${count != 1 ? 's' : ''}'
                          : '$count lead${count != 1 ? 's' : ''} found',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 13.5,
                          fontWeight:
                              hasDate ? FontWeight.w700 : FontWeight.w400),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _Pressable(
                onTap: () => _openCreateLead(context),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: _kCyanDeep.withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.add_rounded, color: _kCyanDeep, size: 18),
                    SizedBox(width: 4),
                    Text('New Lead',
                        style: TextStyle(
                            color: _kCyanDeep,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800)),
                  ]),
                ),
              ),
            ]),
            const SizedBox(height: 16),
            _buildTabSwitcher(),
            const SizedBox(height: 12),
            _buildSearchBar(),
          ]),
        ),
      ]),
    );
  }

  // ── Tab switcher (glass) ──────────────────────────────────────────────────
  Widget _buildTabSwitcher() {
    const labels = ['All', 'My Leads', 'Assigned'];
    final alignX = -1.0 + _selectedTab * 1.0;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
      ),
      child: Stack(children: [
        AnimatedAlign(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          alignment: Alignment(alignX, 0),
          child: FractionallySizedBox(
            widthFactor: 1 / 3,
            child: Container(
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: _kCyanDeep.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          height: 38,
          child: Row(
            children: List.generate(labels.length, (i) {
              final active = _selectedTab == i;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _setTab(i),
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: active ? _kCyanDeep : Colors.white,
                      ),
                      child: Text(labels[i]),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ]),
    );
  }

  // ── Search bar (white, inside header) ─────────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _kCyanDeep.withValues(alpha: 0.18),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(children: [
        const Icon(Icons.search_rounded, color: _kCyan, size: 21),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: _searchCtrl,
            cursorColor: _kCyan,
            style: const TextStyle(
                fontSize: 14.5, color: _kInk, fontWeight: FontWeight.w600),
            decoration: const InputDecoration(
              hintText: 'Search name, company, phone…',
              hintStyle: TextStyle(color: _kSlate, fontSize: 14),
              border: InputBorder.none,
              isCollapsed: true,
            ),
          ),
        ),
        if (_searchTerm.isNotEmpty)
          _Pressable(
            onTap: () {
              _searchCtrl.clear();
              setState(() {
                _searchTerm = '';
                _currentPage = 0;
              });
            },
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: _kCyan.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded,
                  size: 14, color: _kCyanDeep),
            ),
          ),
      ]),
    );
  }

  // ── Filter row (below header) ─────────────────────────────────────────────
  Widget _buildFilterRow(
      BuildContext context, List<String> statusList, List<String> courseList) {
    final sw = MediaQuery.of(context).size.width;
    final hasDate = _dateFrom != null || _dateTo != null;
    final hasStatus = _selectedStatus != null;
    final hasCourse = _selectedCourse != null;
    final hasAny = hasDate || hasStatus || hasCourse || _searchTerm.isNotEmpty;

    String dateLabel = 'Date';
    if (_dateFrom != null && _dateTo != null) {
      dateLabel =
          '${_dateFrom!.day}/${_dateFrom!.month} – ${_dateTo!.day}/${_dateTo!.month}';
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(sw * .04, 16, sw * .04, 10),
      child: Column(children: [
        Row(children: [
          Expanded(
            child: _FilterChip(
              icon: Icons.calendar_month_rounded,
              label: dateLabel,
              color: _kBlue,
              active: hasDate,
              onTap: _pickDateRange,
              onClear: hasDate ? () => _setDateRange(null, null) : null,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _FilterChip(
              icon: Icons.flag_rounded,
              label: _selectedStatus ?? 'Status',
              color: hasStatus ? _statusColor(_selectedStatus!) : _kViolet,
              active: hasStatus,
              onTap: () => _showSelectionSheet(
                context: context,
                title: 'Filter by Status',
                icon: Icons.flag_rounded,
                color: _kViolet,
                options: statusList,
                selected: _selectedStatus ?? 'All',
                colorByStatus: true,
                onSelect: (val) => _setStatus(val == 'All' ? null : val),
              ),
              onClear: hasStatus ? () => _setStatus(null) : null,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _FilterChip(
              icon: Icons.menu_book_rounded,
              label: _selectedCourse ?? 'Course',
              color: _kPink,
              active: hasCourse,
              onTap: () => _showSelectionSheet(
                context: context,
                title: 'Filter by Course',
                icon: Icons.menu_book_rounded,
                color: _kPink,
                options: courseList,
                selected: _selectedCourse ?? 'All',
                onSelect: (val) => _setCourse(val == 'All' ? null : val),
              ),
              onClear: hasCourse ? () => _setCourse(null) : null,
            ),
          ),
        ]),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          child: hasAny
              ? Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(children: [
                    Expanded(
                      child: Text(
                        [
                          if (hasDate) 'Date',
                          if (hasStatus) 'Status',
                          if (hasCourse) 'Course',
                          if (_searchTerm.isNotEmpty) 'Search',
                        ].join(' · ') + ' filter applied',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _kSlate),
                      ),
                    ),
                    _Pressable(
                      onTap: _clearAllFilters,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _kRed.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.filter_alt_off_rounded,
                              size: 14, color: _kRed),
                          SizedBox(width: 4),
                          Text('Clear all',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: _kRed)),
                        ]),
                      ),
                    ),
                  ]),
                )
              : const SizedBox(width: double.infinity),
        ),
      ]),
    );
  }

  // ── Pagination bar ────────────────────────────────────────────────────────
  Widget _buildPaginationBar(int page, int totalPages, int totalCount) {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _kLine),
        boxShadow: [
          BoxShadow(
            color: _kCyan.withValues(alpha: 0.10),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(children: [
        Row(children: [
          _pageBtn(
            icon: Icons.chevron_left_rounded,
            enabled: page > 0,
            onTap: () => _setPage(page - 1),
          ),
          const SizedBox(width: 6),
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
                      width: isActive ? 38 : 32,
                      height: 32,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        gradient: isActive
                            ? const LinearGradient(
                                colors: [_kCyanDeep, _kCyan])
                            : null,
                        color: isActive ? null : _kPageBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: isActive ? Colors.transparent : _kLine),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: _kCyan.withValues(alpha: 0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : const [],
                      ),
                      child: Center(
                        child: Text('${i + 1}',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: isActive ? Colors.white : _kSlate)),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(width: 6),
          _pageBtn(
            icon: Icons.chevron_right_rounded,
            enabled: page < totalPages - 1,
            onTap: () => _setPage(page + 1),
          ),
        ]),
        const SizedBox(height: 8),
        Text(
          'Showing ${page * _kPageSize + 1}–'
          '${(page * _kPageSize + _kPageSize).clamp(0, totalCount)}'
          ' of $totalCount leads',
          style: const TextStyle(
              fontSize: 12, color: _kSlate, fontWeight: FontWeight.w600),
        ),
      ]),
    );
  }

  Widget _pageBtn({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return _Pressable(
      onTap: enabled ? onTap : () {},
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: enabled ? _kCyan.withValues(alpha: 0.12) : _kPageBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: enabled ? _kCyan.withValues(alpha: 0.35) : _kLine),
        ),
        child: Icon(icon,
            size: 20,
            color: enabled ? _kCyanDeep : _kSlate.withValues(alpha: 0.35)),
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _kCyan.withValues(alpha: 0.10),
                    _kCyan.withValues(alpha: 0.22),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(color: _kCyan.withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.person_search_rounded,
                  color: _kCyanDeep, size: 38),
            ),
            const SizedBox(height: 16),
            const Text('No Leads Found',
                style: TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w800, color: _kInk)),
            const SizedBox(height: 6),
            const Text('Try adjusting your search or filters',
                style: TextStyle(fontSize: 13.5, color: _kSlate)),
            const SizedBox(height: 18),
            _Pressable(
              onTap: _clearAllFilters,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                decoration: BoxDecoration(
                  gradient:
                      const LinearGradient(colors: [_kCyanDeep, _kCyan]),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: _kCyan.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.filter_alt_off_rounded,
                      size: 16, color: Colors.white),
                  SizedBox(width: 6),
                  Text('Clear Filters',
                      style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Filter chip
// ═════════════════════════════════════════════════════════════════════════════
class _FilterChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool active;
  final VoidCallback onTap;
  final VoidCallback? onClear;
  const _FilterChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.active,
    required this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return _Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          gradient: active
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_tint(color, 0.15), color],
                )
              : null,
          color: active ? null : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: active ? Colors.transparent : _kLine),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: active ? 0.32 : 0.08),
              blurRadius: active ? 10 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(children: [
          Icon(icon, size: 15, color: active ? Colors.white : color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: active ? Colors.white : _kInk)),
          ),
          if (active && onClear != null)
            GestureDetector(
              onTap: onClear,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded,
                    size: 12, color: Colors.white),
              ),
            )
          else
            Icon(Icons.keyboard_arrow_down_rounded,
                size: 17, color: active ? Colors.white : _kSlate),
        ]),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Lead card
// ═════════════════════════════════════════════════════════════════════════════
class _LeadCard extends StatelessWidget {
  final LeadModel lead;
  final Map<int, String> sourceNames;
  final Map<int, String> courseNames;
  final VoidCallback onTap;

  const _LeadCard({
    required this.lead,
    required this.sourceNames,
    required this.courseNames,
    required this.onTap,
  });

  String _formatDate(String? s) {
    if (s == null || s.isEmpty) return '—';
    try {
      final d = DateTime.parse(s);
      const m = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${d.day} ${m[d.month - 1]} ${d.year}';
    } catch (_) {
      return s;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusDisplay = (lead.leadStatusDisplay ?? _kDefaultStatus).trim();
    final status = statusDisplay.isEmpty ? _kDefaultStatus : statusDisplay;
    final sColor = _statusColor(status);
    final isConverted = status.toLowerCase() == 'converted';
    final aColor = _avatarColor(lead.name);

    final rawDate = lead.date.isNotEmpty ? lead.date : lead.enquiry;
    final dateStr = _formatDate(rawDate);
    final sourceDisplay = lead.leadSource != null
        ? (sourceNames[lead.leadSource] ?? '')
        : '';
    final courseDisplay = lead.course != null
        ? (courseNames[lead.course] ??
            (courseNames.isEmpty ? '' : lead.course.toString()))
        : '';

    return _Pressable(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isConverted ? sColor.withValues(alpha: 0.45) : _kLine,
              width: isConverted ? 1.5 : 1),
          boxShadow: [
            BoxShadow(
              color: sColor.withValues(alpha: isConverted ? 0.20 : 0.10),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: IntrinsicHeight(
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 6,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [_tint(sColor, 0.25), sColor],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [_tint(aColor, 0.22), aColor],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: aColor.withValues(alpha: 0.32),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  lead.name.isNotEmpty
                                      ? lead.name[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(lead.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 15.5,
                                          fontWeight: FontWeight.w800,
                                          color: _kInk)),
                                  const SizedBox(height: 2),
                                  Text(
                                    (lead.company ?? '').isNotEmpty
                                        ? lead.company!
                                        : (lead.phone.isNotEmpty
                                            ? lead.phone
                                            : lead.leadNumber),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 12.5, color: _kSlate),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: sColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                          color: sColor,
                                          shape: BoxShape.circle),
                                    ),
                                    const SizedBox(width: 5),
                                    ConstrainedBox(
                                      constraints:
                                          const BoxConstraints(maxWidth: 86),
                                      child: Text(status,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w800,
                                              color: _shade(sColor, 0.1))),
                                    ),
                                  ]),
                            ),
                          ]),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              if (courseDisplay.isNotEmpty)
                                _MetaChip(
                                    icon: Icons.menu_book_rounded,
                                    text: courseDisplay,
                                    color: _kViolet),
                              if (sourceDisplay.isNotEmpty)
                                _MetaChip(
                                    icon: Icons.alt_route_rounded,
                                    text: sourceDisplay,
                                    color: _kBlue),
                              _MetaChip(
                                  icon: Icons.calendar_today_rounded,
                                  text: dateStr,
                                  color: rawDate.isNotEmpty
                                      ? _kCyan
                                      : _kSlate),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Center(
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: _kCyan.withValues(alpha: 0.10),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.chevron_right_rounded,
                            size: 20, color: _kCyanDeep),
                      ),
                    ),
                  ),
                ]),
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const _MetaChip(
      {required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    final maxW = MediaQuery.of(context).size.width * 0.5;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxW),
          child: Text(text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: _shade(color, 0.15))),
        ),
      ]),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Small shared widgets
// ═════════════════════════════════════════════════════════════════════════════
class _GradientTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  const _GradientTile(
      {required this.icon, required this.color, this.size = 44});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_tint(color, 0.22), color],
          ),
          borderRadius: BorderRadius.circular(size * 0.32),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.32),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: size * 0.5),
      );
}

class _GlassCircle extends StatelessWidget {
  final IconData icon;
  final double size;
  const _GlassCircle({required this.icon, this.size = 20});

  @override
  Widget build(BuildContext context) => Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
        ),
        child: Icon(icon, color: Colors.white, size: size),
      );
}

class _Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _Pressable({required this.child, required this.onTap});

  @override
  State<_Pressable> createState() => _PressableState();
}

class _PressableState extends State<_Pressable>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 90));
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}

class _FadeIn extends StatefulWidget {
  final Widget child;
  final int index;
  const _FadeIn({super.key, required this.child, required this.index});

  @override
  State<_FadeIn> createState() => _FadeInState();
}

class _FadeInState extends State<_FadeIn> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 380));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, .08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(Duration(milliseconds: 40 + widget.index * 50), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child));
}