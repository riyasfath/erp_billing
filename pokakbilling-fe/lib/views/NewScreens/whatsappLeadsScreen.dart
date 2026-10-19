
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pokakbilling/models/data-models/lead_model.dart';
import 'package:pokakbilling/viewmodels/lead_viewmodel.dart';

enum _ContactMode { whatsapp, call }

class WhatsAppLeadsScreen extends StatefulWidget {
  final int initialIndex; // ✅ new
  const WhatsAppLeadsScreen({super.key, this.initialIndex = 0});

  @override
  State<WhatsAppLeadsScreen> createState() => _WhatsAppLeadsScreenState();
}

class _WhatsAppLeadsScreenState extends State<WhatsAppLeadsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialIndex, // ✅ use it
    );
    _searchController.addListener(() =>
        setState(() => _query = _searchController.text.trim().toLowerCase()));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _fg => _isDark ? Colors.white : const Color(0xFF0F0E2E);
  Color get _fgMuted => _isDark
      ? Colors.white.withValues(alpha: 0.50)
      : const Color(0xFF0F0E2E).withValues(alpha: 0.45);
  Color get _cardBg => _isDark
      ? const Color(0xFF1E1A3E).withValues(alpha: 0.85)
      : Colors.white.withValues(alpha: 0.96);
  Color get _cardBorder => _isDark
      ? Colors.white.withValues(alpha: 0.09)
      : const Color(0xFF25D366).withValues(alpha: 0.18);
  Color get _scaffoldBg => Theme.of(context).scaffoldBackgroundColor;

  static const Color _waGreen = Color(0xFF25D366);
  static const Color _waGreenDark = Color(0xFF128C7E);
  static const Color _callBlue = Color(0xFF3B82F6);

  Future<void> _openWhatsApp(String phone, {String message = ''}) async {
    final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final encoded = Uri.encodeComponent(message);
    final uri = Uri.parse('https://wa.me/$cleaned?text=$encoded');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _showError('WhatsApp is not installed on this device.');
    }
  }

  Future<void> _makeCall(String phone) async {
    final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse('tel:$cleaned');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _showError('Unable to make a call from this device.');
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.red.shade600,
      behavior: SnackBarBehavior.floating,
    ));
  }

  Widget _avatar(String name, {double radius = 22}) {
    final initials = name.trim().isEmpty
        ? '?'
        : name.trim().split(' ').take(2).map((w) => w[0].toUpperCase()).join();
    const colors = [
      Color(0xFF6366F1),
      Color(0xFF0EA5E9),
      Color(0xFF10B981),
      Color(0xFFF59E0B),
      Color(0xFFEF4444),
      Color(0xFF8B5CF6),
    ];
    final color = colors[name.isEmpty ? 0 : name.codeUnitAt(0) % colors.length];
    return CircleAvatar(
      radius: radius,
      backgroundColor: color.withValues(alpha: 0.15),
      child: Text(initials,
          style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: radius * 0.7)),
    );
  }

  void _showActionSheet(LeadModel lead) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ActionSheet(
        lead: lead,
        isDark: _isDark,
        fg: _fg,
        fgMuted: _fgMuted,
        cardBg: _cardBg,
        cardBorder: _cardBorder,
        avatarWidget: _avatar(lead.name, radius: 26),
        onWhatsApp: () {
          Navigator.pop(context);
          _openWhatsApp(lead.phone);
        },
        onCall: () {
          Navigator.pop(context);
          _makeCall(lead.phone);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 6),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _LeadsTab(
                    query: _query,
                    searchController: _searchController,
                    isDark: _isDark,
                    fg: _fg,
                    fgMuted: _fgMuted,
                    cardBg: _cardBg,
                    cardBorder: _cardBorder,
                    onLeadTap: _showActionSheet,
                    avatar: _avatar,
                  ),
                  _DialPadTab(
                    isDark: _isDark,
                    fg: _fg,
                    fgMuted: _fgMuted,
                    cardBg: _cardBg,
                    cardBorder: _cardBorder,
                    openWhatsApp: _openWhatsApp,
                    makeCall: _makeCall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: _scaffoldBg,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: _isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : _waGreen.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: _cardBorder, width: 1),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: _waGreen, size: 16),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_waGreen, _waGreenDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const FaIcon(
              FontAwesomeIcons.whatsapp,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Connect',
                    style: TextStyle(
                        color: _fg,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4)),
                Text('WhatsApp · Call · Leads',
                    style: TextStyle(color: _fgMuted, fontSize: 10.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: _isDark
            ? Colors.white.withValues(alpha: 0.06)
            : _waGreen.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _cardBorder, width: 1),
      ),
      padding: const EdgeInsets.all(4),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: _waGreen,
          borderRadius: BorderRadius.circular(9),
          boxShadow: [
            BoxShadow(
                color: _waGreen.withValues(alpha: 0.30),
                blurRadius: 10,
                offset: const Offset(0, 3)),
          ],
        ),
        labelColor: Colors.white,
        unselectedLabelColor: _fgMuted,
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        unselectedLabelStyle:
            const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(FontAwesomeIcons.whatsapp, size: 14),
                  SizedBox(width: 6),
                  Text('Leads'),
                ]),
          ),
          Tab(
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.dialpad_rounded, size: 14),
              SizedBox(width: 6),
              Text('Dial Pad'),
            ]),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ACTION BOTTOM SHEET
