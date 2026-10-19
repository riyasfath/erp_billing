import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pokakbilling/models/data-models/lead_model.dart';
import 'package:provider/provider.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/views/Screens/leads/reminder/add_new_reminder.dart';
import 'package:pokakbilling/models/data-models/reminder_model.dart';
import 'package:pokakbilling/viewmodels/lead_viewmodel.dart';
import 'package:pokakbilling/viewmodels/reminder/reminder_viewmodel.dart';
import 'package:pokakbilling/views/Screens/leads/lead_screens/leadsviewscreen.dart';
import 'package:url_launcher/url_launcher.dart';

// ─── WhatsApp SVG (matches home screen exactly) ───────────────────────────────
const String _kWhatsAppSvg = '''
<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
  <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347z"/>
  <path d="M12 0C5.373 0 0 5.373 0 12c0 2.125.558 4.122 1.528 5.855L.057 23.885a.5.5 0 00.611.611l6.101-1.459A11.945 11.945 0 0012 24c6.627 0 12-5.373 12-12S18.627 0 12 0zm0 21.818a9.818 9.818 0 01-5.012-1.378l-.36-.214-3.724.89.908-3.64-.235-.374A9.818 9.818 0 0112 2.182c5.428 0 9.818 4.39 9.818 9.818 0 5.429-4.39 9.818-9.818 9.818z"/>
</svg>
''';

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

  @override
  void initState() {
    super.initState();

    _selectedTab = 0;
    _search = '';

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
      // ✅ FIX: Always fetch fresh data when screen opens.
      // Old code: if (!vm.loading && vm.reminders.isEmpty) vm.fetchReminders();
      // That guard meant after reset() a cached widget would never re-fetch
      // because initState only fires once per widget lifetime.
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

  // ── Helpers ───────────────────────────────────────────────────────────────
  String _resolveLeadName(ReminderModel rem, LeadViewmodel leadVm) {
    return rem.leadName?.isNotEmpty == true
        ? rem.leadName!
        : _findLeadContact('name', rem.leadId, leadVm);
  }

  String _resolveLeadPhone(ReminderModel rem, LeadViewmodel leadVm) {
    if (rem.phone != null && rem.phone!.trim().isNotEmpty)
      return rem.phone!.trim();
    return _findLeadContact('phone', rem.leadId, leadVm);
  }

  String _resolveLeadEmail(ReminderModel rem, LeadViewmodel leadVm) {
    if (rem.email != null && rem.email!.trim().isNotEmpty)
      return rem.email!.trim();
    return _findLeadContact('email', rem.leadId, leadVm);
  }

  String _findLeadContact(String type, String? leadId, LeadViewmodel leadVm) {
    if (leadId == null || leadId.isEmpty)
      return type == 'name' ? 'Unknown Lead' : '';
    final l = leadVm.leadList.firstWhere(
      (l) => l.leadId.toString() == leadId || l.id.toString() == leadId,
      orElse: () => LeadModel(
        id: 0,
        leadId: '',
        name: type == 'name' ? 'Lead #$leadId' : '',
        company: '',
        email: '',
        phone: '',
        status: 'NEW',
        createdAt: '',
        updatedAt: '',
      ),
    );
    if (type == 'name') return l.name.isNotEmpty ? l.name : 'Lead #$leadId';
    if (type == 'phone') return l.phone ?? '';
    return l.email ?? '';
  }

  LeadModel? _findLeadForReminder(ReminderModel rem, LeadViewmodel leadVm) {
    final leadId = rem.leadId;
    if (leadId == null || leadId.isEmpty) return null;
    try {
      return leadVm.leadList.firstWhere(
        (l) => l.leadId.toString() == leadId || l.id.toString() == leadId,
      );
    } catch (_) {
      return null;
    }
  }

  IconData _getIconForType(String subtype) {
    switch (subtype.toLowerCase()) {
      case 'call':
        return Icons.call_rounded;
      case 'whatsapp':
        return Icons.message_rounded;
      case 'email':
        return Icons.email_rounded;
      case 'message':
        return Icons.sms_rounded;
      case 'follow-up':
      case 'followup':
        return Icons.repeat_rounded;
      default:
        return Icons.notifications_active_rounded;
    }
  }

  String _formatDate(String s) {
    try {
      final d = DateTime.parse(s);
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
      return '${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]} ${d.year}';
    } catch (_) {
      return s;
    }
  }

  String _formatTime(String s) {
    final parts = s.split(':');
    if (parts.length >= 2) {
      return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
    }
    return s;
  }

  DateTime? _tryParseDate(String? s) {
    if (s == null) return null;
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

  bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Map<String, int> _computeCounts(ReminderViewmodel vm) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    int a = vm.reminders.length, t = 0, u = 0, c = 0, o = 0;

    for (final rem in vm.reminders) {
      final date = _tryParseDate(rem.date);
      final completed = rem.completed;
      if (completed) {
        c++;
        continue;
      }
      if (date != null) {
        final dOnly = DateTime(date.year, date.month, date.day);
        if (_isSameDate(dOnly, today)) {
          t++;
        } else if (dOnly.isAfter(today)) {
          u++;
        } else if (dOnly.isBefore(today)) {
          o++;
        }
      }
    }
    return {'all': a, 'today': t, 'upcoming': u, 'completed': c, 'overdue': o};
  }

  List<ReminderModel> _filterReminders(ReminderViewmodel vm) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final out = <ReminderModel>[];

    for (final rem in vm.reminders) {
      if (_search.isNotEmpty) {
        final q = _search.toLowerCase();
        final name = (rem.leadName ?? '').toLowerCase();
        final title = (rem.title ?? rem.subject ?? '').toLowerCase();
        if (!name.contains(q) && !title.contains(q)) continue;
      }

      final date = _tryParseDate(rem.date);
      final completed = rem.completed;

      if (_selectedTab == 0) {
        // All
        out.add(rem);
      } else if (_selectedTab == 1) {
        // Today
        if (date != null) {
          final dOnly = DateTime(date.year, date.month, date.day);
          if (_isSameDate(dOnly, today) && !completed) out.add(rem);
        }
      } else if (_selectedTab == 2) {
        // Upcoming
        if (date != null) {
          final dOnly = DateTime(date.year, date.month, date.day);
          if (dOnly.isAfter(today) && !completed) out.add(rem);
        }
      } else if (_selectedTab == 3) {
        // Completed
        if (completed) out.add(rem);
      } else if (_selectedTab == 4) {
        // Overdue
        if (date != null) {
          final dOnly = DateTime(date.year, date.month, date.day);
          if (dOnly.isBefore(today) && !completed) out.add(rem);
        }
      }
    }
    return out;
  }

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

  Future<void> _onMarkDone(ReminderModel rem, ReminderViewmodel vm) async {
    if (rem.completed) return;

    // Optimistic update + API handled inside ViewModel
    vm.markCompleted(rem.id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Reminder marked as done'),
          backgroundColor: AppColors.c1,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ReminderViewmodel>();
    final leadVm = context.watch<LeadViewmodel>();
    final counts = _computeCounts(vm);
    final sw = MediaQuery.of(context).size.width;
    final topPad = MediaQuery.of(context).padding.top;
    final total = vm.reminders.length;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          FadeTransition(
            opacity: _headerFade,
            child: SlideTransition(
              position: _headerSlide,
              child: _buildHeader(context, topPad, sw, total, counts),
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
                        _buildFilterBar(counts),
                        Expanded(
                          child: vm.loading
                              ? Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.c1,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : _buildList(vm, leadVm),
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

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(
    BuildContext context,
    double topPad,
    double sw,
    int total,
    Map<String, int> counts,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: topPad + 14,
        bottom: 24,
        left: sw * 0.05,
        right: sw * 0.05,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.cborder, width: 1.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.c1.withOpacity(0.10),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.c1.withOpacity(0.20)),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColors.c1,
                    size: 15,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'My Reminders',
                      style: TextStyle(
                        color: AppColors.cdark,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$total total reminders',
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
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AddReminderScreen()),
                  );
                  if (mounted) {
                    await context
                        .read<ReminderViewmodel>()
                        .refreshAllReminders();
                  }
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
                        'New',
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
              _headerStat('All', counts['all'] ?? 0, AppColors.cdark),
              const SizedBox(width: 8),
              _headerStat('Today', counts['today'] ?? 0, AppColors.c1),
              const SizedBox(width: 8),
              _headerStat('Upcoming', counts['upcoming'] ?? 0, AppColors.ctext),
              const SizedBox(width: 8),
              _headerStat(
                  'Done', counts['completed'] ?? 0, Colors.green.shade500),
              const SizedBox(width: 8),
              _headerStat(
                  'Overdue', counts['overdue'] ?? 0, Colors.red.shade500),
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
  Widget _buildFilterBar(Map<String, int> counts) {
    final tabs = [
      _TabData('All', counts['all'] ?? 0),
      _TabData('Today', counts['today'] ?? 0),
      _TabData('Upcoming', counts['upcoming'] ?? 0),
      _TabData('Done', counts['completed'] ?? 0),
      _TabData('Overdue', counts['overdue'] ?? 0),
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
                    onTap: () => setState(() => _selectedTab = i),
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
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.cxl,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cborder),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Icon(Icons.search_rounded, size: 16, color: AppColors.ctext),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _search = v),
                    style:
                        const TextStyle(fontSize: 13, color: AppColors.cdark),
                    decoration: InputDecoration(
                      hintText: 'Search reminders…',
                      hintStyle: TextStyle(
                        fontSize: 12,
                        color: AppColors.ctext.withOpacity(0.60),
                      ),
                      border: InputBorder.none,
                      isCollapsed: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
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
        ],
      ),
    );
  }

  // ── List ──────────────────────────────────────────────────────────────────
  Widget _buildList(ReminderViewmodel vm, LeadViewmodel leadVm) {
    final filtered = _filterReminders(vm);
    final tabLabels = ['All', 'Today', 'Upcoming', 'Done', 'Overdue'];

    if (filtered.isEmpty) {
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
              child: Icon(Icons.notifications_off_rounded,
                  color: AppColors.c1.withOpacity(0.55), size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              'No ${tabLabels[_selectedTab]} Reminders',
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

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      itemCount: filtered.length,
      itemBuilder: (_, i) {
        final rem = filtered[i];
        return _AnimatedReminderCard(
          key: ValueKey('${rem.id}_${rem.completed}'),
          reminder: rem,
          delay: Duration(milliseconds: 40 + i * 60),
          leadName: _resolveLeadName(rem, leadVm),
          phone: _resolveLeadPhone(rem, leadVm),
          email: _resolveLeadEmail(rem, leadVm),
          leadObj: _findLeadForReminder(rem, leadVm),
          typeIcon: _getIconForType(rem.subtype ?? rem.type ?? 'email'),
          dateStr: _formatDate(rem.date ?? ''),
          timeStr: _formatTime(rem.time ?? ''),
          onWhatsApp: () => _launchWhatsApp(_resolveLeadPhone(rem, leadVm)),
          onCall: () => _launchCall(_resolveLeadPhone(rem, leadVm)),
          onEmail: () => _launchEmail(_resolveLeadEmail(rem, leadVm)),
          onMarkDone: () => _onMarkDone(rem, vm),
          onViewLead: (lead) => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => LeadsViewScreen(lead: lead)),
          ),
        );
      },
    );
  }
}

