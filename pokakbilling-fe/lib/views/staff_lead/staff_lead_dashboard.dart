// ═════════════════════════════════════════════════════════════════════════════
// STAFF ACADEMIC LEAD DASHBOARD — connected to live API
// Place at: lib/views/staff_lead/staff_lead_dashboard.dart
//
// GET   /leads/academic-dashboard/staff/   (tabs, counts, filters)
// POST  /leads/staff/                      (add lead, lead_category = intern)
// PATCH /leads/staff/{id}/                 (priority_status / lead_status,
//                                           reason_note / other_note)
// ═════════════════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pokakbilling/ERP_UI_KIT.dart';
import 'package:pokakbilling/models/staff_lead/staff_lead_model.dart';
import 'package:pokakbilling/viewmodels/staff_lead/staff_lead_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

// ─── UI extras for tabs ──────────────────────────────────────────────────────
extension LeadStageUi on LeadStage {
  String get label => switch (this) {
        LeadStage.priorityPending => 'Priority Pending',
        LeadStage.prospects => 'Prospects',
        LeadStage.warm => 'Warm',
        LeadStage.cold => 'Cold',
        LeadStage.rnr => 'RNR',
        LeadStage.notValid => 'Number Not Valid',
      };

  String get shortLabel => switch (this) {
        LeadStage.notValid => 'Not Valid',
        LeadStage.priorityPending => 'Priority',
        _ => label,
      };

  /// compact label for the stat grid tiles
  String get gridLabel => switch (this) {
        LeadStage.priorityPending => 'Pending',
        LeadStage.notValid => 'Not Valid',
        _ => label,
      };

  IconData get icon => switch (this) {
        LeadStage.priorityPending => Icons.priority_high_rounded,
        LeadStage.prospects => Icons.local_fire_department_rounded,
        LeadStage.warm => Icons.whatshot_rounded,
        LeadStage.cold => Icons.ac_unit_rounded,
        LeadStage.rnr => Icons.phone_missed_rounded,
        LeadStage.notValid => Icons.phone_disabled_rounded,
      };

  Color get color => switch (this) {
        LeadStage.priorityPending => ErpColors.red,
        LeadStage.prospects => ErpColors.pink,
        LeadStage.warm => ErpColors.orange,
        LeadStage.cold => ErpColors.blue,
        LeadStage.rnr => ErpColors.violet,
        LeadStage.notValid => ErpColors.slate,
      };
}

Color _statusColor(String key) => switch (key) {
      'rnr' => ErpColors.violet,
      'number_not_valid' => ErpColors.slate,
      'converted' => ErpColors.green,
      'lost' => ErpColors.red,
      'other' => ErpColors.slate,
      'follow_up' => ErpColors.orange,
      'contacted' => ErpColors.blue,
      'in_progress' => ErpColors.amber,
      'registration' => ErpColors.pink,
      _ => ErpColors.cyan,
    };

Color _courseColor(int? id) =>
    ErpColors.rotation[(id ?? 0).abs() % ErpColors.rotation.length];

String _fmt(DateTime? d, [String p = 'dd MMM yyyy']) =>
    d == null ? '—' : DateFormat(p).format(d);

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty || parts.first.isEmpty) return '?';
  if (parts.length == 1) return parts.first[0].toUpperCase();
  return (parts.first[0] + parts.last[0]).toUpperCase();
}

// ─── Status helpers (adds "Other" even if kLeadStatuses doesn't have it) ─────
const String _kOtherLabel = 'Other';

/// Statuses that need an extra note: lost → reason_note, other → other_note
bool _isNoteStatus(String key) => key == 'lost' || key == 'other';

List<ErpChoice> _statusChoices() {
  final list = kLeadStatuses
      .map((s) => ErpChoice(s.label, Icons.flag_rounded, _statusColor(s.key)))
      .toList();
  if (!kLeadStatuses.any((s) => s.key == 'other')) {
    list.add(ErpChoice(_kOtherLabel, Icons.flag_rounded, _statusColor('other')));
  }
  return list;
}

String _keyForLabel(String label) {
  for (final s in kLeadStatuses) {
    if (s.label == label) return s.key;
  }
  return label == _kOtherLabel
      ? 'other'
      : label.toLowerCase().replaceAll(' ', '_');
}

String _labelForKey(String key) {
  for (final s in kLeadStatuses) {
    if (s.key == key) return s.label;
  }
  return key == 'other' ? _kOtherLabel : '';
}

// ═════════════════════════════════════════════════════════════════════════════
// SCREEN
// ═════════════════════════════════════════════════════════════════════════════
class StaffLeadDashboardScreen extends StatefulWidget {
  const StaffLeadDashboardScreen({super.key});

  @override
  State<StaffLeadDashboardScreen> createState() =>
      _StaffLeadDashboardScreenState();
}

