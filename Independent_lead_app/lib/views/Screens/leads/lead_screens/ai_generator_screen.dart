// lib/views/Screens/leads/ai/ai_generator_screen.dart  (NEW)
// AI Follow-up Email Generator + AI WhatsApp Generator (same as the web).
//
// Flow:  Generate New → pick lead → options → generated message → edit / copy
//        / send.  Email is sent by the backend (SMTP). WhatsApp opens
//        api.whatsapp.com with the text, then the entry is marked SENT.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pokakbilling/viewmodels/ai_generator/ai_generator_viewmodel.dart';
import 'package:pokakbilling/views/Screens/leads/lead_screens/lead_widgets.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/models/data-models/ai_followup_model.dart';
import 'package:pokakbilling/models/data-models/lead_model.dart';
import 'package:pokakbilling/models/services/ai_generator_service.dart';
import 'package:pokakbilling/viewmodels/lead_viewmodel.dart';
import 'package:pokakbilling/views/Screens/leads/lead_screens/leads_bottomBar.dart';

final DateFormat _dtFmt = DateFormat('dd MMM yyyy  •  hh:mm a');

Future<bool> _openWhatsApp(
    BuildContext context, LeadModel lead, String text) async {
  if (lead.phone.trim().isEmpty) {
    showToast(context, 'This lead has no phone number', error: true);
    return false;
  }
  try {
    final ok = await launchUrl(
      AiGeneratorService.whatsappUri(lead.phone, text),
      mode: LaunchMode.externalApplication,
    );
    if (!ok && context.mounted) {
      showToast(context, 'Could not open WhatsApp', error: true);
    }
    return ok;
  } catch (_) {
    if (context.mounted) {
      showToast(context, 'Could not open WhatsApp', error: true);
    }
    return false;
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// MAIN SCREEN
// ═════════════════════════════════════════════════════════════════════════════
class AiGeneratorScreen extends StatefulWidget {
  final String initialChannel; // 'email' | 'whatsapp'
  const AiGeneratorScreen({super.key, this.initialChannel = 'email'});

  @override
  State<AiGeneratorScreen> createState() => _AiGeneratorScreenState();
}

class _AiGeneratorScreenState extends State<AiGeneratorScreen> {
  late String _channel;
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';
  DateTime? _date;
  String _status = 'All';
  final Set<int> _open = {};
  bool _autoOpened = false;

  bool get _isEmail => _channel == 'email';

  @override
  void initState() {
    super.initState();
    _channel = widget.initialChannel == 'whatsapp' ? 'whatsapp' : 'email';
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (!mounted) return;
    final lv = context.read<LeadViewmodel>();
    if (lv.leadList.isEmpty) lv.getAllLeads();
    if (lv.assignedLeadList.isEmpty) lv.getAssignedLeads();
    await context.read<AiGeneratorViewModel>().load(_channel);
  }

  void _setChannel(String c) {
    if (c == _channel) return;
    setState(() {
      _channel = c;
      _open.clear();
      _autoOpened = false;
      _status = 'All';
    });
    _load();
  }

  // ─── data helpers ─────────────────────────────────────────────────────────
  List<LeadModel> _allLeads(LeadViewmodel lv) {
    final map = <int, LeadModel>{};
    for (final l in [...lv.leadList, ...lv.assignedLeadList]) {
      map[l.id] = l;
    }
    return map.values.toList();
  }

  LeadModel _leadFor(AiFollowup it, LeadViewmodel lv) {
    for (final l in _allLeads(lv)) {
      if (l.id == it.lead) return l;
    }
    return LeadModel(
      id: it.lead,
      leadId: '',
      name: it.leadName ?? 'Lead',
      company: it.leadCompany ?? '',
      email: '',
      phone: '',
      status: 'NEW',
      createdAt: '',
      updatedAt: '',
    );
  }

  List<AiFollowup> _filtered(List<AiFollowup> all) {
    final q = _query.trim().toLowerCase();
    return all.where((i) {
      if (q.isNotEmpty) {
        final hay =
            '${i.leadName ?? ''} ${i.leadCompany ?? ''} ${i.message} ${i.purpose}'
                .toLowerCase();
        if (!hay.contains(q)) return false;
      }
      if (_status != 'All' && i.status != _status.toUpperCase()) return false;
      if (_date != null) {
        final c = i.created;
        if (c == null || !DateUtils.isSameDay(c, _date)) return false;
      }
      return true;
    }).toList();
  }

  // ─── actions ──────────────────────────────────────────────────────────────
  Future<void> _generateNew() async {
    final lv = context.read<LeadViewmodel>();
    final lead = await showModalBottomSheet<LeadModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LeadPickerSheet(leads: _allLeads(lv)),
    );
    if (lead != null && mounted) await _generateFor(lead);
  }

  Future<void> _generateFor(LeadModel lead) async {
    final res = await showModalBottomSheet<AiFollowup>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _GenerateSheet(lead: lead, channel: _channel),
    );
    if (res != null && mounted) {
      setState(() => _open.add(res.lead));
      await _openMessage(res, lead);
    }
  }

  Future<void> _openMessage(AiFollowup it, LeadModel lead) async {
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MessageSheet(item: it, lead: lead, channel: _channel),
    );
  }

  Future<void> _quickSend(AiFollowup it, LeadModel lead) async {
    final vm = context.read<AiGeneratorViewModel>();
    if (!_isEmail) {
      final ok = await _openWhatsApp(context, lead, it.message);
      if (!ok) return;
    }
    final ok = await vm.send(it.id);
    if (!mounted) return;
    showToast(
      context,
      ok
          ? (_isEmail ? 'Email sent successfully' : 'WhatsApp opened & marked as sent')
          : (vm.lastError ?? 'Failed to send'),
      error: !ok,
    );
  }

  Future<void> _delete(AiFollowup it) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Delete message?',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text('This AI follow-up will be removed permanently.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete',
                  style: TextStyle(color: LeadUi.danger))),
        ],
      ),
    );
    if (yes != true || !mounted) return;
    final vm = context.read<AiGeneratorViewModel>();
    final ok = await vm.delete(it.id);
    if (!mounted) return;
    showToast(context, ok ? 'Deleted' : (vm.lastError ?? 'Delete failed'),
        error: !ok);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 1, 12, 31),
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
    if (d != null) setState(() => _date = d);
  }

  // ─── BUILD ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Consumer2<AiGeneratorViewModel, LeadViewmodel>(
      builder: (context, vm, lv, _) {
        final all = vm.itemsFor(_channel);
        final items = _filtered(all);

        final groups = <int, List<AiFollowup>>{};
        for (final i in items) {
          groups.putIfAbsent(i.lead, () => []).add(i);
        }
        final keys = groups.keys.toList()
          ..sort((a, b) {
            final da = groups[a]!.first.created ?? DateTime(2000);
            final db = groups[b]!.first.created ?? DateTime(2000);
            return db.compareTo(da);
          });

        if (!_autoOpened && keys.isNotEmpty) {
          _autoOpened = true;
          _open.add(keys.first);
        }

        final loading = vm.isLoading(_channel);
        final error = vm.loadErrorFor(_channel);

        return Scaffold(
          backgroundColor: const Color(0xFFF5F8FC),
          bottomNavigationBar: const LeadsBottomBar(index: 4),
          body: Column(children: [
            AppHeader(
              title: _isEmail ? 'AI Follow-up Email Generator' : 'AI WhatsApp Generator',
              subtitle: _isEmail
                  ? 'Generate personalized emails using CRM lead information.'
                  : 'Generate personalized WhatsApp messages using CRM lead information.',
              onBack: () => Navigator.maybePop(context),
            ),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.c1,
                onRefresh: _load,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics()),
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
                  children: [
                    Reveal(child: _channelSwitch()),
                    const SizedBox(height: 12),
                    Reveal(delayMs: 50, child: _intro()),
                    const SizedBox(height: 12),
                    Reveal(delayMs: 90, child: _filters()),
                    const SizedBox(height: 14),
                    if (loading && all.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 60),
                        child: Center(
                            child: CircularProgressIndicator(
                                color: AppColors.c1, strokeWidth: 2.5)),
                      )
                    else if (error != null && all.isEmpty)
                      AppCard(
                        child: Column(children: [
                          const Icon(Icons.error_outline_rounded,
                              color: LeadUi.danger, size: 30),
                          const SizedBox(height: 8),
                          Text(error,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 12.5, color: LeadUi.danger)),
                          TextButton(onPressed: _load, child: const Text('Retry')),
                        ]),
                      )
                    else if (keys.isEmpty)
                      AppCard(
                        child: EmptyHint(
                          icon: _isEmail
                              ? Icons.mark_email_unread_outlined
                              : Icons.chat_bubble_outline_rounded,
                          text: all.isEmpty
                              ? 'Nothing generated yet.\nTap "Generate New" to create your first message.'
                              : 'No messages match your filters.',
                        ),
                      )
                    else
                      for (var i = 0; i < keys.length; i++)
                        Reveal(
                          delayMs: i * 40,
                          child: _group(keys[i], groups[keys[i]]!, lv),
                        ),
                  ],
                ),
              ),
            ),
          ]),
        );
      },
    );
  }

  // ─── channel switch ───────────────────────────────────────────────────────
  Widget _channelSwitch() {
    Widget tab(String c, IconData icon, String label) {
      final sel = _channel == c;
      return Expanded(
        child: GestureDetector(
          onTap: () => _setChannel(c),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            height: 42,
            decoration: BoxDecoration(
              color: sel ? AppColors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(26),
              boxShadow: sel ? LeadUi.shadow(.15) : null,
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icon,
                  size: 17, color: sel ? AppColors.c3 : AppColors.white),
              const SizedBox(width: 7),
              Text(label,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: sel ? AppColors.cdark : AppColors.white)),
            ]),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(children: [
        tab('email', Icons.mail_rounded, 'Email'),
        tab('whatsapp', Icons.chat_rounded, 'WhatsApp'),
      ]),
    );
  }

  Widget _intro() {
    return AppCard(
      accent: AppColors.c1,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(_isEmail ? 'AI Emails Follow-ups' : 'AI WhatsApp Follow-ups Messages',
            style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: AppColors.cdark)),
        const SizedBox(height: 3),
        Text(
          _isEmail
              ? 'Review, resend or regenerate previous AI-generated emails.'
              : 'Review, resend or regenerate previous AI-generated whatsapps.',
          style: const TextStyle(fontSize: 12, color: AppColors.ctext),
        ),
        const SizedBox(height: 14),
        GradientButton(
          label: _isEmail ? 'Generate New Email' : 'Generate New WhatsApp',
          icon: Icons.add_rounded,
          onTap: _generateNew,
        ),
      ]),
    );
  }

  Widget _filters() {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(children: [
        SearchField(
          controller: _searchCtrl,
          hint: 'Search by lead, company, or text...',
          onChanged: (v) => setState(() => _query = v),
        ),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
            child: SoftChip(
              icon: Icons.calendar_today_outlined,
              label: _date == null ? 'dd/mm/yyyy' : DateFormat('dd/MM/yyyy').format(_date!),
              active: _date != null,
              onTap: _pickDate,
              onClear: () => setState(() => _date = null),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SoftChip(
              icon: Icons.tune_rounded,
              label: _status == 'All' ? 'All Status' : _status,
              active: _status != 'All',
              onTap: () => showPickerSheet(
                context,
                title: 'Filter by status',
                options: const ['All', 'Generated', 'Sent', 'Replied', 'Failed'],
                selected: _status,
                onSelect: (v) => setState(() => _status = v),
              ),
              onClear: () => setState(() => _status = 'All'),
            ),
          ),
        ]),
      ]),
    );
  }

  // ─── lead group ───────────────────────────────────────────────────────────
  Widget _group(int leadId, List<AiFollowup> list, LeadViewmodel lv) {
    final latest = list.first;
    final lead = _leadFor(latest, lv);
    final open = _open.contains(leadId);
    final name = (latest.leadName ?? lead.name).isEmpty
        ? 'Lead'
        : (latest.leadName ?? lead.name);
    final company = (latest.leadCompany ?? lead.company);
    final code = lead.leadId.isEmpty ? '' : '#${lead.leadId}';

    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.zero,
      child: Column(children: [
        InkWell(
          onTap: () => setState(() {
            if (open) {
              _open.remove(leadId);
            } else {
              _open.add(leadId);
            }
          }),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              AnimatedRotation(
                turns: open ? 0.25 : 0,
                duration: const Duration(milliseconds: 200),
                child: const Icon(Icons.chevron_right_rounded,
                    size: 20, color: AppColors.ctext),
              ),
              const SizedBox(width: 6),
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF1E5163),
                child: Text(name.isNotEmpty ? name[0].toLowerCase() : '?',
                    style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Flexible(
                      child: Text(name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.cdark)),
                    ),
                    if (code.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Text(code,
                          style: const TextStyle(
                              fontSize: 10.5, color: AppColors.ctext)),
                    ],
                  ]),
                  Text(company.isEmpty ? 'N/A' : company,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11.5, color: AppColors.ctext)),
                ]),
              ),
              const SizedBox(width: 8),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(_isEmail ? 'LATEST EMAIL' : 'LATEST WHATSAPP',
                    style: const TextStyle(
                        fontSize: 8,
                        letterSpacing: .6,
                        color: AppColors.ctext,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                    latest.created == null
                        ? ''
                        : DateFormat('dd MMM yyyy').format(latest.created!),
                    style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.cdark)),
                const SizedBox(height: 3),
                StatusPill(
                    label: latest.status, color: LeadUi.statusColor(latest.status)),
              ]),
            ]),
          ),
        ),
        if (open) ...[
          Divider(height: 1, color: AppColors.c1.withOpacity(0.12)),
          _itemTile(latest, lead, latest: true),
          if (list.length > 1) ...[
            Container(
              width: double.infinity,
              color: AppColors.cxl,
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
              child: const Text('PREVIOUS AI FOLLOW-UPS',
                  style: TextStyle(
                      fontSize: 9.5,
                      letterSpacing: .8,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ctext)),
            ),
            for (final p in list.skip(1)) ...[
              Divider(height: 1, color: AppColors.c1.withOpacity(0.08)),
              _itemTile(p, lead, latest: false),
            ],
          ],
        ],
      ]),
    );
  }

  Widget _itemTile(AiFollowup it, LeadModel lead, {required bool latest}) {
    final sc = LeadUi.statusColor(it.status);
    final emailSent = _isEmail && it.status == 'SENT';

    return Container(
      width: double.infinity,
      color: latest ? AppColors.cxl.withOpacity(0.55) : AppColors.white,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          if (latest)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Text('LATEST',
                  style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .8,
                      color: AppColors.c3)),
            ),
          Text(it.created == null ? '' : _dtFmt.format(it.created!),
              style: const TextStyle(fontSize: 10.5, color: AppColors.ctext)),
          const SizedBox(width: 8),
          StatusPill(label: it.status, color: sc),
        ]),
        const SizedBox(height: 8),
        Text(it.purposeLabel,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: AppColors.cdark,
                letterSpacing: .2)),
        const SizedBox(height: 4),
        Text(it.message,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontSize: 12.5,
                height: 1.4,
                color: AppColors.cdark.withOpacity(0.72))),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: [
          _act(Icons.visibility_outlined, 'View', () => _openMessage(it, lead)),
          _act(Icons.autorenew_rounded, 'Generate', () => _generateFor(lead)),
          _act(Icons.copy_rounded, 'Copy', () {
            Clipboard.setData(ClipboardData(text: it.message));
            showToast(context, 'Message copied');
          }),
          _act(Icons.send_rounded, 'Send', () => _quickSend(it, lead),
              enabled: !emailSent, primary: true),
          GestureDetector(
            onTap: () => _delete(it),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: LeadUi.danger.withOpacity(0.07),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.delete_outline_rounded,
                  size: 18, color: LeadUi.danger),
            ),
          ),
        ]),
      ]),
    );
  }

  Widget _act(IconData icon, String label, VoidCallback onTap,
      {bool enabled = true, bool primary = false}) {
    final fg = !enabled
        ? AppColors.ctext.withOpacity(0.4)
        : (primary ? AppColors.white : AppColors.cdark);
    return Opacity(
      opacity: enabled ? 1 : .6,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: primary && enabled ? AppColors.c1 : AppColors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: primary && enabled ? AppColors.c1 : AppColors.cborder),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 15, color: fg),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w700, color: fg)),
          ]),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Sheet frame