// ─────────────────────────────────────────────────────────────────────────────
class _ActionSheet extends StatelessWidget {
  final LeadModel lead;
  final bool isDark;
  final Color fg, fgMuted, cardBg, cardBorder;
  final Widget avatarWidget;
  final VoidCallback onWhatsApp;
  final VoidCallback onCall;

  static const Color _waGreen = Color(0xFF25D366);
  static const Color _callBlue = Color(0xFF3B82F6);

  const _ActionSheet({
    required this.lead,
    required this.isDark,
    required this.fg,
    required this.fgMuted,
    required this.cardBg,
    required this.cardBorder,
    required this.avatarWidget,
    required this.onWhatsApp,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1736) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: cardBorder, width: 1),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              avatarWidget,
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lead.name.isNotEmpty ? lead.name : 'Unnamed Lead',
                      style: TextStyle(
                          color: fg,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3),
                    ),
                    const SizedBox(height: 3),
                    Row(children: [
                      Icon(Icons.phone_rounded, size: 11, color: fgMuted),
                      const SizedBox(width: 4),
                      Text(lead.phone.isNotEmpty ? lead.phone : 'No phone',
                          style: TextStyle(color: fgMuted, fontSize: 11.5)),
                    ]),
                  ],
                ),
              ),
              if (lead.leadStatus.isNotEmpty)
                _StatusBadge(status: lead.leadStatus),
            ],
          ),
          const SizedBox(height: 22),
          Divider(color: cardBorder, thickness: 0.8),
          const SizedBox(height: 6),
          Text('Choose how to connect',
              style: TextStyle(
                  color: fgMuted, fontSize: 11, fontWeight: FontWeight.w600)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  iconWidget: const FaIcon(
                    FontAwesomeIcons.whatsapp,
                    color: _waGreen,
                    size: 24,
                  ),
                  label: 'WhatsApp',
                  subtitle: 'Send a message',
                  color: _waGreen,
                  isDark: isDark,
                  onTap: onWhatsApp,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  iconWidget: const Icon(
                    Icons.call_rounded,
                    color: _callBlue,
                    size: 24,
                  ),
                  label: 'Call',
                  subtitle: 'Direct phone call',
                  color: _callBlue,
                  isDark: isDark,
                  onTap: onCall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Center(
                child: Text('Cancel',
                    style: TextStyle(
                        color: fgMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final Widget iconWidget;
  final String label;
  final String subtitle;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _ActionButton({
    required this.iconWidget,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.35), width: 1.2),
        ),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: color.withValues(alpha: 0.40), width: 1.5),
              ),
              child: Center(child: iconWidget),
            ),
            const SizedBox(height: 10),
            Text(label,
                style: TextStyle(
                    color: color, fontSize: 13, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(subtitle,
                style: TextStyle(
                    color: color.withValues(alpha: 0.70),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LEADS TAB
// ─────────────────────────────────────────────────────────────────────────────
class _LeadsTab extends StatelessWidget {
  final String query;
  final TextEditingController searchController;
  final bool isDark;
  final Color fg, fgMuted, cardBg, cardBorder;
  final void Function(LeadModel) onLeadTap;
  final Widget Function(String name, {double radius}) avatar;

  static const Color _waGreen = Color(0xFF25D366);

  const _LeadsTab({
    required this.query,
    required this.searchController,
    required this.isDark,
    required this.fg,
    required this.fgMuted,
    required this.cardBg,
    required this.cardBorder,
    required this.onLeadTap,
    required this.avatar,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<LeadViewmodel>(builder: (context, vm, _) {
      final filtered = vm.leadList.where((l) {
        if (query.isEmpty) return true;
        return l.name.toLowerCase().contains(query) ||
            l.phone.toLowerCase().contains(query);
      }).toList();

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: _SearchField(
              controller: searchController,
              isDark: isDark,
              fgMuted: fgMuted,
              cardBorder: cardBorder,
            ),
          ),
          if (!vm.getLeadLoader && vm.leadList.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(children: [
                _SummaryChip(
                    label: '${vm.leadList.length} Total',
                    color: _waGreen,
                    isDark: isDark),
                const SizedBox(width: 8),
                _SummaryChip(
                    label:
                        '${vm.leadList.where((l) => l.phone.isNotEmpty).length} With Phone',
                    color: const Color(0xFF3B82F6),
                    isDark: isDark),
              ]),
            ),
          if (vm.getLeadLoader)
            const Expanded(
                child: Center(
                    child: CircularProgressIndicator(
                        color: _waGreen, strokeWidth: 2)))
          else if (filtered.isEmpty)
            Expanded(
              child: Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.search_off_rounded, color: fgMuted, size: 40),
                  const SizedBox(height: 10),
                  Text('No leads found',
                      style: TextStyle(color: fgMuted, fontSize: 13)),
                ]),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (ctx, i) => _LeadCard(
                  lead: filtered[i],
                  isDark: isDark,
                  fg: fg,
                  fgMuted: fgMuted,
                  cardBg: cardBg,
                  cardBorder: cardBorder,
                  onTap: () => onLeadTap(filtered[i]),
                  avatarWidget: avatar(filtered[i].name),
                ),
              ),
            ),
        ],
      );
    });
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool isDark;
  const _SummaryChip(
      {required this.label, required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.28), width: 0.8),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }
}