class _StaffLeadDashboardScreenState extends State<StaffLeadDashboardScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final vm = context.read<StaffLeadViewmodel>();
      _searchCtrl.text = vm.search;
      vm.init();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Actions ────────────────────────────────────────────────────────────────
  void _clearFilters(StaffLeadViewmodel vm) {
    _searchCtrl.clear();
    vm.clearFilters();
  }

  Future<void> _call(String phone) async {
    final cleaned = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleaned.length < 6) {
      erpToast(context, 'Phone number is not valid',
          color: ErpColors.red, icon: Icons.error_outline_rounded);
      return;
    }
    final uri = Uri(scheme: 'tel', path: cleaned);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _whatsapp(String phone) async {
    var cleaned = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.length < 6) {
      erpToast(context, 'Phone number is not valid',
          color: ErpColors.red, icon: Icons.error_outline_rounded);
      return;
    }
    if (cleaned.length == 10) cleaned = '91$cleaned';
    final uri = Uri.parse('https://wa.me/$cleaned');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // ── Bottom sheets ──────────────────────────────────────────────────────────
  Future<void> _openAddLead(StaffLeadViewmodel vm) async {
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddLeadSheet(vm: vm),
    );
    if (ok == true && mounted) {
      erpToast(context, 'Academic lead added', color: ErpColors.green);
    }
  }

  Future<void> _openStatusSheet(StaffLeadViewmodel vm, AcademicLead lead) async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _StatusSheet(vm: vm, lead: lead),
    );
    if (changed == true && mounted) {
      erpToast(context, 'Status updated for ${lead.name}',
          color: ErpColors.green);
    }
  }

  Future<void> _openDetails(StaffLeadViewmodel vm, AcademicLead lead) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => _LeadDetailSheet(
        lead: lead,
        onCall: () => _call(lead.phone),
        onWhatsApp: () => _whatsapp(lead.phone),
        onChangeStatus: () {
          Navigator.pop(sheetCtx);
          _openStatusSheet(vm, lead);
        },
      ),
    );
  }

  Future<void> _pickCourse(StaffLeadViewmodel vm) async {
    if (vm.courses.isEmpty) {
      erpToast(context, 'No courses available',
          icon: Icons.menu_book_rounded);
      vm.loadCourses(force: true);
      return;
    }
    final picked = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ErpSheet(
        title: 'Course',
        subtitle: 'Choose one to filter the list',
        icon: Icons.menu_book_rounded,
        color: ErpColors.cyan,
        children: [
          _FilterOption(
            label: 'All Courses',
            icon: Icons.apps_rounded,
            color: ErpColors.cyan,
            selected: vm.courseId == null,
            onTap: () => Navigator.pop(ctx, -1),
          ),
          for (final c in vm.courses)
            _FilterOption(
              label: c.name,
              icon: Icons.menu_book_rounded,
              color: _courseColor(c.id),
              selected: vm.courseId == c.id,
              onTap: () => Navigator.pop(ctx, c.id),
            ),
        ],
      ),
    );
    if (picked == null) return;
    vm.setCourse(picked == -1 ? null : picked);
  }

  Future<void> _pickDates(StaffLeadViewmodel vm) async {
    final r = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: vm.dateRange,
      builder: (ctx, child) => erpPickerTheme(ctx, child),
    );
    if (r != null) vm.setDateRange(r);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StaffLeadViewmodel>();
    final sw = MediaQuery.of(context).size.width;
    final items = vm.leads;
    final tab = vm.tab;

    final dr = vm.dateRange;
    final dateLabel = dr == null
        ? null
        : '${DateFormat('dd MMM').format(dr.start)} – ${DateFormat('dd MMM').format(dr.end)}';

    return Scaffold(
      backgroundColor: ErpColors.pageBg,
      floatingActionButton: _AddFab(onTap: () => _openAddLead(vm)),
      body: Column(
        children: [
          _Header(
            tabLabel: tab.label,
            tabCount: vm.counts[tab] ?? 0,
            loading: vm.loading,
            onRefresh: vm.fetch,
            onExport: () => erpToast(context, 'PDF export coming soon',
                icon: Icons.picture_as_pdf_rounded),
          ),
          Expanded(
            child: RefreshIndicator(
              color: ErpColors.cyan,
              onRefresh: vm.refresh,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics()),
                slivers: [
                  // ── Lead overview (3 x 2 stat grid) ───────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(sw * .04, 18, sw * .04, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _OverviewLabel(text: 'LEAD OVERVIEW'),
                          const SizedBox(height: 10),
                          _StageStatGrid(
                            counts: vm.counts,
                            selected: tab,
                            onSelect: vm.setTab,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Tabs (sticky) ─────────────────────────────────────────
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _TabsDelegate(
                      child: Container(
                        color: ErpColors.pageBg,
                        padding:
                            EdgeInsets.fromLTRB(sw * .04, 12, sw * .04, 8),
                        child: _StageTabs(
                          selected: tab,
                          countOf: (s) => vm.counts[s] ?? 0,
                          onSelect: vm.setTab,
                        ),
                      ),
                    ),
                  ),

                  // ── Search + filters ──────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(sw * .04, 4, sw * .04, 6),
                      child: _FilterCard(
                        controller: _searchCtrl,
                        search: vm.search,
                        courseLabel: vm.courseName,
                        dateLabel: dateLabel,
                        onSearch: vm.onSearch,
                        onClearSearch: () {
                          _searchCtrl.clear();
                          vm.onSearch('');
                        },
                        onCourseTap: () => _pickCourse(vm),
                        onDateTap: () => _pickDates(vm),
                        onClearAll:
                            vm.hasFilters ? () => _clearFilters(vm) : null,
                      ),
                    ),
                  ),

                  // ── Result line ───────────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(sw * .045, 8, sw * .045, 6),
                      child: Row(children: [
                        Container(
                          width: 4,
                          height: 16,
                          decoration: BoxDecoration(
                            color: tab.color,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('${tab.label} Leads',
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: ErpColors.ink)),
                        const Spacer(),
                        Text(
                            '${items.length} result${items.length == 1 ? '' : 's'}',
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: ErpColors.slate)),
                      ]),
                    ),
                  ),

                  // ── List / loading / error / empty ───────────────────────
                  if (vm.loading)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(top: 60),
                        child: Center(
                          child: SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                                color: ErpColors.cyan, strokeWidth: 2.5),
                          ),
                        ),
                      ),
                    )
                  else if (vm.error != null && items.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 30, bottom: 120),
                        child: ErpEmptyState(
                          icon: Icons.cloud_off_rounded,
                          title: 'Could not load leads',
                          subtitle: vm.error!,
                          color: ErpColors.red,
                          actionLabel: 'Retry',
                          actionIcon: Icons.refresh_rounded,
                          onAction: vm.fetch,
                        ),
                      ),
                    )
                  else if (items.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 30, bottom: 120),
                        child: ErpEmptyState(
                          icon: Icons.layers_clear_rounded,
                          title: 'No Academic Leads Found',
                          subtitle: vm.hasFilters
                              ? 'No leads in "${tab.label}" match your filters.'
                              : 'No leads in "${tab.label}" yet.',
                          color: tab.color,
                          actionLabel: vm.hasFilters
                              ? 'Clear filters'
                              : 'Add Academic Lead',
                          actionIcon: vm.hasFilters
                              ? Icons.filter_alt_off_rounded
                              : Icons.add_rounded,
                          onAction: vm.hasFilters
                              ? () => _clearFilters(vm)
                              : () => _openAddLead(vm),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                          sw * .04,
                          4,
                          sw * .04,
                          MediaQuery.of(context).padding.bottom + 96),
                      sliver: SliverList.builder(
                        itemCount: items.length,
                        itemBuilder: (_, i) {
                          final l = items[i];
                          return ErpFadeIn(
                            key: ValueKey(
                                '${l.id}_${l.priorityStatus}_${l.leadStatus}'),
                            index: i < 8 ? i : 8,
                            child: _LeadCard(
                              lead: l,
                              onTap: () => _openDetails(vm, l),
                              onCall: () => _call(l.phone),
                              onWhatsApp: () => _whatsapp(l.phone),
                              onStatus: () => _openStatusSheet(vm, l),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// HEADER
// ═════════════════════════════════════════════════════════════════════════════
class _Header extends StatelessWidget {
  final String tabLabel;
  final int tabCount;
  final bool loading;
  final VoidCallback onRefresh;
  final VoidCallback onExport;

  const _Header({
    required this.tabLabel,
    required this.tabCount,
    required this.loading,
    required this.onRefresh,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;

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
        Positioned(right: -34, top: -44, child: _bubble(150, 0.10)),
        Positioned(left: -26, bottom: -34, child: _bubble(90, 0.08)),
        Positioned(
          right: 24,
          bottom: 6,
          child: Transform.rotate(
            angle: -0.25,
            child: Icon(Icons.school_rounded,
                size: 92, color: Colors.white.withValues(alpha: 0.12)),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
              top: mq.padding.top + 10,
              bottom: 20,
              left: sw * .045,
              right: sw * .045),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                ErpPressable(
                  onTap: () => Navigator.pop(context),
                  child: const ErpGlassCircle(
                      icon: Icons.arrow_back_ios_new_rounded, iconSize: 19),
                ),
                const Spacer(),
                ErpPressable(
                  onTap: onExport,
                  child: const ErpGlassCircle(
                      icon: Icons.picture_as_pdf_rounded, iconSize: 19),
                ),
                const SizedBox(width: 8),
                loading
                    ? const SizedBox(
                        width: 42,
                        height: 42,
                        child: Padding(
                          padding: EdgeInsets.all(11),
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        ),
                      )
                    : ErpPressable(
                        onTap: onRefresh,
                        child:
                            const ErpGlassCircle(icon: Icons.refresh_rounded),
                      ),
              ]),
              const SizedBox(height: 16),
              Row(children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(17),
                    boxShadow: [
                      BoxShadow(
                        color: ErpColors.cyanDeep.withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.layers_rounded,
                      color: ErpColors.cyanDeep, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Flexible(
                          child: Text('Staff Lead Dashboard',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 21,
                                  fontWeight: FontWeight.w900)),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text('STAFF VIEW',
                              style: TextStyle(
                                  fontSize: 9,
                                  letterSpacing: 0.6,
                                  fontWeight: FontWeight.w900,
                                  color: ErpColors.green)),
                        ),
                      ]),
                      const SizedBox(height: 3),
                      Text(
                          'Manage student inquiries, courses & lead statuses',
                          maxLines: 2,
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 12.5,
                              height: 1.35)),
                    ],
                  ),
                ),
              ]),
              const SizedBox(height: 14),
              Row(children: [
                _HeaderPill(
                    icon: Icons.groups_rounded,
                    text: '$tabCount in $tabLabel'),
                const SizedBox(width: 8),
                _HeaderPill(
                    icon: Icons.calendar_month_rounded,
                    text: DateFormat('dd MMM yyyy').format(DateTime.now())),
              ]),
            ],
          ),
        ),
      ]),
    );
  }

  static Widget _bubble(double s, double a) => Container(
        width: s,
        height: s,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: a),
          shape: BoxShape.circle,
        ),
      );
}

