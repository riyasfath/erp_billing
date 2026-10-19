// lib/views/Screens/leads/lead_screens/leadsNewScreen.dart
// REPLACED: Leads screen like the web
//  • High / Medium / Low priority cards (tap to filter)
//  • Tabs: Assigned Leads | My Leads | Convert Leads
//  • Filters: search, priority, status, source, date range

import 'package:flutter/material.dart';
import 'package:pokakbilling/views/Screens/leads/lead_screens/lead_widgets.dart';
import 'package:provider/provider.dart';
import 'package:pokakbilling/core/navigations.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/models/data-models/lead_model.dart';
import 'package:pokakbilling/viewmodels/lead_viewmodel.dart';
import 'package:pokakbilling/views/Screens/leads/lead_screens/create_lead.dart';
import 'package:pokakbilling/views/Screens/leads/lead_screens/leads_bottomBar.dart';
import 'package:pokakbilling/views/Screens/leads/lead_screens/leadsviewscreen.dart';

const int _kPageSize = 10;

class LeadsNewScreen extends StatefulWidget {
  final DateTime? preFilterFrom;
  final DateTime? preFilterTo;
  final int initialTab; // 0 Assigned, 1 My Leads, 2 Converted

  const LeadsNewScreen({
    super.key,
    this.preFilterFrom,
    this.preFilterTo,
    this.initialTab = 0,
  });

  @override
  State<LeadsNewScreen> createState() => _LeadsNewScreenState();
}