class _LeadCard extends StatelessWidget {
  final LeadModel lead;
  final bool isDark;
  final Color fg, fgMuted, cardBg, cardBorder;
  final VoidCallback onTap;
  final Widget avatarWidget;

  static const Color _waGreen = Color(0xFF25D366);
  static const Color _callBlue = Color(0xFF3B82F6);

  const _LeadCard({
    required this.lead,
    required this.isDark,
    required this.fg,
    required this.fgMuted,
    required this.cardBg,
    required this.cardBorder,
    required this.onTap,
    required this.avatarWidget,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhone = lead.phone.trim().isNotEmpty;
    return GestureDetector(
      onTap: hasPhone ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cardBorder, width: 1),
        ),
        child: Row(
          children: [
            avatarWidget,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lead.name.isNotEmpty ? lead.name : 'Unnamed Lead',
                    style: TextStyle(
                        color: fg,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2),
                  ),
                  const SizedBox(height: 3),
                  Row(children: [
                    Icon(Icons.phone_rounded, size: 11, color: fgMuted),
                    const SizedBox(width: 4),
                    Text(
                      hasPhone ? lead.phone : 'No phone',
                      style: TextStyle(
                          color: hasPhone ? fgMuted : Colors.red.shade400,
                          fontSize: 11),
                    ),
                  ]),
                  if (lead.leadStatus.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    _StatusBadge(status: lead.leadStatus),
                  ],
                ],
              ),
            ),
            if (hasPhone) ...[
              const SizedBox(width: 8),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _waGreen.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: _waGreen.withValues(alpha: 0.28), width: 1),
                ),
                child: const Center(
                  child: FaIcon(
                    FontAwesomeIcons.whatsapp,
                    color: _waGreen,
                    size: 17,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _callBlue.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: _callBlue.withValues(alpha: 0.28), width: 1),
                ),
                child:
                    const Icon(Icons.call_rounded, color: _callBlue, size: 18),
              ),
            ] else
              Icon(Icons.block_rounded,
                  color: Colors.red.withValues(alpha: 0.4), size: 20),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DIAL PAD TAB
// ─────────────────────────────────────────────────────────────────────────────
class _DialPadTab extends StatefulWidget {
  final bool isDark;
  final Color fg, fgMuted, cardBg, cardBorder;
  final Future<void> Function(String phone, {String message}) openWhatsApp;
  final Future<void> Function(String phone) makeCall;

  const _DialPadTab({
    required this.isDark,
    required this.fg,
    required this.fgMuted,
    required this.cardBg,
    required this.cardBorder,
    required this.openWhatsApp,
    required this.makeCall,
  });

  @override
  State<_DialPadTab> createState() => _DialPadTabState();
}