class _HeaderPill extends StatelessWidget {
  final IconData icon;
  final String text;
  const _HeaderPill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Flexible(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 14, color: Colors.white),
            const SizedBox(width: 5),
            Flexible(
              child: Text(text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
            ),
          ]),
        ),
      );
}

// ═════════════════════════════════════════════════════════════════════════════
// LEAD OVERVIEW — 3 x 2 stat grid (tap a tile to switch tab)
// ═════════════════════════════════════════════════════════════════════════════
class _OverviewLabel extends StatelessWidget {
  final String text;
  const _OverviewLabel({required this.text});

  @override
  Widget build(BuildContext context) => Row(children: [
        Container(
          width: 4,
          height: 12,
          decoration: BoxDecoration(
            color: ErpColors.cyan,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 7),
        Text(text,
            style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: ErpColors.slate,
                letterSpacing: 1.1)),
      ]);
}

class _StageStatGrid extends StatelessWidget {
  final Map<LeadStage, int> counts;
  final LeadStage selected;
  final ValueChanged<LeadStage> onSelect;

  const _StageStatGrid({
    required this.counts,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    const cols = 3;
    const gap = 10.0;
    final stages = LeadStage.values;
    final rows = (stages.length / cols).ceil();

    return Column(
      children: List.generate(rows, (r) {
        return Padding(
          padding: EdgeInsets.only(bottom: r < rows - 1 ? gap : 0),
          child: Row(
            children: List.generate(cols, (c) {
              final idx = r * cols + c;
              if (idx >= stages.length) {
                return const Expanded(child: SizedBox.shrink());
              }
              final s = stages[idx];
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: c < cols - 1 ? gap : 0),
                  child: ErpFadeIn(
                    index: idx,
                    child: _StageStatTile(
                      stage: s,
                      count: counts[s] ?? 0,
                      selected: selected == s,
                      onTap: () => onSelect(s),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }
}

class _StageStatTile extends StatelessWidget {
  final LeadStage stage;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _StageStatTile({
    required this.stage,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = stage.color;
    return ErpPressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
        height: 98,
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 9),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [ErpColors.tint(c, 0.12), c],
                )
              : null,
          color: selected ? null : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? Colors.transparent : c.withValues(alpha: 0.18)),
          boxShadow: [
            BoxShadow(
              color: c.withValues(alpha: selected ? 0.36 : 0.08),
              blurRadius: selected ? 14 : 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withValues(alpha: 0.24)
                      : c.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(stage.icon,
                    size: 17,
                    color: selected ? Colors.white : ErpColors.shade(c, 0.08)),
              ),
              const Spacer(),
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected
                      ? Colors.white
                      : c.withValues(alpha: count > 0 ? 0.9 : 0.25),
                ),
              ),
            ]),
            const Spacer(),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text('$count',
                  style: TextStyle(
                      fontSize: 25,
                      height: 1,
                      fontWeight: FontWeight.w900,
                      color: selected ? Colors.white : ErpColors.ink)),
            ),
            const SizedBox(height: 3),
            Text(stage.gridLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: selected
                        ? Colors.white.withValues(alpha: 0.95)
                        : ErpColors.slate)),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// TABS
// ═════════════════════════════════════════════════════════════════════════════
class _TabsDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _TabsDelegate({required this.child});

  @override
  double get minExtent => 66;
  @override
  double get maxExtent => 66;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) =>
      SizedBox.expand(child: child);

  @override
  bool shouldRebuild(covariant _TabsDelegate old) => true;
}

class _StageTabs extends StatelessWidget {
  final LeadStage selected;
  final int Function(LeadStage) countOf;
  final ValueChanged<LeadStage> onSelect;

  const _StageTabs({
    required this.selected,
    required this.countOf,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: LeadStage.values.map((s) {
          final sel = s == selected;
          final c = s.color;
          return Padding(
            padding: const EdgeInsets.only(right: 4),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onSelect(s),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  gradient: sel
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [ErpColors.tint(c, 0.15), c])
                      : null,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: sel
                      ? [
                          BoxShadow(
                            color: c.withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : const [],
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(s.shortLabel,
                      style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: sel ? Colors.white : ErpColors.slate)),
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: sel
                          ? Colors.white.withValues(alpha: 0.25)
                          : c.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('${countOf(s)}',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: sel
                                ? Colors.white
                                : ErpColors.shade(c, 0.1))),
                  ),
                ]),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// FILTER CARD  (name search · course · date range) — all server side
// ═════════════════════════════════════════════════════════════════════════════
class _FilterCard extends StatelessWidget {
  final TextEditingController controller;
  final String search;
  final String? courseLabel;
  final String? dateLabel;
  final ValueChanged<String> onSearch;
  final VoidCallback onClearSearch;
  final VoidCallback onCourseTap;
  final VoidCallback onDateTap;
  final VoidCallback? onClearAll;

  const _FilterCard({
    required this.controller,
    required this.search,
    required this.courseLabel,
    required this.dateLabel,
    required this.onSearch,
    required this.onClearSearch,
    required this.onCourseTap,
    required this.onDateTap,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ErpColors.line),
      ),
      child: Column(children: [
        Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: ErpColors.pageBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: ErpColors.line),
          ),
          child: Row(children: [
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
                controller: controller,
                onChanged: onSearch,
                cursorColor: ErpColors.cyan,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ErpColors.ink),
                decoration: InputDecoration(
                  hintText: 'Search candidate name…',
                  hintStyle: TextStyle(
                      fontSize: 13,
                      color: ErpColors.slate.withValues(alpha: 0.7)),
                  border: InputBorder.none,
                  isCollapsed: true,
                ),
              ),
            ),
            if (search.isNotEmpty)
              ErpPressable(
                onTap: onClearSearch,
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
          ]),
        ),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: _FilterPill(
              icon: Icons.menu_book_rounded,
              label: courseLabel ?? 'All Courses',
              active: courseLabel != null,
              color: ErpColors.violet,
              onTap: onCourseTap,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _FilterPill(
              icon: Icons.date_range_rounded,
              label: dateLabel ?? 'All Dates',
              active: dateLabel != null,
              color: ErpColors.orange,
              onTap: onDateTap,
            ),
          ),
          if (onClearAll != null) ...[
            const SizedBox(width: 8),
            ErpPressable(
              onTap: onClearAll!,
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: ErpColors.red.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(13),
                  border:
                      Border.all(color: ErpColors.red.withValues(alpha: 0.25)),
                ),
                child: const Icon(Icons.filter_alt_off_rounded,
                    size: 19, color: ErpColors.red),
              ),
            ),
          ],
        ]),
      ]),
    );
  }
}