// ═════════════════════════════════════════════════════════════════════════════
class _SheetFrame extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  const _SheetFrame({required this.title, this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.92),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              decoration: BoxDecoration(
                  color: AppColors.c1.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 8, 6),
              child: Row(children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: AppColors.cdark)),
                    if (subtitle != null)
                      Text(subtitle!,
                          style: const TextStyle(
                              fontSize: 11.5, color: AppColors.ctext)),
                  ]),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close_rounded,
                      color: AppColors.ctext.withOpacity(0.6)),
                ),
              ]),
            ),
            Divider(height: 1, color: AppColors.c1.withOpacity(0.10)),
            Flexible(child: child),
          ]),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// SELECT A LEAD
// ═════════════════════════════════════════════════════════════════════════════
class _LeadPickerSheet extends StatefulWidget {
  final List<LeadModel> leads;
  const _LeadPickerSheet({required this.leads});

  @override
  State<_LeadPickerSheet> createState() => _LeadPickerSheetState();
}

class _LeadPickerSheetState extends State<_LeadPickerSheet> {
  final TextEditingController _ctrl = TextEditingController();
  String _q = '';
  String _status = 'All';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = _q.trim().toLowerCase();
    final list = widget.leads.where((l) {
      if (_status != 'All' && l.status.toUpperCase() != _status.toUpperCase()) {
        return false;
      }
      if (q.isEmpty) return true;
      return '${l.name} ${l.company} ${l.phone} ${l.email} ${l.leadId}'
          .toLowerCase()
          .contains(q);
    }).toList();