// ─── Tab data ─────────────────────────────────────────────────────────────────
class _TabData {
  final String label;
  final int count;
  const _TabData(this.label, this.count);
}

// ─── Animated reminder card ───────────────────────────────────────────────────
class _AnimatedReminderCard extends StatefulWidget {
  final ReminderModel reminder;
  final Duration delay;
  final String leadName;
  final String phone;
  final String email;
  final LeadModel? leadObj;
  final IconData typeIcon;
  final String dateStr;
  final String timeStr;
  final VoidCallback onWhatsApp;
  final VoidCallback onCall;
  final VoidCallback onEmail;
  final VoidCallback onMarkDone;
  final void Function(LeadModel) onViewLead;

  const _AnimatedReminderCard({
    super.key,
    required this.reminder,
    required this.delay,
    required this.leadName,
    required this.phone,
    required this.email,
    required this.leadObj,
    required this.typeIcon,
    required this.dateStr,
    required this.timeStr,
    required this.onWhatsApp,
    required this.onCall,
    required this.onEmail,
    required this.onMarkDone,
    required this.onViewLead,
  });

  @override
  State<_AnimatedReminderCard> createState() => _AnimatedReminderCardState();
}

class _AnimatedReminderCardState extends State<_AnimatedReminderCard>
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
    final rem = widget.reminder;
    final isCompleted = rem.completed;
    final title = rem.title ?? rem.subject ?? '—';
    final description = rem.description ?? rem.notes ?? '';
    final initials =
        widget.leadName.isNotEmpty ? widget.leadName[0].toUpperCase() : 'R';

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
                    color: isCompleted
                        ? AppColors.c1.withOpacity(0.40)
                        : AppColors.c1.withOpacity(0.15),
                    width: isCompleted ? 1.5 : 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isCompleted
                          ? AppColors.c1.withOpacity(0.12)
                          : AppColors.c1.withOpacity(0.07),
                      blurRadius: isCompleted ? 16 : 10,
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
                        color:
                            isCompleted ? Colors.green.shade400 : AppColors.c1,
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
                          // Lead avatar + name + status
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                    initials,
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
                                      title,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.cdark,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        if (widget.leadObj == null) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                                  content:
                                                      Text('Lead not found')));
                                          return;
                                        }
                                        widget.onViewLead(widget.leadObj!);
                                      },
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            widget.leadName,
                                            style: TextStyle(
                                              color: AppColors.c1,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(width: 3),
                                          Icon(Icons.arrow_forward_rounded,
                                              size: 10, color: AppColors.c1),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (isCompleted)
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
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withOpacity(0.10),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                            color: Colors.orange
                                                .withOpacity(0.30)),
                                      ),
                                      child: Text(
                                        'Pending',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.orange.shade700,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 4),
                                  GestureDetector(
                                    onTap: () {
                                      if (widget.leadObj != null) {
                                        widget.onViewLead(widget.leadObj!);
                                      }
                                    },
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

                          if (description.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              description[0].toUpperCase() +
                                  description.substring(1),
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.ctext.withOpacity(0.55),
                                height: 1.4,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],

                          const SizedBox(height: 10),
                          Divider(
                              height: 1, color: AppColors.c1.withOpacity(0.10)),
                          const SizedBox(height: 10),

                          // Type icon + date + time row
                          Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: AppColors.c1.withOpacity(0.10),
                                  borderRadius: BorderRadius.circular(9),
                                ),
                                child: Icon(widget.typeIcon,
                                    size: 15, color: AppColors.c1),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.cxl,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.cborder),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.calendar_today_rounded,
                                        size: 10, color: AppColors.ctext),
                                    const SizedBox(width: 4),
                                    Text(
                                      widget.dateStr,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            AppColors.ctext.withOpacity(0.70),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.cxl,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.cborder),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.access_time_rounded,
                                        size: 10, color: AppColors.ctext),
                                    const SizedBox(width: 4),
                                    Text(
                                      widget.timeStr,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            AppColors.ctext.withOpacity(0.70),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // ── Action row ────────────────────────────────────
                          Row(
                            children: [
                              // WhatsApp — SVG icon (matches home screen)
                              if (widget.phone.isNotEmpty) ...[
                                _WaActionBtn(onTap: widget.onWhatsApp),
                                const SizedBox(width: 6),
                              ],
                              if (widget.phone.isNotEmpty) ...[
                                _ActionBtn(
                                  icon: Icons.call_rounded,
                                  label: 'Call',
                                  color: AppColors.cdark,
                                  onTap: widget.onCall,
                                ),
                                const SizedBox(width: 6),
                              ],
                              if (widget.email.isNotEmpty) ...[
                                _ActionBtn(
                                  icon: Icons.email_rounded,
                                  label: 'Email',
                                  color: AppColors.c1,
                                  onTap: widget.onEmail,
                                ),
                                const SizedBox(width: 6),
                              ],
                              const Spacer(),
                              // Mark done button — hidden when already done
                              if (!isCompleted)
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
                                        ),
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
    const color = Color(0xFF25D366);
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