class _FilterPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final Color color;
  final VoidCallback onTap;

  const _FilterPill({
    required this.icon,
    required this.label,
    required this.active,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ErpPressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          gradient: active
              ? LinearGradient(colors: [ErpColors.tint(color, 0.15), color])
              : null,
          color: active ? null : ErpColors.pageBg,
          borderRadius: BorderRadius.circular(13),
          border:
              Border.all(color: active ? Colors.transparent : ErpColors.line),
        ),
        child: Row(children: [
          Icon(icon,
              size: 16, color: active ? Colors.white : ErpColors.cyanDeep),
          const SizedBox(width: 6),
          Expanded(
            child: Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: active ? Colors.white : ErpColors.ink)),
          ),
          Icon(Icons.keyboard_arrow_down_rounded,
              size: 18, color: active ? Colors.white : ErpColors.slate),
        ]),
      ),
    );
  }
}

class _FilterOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _FilterOption({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ErpPressable(
        scale: 0.98,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.08) : ErpColors.pageBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? color.withValues(alpha: 0.6) : ErpColors.line,
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Row(children: [
            ErpGradientTile(icon: icon, color: color, size: 36),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: selected
                          ? ErpColors.shade(color, 0.15)
                          : ErpColors.ink)),
            ),
            if (selected)
              Icon(Icons.check_circle_rounded, color: color, size: 22),
          ]),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// LEAD CARD