class _DialPadTabState extends State<_DialPadTab> {
  String _number = '';
  _ContactMode _mode = _ContactMode.whatsapp;

  static const Color _waGreen = Color(0xFF25D366);
  static const Color _callBlue = Color(0xFF3B82F6);
  static const Color _callBlueDark = Color(0xFF1D4ED8);

  bool get _isValid => _number.replaceAll(RegExp(r'[^\d]'), '').length >= 7;
  Color get _activeColor =>
      _mode == _ContactMode.whatsapp ? _waGreen : _callBlue;

  void _onKey(String val) => setState(() => _number += val);

  void _onBackspace() {
    if (_number.isNotEmpty) {
      setState(() => _number = _number.substring(0, _number.length - 1));
    }
  }

  void _onAction() {
    if (!_isValid) return;
    if (_mode == _ContactMode.whatsapp) {
      widget.openWhatsApp(_number);
    } else {
      widget.makeCall(_number);
    }
  }

  static const List<Map<String, String>> _keys = [
    {'main': '1', 'sub': ''},
    {'main': '2', 'sub': 'ABC'},
    {'main': '3', 'sub': 'DEF'},
    {'main': '4', 'sub': 'GHI'},
    {'main': '5', 'sub': 'JKL'},
    {'main': '6', 'sub': 'MNO'},
    {'main': '7', 'sub': 'PQRS'},
    {'main': '8', 'sub': 'TUV'},
    {'main': '9', 'sub': 'WXYZ'},
    {'main': '*', 'sub': ''},
    {'main': '0', 'sub': '+'},
    {'main': '#', 'sub': ''},
  ];

  String _formatNumber(String raw) {
    if (raw.startsWith('+')) return raw;
    if (raw.length <= 5) return raw;
    if (raw.length <= 10) {
      return '${raw.substring(0, 5)} ${raw.substring(5)}';
    }
    return '${raw.substring(0, 5)} ${raw.substring(5, 10)} ${raw.substring(10)}';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          children: [
            _ModeToggle(
              mode: _mode,
              isDark: widget.isDark,
              fgMuted: widget.fgMuted,
              onChanged: (m) => setState(() => _mode = m),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                color: widget.cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _number.isEmpty
                      ? widget.cardBorder
                      : _activeColor.withValues(alpha: 0.45),
                  width: _number.isEmpty ? 1 : 1.5,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _number.isEmpty ? 'Enter number' : _formatNumber(_number),
                      style: TextStyle(
                        color: _number.isEmpty ? widget.fgMuted : widget.fg,
                        fontSize: _number.isEmpty ? 14 : 24,
                        fontWeight: FontWeight.w700,
                        letterSpacing: _number.isEmpty ? 0 : 2.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (_number.isNotEmpty)
                    GestureDetector(
                      onTap: _onBackspace,
                      onLongPress: () => setState(() => _number = ''),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _activeColor.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Icon(Icons.backspace_outlined,
                            color: _activeColor, size: 18),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
              ),
              itemCount: _keys.length,
              itemBuilder: (ctx, i) {
                final key = _keys[i];
                return _DialKey(
                  main: key['main']!,
                  sub: key['sub']!,
                  activeColor: _activeColor,
                  isDark: widget.isDark,
                  fg: widget.fg,
                  fgMuted: widget.fgMuted,
                  cardBg: widget.cardBg,
                  cardBorder: widget.cardBorder,
                  onTap: () => _onKey(key['main']!),
                  onLongPress: key['main'] == '0' ? () => _onKey('+') : null,
                );
              },
            ),
            const SizedBox(height: 18),
            GestureDetector(
              onTap: _isValid ? _onAction : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: _isValid
                      ? LinearGradient(
                          colors: _mode == _ContactMode.whatsapp
                              ? [_waGreen, const Color(0xFF128C7E)]
                              : [_callBlue, _callBlueDark],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        )
                      : null,
                  color: _isValid ? null : widget.fgMuted.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_mode == _ContactMode.whatsapp)
                      const FaIcon(FontAwesomeIcons.whatsapp,
                          color: Colors.white, size: 20)
                    else
                      Icon(Icons.call_rounded,
                          color: _isValid ? Colors.white : widget.fgMuted,
                          size: 21),
                    const SizedBox(width: 10),
                    Text(
                      _mode == _ContactMode.whatsapp
                          ? 'Open in WhatsApp'
                          : 'Call Now',
                      style: TextStyle(
                        color: _isValid ? Colors.white : widget.fgMuted,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _mode == _ContactMode.whatsapp
                  ? 'WhatsApp will open with the number pre-filled'
                  : 'Your phone dialer will open with this number',
              textAlign: TextAlign.center,
              style: TextStyle(color: widget.fgMuted, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  final _ContactMode mode;
  final bool isDark;
  final Color fgMuted;
  final void Function(_ContactMode) onChanged;

  static const Color _waGreen = Color(0xFF25D366);
  static const Color _callBlue = Color(0xFF3B82F6);

  const _ModeToggle({
    required this.mode,
    required this.isDark,
    required this.fgMuted,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.09)
              : Colors.black.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _ModePill(
            iconWidget: const FaIcon(FontAwesomeIcons.whatsapp, size: 15),
            label: 'WhatsApp',
            color: _waGreen,
            isActive: mode == _ContactMode.whatsapp,
            fgMuted: fgMuted,
            onTap: () => onChanged(_ContactMode.whatsapp),
          ),
          _ModePill(
            iconWidget: const Icon(Icons.call_rounded, size: 15),
            label: 'Phone Call',
            color: _callBlue,
            isActive: mode == _ContactMode.call,
            fgMuted: fgMuted,
            onTap: () => onChanged(_ContactMode.call),
          ),
        ],
      ),
    );
  }
}

class _ModePill extends StatelessWidget {
  final Widget iconWidget;
  final String label;
  final Color color;
  final bool isActive;
  final Color fgMuted;
  final VoidCallback onTap;

  const _ModePill({
    required this.iconWidget,
    required this.label,
    required this.color,
    required this.isActive,
    required this.fgMuted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: isActive ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isActive
                ? [
                    BoxShadow(
                        color: color.withValues(alpha: 0.30),
                        blurRadius: 10,
                        offset: const Offset(0, 3))
                  ]
                : [],
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                isActive ? Colors.white : fgMuted,
                BlendMode.srcIn,
              ),
              child: iconWidget,
            ),
            const SizedBox(width: 7),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isActive ? Colors.white : fgMuted)),
          ]),
        ),
      ),
    );
  }
}

