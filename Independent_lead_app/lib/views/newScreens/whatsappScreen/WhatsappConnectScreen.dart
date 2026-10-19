import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/lead_viewmodel.dart';
import 'package:pokakbilling/models/data-models/lead_model.dart';

// ─── WhatsApp SVG ─────────────────────────────────────────────────────────────
const String _kWhatsAppSvg = '''
<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
  <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347z"/>
  <path d="M12 0C5.373 0 0 5.373 0 12c0 2.125.558 4.122 1.528 5.855L.057 23.885a.5.5 0 00.611.611l6.101-1.459A11.945 11.945 0 0012 24c6.627 0 12-5.373 12-12S18.627 0 12 0zm0 21.818a9.818 9.818 0 01-5.012-1.378l-.36-.214-3.724.89.908-3.64-.235-.374A9.818 9.818 0 0112 2.182c5.428 0 9.818 4.39 9.818 9.818 0 5.429-4.39 9.818-9.818 9.818z"/>
</svg>
''';

// ─── Color palette ────────────────────────────────────────────────────────────
class _C {
  _C._();
  static const Color navy = AppColors.navy;
  static const Color cyan = AppColors.cyan;
  static const Color ice = AppColors.ice;
  static const Color white = AppColors.white;
  static const Color green = Color(0xFF25D366); // WhatsApp green
  static const Color blue = Color(0xFF2563EB); // Call blue
}