// ═════════════════════════════════════════════════════════════════════════════
class _LeadCard extends StatelessWidget {
  final AcademicLead lead;
  final VoidCallback onTap;
  final VoidCallback onCall;
  final VoidCallback onWhatsApp;
  final VoidCallback onStatus;

  const _LeadCard({
    required this.lead,
    required this.onTap,
    required this.onCall,
    required this.onWhatsApp,
    required this.onStatus,
  });

  @override
  Widget build(BuildContext context) {
    final stage = lead.priorityStage;
    final stageColor = stage.color;
    final courseColor = _courseColor(lead.courseId);
    final avatarColor = ErpColors
        .rotation[lead.name.hashCode.abs() % ErpColors.rotation.length];
    final sub = [
      if (lead.qualification.isNotEmpty) lead.qualification,
      if (lead.addOn.isNotEmpty) 'Add-on: ${lead.addOn}',
    ].join('  ·  ');

    return ErpPressable(
      scale: 0.98,
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: ErpColors.line),
          boxShadow: [
            BoxShadow(
              color: stageColor.withValues(alpha: 0.10),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(children: [
          Container(
            height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [ErpColors.tint(stageColor, 0.3), stageColor]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Lead # + date + calls ──────────────────────────────────
                Row(children: [
                  if (lead.leadNumber.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: ErpColors.cyan.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(lead.leadNumber,
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: ErpColors.cyanDeep)),
                    ),
                  const SizedBox(width: 6),
                  Text(_fmt(lead.leadDate, 'dd MMM yyyy'),
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: ErpColors.slate)),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: ErpColors.blue.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.call_made_rounded,
                          size: 12, color: ErpColors.blue),
                      const SizedBox(width: 3),
                      Text('${lead.callCount} calls',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: ErpColors.shade(ErpColors.blue, 0.15))),
                    ]),
                  ),
                ]),
                const SizedBox(height: 12),

                // ── Candidate ──────────────────────────────────────────────
                Row(children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [ErpColors.tint(avatarColor, 0.22), avatarColor],
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
                      child: Text(_initials(lead.name),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900)),
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(lead.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w900,
                                color: ErpColors.ink)),
                        const SizedBox(height: 2),
                        Row(children: [
                          const Icon(Icons.phone_rounded,
                              size: 12, color: ErpColors.slate),
                          const SizedBox(width: 4),
                          Text(lead.phone.isEmpty ? '—' : lead.phone,
                              style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: ErpColors.slate)),
                        ]),
                      ],
                    ),
                  ),
                  ErpStatusChip(label: stage.shortLabel, color: stageColor),
                ]),
                const SizedBox(height: 12),

                // ── Course box ─────────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: courseColor.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: courseColor.withValues(alpha: 0.16)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        ErpGradientTile(
                            icon: Icons.menu_book_rounded,
                            color: courseColor,
                            size: 36),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  lead.courseName.isEmpty
                                      ? 'No course selected'
                                      : lead.courseName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      color: ErpColors.ink)),
                              if (sub.isNotEmpty)
                                Text(sub,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 11.5,
                                        color: ErpColors.slate)),
                            ],
                          ),
                        ),
                      ]),
                      if (lead.courseEnquiry.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(lead.courseEnquiry,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12,
                                height: 1.35,
                                color: ErpColors.slate)),
                      ],
                      const SizedBox(height: 8),
                      Wrap(spacing: 6, runSpacing: 6, children: [
                        if (lead.expectedStart != null)
                          ErpMetaChip(
                            icon: Icons.event_available_rounded,
                            text: 'Starts ${_fmt(lead.expectedStart)}',
                            color: ErpColors.cyanDeep,
                          ),
                        if (lead.nextFollowup != null)
                          ErpMetaChip(
                            icon: Icons.event_repeat_rounded,
                            text: 'Follow-up ${_fmt(lead.nextFollowup)}',
                            color: ErpColors.orange,
                          ),
                        ErpMetaChip(
                          icon: Icons.flag_rounded,
                          text: lead.leadStatusDisplay.isEmpty
                              ? lead.leadStatus
                              : lead.leadStatusDisplay,
                          color: _statusColor(lead.leadStatus),
                        ),
                      ]),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // ── Actions ────────────────────────────────────────────────
                Row(children: [
                  _ActionChip(
                    icon: Icons.call_rounded,
                    label: 'Call',
                    color: ErpColors.cyan,
                    onTap: onCall,
                  ),
                  const SizedBox(width: 6),
                  _ActionChip(
                    icon: ErpIcons.whatsapp,
                    label: 'WhatsApp',
                    color: ErpColors.whatsapp,
                    onTap: onWhatsApp,
                  ),
                  const Spacer(),
                  _ActionChip(
                    icon: Icons.swap_horiz_rounded,
                    label: 'Status',
                    color: stageColor == ErpColors.slate
                        ? ErpColors.violet
                        : stageColor,
                    filled: true,
                    onTap: onStatus,
                  ),
                ]),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool filled;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return ErpPressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
        decoration: BoxDecoration(
          gradient: filled
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [ErpColors.tint(color, 0.2), color])
              : null,
          color: filled ? null : color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(20),
          border:
              filled ? null : Border.all(color: color.withValues(alpha: 0.25)),
          boxShadow: filled
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.32),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : const [],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          erpIcon(icon, size: 14, color: filled ? Colors.white : color),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: filled ? Colors.white : ErpColors.shade(color, 0.12))),
        ]),
      ),
    );
  }
}