class _LeadsNewScreenState extends State<LeadsNewScreen> {
  late int _tab;
  String _search = '';
  String? _status; // label (New, Contacted, ... Other)
  String? _source;
  String? _priority; // HOT | WARM | COOL
  DateTime? _from;
  DateTime? _to;
  int _page = 0;

  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab;
    _from = widget.preFilterFrom;
    _to = widget.preFilterTo;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<LeadViewmodel>();
      vm.getAllLeads();
      vm.getAssignedLeads();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ─── helpers ──────────────────────────────────────────────────────────────
  DateTime? _parse(String? s) {
    if (s == null || s.isEmpty) return null;
    return DateTime.tryParse(s);
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _statusLabel(LeadModel l) {
    switch (l.status.toUpperCase()) {
      case 'NEW':
        return 'New';
      case 'CONTACTED':
        return 'Contacted';
      case 'QUALIFIED':
        return 'Qualified';
      case 'CONVERTED':
        return 'Converted';
      case 'LOST':
        return 'Lost';
      case 'OTHER':
        return 'Other';
      default:
        return l.statusDisplay;
    }
  }

  bool get _anyFilter =>
      _search.isNotEmpty ||
      _status != null ||
      _source != null ||
      _priority != null ||
      _from != null ||
      _to != null;

  void _clearAll() {
    _searchCtrl.clear();
    setState(() {
      _search = '';
      _status = null;
      _source = null;
      _priority = null;
      _from = null;
      _to = null;
      _page = 0;
    });
  }

  List<LeadModel> _baseFor(LeadViewmodel vm) {
    switch (_tab) {
      case 0:
        return vm.assignedLeadList;
      case 1:
        return vm.leadList;
      default:
        final map = <int, LeadModel>{};
        for (final l in [...vm.leadList, ...vm.assignedLeadList]) {
          if (l.status.toUpperCase() == 'CONVERTED') map[l.id] = l;
        }
        return map.values.toList();
    }
  }

  bool _passes(LeadModel l, {bool ignorePriority = false}) {
    if (_search.isNotEmpty) {
      final q = _search.trim().toLowerCase();
      final hay = '${l.name} ${l.company} ${l.email} ${l.phone} ${l.leadId} ${l.source ?? ''}'
          .toLowerCase();
      if (!hay.contains(q)) return false;
    }
    if (_status != null && _statusLabel(l).toLowerCase() != _status!.toLowerCase()) {
      return false;
    }
    if (_source != null &&
        (l.source ?? '').toLowerCase() != _source!.toLowerCase()) {
      return false;
    }
    if (!ignorePriority && _priority != null && l.priorityKey != _priority) {
      return false;
    }
    if (_from != null || _to != null) {
      final d = _parse(l.receivedDate);
      if (d == null) return false;
      final dd = DateTime(d.year, d.month, d.day);
      if (_from != null &&
          dd.isBefore(DateTime(_from!.year, _from!.month, _from!.day))) {
        return false;
      }
      if (_to != null && dd.isAfter(DateTime(_to!.year, _to!.month, _to!.day))) {
        return false;
      }
    }
    return true;
  }

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange:
          DateTimeRange(start: _from ?? now, end: _to ?? _from ?? now),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
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
        _from = picked.start;
        _to = picked.end;
        _page = 0;
      });
    }
  }

  void _open(LeadModel lead) {
    final vm = context.read<LeadViewmodel>();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LeadsViewScreen(lead: lead)),
    ).then((_) {
      vm.getAllLeads();
      vm.getAssignedLeads();
    });
  }

  // ─── BUILD ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Consumer<LeadViewmodel>(builder: (context, vm, _) {
      final base = _baseFor(vm);

      final statuses = <String>{};
      final sources = <String>{};
      for (final l in base) {
        if (l.status.trim().isNotEmpty) statuses.add(_statusLabel(l));
        if ((l.source ?? '').trim().isNotEmpty) sources.add(l.source!);
      }

      // counts ignore the priority filter itself so cards stay meaningful
      final forCounts = base.where((l) => _passes(l, ignorePriority: true)).toList();
      final summary = PrioritySummary.fromLeads(forCounts);

      final filtered = base.where(_passes).toList()
        ..sort((a, b) {
          final da = _parse(a.receivedDate) ?? _parse(a.createdAt) ?? DateTime(2000);
          final db = _parse(b.receivedDate) ?? _parse(b.createdAt) ?? DateTime(2000);
          return db.compareTo(da);
        });

      final totalPages = filtered.isEmpty ? 1 : (filtered.length / _kPageSize).ceil();
      final page = _page.clamp(0, totalPages - 1);
      final start = page * _kPageSize;
      final end = (start + _kPageSize).clamp(0, filtered.length);
      final items = filtered.isEmpty ? <LeadModel>[] : filtered.sublist(start, end);

      final tabTitle = ['Assigned Leads', 'My Leads', 'Converted Leads'][_tab];

      return Scaffold(
        backgroundColor: const Color(0xFFF5F8FC),
        bottomNavigationBar: const LeadsBottomBar(index: 2),
        body: Column(children: [
          AppHeader(
            title: 'Leads',
            subtitle: 'Manage and track your sales leads',
            onBack: () => Navigator.maybePop(context),
            trailing: GestureDetector(
              onTap: () => pushNavigation(context, const CreateLead(isEdit: false)),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  gradient: AppColors.buttonGradient,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: LeadUi.shadow(.25),
                ),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.add_rounded, color: AppColors.white, size: 16),
                  SizedBox(width: 4),
                  Text('New Lead',
                      style: TextStyle(
                          color: AppColors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800)),
                ]),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.c1,
              onRefresh: () async {
                await vm.getAllLeads();
                await vm.getAssignedLeads();
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics()),
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
                children: [
                  Reveal(child: _priorityCards(summary)),
                  const SizedBox(height: 12),
                  Reveal(
                    delayMs: 60,
                    child: _filterCard(statuses.toList()..sort(), sources.toList()..sort()),
                  ),
                  const SizedBox(height: 14),
                  Row(children: [
                    Text(tabTitle,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: AppColors.cdark)),
                    const SizedBox(width: 8),
                    StatusPill(label: '${filtered.length}', color: AppColors.c3),
                    const Spacer(),
                    if (_anyFilter)
                      GestureDetector(
                        onTap: _clearAll,
                        child: const Row(children: [
                          Icon(Icons.filter_alt_off_rounded,
                              size: 14, color: LeadUi.danger),
                          SizedBox(width: 4),
                          Text('Clear all',
                              style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  color: LeadUi.danger)),
                        ]),
                      ),
                  ]),
                  const SizedBox(height: 10),
                  if (vm.getLeadLoader && base.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 60),
                      child: Center(
                          child: CircularProgressIndicator(
                              color: AppColors.c1, strokeWidth: 2.5)),
                    )
                  else if (filtered.isEmpty)
                    AppCard(
                      child: EmptyHint(
                        icon: Icons.person_search_rounded,
                        text: _anyFilter
                            ? 'No leads match your filters'
                            : 'No records found matching your criteria.',
                      ),
                    )
                  else ...[
                    for (var i = 0; i < items.length; i++)
                      Reveal(
                        delayMs: i * 40,
                        child: _LeadCard(lead: items[i], onTap: () => _open(items[i])),
                      ),
                    if (totalPages > 1) _pagination(page, totalPages, filtered.length),
                  ],
                ],
              ),
            ),
          ),
        ]),
      );
    });
  }

  // ─── priority cards ───────────────────────────────────────────────────────
  Widget _priorityCards(PrioritySummary s) {
    final items = [
      _PItem('HOT', s.hot),
      _PItem('WARM', s.warm),
      _PItem('COOL', s.cool),
    ];
    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                _priority = _priority == items[i].key ? null : items[i].key;
                _page = 0;
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _priority == items[i].key
                      ? LeadUi.priorityColor(items[i].key).withOpacity(0.10)
                      : AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _priority == items[i].key
                        ? LeadUi.priorityColor(items[i].key)
                        : AppColors.c1.withOpacity(0.15),
                    width: _priority == items[i].key ? 1.6 : 1,
                  ),
                  boxShadow: LeadUi.shadow(),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: LeadUi.priorityColor(items[i].key).withOpacity(0.14),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.star_rounded,
                          size: 16, color: LeadUi.priorityColor(items[i].key)),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  Text('${LeadUi.priorityLevel(items[i].key)} PRIORITY'.toUpperCase(),
                      style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: .4,
                          color: LeadUi.priorityColor(items[i].key))),
                  const SizedBox(height: 2),
                  Text('${items[i].count}',
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: AppColors.cdark,
                          height: 1)),
                ]),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ─── filter card ──────────────────────────────────────────────────────────
  Widget _filterCard(List<String> statuses, List<String> sources) {
    final tabs = ['Assigned Leads', 'My Leads', 'Convert Leads'];
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            gradient: AppColors.headerGradient,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: List.generate(tabs.length, (i) {
              final sel = _tab == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() {
                    _tab = i;
                    _page = 0;
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: sel ? AppColors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: Text(tabs[i],
                        style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: sel ? AppColors.cdark : AppColors.white)),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 12),
        SearchField(
          controller: _searchCtrl,
          hint: 'Search by name, email, phone...',
          onChanged: (v) => setState(() {
            _search = v;
            _page = 0;
          }),
        ),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
            child: SoftChip(
              icon: Icons.calendar_today_outlined,
              label: _from != null
                  ? (_to != null ? '${_fmt(_from!)} – ${_fmt(_to!)}' : _fmt(_from!))
                  : 'Lead date',
              active: _from != null || _to != null,
              onTap: _pickRange,
              onClear: () => setState(() {
                _from = null;
                _to = null;
                _page = 0;
              }),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SoftChip(
              icon: Icons.tune_rounded,
              label: _status ?? 'Status',
              active: _status != null,
              onTap: () => showPickerSheet(
                context,
                title: 'Select Status',
                options: ['All', ...statuses],
                selected: _status ?? 'All',
                onSelect: (v) => setState(() {
                  _status = v == 'All' ? null : v;
                  _page = 0;
                }),
              ),
              onClear: () => setState(() {
                _status = null;
                _page = 0;
              }),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SoftChip(
              icon: Icons.public_rounded,
              label: _source ?? 'Source',
              active: _source != null,
              onTap: () => showPickerSheet(
                context,
                title: 'Select Source',
                options: ['All', ...sources],
                selected: _source ?? 'All',
                onSelect: (v) => setState(() {
                  _source = v == 'All' ? null : v;
                  _page = 0;
                }),
              ),
              onClear: () => setState(() {
                _source = null;
                _page = 0;
              }),
            ),
          ),
        ]),
      ]),
    );
  }

  // ─── pagination ───────────────────────────────────────────────────────────
  Widget _pagination(int page, int total, int count) {
    Widget btn(IconData i, bool en, VoidCallback t) => GestureDetector(
          onTap: en ? t : null,
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: en ? AppColors.c1.withOpacity(0.10) : AppColors.cxl,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: en ? AppColors.c1.withOpacity(0.3) : AppColors.cborder),
            ),
            child: Icon(i,
                size: 20,
                color: en ? AppColors.c1 : AppColors.ctext.withOpacity(0.3)),
          ),
        );

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(children: [
        btn(Icons.chevron_left_rounded, page > 0, () => setState(() => _page = page - 1)),
        Expanded(
          child: Center(
            child: Text(
              '${page * _kPageSize + 1}–${((page + 1) * _kPageSize).clamp(0, count)} of $count   •   Page ${page + 1}/$total',
              style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ctext),
            ),
          ),
        ),
        btn(Icons.chevron_right_rounded, page < total - 1,
            () => setState(() => _page = page + 1)),
      ]),
    );
  }
}

