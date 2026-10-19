import 'package:flutter/material.dart';
import 'package:pokakbilling/ERP_UI_KIT.dart';
import 'package:pokakbilling/models/data-models/lead_model.dart';
import 'package:pokakbilling/models/data-models/reminder_model.dart';
import 'package:pokakbilling/viewmodels/lead_viewmodel.dart';
import 'package:pokakbilling/viewmodels/reminder/reminder_viewmodel.dart';
import 'package:pokakbilling/views/Screens/leads/lead_screens/leadsviewscreen.dart';
import 'package:pokakbilling/views/Screens/leads/reminder/add_new_reminder.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class LeadReminder extends StatefulWidget {
  const LeadReminder({super.key});

  @override
  State<LeadReminder> createState() => _LeadReminderState();
}

class _LeadReminderState extends State<LeadReminder>
    with TickerProviderStateMixin {
  int _selectedTab = 0;

  late final AnimationController _headerCtrl;
  late final AnimationController _bodyCtrl;
  late final Animation<double> _headerFade;
  late final Animation<Offset> _headerSlide;
  late final Animation<double> _bodyFade;
  late final Animation<Offset> _bodySlide;

  final TextEditingController _searchCtrl = TextEditingController();
  String _search = '';

  static const _tabColors = [
    ErpColors.cyan,
    ErpColors.blue,
    ErpColors.violet,
    ErpColors.green,
    ErpColors.red,
  ];

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
      final vm = context.read<ReminderViewmodel>();
      vm.attachContext(context);
      if (!vm.loading) vm.fetchReminders();

      final leadVm = context.read<LeadViewmodel>();
      if (leadVm.leadList.isEmpty) leadVm.getAllLeads();
    });
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    _bodyCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ═════════════════════════════════════════════════════════════════════════
  //  LEAD RESOLUTION
  // ═════════════════════════════════════════════════════════════════════════
  String _resolveLeadName(ReminderModel rem, LeadViewmodel leadVm) {
    if (rem.leadName != null && rem.leadName!.trim().isNotEmpty) {
      return rem.leadName!;
    }
    return _findLeadField('name', rem.leadId, leadVm);
  }

  String _resolvePhone(ReminderModel rem, LeadViewmodel leadVm) {
    if (rem.phone != null && rem.phone!.trim().isNotEmpty) {
      return rem.phone!.trim();
    }
    return _findLeadField('phone', rem.leadId, leadVm);
  }

  String _resolveEmail(ReminderModel rem, LeadViewmodel leadVm) {
    if (rem.email != null && rem.email!.trim().isNotEmpty) {
      return rem.email!.trim();
    }
    return _findLeadField('email', rem.leadId, leadVm);
  }

  String _findLeadField(String field, String? leadId, LeadViewmodel leadVm) {
    if (leadId == null || leadId.isEmpty) {
      return field == 'name' ? 'Unknown Lead' : '';
    }
    final lead = leadVm.leadList.cast<LeadModel?>().firstWhere(
          (l) => l!.leadId.toString() == leadId,
          orElse: () => null,
        );
    if (lead == null) return field == 'name' ? 'Lead #$leadId' : '';
    if (field == 'name') {
      return lead.name.isNotEmpty ? lead.name : 'Lead #$leadId';
    }
    if (field == 'phone') return lead.phone;
    return lead.emailId ?? '';
  }

  LeadModel? _findLeadObj(ReminderModel rem, LeadViewmodel leadVm) {
    final id = rem.leadId;
    if (id == null || id.isEmpty) return null;
    try {
      return leadVm.leadList.firstWhere((l) => l.leadId.toString() == id);
    } catch (_) {
      return null;
    }
  }

  // ═════════════════════════════════════════════════════════════════════════
  //  DATE / TIME FORMATTING
  // ═════════════════════════════════════════════════════════════════════════
  String _fmtDate(String? s) {
    if (s == null || s.isEmpty) return '—';
    try {
      final d = DateTime.parse(s);
      const m = [
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
      return '${d.day.toString().padLeft(2, '0')} ${m[d.month - 1]} ${d.year}';
    } catch (_) {
      return s;
    }
  }

  String _fmtTime(String? s) {
    if (s == null || s.isEmpty) return '—';
    final parts = s.split(':');
    if (parts.length >= 2) {
      final h = int.tryParse(parts[0]) ?? 0;
      final m = parts[1].padLeft(2, '0');
      final period = h >= 12 ? 'PM' : 'AM';
      final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
      return '$h12:$m $period';
    }
    return s;
  }

  DateTime? _tryParse(String? s) {
    if (s == null) return null;
    try {
      return DateTime.parse(s);
    } catch (_) {}
    try {
      final p = s.split(RegExp(r'[-/\s]'));
      if (p.length == 3) {
        if (p[0].length == 4) {
          return DateTime(int.tryParse(p[0]) ?? 1970, int.tryParse(p[1]) ?? 1,
              int.tryParse(p[2]) ?? 1);
        } else {
          return DateTime(int.tryParse(p[2]) ?? 1970, int.tryParse(p[1]) ?? 1,
              int.tryParse(p[0]) ?? 1);
        }
      }
    } catch (_) {}
    return null;
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  // ═════════════════════════════════════════════════════════════════════════
  //  COUNT & FILTER
  // ═════════════════════════════════════════════════════════════════════════
  Map<String, int> _counts(ReminderViewmodel vm) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    int a = vm.reminders.length, t = 0, u = 0, c = 0, o = 0;

    for (final rem in vm.reminders) {
      if (rem.completed) {
        c++;
        continue;
      }
      final d = _tryParse(rem.date);
      if (d != null) {
        final dOnly = DateTime(d.year, d.month, d.day);
        if (_sameDay(dOnly, today)) {
          t++;
        } else if (dOnly.isAfter(today)) {
          u++;
        } else {
          o++;
        }
      }
    }
    return {'all': a, 'today': t, 'upcoming': u, 'done': c, 'overdue': o};
  }

  List<ReminderModel> _filtered(ReminderViewmodel vm) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final out = <ReminderModel>[];

    for (final rem in vm.reminders) {
      if (_search.isNotEmpty) {
        final q = _search.toLowerCase();
        final name = (rem.leadName ?? '').toLowerCase();
        final subj = (rem.subject ?? '').toLowerCase();
        if (!name.contains(q) && !subj.contains(q)) continue;
      }

      final d = _tryParse(rem.date);

      switch (_selectedTab) {
        case 0:
          out.add(rem);
          break;
        case 1:
          if (d != null &&
              _sameDay(DateTime(d.year, d.month, d.day), today) &&
              !rem.completed) {
            out.add(rem);
          }
          break;
        case 2:
          if (d != null &&
              DateTime(d.year, d.month, d.day).isAfter(today) &&
              !rem.completed) {
            out.add(rem);
          }
          break;
        case 3:
          if (rem.completed) out.add(rem);
          break;
        case 4:
          if (d != null &&
              DateTime(d.year, d.month, d.day).isBefore(today) &&
              !rem.completed) {
            out.add(rem);
          }
          break;
      }
    }
    return out;
  }

  // ═════════════════════════════════════════════════════════════════════════
  //  LAUNCHERS
  // ═════════════════════════════════════════════════════════════════════════
  Future<void> _launchWhatsApp(String phone) async {
    final c = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (c.isEmpty) {
      _snack('No phone number available', isError: true);
      return;
    }
    final uri = Uri.parse('https://wa.me/$c');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _snack('Could not open WhatsApp', isError: true);
    }
  }

  Future<void> _launchCall(String phone) async {
    final c = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (c.isEmpty) {
      _snack('No phone number available', isError: true);
      return;
    }
    final uri = Uri(scheme: 'tel', path: c);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _snack('Could not open dialer', isError: true);
    }
  }

  Future<void> _launchEmail(String email) async {
    if (email.trim().isEmpty) {
      _snack('No email address available', isError: true);
      return;
    }
    final uri = Uri(scheme: 'mailto', path: email.trim());
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _snack('Could not open email app', isError: true);
    }
  }

  // ═════════════════════════════════════════════════════════════════════════
  //  MARK DONE
  // ═════════════════════════════════════════════════════════════════════════
  Future<void> _onMarkDone(ReminderModel rem, ReminderViewmodel vm) async {
    if (rem.completed) return;
    vm.markCompleted(rem.id);
    if (mounted) _snack('Reminder marked as done ✓');
  }

  void _snack(String msg, {bool isError = false}) {
    if (!mounted) return;
    erpToast(
      context,
      msg,
      color: isError ? ErpColors.red : ErpColors.green,
      icon: isError ? Icons.error_outline_rounded : Icons.check_circle_rounded,
    );
  }

  Future<void> _openAddReminder() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddReminderScreen()),
    );
    if (mounted) {
      await context.read<ReminderViewmodel>().refreshAllReminders();
    }
  }

  // ═════════════════════════════════════════════════════════════════════════
  //  BUILD
  // ═════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ReminderViewmodel>();
    final leadVm = context.watch<LeadViewmodel>();
    final counts = _counts(vm);
    final sw = MediaQuery.of(context).size.width;
    final topPad = MediaQuery.of(context).padding.top;
    final total = vm.reminders.length;

    return Scaffold(
      backgroundColor: ErpColors.pageBg,
      body: Column(
        children: [
          FadeTransition(
            opacity: _headerFade,
            child: SlideTransition(
              position: _headerSlide,
              child: _buildHeader(topPad, sw, total, counts),
            ),
          ),
          Expanded(
            child: FadeTransition(
              opacity: _bodyFade,
              child: SlideTransition(
                position: _bodySlide,
                child: Column(
                  children: [
                    _buildFilterBar(counts),
                    Expanded(
                      child: vm.loading
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
                          : _buildList(vm, leadVm),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  //  HEADER
  // ═════════════════════════════════════════════════════════════════════════
  Widget _buildHeader(
      double topPad, double sw, int total, Map<String, int> counts) {
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
            right: 104,
            top: topPad + 4,
            child: Transform.rotate(
              angle: -0.25,
              child: Icon(Icons.notifications_active_rounded,
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
              top: topPad + 12,
              bottom: 20,
              left: sw * 0.045,
              right: sw * 0.045,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ErpPressable(
                      onTap: () => Navigator.pop(context),
                      child: const ErpGlassCircle(
                          icon: Icons.arrow_back_ios_new_rounded,
                          iconSize: 19),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'My Reminders',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$total total reminders',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ErpPressable(
                      onTap: _openAddReminder,
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
                              'New',
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
                    _statPill('All', counts['all'] ?? 0, Icons.layers_rounded),
                    const SizedBox(width: 7),
                    _statPill(
                        'Today', counts['today'] ?? 0, Icons.today_rounded),
                    const SizedBox(width: 7),
                    _statPill('Upcoming', counts['upcoming'] ?? 0,
                        Icons.upcoming_rounded),
                    const SizedBox(width: 7),
                    _statPill('Done', counts['done'] ?? 0,
                        Icons.check_circle_rounded),
                    const SizedBox(width: 7),
                    _statPill('Overdue', counts['overdue'] ?? 0,
                        Icons.warning_amber_rounded),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statPill(String label, int count, IconData icon) {
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
            Text('$count',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900)),
            Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.88),
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                )),
          ],
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  //  FILTER BAR
  // ═════════════════════════════════════════════════════════════════════════
  Widget _buildFilterBar(Map<String, int> counts) {
    final tabs = [
      _Tab('All', counts['all'] ?? 0),
      _Tab('Today', counts['today'] ?? 0),
      _Tab('Upcoming', counts['upcoming'] ?? 0),
      _Tab('Done', counts['done'] ?? 0),
      _Tab('Overdue', counts['overdue'] ?? 0),
    ];
    final sw = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.fromLTRB(sw * 0.04, 16, sw * 0.04, 10),
      child: Column(
        children: [
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
                final sel = _selectedTab == i;
                final c = _tabColors[i];
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _selectedTab = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                      decoration: sel
                          ? BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [ErpColors.tint(c, 0.2), c],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: c.withValues(alpha: 0.35),
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
                            Text(tab.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: sel ? Colors.white : ErpColors.slate,
                                )),
                            Text('${tab.count}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: sel
                                      ? Colors.white
                                      : ErpColors.shade(c, 0.1),
                                )),
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
          Container(
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
                      hintText: 'Search reminders…',
                      hintStyle: TextStyle(
                          fontSize: 13.5,
                          color: ErpColors.slate.withValues(alpha: 0.7)),
                      border: InputBorder.none,
                      isCollapsed: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
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
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  //  LIST
  // ═════════════════════════════════════════════════════════════════════════
  Widget _buildList(ReminderViewmodel vm, LeadViewmodel leadVm) {
    final items = _filtered(vm);
    final tabLabels = ['All', 'Today', 'Upcoming', 'Done', 'Overdue'];
    final sw = MediaQuery.of(context).size.width;

    if (items.isEmpty) {
      return RefreshIndicator(
        color: ErpColors.cyan,
        onRefresh: () => vm.refreshAllReminders(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics()),
          children: [
            const SizedBox(height: 50),
            ErpEmptyState(
              icon: Icons.notifications_off_rounded,
              title: 'No ${tabLabels[_selectedTab]} Reminders',
              subtitle: 'Nothing scheduled for this filter',
              color: _tabColors[_selectedTab],
              actionLabel: 'Add a reminder',
              actionIcon: Icons.add_rounded,
              onAction: _openAddReminder,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: ErpColors.cyan,
      onRefresh: () => vm.refreshAllReminders(),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        padding: EdgeInsets.fromLTRB(sw * 0.04, 6, sw * 0.04, 32),
        itemCount: items.length,
        itemBuilder: (_, i) {
          final rem = items[i];
          final phone = _resolvePhone(rem, leadVm);
          final email = _resolveEmail(rem, leadVm);

          return ErpFadeIn(
            key: ValueKey('${rem.id}_${rem.completed}'),
            index: i < 10 ? i : 10,
            child: _ReminderCard(
              reminder: rem,
              leadName: _resolveLeadName(rem, leadVm),
              phone: phone,
              email: email,
              leadObj: _findLeadObj(rem, leadVm),
              dateStr: _fmtDate(rem.date),
              timeStr: _fmtTime(rem.time),
              onWhatsApp: () => _launchWhatsApp(phone),
              onCall: () => _launchCall(phone),
              onEmail: () => _launchEmail(email),
              onMarkDone: () => _onMarkDone(rem, vm),
              onLeadNotFound: () => _snack('Lead not found', isError: true),
              onViewLead: (lead) => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => LeadsViewScreen(lead: lead)),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Tab data ──────────────────────────────────────────────────────────────────
class _Tab {
  final String label;
  final int count;
  const _Tab(this.label, this.count);
}

// ═══════════════════════════════════════════════════════════════════════════════
//  REMINDER CARD
// ═══════════════════════════════════════════════════════════════════════════════
class _ReminderCard extends StatelessWidget {
  final ReminderModel reminder;
  final String leadName;
  final String phone;
  final String email;
  final LeadModel? leadObj;
  final String dateStr;
  final String timeStr;
  final VoidCallback onWhatsApp;
  final VoidCallback onCall;
  final VoidCallback onEmail;
  final VoidCallback onMarkDone;
  final VoidCallback onLeadNotFound;
  final void Function(LeadModel) onViewLead;

  const _ReminderCard({
    required this.reminder,
    required this.leadName,
    required this.phone,
    required this.email,
    required this.leadObj,
    required this.dateStr,
    required this.timeStr,
    required this.onWhatsApp,
    required this.onCall,
    required this.onEmail,
    required this.onMarkDone,
    required this.onLeadNotFound,
    required this.onViewLead,
  });

  @override
  Widget build(BuildContext context) {
    final rem = reminder;
    final isDone = rem.completed;

    final subject = rem.subject ?? '—';
    final notes = rem.notes ?? '';
    final type = rem.type ?? '';
    final status = rem.status ?? '';

    final initial = leadName.isNotEmpty ? leadName[0].toUpperCase() : 'R';

    bool isOverdue = false;
    if (!isDone && rem.date != null) {
      try {
        final d = DateTime.parse(rem.date!);
        final today = DateTime.now();
        if (DateTime(d.year, d.month, d.day)
            .isBefore(DateTime(today.year, today.month, today.day))) {
          isOverdue = true;
        }
      } catch (_) {}
    }

    // Type icon + colour from the kit (WhatsApp → real logo)
    final (typeIcon, typeColor) = type.isEmpty
        ? (Icons.notifications_active_rounded, ErpColors.pink)
        : erpTypeStyle(type);

    final Color accent = isDone
        ? ErpColors.green
        : isOverdue
            ? ErpColors.red
            : ErpColors.pink;

    final avatarColor =
        ErpColors.rotation[leadName.hashCode.abs() % ErpColors.rotation.length];

    void viewLead() {
      if (leadObj == null) {
        onLeadNotFound();
        return;
      }
      onViewLead(leadObj!);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDone
              ? ErpColors.green.withValues(alpha: 0.35)
              : isOverdue
                  ? ErpColors.red.withValues(alpha: 0.25)
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
          // Top accent strip
          Container(
            height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [ErpColors.tint(accent, 0.3), accent]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Avatar + subject + status ─────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                        child: Text(initial,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            )),
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(subject,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: ErpColors.ink,
                              )),
                          const SizedBox(height: 2),
                          GestureDetector(
                            onTap: viewLead,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.person_rounded,
                                    size: 13, color: ErpColors.slate),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(leadName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: ErpColors.slate,
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                      )),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _statusBadge(isDone, isOverdue, status),
                        if (leadObj != null) ...[
                          const SizedBox(height: 6),
                          ErpPressable(
                            onTap: () => onViewLead(leadObj!),
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
                                  Text('View Lead',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: ErpColors.cyanDeep,
                                        fontWeight: FontWeight.w800,
                                      )),
                                  SizedBox(width: 2),
                                  Icon(Icons.arrow_forward_rounded,
                                      size: 12, color: ErpColors.cyanDeep),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ── Type + notes + date/time box ──────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: typeColor.withValues(alpha: 0.16)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ErpGradientTile(
                              icon: typeIcon, color: typeColor, size: 36),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              type.isNotEmpty ? erpTitleCase(type) : 'Reminder',
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: ErpColors.ink,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (notes.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          notes[0].toUpperCase() + notes.substring(1),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: ErpColors.slate,
                            height: 1.4,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          ErpMetaChip(
                            icon: Icons.calendar_today_rounded,
                            text: dateStr,
                            color: isOverdue
                                ? ErpColors.red
                                : ErpColors.cyanDeep,
                          ),
                          ErpMetaChip(
                            icon: Icons.access_time_rounded,
                            text: timeStr,
                            color: isOverdue
                                ? ErpColors.red
                                : ErpColors.cyanDeep,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ── Action row ────────────────────────────────────────────
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      if (phone.isNotEmpty) ...[
                        _ActionChip(
                          icon: ErpIcons.whatsapp,
                          label: 'WhatsApp',
                          color: ErpColors.whatsapp,
                          onTap: onWhatsApp,
                        ),
                        const SizedBox(width: 6),
                        _ActionChip(
                          icon: Icons.call_rounded,
                          label: 'Call',
                          color: ErpColors.cyan,
                          onTap: onCall,
                        ),
                        const SizedBox(width: 6),
                      ],
                      if (email.isNotEmpty) ...[
                        _ActionChip(
                          icon: Icons.email_rounded,
                          label: 'Email',
                          color: ErpColors.violet,
                          onTap: onEmail,
                        ),
                        const SizedBox(width: 6),
                      ],
                      const SizedBox(width: 4),
                      if (!isDone)
                        _ActionChip(
                          icon: Icons.check_rounded,
                          label: 'Mark Done',
                          color: ErpColors.green,
                          filled: true,
                          onTap: onMarkDone,
                        )
                      else
                        const ErpStatusChip(
                            label: 'Completed', color: ErpColors.green),
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

  // ── Status badge ───────────────────────────────────────────────────────────
  Widget _statusBadge(bool isDone, bool isOverdue, String status) {
    if (isDone) {
      return const ErpStatusChip(label: 'Done', color: ErpColors.green);
    }
    if (isOverdue) {
      return const ErpStatusChip(label: 'Overdue', color: ErpColors.red);
    }
    final displayStatus = status.isNotEmpty
        ? status[0].toUpperCase() + status.substring(1)
        : 'Pending';
    return ErpStatusChip(label: displayStatus, color: ErpColors.orange);
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  REUSABLE ACTION CHIP (understands ErpIcons.whatsapp)
// ═══════════════════════════════════════════════════════════════════════════════
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
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          gradient: filled
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [ErpColors.tint(color, 0.2), color],
                )
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            erpIcon(icon, size: 14, color: filled ? Colors.white : color),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color:
                        filled ? Colors.white : ErpColors.shade(color, 0.12))),
          ],
        ),
      ),
    );
  }
}