class _AddFab extends StatelessWidget {
  final VoidCallback onTap;
  const _AddFab({required this.onTap});

  @override
  Widget build(BuildContext context) => ErpPressable(
        onTap: onTap,
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            gradient: ErpColors.headerGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: ErpColors.cyan.withValues(alpha: 0.45),
                blurRadius: 16,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.person_add_alt_1_rounded, color: Colors.white, size: 22),
            SizedBox(width: 8),
            Text('Add Lead',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900)),
          ]),
        ),
      );
}

// ═════════════════════════════════════════════════════════════════════════════
// STATUS NOTE BOX — same size / look as every other field.
//   Lost  → Reason Note  (reason_note)
//   Other → Other Note   (other_note)
// ═════════════════════════════════════════════════════════════════════════════
class _StatusNoteBox extends StatelessWidget {
  final String statusKey; // 'lost' or 'other'
  final TextEditingController controller;
  final String? error;
  final VoidCallback onChanged;

  const _StatusNoteBox({
    required this.statusKey,
    required this.controller,
    required this.error,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isLost = statusKey == 'lost';
    final hasError = error != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ErpFieldLabel(isLost ? 'Reason Note' : 'Other Note', isRequired: true),
        TextField(
          controller: controller,
          minLines: 1,
          maxLines: 3,
          textAlignVertical: TextAlignVertical.center,
          cursorColor: ErpColors.cyan,
          onChanged: (_) => onChanged(),
          style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: hasError ? ErpColors.red : ErpColors.ink),
          decoration: erpInputDecoration(
            hint:
                isLost ? 'Why was this lead lost?' : 'Enter additional details...',
            icon: isLost
                ? Icons.sentiment_dissatisfied_rounded
                : Icons.edit_note_rounded,
            hasError: hasError,
          ),
        ),
        if (hasError) ErpErrorText(error!),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// STATUS SHEET  → PATCH /leads/staff/{id}/  (only changed fields are sent)
// ═════════════════════════════════════════════════════════════════════════════
class _StatusSheet extends StatefulWidget {
  final StaffLeadViewmodel vm;
  final AcademicLead lead;
  const _StatusSheet({required this.vm, required this.lead});

  @override
  State<_StatusSheet> createState() => _StatusSheetState();
}

class _StatusSheetState extends State<_StatusSheet> {
  late LeadStage _priority = widget.lead.priorityStage;
  late String _status = widget.lead.leadStatus;
  bool _saving = false;

  final TextEditingController _noteCtrl = TextEditingController();
  String? _noteErr;

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l = widget.lead;
    final body = <String, dynamic>{};
    final statusChanged = _status != l.leadStatus;

    if (_priority != l.priorityStage) {
      body['priority_status'] = _priority.priorityValue; // null = pending
    }
    if (statusChanged) body['lead_status'] = _status;

    // ── Lost → reason_note   |   Other → other_note ──────────────────────────
    if (_isNoteStatus(_status)) {
      final note = _noteCtrl.text.trim();
      if (statusChanged && note.isEmpty) {
        setState(() => _noteErr = _status == 'lost'
            ? 'Reason note is required'
            : 'Other note is required');
        return;
      }
      if (note.isNotEmpty) {
        body[_status == 'lost' ? 'reason_note' : 'other_note'] = note;
      }
    }

    if (body.isEmpty) {
      Navigator.pop(context, false);
      return;
    }

    setState(() => _saving = true);
    final err = await widget.vm.updateLead(l.id, body);
    if (!mounted) return;
    setState(() => _saving = false);

    if (err == null) {
      Navigator.pop(context, true);
    } else {
      erpToast(context, err,
          color: ErpColors.red, icon: Icons.error_outline_rounded);
    }
  }

  @override
  Widget build(BuildContext context) {
    final priorities = LeadStageApi.priorities;
    final showNote = _isNoteStatus(_status);

    return ErpSheet(
      title: 'Update Status',
      subtitle: '${widget.lead.name} · ${widget.lead.leadNumber}',
      icon: Icons.swap_horiz_rounded,
      color: ErpColors.violet,
      children: [
        const ErpFieldLabel('Priority'),
        ErpChoiceGrid(
          columns: 2,
          options:
              priorities.map((s) => ErpChoice(s.label, s.icon, s.color)).toList(),
          selected: _priority.label,
          onSelect: (v) => setState(
              () => _priority = priorities.firstWhere((s) => s.label == v)),
        ),
        const SizedBox(height: 16),
        const ErpFieldLabel('Lead Status'),
        ErpChoiceGrid(
          columns: 2,
          options: _statusChoices(),
          selected: _labelForKey(_status),
          onSelect: (v) => setState(() {
            _status = _keyForLabel(v);
            _noteErr = null;
          }),
        ),

        // ── Reason / Other note box ──────────────────────────────────────────
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: showNote
              ? Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: _StatusNoteBox(
                    statusKey: _status,
                    controller: _noteCtrl,
                    error: _noteErr,
                    onChanged: () {
                      if (_noteErr != null) setState(() => _noteErr = null);
                    },
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),

        const SizedBox(height: 20),
        ErpPrimaryButton(
          text: 'Save Status',
          icon: Icons.check_rounded,
          color: ErpColors.violet,
          loading: _saving,
          onTap: _save,
        ),
        const SizedBox(height: 10),
        ErpSecondaryButton(
            text: 'Cancel', onTap: () => Navigator.pop(context, false)),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// DETAIL SHEET
// ═════════════════════════════════════════════════════════════════════════════
class _LeadDetailSheet extends StatelessWidget {
  final AcademicLead lead;
  final VoidCallback onCall;
  final VoidCallback onWhatsApp;
  final VoidCallback onChangeStatus;

  const _LeadDetailSheet({
    required this.lead,
    required this.onCall,
    required this.onWhatsApp,
    required this.onChangeStatus,
  });

  @override
  Widget build(BuildContext context) {
    final l = lead;
    final stage = l.priorityStage;
    final courseColor = _courseColor(l.courseId);

    Widget row(IconData i, String label, String value, Color c,
            {bool copy = false}) =>
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: c.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(i, size: 17, color: ErpColors.shade(c, 0.12)),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: ErpColors.slate)),
                  Text(value,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: ErpColors.ink)),
                ],
              ),
            ),
            if (copy)
              ErpPressable(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: value));
                  erpToast(context, '$label copied', icon: Icons.copy_rounded);
                },
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(Icons.copy_rounded,
                      size: 17, color: ErpColors.slate),
                ),
              ),
          ]),
        );

    final qual = [
      if (l.qualification.isNotEmpty) l.qualification,
      if (l.addOn.isNotEmpty) l.addOn,
    ].join(' · ');

    return ErpSheet(
      title: l.name,
      subtitle: l.leadNumber,
      icon: Icons.person_rounded,
      color: stage.color == ErpColors.slate ? ErpColors.cyan : stage.color,
      children: [
        Wrap(spacing: 6, runSpacing: 6, children: [
          ErpStatusChip(label: stage.label, color: stage.color),
          ErpStatusChip(
              label: l.leadStatusDisplay.isEmpty
                  ? l.leadStatus
                  : l.leadStatusDisplay,
              color: _statusColor(l.leadStatus)),
          ErpStatusChip(label: '${l.callCount} calls', color: ErpColors.blue),
        ]),
        const SizedBox(height: 16),
        if (l.phone.isNotEmpty)
          row(Icons.phone_rounded, 'Phone', l.phone, ErpColors.cyan,
              copy: true),
        if (l.email.isNotEmpty)
          row(Icons.email_rounded, 'Email', l.email, ErpColors.violet,
              copy: true),
        if (l.courseName.isNotEmpty)
          row(Icons.menu_book_rounded, 'Course Enquired', l.courseName,
              courseColor),
        if (qual.isNotEmpty)
          row(Icons.workspace_premium_rounded, 'Qualification & Add-on', qual,
              ErpColors.amber),
        if (l.courseEnquiry.isNotEmpty)
          row(Icons.notes_rounded, 'Enquiry', l.courseEnquiry, ErpColors.pink),
        if (l.expectedStart != null)
          row(Icons.event_available_rounded, 'Expected Start Date',
              _fmt(l.expectedStart, 'EEEE, dd MMM yyyy'), ErpColors.green),
        if (l.nextFollowup != null)
          row(Icons.event_repeat_rounded, 'Next Follow-up',
              _fmt(l.nextFollowup, 'EEEE, dd MMM yyyy'), ErpColors.orange),
        if (l.leadDate != null)
          row(Icons.schedule_rounded, 'Lead Date', _fmt(l.leadDate),
              ErpColors.slate),
        const SizedBox(height: 6),
        Row(children: [
          Expanded(
            child: _BigAction(
              icon: Icons.call_rounded,
              label: 'Call',
              color: ErpColors.cyan,
              onTap: onCall,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _BigAction(
              icon: ErpIcons.whatsapp,
              label: 'WhatsApp',
              color: ErpColors.whatsapp,
              onTap: onWhatsApp,
            ),
          ),
        ]),
        const SizedBox(height: 14),
        ErpPrimaryButton(
          text: 'Change Status',
          icon: Icons.swap_horiz_rounded,
          color: ErpColors.violet,
          onTap: onChangeStatus,
        ),
      ],
    );
  }
}