class _DialKey extends StatefulWidget {
  final String main;
  final String sub;
  final Color activeColor;
  final bool isDark;
  final Color fg, fgMuted, cardBg, cardBorder;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _DialKey({
    required this.main,
    required this.sub,
    required this.activeColor,
    required this.isDark,
    required this.fg,
    required this.fgMuted,
    required this.cardBg,
    required this.cardBorder,
    required this.onTap,
    this.onLongPress,
  });

  @override
  State<_DialKey> createState() => _DialKeyState();
}

class _DialKeyState extends State<_DialKey>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 80));
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.90)
        .animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) {
        _pressCtrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _pressCtrl.reverse(),
      onLongPress: widget.onLongPress,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          decoration: BoxDecoration(
            color: widget.cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: widget.cardBorder, width: 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.main,
                style: TextStyle(
                  color: widget.fg,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              if (widget.sub.isNotEmpty) ...[
                const SizedBox(height: 1),
                Text(
                  widget.sub,
                  style: TextStyle(
                    color: widget.fgMuted,
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final Map<String, Color> colorMap = {
      'new': const Color(0xFF6366F1),
      'contacted': const Color(0xFF0EA5E9),
      'follow_up': const Color(0xFFF59E0B),
      'in_progress': const Color(0xFF8B5CF6),
      'converted': const Color(0xFF10B981),
      'lost': const Color(0xFFEF4444),
    };
    final normalized = status.toLowerCase().replaceAll(' ', '_');
    final color = colorMap[normalized] ?? const Color(0xFF6B7280);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.30), width: 0.8),
      ),
      child: Text(status,
          style: TextStyle(
              fontSize: 8.5, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;
  final Color fgMuted, cardBorder;

  static const Color _waGreen = Color(0xFF25D366);

  const _SearchField({
    required this.controller,
    required this.isDark,
    required this.fgMuted,
    required this.cardBorder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: cardBorder, width: 1),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          const FaIcon(FontAwesomeIcons.whatsapp, color: _waGreen, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : const Color(0xFF0F0E2E),
                fontSize: 13,
              ),
              decoration: InputDecoration(
                hintText: 'Search by name or phone...',
                hintStyle: TextStyle(color: fgMuted, fontSize: 12),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 13),
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: controller.clear,
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Icon(Icons.cancel_rounded, color: fgMuted, size: 16),
              ),
            ),
        ],
      ),
    );
  }
}