class _PItem {
  final String key;
  final int count;
  const _PItem(this.key, this.count);
}

// ─── Lead card ───────────────────────────────────────────────────────────────
class _LeadCard extends StatelessWidget {
  final LeadModel lead;
  final VoidCallback onTap;
  const _LeadCard({required this.lead, required this.onTap});

  String _date(String? s) {
    final d = DateTime.tryParse(s ?? '');
    if (d == null) return '–';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final pc = lead.priorityKey.isEmpty
        ? AppColors.c1
        : LeadUi.priorityColor(lead.priorityKey);
    final sc = LeadUi.statusColor(lead.status);

    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      accent: pc,
      onTap: onTap,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: pc.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(color: pc.withOpacity(0.35), width: 1.5),
            ),
            child: Center(
              child: Text(lead.name.isNotEmpty ? lead.name[0].toUpperCase() : '?',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w900, color: pc)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(lead.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.cdark)),
              const SizedBox(height: 2),
              Text(
                  [lead.leadId, lead.company].where((e) => e.isNotEmpty).join(' • '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11.5, color: AppColors.ctext)),
            ]),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: StatusPill(label: lead.statusDisplay.toUpperCase(), color: sc),
          ),
        ]),
        const SizedBox(height: 12),
        Divider(height: 1, color: AppColors.c1.withOpacity(0.10)),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
          PriorityBadge(priority: lead.priority),
          _meta(Icons.public_rounded, lead.source ?? 'No source'),
          _meta(Icons.calendar_today_outlined, _date(lead.receivedDate)),
          if (lead.phone.isNotEmpty) _meta(Icons.phone_outlined, lead.phone),
          if ((lead.assignedToName ?? '').isNotEmpty)
            _meta(Icons.person_outline_rounded, lead.assignedToName!),
        ]),
      ]),
    );
  }

  Widget _meta(IconData i, String t) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.cxl,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.cborder),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(i, size: 11, color: AppColors.ctext.withOpacity(0.6)),
          const SizedBox(width: 4),
          Text(t,
              style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ctext.withOpacity(0.85))),
        ]),
      );
}