class _BigAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _BigAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => ErpPressable(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Column(children: [
            erpIcon(icon, size: 22, color: color),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: ErpColors.shade(color, 0.15))),
          ]),
        ),
      );
}

// ═════════════════════════════════════════════════════════════════════════════
// ADD LEAD SHEET  → POST /leads/staff/  (lead_category = "intern")
// ═════════════════════════════════════════════════════════════════════════════
class _AddLeadSheet extends StatefulWidget {
  final StaffLeadViewmodel vm;
  const _AddLeadSheet({required this.vm});

  @override
  State<_AddLeadSheet> createState() => _AddLeadSheetState();
}

class _AddLeadSheetState extends State<_AddLeadSheet> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _qualCtrl = TextEditingController();
  final _addOnCtrl = TextEditingController();
  final _enquiryCtrl = TextEditingController();

  StaffCourse? _course;
  LeadStage _priority = LeadStage.priorityPending;
  String _status = 'new';
  DateTime? _start;

  String? _errName, _errPhone;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _qualCtrl.dispose();
    _addOnCtrl.dispose();
    _enquiryCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickStart() async {
    final p = await showDatePicker(
      context: context,
      initialDate: _start ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => erpPickerTheme(ctx, child),
    );
    if (p != null) setState(() => _start = p);
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    setState(() {
      _errName = name.isEmpty ? 'Candidate name is required' : null;
      _errPhone = phone.isNotEmpty && phone.length < 10
          ? 'Enter a valid 10-digit phone'
          : null;
    });
    if (_errName != null || _errPhone != null) return;

    setState(() => _saving = true);
    final err = await widget.vm.createLead(
      name: name,
      phone: phone,
      email: _emailCtrl.text.trim(),
      courseId: _course?.id,
      qualification: _qualCtrl.text.trim(),
      addOn: _addOnCtrl.text.trim(),
      expectedStart: _start,
      leadStatus: _status,
      priority: _priority,
      enquiry: _enquiryCtrl.text.trim(),
    );
    if (!mounted) return;
    setState(() => _saving = false);

    if (err == null) {
      Navigator.pop(context, true);
    } else {
      erpToast(context, err,
          color: ErpColors.red, icon: Icons.error_outline_rounded);
    }
  }

  Widget _field(TextEditingController c, String label, String hint,
      IconData icon,
      {String? error,
      bool required = false,
      TextInputType? type,
      int maxLines = 1,
      List<TextInputFormatter>? fmt,
      VoidCallback? onChanged}) {
    final hasError = error != null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ErpFieldLabel(label, isRequired: required, isOptional: !required),
          TextField(
            controller: c,
            keyboardType: type,
            inputFormatters: fmt,
            minLines: 1,
            maxLines: maxLines,
            textAlignVertical: TextAlignVertical.center,
            cursorColor: ErpColors.cyan,
            onChanged: (_) => onChanged?.call(),
            style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: hasError ? ErpColors.red : ErpColors.ink),
            decoration:
                erpInputDecoration(hint: hint, icon: icon, hasError: hasError),
          ),
          if (hasError) ErpErrorText(error),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final courses = widget.vm.courses;
    final priorities = LeadStageApi.priorities;
    final statusLabel = {for (final s in kLeadStatuses) s.key: s.label};

    return ErpSheet(
      title: 'Add Academic Lead',
      subtitle: 'New student enquiry',
      icon: Icons.person_add_alt_1_rounded,
      color: ErpColors.cyan,
      children: [
        _field(_nameCtrl, 'Candidate Name', 'e.g. Aishwarya Menon',
            Icons.person_rounded,
            required: true,
            error: _errName,
            onChanged: () {
              if (_errName != null) setState(() => _errName = null);
            }),
        _field(_phoneCtrl, 'Phone', '10-digit mobile number',
            Icons.phone_rounded,
            error: _errPhone,
            type: TextInputType.phone,
            fmt: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            onChanged: () {
              if (_errPhone != null) setState(() => _errPhone = null);
            }),
        _field(_emailCtrl, 'Email', 'student@email.com', Icons.email_rounded,
            type: TextInputType.emailAddress),
        if (courses.isNotEmpty) ...[
          const ErpFieldLabel('Course Enquired', isOptional: true),
          ErpChoiceGrid(
            columns: 2,
            options: courses
                .map((c) => ErpChoice(
                    c.name, Icons.menu_book_rounded, _courseColor(c.id)))
                .toList(),
            selected: _course?.name ?? '',
            onSelect: (v) => setState(
                () => _course = courses.firstWhere((c) => c.name == v)),
          ),
          const SizedBox(height: 14),
        ],
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: _field(_qualCtrl, 'Qualification', 'e.g. B.Tech',
                Icons.workspace_premium_rounded),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _field(_addOnCtrl, 'Add-on Course', 'e.g. Firebase',
                Icons.extension_rounded),
          ),
        ]),
        const ErpFieldLabel('Expected Start Date', isOptional: true),
        ErpPickerTile(
          icon: Icons.event_available_rounded,
          placeholder: 'Pick a date',
          value: _start == null ? null : _fmt(_start),
          hasError: false,
          onTap: _pickStart,
        ),
        const SizedBox(height: 14),
        _field(_enquiryCtrl, 'Enquiry', 'e.g. Interested in weekend batch',
            Icons.notes_rounded,
            maxLines: 3),
        const ErpFieldLabel('Priority'),
        ErpChoiceGrid(
          columns: 2,
          options:
              priorities.map((s) => ErpChoice(s.label, s.icon, s.color)).toList(),
          selected: _priority.label,
          onSelect: (v) => setState(
              () => _priority = priorities.firstWhere((s) => s.label == v)),
        ),
        const SizedBox(height: 14),
        const ErpFieldLabel('Lead Status'),
        ErpChoiceGrid(
          columns: 2,
          options: kLeadStatuses
              .map((s) =>
                  ErpChoice(s.label, Icons.flag_rounded, _statusColor(s.key)))
              .toList(),
          selected: statusLabel[_status] ?? '',
          onSelect: (v) => setState(() =>
              _status = kLeadStatuses.firstWhere((s) => s.label == v).key),
        ),
        const SizedBox(height: 20),
        ErpPrimaryButton(
          text: 'Add Lead',
          icon: Icons.check_rounded,
          loading: _saving,
          onTap: _save,
        ),
        const SizedBox(height: 10),
        ErpSecondaryButton(text: 'Cancel', onTap: () => Navigator.pop(context)),
      ],
    );
  }
}