    const statuses = ['All', 'New', 'Contacted', 'Qualified', 'Converted', 'Lost'];

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scroll) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 10, bottom: 6),
            decoration: BoxDecoration(
                color: AppColors.c1.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 8, 4),
            child: Row(children: [
              const Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Select a Lead',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.cdark)),
                  Text('Search and select a lead to generate customized AI follow-up messages.',
                      style: TextStyle(fontSize: 11.5, color: AppColors.ctext)),
                ]),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close_rounded,
                    color: AppColors.ctext.withOpacity(0.6)),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: SearchField(
              controller: _ctrl,
              hint: 'Search by name, company, phone, email, lead code...',
              onChanged: (v) => setState(() => _q = v),
            ),
          ),
          SizedBox(
            height: 50,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: statuses.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final s = statuses[i];
                final sel = s == _status;
                return GestureDetector(
                  onTap: () => setState(() => _status = s),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: sel ? AppColors.cdark : AppColors.cxl,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: sel ? AppColors.cdark : AppColors.cborder),
                    ),
                    child: Text(s,
                        style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: sel ? AppColors.white : AppColors.ctext)),
                  ),
                );
              },
            ),
          ),
          Divider(height: 1, color: AppColors.c1.withOpacity(0.10)),
          Expanded(
            child: list.isEmpty
                ? const Center(
                    child: EmptyHint(
                        icon: Icons.apartment_rounded,
                        text: 'No leads found\nTry adjusting your search query or filter options.'))
                : ListView.separated(
                    controller: scroll,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    itemCount: list.length,
                    separatorBuilder: (_, __) =>
                        Divider(height: 1, color: AppColors.c1.withOpacity(0.07)),
                    itemBuilder: (_, i) {
                      final l = list[i];
                      return ListTile(
                        onTap: () => Navigator.pop(context, l),
                        leading: CircleAvatar(
                          backgroundColor: AppColors.c1.withOpacity(0.15),
                          child: Text(
                              l.name.isNotEmpty ? l.name[0].toUpperCase() : '?',
                              style: const TextStyle(
                                  color: AppColors.c3,
                                  fontWeight: FontWeight.w800)),
                        ),
                        title: Text(l.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 14)),
                        subtitle: Text(
                            [l.leadId, l.company, l.phone]
                                .where((e) => e.isNotEmpty)
                                .join(' • '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11.5)),
                        trailing: StatusPill(
                            label: l.statusDisplay.toUpperCase(),
                            color: LeadUi.statusColor(l.status)),
                      );
                    },
                  ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.cborder)),
            ),
            child: Row(children: [
              Text('Total leads: ${list.length}',
                  style: const TextStyle(fontSize: 12, color: AppColors.ctext)),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Text('Cancel',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ctext)),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// GENERATE OPTIONS
// ═════════════════════════════════════════════════════════════════════════════
class _GenerateSheet extends StatefulWidget {
  final LeadModel lead;
  final String channel;
  const _GenerateSheet({required this.lead, required this.channel});

  @override
  State<_GenerateSheet> createState() => _GenerateSheetState();
}

class _GenerateSheetState extends State<_GenerateSheet> {
  static const _tones = ['professional', 'friendly', 'casual'];
  static const _lengths = ['short', 'medium', 'long'];
  static const _languages = ['English', 'Malayalam', 'Hindi'];
  static const _purposes = [
    'general_followup',
    'check_interest',
    'product_followup',
    'quotation_followup',
    'demo_followup',
    'meeting_followup',
    'payment_followup',
    're_engagement',
  ];

  String _tone = 'professional';
  String _length = 'medium';
  String _language = 'English';
  String _purpose = 'general_followup';
  final TextEditingController _ctx = TextEditingController();
  bool _busy = false;
  String? _err;

  @override
  void dispose() {
    _ctx.dispose();
    super.dispose();
  }

  String _cap(String s) {
    final t = s.replaceAll('_', ' ');
    return t.isEmpty ? t : t[0].toUpperCase() + t.substring(1);
  }

  Future<void> _go() async {
    setState(() {
      _busy = true;
      _err = null;
    });
    final vm = context.read<AiGeneratorViewModel>();
    final res = await vm.generate(
      leadId: widget.lead.id,
      channel: widget.channel,
      tone: _tone,
      length: _length,
      language: _language,
      purpose: _purpose,
      additionalContext: _ctx.text,
    );
    if (!mounted) return;
    if (res == null) {
      setState(() {
        _busy = false;
        _err = vm.lastError ?? 'Could not generate the message. Try again.';
      });
      return;
    }
    Navigator.pop(context, res);
  }

  Widget _group(String label, List<String> opts, String sel,
      ValueChanged<String> onSel) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.ctext)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: opts.map((o) {
            final s = o == sel;
            return GestureDetector(
              onTap: _busy ? null : () => onSel(o),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                decoration: BoxDecoration(
                  color: s ? AppColors.c1.withOpacity(0.14) : AppColors.cxl,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: s ? AppColors.c1 : AppColors.cborder,
                      width: s ? 1.5 : 1),
                ),
                child: Text(_cap(o),
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: s ? AppColors.c3 : AppColors.ctext)),
              ),
            );
          }).toList(),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEmail = widget.channel == 'email';
    return _SheetFrame(
      title: isEmail ? 'Generate Email' : 'Generate WhatsApp',
      subtitle:
          'For ${widget.lead.name}${widget.lead.company.isNotEmpty ? ' • ${widget.lead.company}' : ''}',
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _group('Purpose', _purposes, _purpose, (v) => setState(() => _purpose = v)),
          _group('Tone', _tones, _tone, (v) => setState(() => _tone = v)),
          _group('Length', _lengths, _length, (v) => setState(() => _length = v)),
          _group('Language', _languages, _language,
              (v) => setState(() => _language = v)),
          const Text('Additional context (optional)',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ctext)),
          const SizedBox(height: 8),
          TextField(
            controller: _ctx,
            enabled: !_busy,
            maxLines: 3,
            cursorColor: AppColors.c1,
            style: const TextStyle(fontSize: 13.5, color: AppColors.cdark),
            decoration: InputDecoration(
              hintText: 'e.g. Sent quote on Monday, ask about timeline',
              hintStyle: TextStyle(
                  fontSize: 12.5, color: AppColors.ctext.withOpacity(0.55)),
              filled: true,
              fillColor: AppColors.cxl,
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.cborder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.cborder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.c1, width: 1.5),
              ),
            ),
          ),
          if (_err != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: LeadUi.danger.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: LeadUi.danger.withOpacity(0.25)),
              ),
              child: Row(children: [
                const Icon(Icons.error_outline_rounded,
                    size: 16, color: LeadUi.danger),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(_err!,
                      style: const TextStyle(
                          fontSize: 12, color: LeadUi.danger)),
                ),
              ]),
            ),
          ],
          const SizedBox(height: 18),
          GradientButton(
            label: _busy ? 'Generating…' : 'Generate with AI',
            icon: Icons.auto_awesome_rounded,
            loading: _busy,
            height: 52,
            onTap: _go,
          ),
        ]),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// VIEW / EDIT / SEND