// ─────────────────────────────────────────────────────────────────────────────
class ConnectScreen extends StatefulWidget {
  const ConnectScreen({super.key});

  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen>
    with SingleTickerProviderStateMixin {
  // 0 = Leads tab, 1 = Dial Pad tab
  int _tab = 0;

  // Dial pad state
  String _dialNumber = '';
  bool _dialModeWa = true; // true = WhatsApp, false = Phone Call

  // Leads search
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchTerm = '';

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 380));
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LeadViewmodel>(context, listen: false).getAllLeads();
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── URL launchers ─────────────────────────────────────────────────────────

  Future<void> _openWhatsApp(String phone) async {
    final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final number = cleaned.startsWith('+') ? cleaned : '+91$cleaned';
    final uri = Uri.parse('https://wa.me/$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open WhatsApp')),
        );
      }
    }
  }

  Future<void> _makeCall(String phone) async {
    final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse('tel:$cleaned');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open dialer')),
        );
      }
    }
  }

  // ── Dial pad helpers ──────────────────────────────────────────────────────

  void _dialPress(String digit) {
    HapticFeedback.lightImpact();
    setState(() => _dialNumber += digit);
  }

  void _dialBackspace() {
    HapticFeedback.lightImpact();
    if (_dialNumber.isNotEmpty) {
      setState(
          () => _dialNumber = _dialNumber.substring(0, _dialNumber.length - 1));
    }
  }

  void _dialAction() {
    if (_dialNumber.isEmpty) return;
    if (_dialModeWa) {
      _openWhatsApp(_dialNumber);
    } else {
      _makeCall(_dialNumber);
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: _C.ice,
      body: FadeTransition(
        opacity: _fade,
        child: Column(
          children: [
            // ── App bar ───────────────────────────────────────────────────
            _buildAppBar(context, topPad, sw),

            // ── Tab toggle ────────────────────────────────────────────────
            _buildTabToggle(sw),

            // ── Content ───────────────────────────────────────────────────
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                transitionBuilder: (child, anim) =>
                    FadeTransition(opacity: anim, child: child),
                child: _tab == 0
                    ? _LeadsTab(
                        key: const ValueKey('leads'),
                        searchCtrl: _searchCtrl,
                        searchTerm: _searchTerm,
                        onSearchChanged: (v) => setState(() => _searchTerm = v),
                        onWhatsApp: _openWhatsApp,
                        onCall: _makeCall,
                      )
                    : _DialPadTab(
                        key: const ValueKey('dialpad'),
                        number: _dialNumber,
                        modeWa: _dialModeWa,
                        onDigit: _dialPress,
                        onBackspace: _dialBackspace,
                        onModeChange: (wa) => setState(() => _dialModeWa = wa),
                        onAction: _dialAction,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── App bar ───────────────────────────────────────────────────────────────
  Widget _buildAppBar(BuildContext context, double topPad, double sw) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
          top: topPad + 10, bottom: 14, left: sw * .045, right: sw * .045),
      decoration: const BoxDecoration(
        color: _C.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _C.green.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SvgPicture.string(
                  _kWhatsAppSvg,
                  width: 20,
                  height: 20,
                  colorFilter:
                      const ColorFilter.mode(_C.green, BlendMode.srcIn),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Connect',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _C.navy,
                ),
              ),
              Text(
                'WhatsApp · Call · Leads',
                style: TextStyle(
                  fontSize: 10,
                  color: _C.navy.withOpacity(0.45),
                ),
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _C.ice,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  size: 14, color: _C.navy.withOpacity(0.55)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab toggle ────────────────────────────────────────────────────────────
  Widget _buildTabToggle(double sw) {
    return Container(
      color: _C.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: _C.ice,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFD1D5DB)),
        ),
        padding: const EdgeInsets.all(3),
        child: Stack(
          children: [
            // Sliding pill
            AnimatedAlign(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              alignment:
                  _tab == 0 ? Alignment.centerLeft : Alignment.centerRight,
              child: FractionallySizedBox(
                widthFactor: 0.5,
                child: Container(
                  decoration: BoxDecoration(
                    color: _tab == 0 ? _C.green : _C.blue,
                    borderRadius: BorderRadius.circular(11),
                    boxShadow: [
                      BoxShadow(
                        color:
                            (_tab == 0 ? _C.green : _C.blue).withOpacity(0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Labels
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _tab = 0),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.string(
                            _kWhatsAppSvg,
                            width: 14,
                            height: 14,
                            colorFilter: ColorFilter.mode(
                              _tab == 0 ? _C.white : _C.navy.withOpacity(0.45),
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Leads',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _tab == 0
                                  ? _C.white
                                  : _C.navy.withOpacity(0.45),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _tab = 1),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.dialpad_rounded,
                            size: 14,
                            color: _tab == 1
                                ? _C.white
                                : _C.navy.withOpacity(0.45),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Dial Pad',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _tab == 1
                                  ? _C.white
                                  : _C.navy.withOpacity(0.45),
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
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LEADS TAB
// ─────────────────────────────────────────────────────────────────────────────
class _LeadsTab extends StatelessWidget {
  final TextEditingController searchCtrl;
  final String searchTerm;
  final ValueChanged<String> onSearchChanged;
  final Future<void> Function(String) onWhatsApp;
  final Future<void> Function(String) onCall;

  const _LeadsTab({
    super.key,
    required this.searchCtrl,
    required this.searchTerm,
    required this.onSearchChanged,
    required this.onWhatsApp,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<LeadViewmodel>(
      builder: (context, vm, _) {
        // Filter leads that have a phone number
        final allLeads =
            vm.leadList.where((l) => l.phone.trim().isNotEmpty).toList();

        final filtered = searchTerm.trim().isEmpty
            ? allLeads
            : allLeads.where((l) {
                final q = searchTerm.trim().toLowerCase();
                return l.name.toLowerCase().contains(q) ||
                    l.phone.contains(q) ||
                    l.company.toLowerCase().contains(q);
              }).toList();

        final withPhone = allLeads.length;

        return Column(
          children: [
            // ── Search + stats ────────────────────────────────────────────
            Container(
              color: _C.white,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(
                children: [
                  // Search bar
                  Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: _C.ice,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _C.green.withOpacity(0.25)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        SvgPicture.string(
                          _kWhatsAppSvg,
                          width: 16,
                          height: 16,
                          colorFilter: ColorFilter.mode(
                              _C.green.withOpacity(0.55), BlendMode.srcIn),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: searchCtrl,
                            onChanged: onSearchChanged,
                            style:
                                const TextStyle(fontSize: 13, color: _C.navy),
                            decoration: InputDecoration(
                              hintText: 'Search by name or phone…',
                              hintStyle: TextStyle(
                                color: _C.navy.withOpacity(0.35),
                                fontSize: 13,
                              ),
                              border: InputBorder.none,
                              isCollapsed: true,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 0),
                            ),
                          ),
                        ),
                        if (searchTerm.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              searchCtrl.clear();
                              onSearchChanged('');
                            },
                            child: Icon(Icons.close_rounded,
                                size: 16, color: _C.navy.withOpacity(0.40)),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Stats chips
                  Row(
                    children: [
                      _StatChip(
                          label: '${vm.leadList.length} Total', color: _C.navy),
                      const SizedBox(width: 8),
                      _StatChip(
                          label: '$withPhone With Phone', color: _C.green),
                    ],
                  ),
                ],
              ),
            ),

            // ── List ──────────────────────────────────────────────────────
            Expanded(
              child: vm.getLeadLoader
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: _C.green, strokeWidth: 2.5))
                  : filtered.isEmpty
                      ? _EmptyLeads(hasSearch: searchTerm.isNotEmpty)
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                          physics: const BouncingScrollPhysics(),
                          itemCount: filtered.length,
                          itemBuilder: (_, i) => _LeadRow(
                            lead: filtered[i],
                            onWhatsApp: () => onWhatsApp(filtered[i].phone),
                            onCall: () => onCall(filtered[i].phone),
                          ),
                        ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Single lead row ──────────────────────────────────────────────────────────
class _LeadRow extends StatelessWidget {
  final LeadModel lead;
  final VoidCallback onWhatsApp;
  final VoidCallback onCall;

  const _LeadRow({
    required this.lead,
    required this.onWhatsApp,
    required this.onCall,
  });

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'CONVERTED':
        return const Color(0xFF16A34A);
      case 'LOST':
        return Colors.red;
      case 'CONTACTED':
        return _C.blue;
      case 'QUALIFIED':
        return const Color(0xFF7C3AED);
      case 'IN_PROGRESS':
        return const Color(0xFFF59E0B);
      default:
        return _C.navy.withOpacity(0.55);
    }
  }

  @override
  Widget build(BuildContext context) {
    final initials = lead.name.isNotEmpty ? lead.name[0].toUpperCase() : '?';
    final statusColor = _statusColor(lead.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: _C.navy.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _C.green.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _C.green,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Name + phone + status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lead.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _C.navy,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.phone_rounded,
                        size: 11, color: _C.navy.withOpacity(0.45)),
                    const SizedBox(width: 4),
                    Text(
                      lead.phone,
                      style: TextStyle(
                        fontSize: 11,
                        color: _C.navy.withOpacity(0.55),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Status badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: statusColor.withOpacity(0.25)),
                  ),
                  child: Text(
                    lead.statusDisplay,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // WhatsApp button
          _ActionBtn(
            color: _C.green,
            onTap: onWhatsApp,
            child: SvgPicture.string(
              _kWhatsAppSvg,
              width: 18,
              height: 18,
              colorFilter: const ColorFilter.mode(_C.white, BlendMode.srcIn),
            ),
          ),
          const SizedBox(width: 8),

          // Call button
          _ActionBtn(
            color: _C.blue,
            onTap: onCall,
            child: const Icon(Icons.call_rounded, color: _C.white, size: 18),
          ),
        ],
      ),
    );
  }
}

// ─── Round action button ──────────────────────────────────────────────────────
class _ActionBtn extends StatelessWidget {
  final Color color;
  final VoidCallback onTap;
  final Widget child;

  const _ActionBtn({
    required this.color,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.30),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }
}

// ─── Stat chip ────────────────────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final String label;
  final Color color;
  const _StatChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.20)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────
class _EmptyLeads extends StatelessWidget {
  final bool hasSearch;
  const _EmptyLeads({required this.hasSearch});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: _C.green.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SvgPicture.string(
                _kWhatsAppSvg,
                width: 30,
                height: 30,
                colorFilter: ColorFilter.mode(
                    _C.green.withOpacity(0.50), BlendMode.srcIn),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            hasSearch ? 'No results found' : 'No leads with phone',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _C.navy,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            hasSearch
                ? 'Try a different name or number'
                : 'Add phone numbers to your leads',
            style: TextStyle(
              fontSize: 12,
              color: _C.navy.withOpacity(0.45),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DIAL PAD TAB
// ─────────────────────────────────────────────────────────────────────────────
class _DialPadTab extends StatelessWidget {
  final String number;
  final bool modeWa; // true = WhatsApp, false = Phone Call
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final ValueChanged<bool> onModeChange;
  final VoidCallback onAction;

  const _DialPadTab({
    super.key,
    required this.number,
    required this.modeWa,
    required this.onDigit,
    required this.onBackspace,
    required this.onModeChange,
    required this.onAction,
  });

  static const _rows = [
    [
      {'digit': '1', 'sub': ''},
      {'digit': '2', 'sub': 'ABC'},
      {'digit': '3', 'sub': 'DEF'},
    ],
    [
      {'digit': '4', 'sub': 'GHI'},
      {'digit': '5', 'sub': 'JKL'},
      {'digit': '6', 'sub': 'MNO'},
    ],
    [
      {'digit': '7', 'sub': 'PQRS'},
      {'digit': '8', 'sub': 'TUV'},
      {'digit': '9', 'sub': 'WXYZ'},
    ],
    [
      {'digit': '*', 'sub': ''},
      {'digit': '0', 'sub': '+'},
      {'digit': '#', 'sub': ''},
    ],
  ];

  @override
  Widget build(BuildContext context) {
    final activeColor = modeWa ? _C.green : _C.blue;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        children: [
          // ── Mode toggle: WhatsApp / Phone Call ────────────────────────
          Container(
            height: 46,
            decoration: BoxDecoration(
              color: _C.ice,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFD1D5DB)),
            ),
            padding: const EdgeInsets.all(3),
            child: Stack(
              children: [
                AnimatedAlign(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeInOut,
                  alignment:
                      modeWa ? Alignment.centerLeft : Alignment.centerRight,
                  child: FractionallySizedBox(
                    widthFactor: 0.5,
                    child: Container(
                      decoration: BoxDecoration(
                        color: activeColor,
                        borderRadius: BorderRadius.circular(11),
                        boxShadow: [
                          BoxShadow(
                            color: activeColor.withOpacity(0.28),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => onModeChange(true),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.string(
                                _kWhatsAppSvg,
                                width: 14,
                                height: 14,
                                colorFilter: ColorFilter.mode(
                                  modeWa ? _C.white : _C.navy.withOpacity(0.45),
                                  BlendMode.srcIn,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'WhatsApp',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: modeWa
                                      ? _C.white
                                      : _C.navy.withOpacity(0.45),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => onModeChange(false),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.phone_rounded,
                                size: 14,
                                color: !modeWa
                                    ? _C.white
                                    : _C.navy.withOpacity(0.45),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Phone Call',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: !modeWa
                                      ? _C.white
                                      : _C.navy.withOpacity(0.45),
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

          const SizedBox(height: 20),

          // ── Number display ────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: _C.white,
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: activeColor.withOpacity(0.30), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: activeColor.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    number.isEmpty ? '' : _formatDialNumber(number),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color:
                          number.isEmpty ? _C.navy.withOpacity(0.20) : _C.navy,
                      letterSpacing: 2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                if (number.isNotEmpty)
                  GestureDetector(
                    onTap: onBackspace,
                    onLongPress: () {
                      // Clear all on long press
                      for (int i = 0; i < 20; i++) {
                        onBackspace();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      child: Icon(Icons.backspace_outlined,
                          size: 22, color: _C.navy.withOpacity(0.40)),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Keypad ────────────────────────────────────────────────────
          ..._rows.map((row) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: row.map((key) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: _DialKey(
                          digit: key['digit']!,
                          sub: key['sub']!,
                          onTap: () => onDigit(key['digit']!),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              )),

          const SizedBox(height: 20),

          // ── Action button ─────────────────────────────────────────────
          GestureDetector(
            onTap: onAction,
            child: Container(
              width: double.infinity,
              height: 54,
              decoration: BoxDecoration(
                color: activeColor,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: activeColor.withOpacity(0.40),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (modeWa)
                      SvgPicture.string(
                        _kWhatsAppSvg,
                        width: 20,
                        height: 20,
                        colorFilter:
                            const ColorFilter.mode(_C.white, BlendMode.srcIn),
                      )
                    else
                      const Icon(Icons.call_rounded, color: _C.white, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      modeWa ? 'Open in WhatsApp' : 'Call Now',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _C.white,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),
          Text(
            modeWa
                ? 'WhatsApp will open with the number pre-filled'
                : 'Your phone dialer will open with this number',
            style: TextStyle(
              fontSize: 11,
              color: _C.navy.withOpacity(0.40),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatDialNumber(String n) {
    // Simple formatting: group digits like "94969 7204"
    final digits = n.replaceAll(' ', '');
    if (digits.length <= 5) return digits;
    return '${digits.substring(0, 5)} ${digits.substring(5)}';
  }
}

// ─── Dial key ─────────────────────────────────────────────────────────────────
class _DialKey extends StatefulWidget {
  final String digit;
  final String sub;
  final VoidCallback onTap;

  const _DialKey({
    required this.digit,
    required this.sub,
    required this.onTap,
  });

  @override
  State<_DialKey> createState() => _DialKeyState();
}

class _DialKeyState extends State<_DialKey>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 80),
        lowerBound: 0,
        upperBound: 1);
    _scale = Tween<double>(begin: 1.0, end: 0.90).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: _C.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: [
              BoxShadow(
                color: _C.navy.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.digit,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: _C.navy,
                ),
              ),
              if (widget.sub.isNotEmpty)
                Text(
                  widget.sub,
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    color: _C.navy.withOpacity(0.35),
                    letterSpacing: 0.8,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