// ═════════════════════════════════════════════════════════════════════════════
class _MessageSheet extends StatefulWidget {
  final AiFollowup item;
  final LeadModel lead;
  final String channel;
  const _MessageSheet(
      {required this.item, required this.lead, required this.channel});

  @override
  State<_MessageSheet> createState() => _MessageSheetState();
}

class _MessageSheetState extends State<_MessageSheet> {
  late final TextEditingController _ctrl;
  bool _busy = false;

  bool get _isEmail => widget.channel == 'email';

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.item.message);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  AiFollowup _cur(AiGeneratorViewModel vm) =>
      vm.byId(widget.item.id) ?? widget.item;

  Future<void> _save() async {
    final vm = context.read<AiGeneratorViewModel>();
    final text = _ctrl.text.trim();
    if (text.isEmpty) {
      showToast(context, 'Message is empty', error: true);
      return;
    }
    setState(() => _busy = true);
    final ok = await vm.saveMessage(widget.item.id, text);
    if (!mounted) return;
    setState(() => _busy = false);
    showToast(context, ok ? 'Message saved' : (vm.lastError ?? 'Could not save'),
        error: !ok);
  }

  Future<void> _send() async {
    final vm = context.read<AiGeneratorViewModel>();
    final text = _ctrl.text.trim();
    if (text.isEmpty) {
      showToast(context, 'Message is empty', error: true);
      return;
    }
    setState(() => _busy = true);

    final cur = _cur(vm);
    if (text != cur.message) {
      final ok = await vm.saveMessage(cur.id, text);
      if (!ok) {
        if (!mounted) return;
        setState(() => _busy = false);
        showToast(context, vm.lastError ?? 'Could not save changes', error: true);
        return;
      }
    }

    if (!_isEmail) {
      final ok = await _openWhatsApp(context, widget.lead, text);
      if (!ok) {
        if (mounted) setState(() => _busy = false);
        return;
      }
    }

    final sent = await vm.send(cur.id);
    if (!mounted) return;
    setState(() => _busy = false);
    if (sent) {
      showToast(context,
          _isEmail ? 'Email sent successfully' : 'WhatsApp opened & marked as sent');
      Navigator.pop(context, true);
    } else {
      showToast(context, vm.lastError ?? 'Failed to send', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AiGeneratorViewModel>();
    final cur = _cur(vm);
    final sc = LeadUi.statusColor(cur.status);
    final emailSent = _isEmail && cur.status == 'SENT';

    return _SheetFrame(
      title: cur.purposeLabel,
      subtitle:
          '${widget.lead.name}${widget.lead.company.isNotEmpty ? ' • ${widget.lead.company}' : ''}',
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            StatusPill(label: cur.status, color: sc),
            const SizedBox(width: 8),
            _tag(Icons.record_voice_over_outlined, cur.tone),
            const SizedBox(width: 6),
            _tag(Icons.translate_rounded, cur.language),
          ]),
          const SizedBox(height: 4),
          if (cur.created != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(_dtFmt.format(cur.created!),
                  style: const TextStyle(fontSize: 11, color: AppColors.ctext)),
            ),
          const SizedBox(height: 12),
          TextField(
            controller: _ctrl,
            enabled: !_busy,
            minLines: 8,
            maxLines: 14,
            cursorColor: AppColors.c1,
            style: const TextStyle(
                fontSize: 13.5, height: 1.5, color: AppColors.cdark),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.cxl,
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.cborder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.cborder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.c1, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Text('You can edit the text before sending. Changes are saved automatically when you send.',
              style: TextStyle(fontSize: 10.5, color: AppColors.ctext)),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: _outlineBtn(Icons.copy_rounded, 'Copy', () {
                Clipboard.setData(ClipboardData(text: _ctrl.text));
                showToast(context, 'Message copied');
              }),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _outlineBtn(Icons.save_outlined, 'Save', _busy ? null : _save),
            ),
          ]),
          const SizedBox(height: 10),
          GradientButton(
            label: emailSent
                ? 'Already sent'
                : (_isEmail ? 'Send Email' : 'Send on WhatsApp'),
            icon: _isEmail ? Icons.send_rounded : Icons.chat_rounded,
            loading: _busy,
            height: 52,
            onTap: emailSent ? null : _send,
          ),
        ]),
      ),
    );
  }

  Widget _tag(IconData i, String t) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.cxl,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.cborder),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(i, size: 11, color: AppColors.ctext),
          const SizedBox(width: 4),
          Text(t,
              style: const TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.ctext)),
        ]),
      );

  Widget _outlineBtn(IconData i, String l, VoidCallback? t) => GestureDetector(
        onTap: t,
        child: Container(
          height: 46,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(23),
            border: Border.all(color: AppColors.cborder, width: 1.5),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(i, size: 17, color: AppColors.cdark),
            const SizedBox(width: 7),
            Text(l,
                style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.cdark)),
          ]),
        ),
      );
}