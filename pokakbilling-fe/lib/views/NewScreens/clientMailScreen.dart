
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pokakbilling/models/data-models/customer_model.dart';
import 'package:pokakbilling/viewmodels/customer_viewmodel.dart';
import 'package:provider/provider.dart';

class ClientsMailScreen extends StatefulWidget {
  const ClientsMailScreen({super.key});

  @override
  State<ClientsMailScreen> createState() => _ClientsMailScreenState();
}

class _ClientsMailScreenState extends State<ClientsMailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final Set<int> _selectedCustomerIds = {};
  final Map<int, CustomerModel> _selectedCustomers = {};
  String _searchQuery = '';

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _bg => Theme.of(context).scaffoldBackgroundColor;
  Color get _fg => _isDark ? Colors.white : const Color(0xFF1E1B4B);
  Color get _fgMuted => _isDark
      ? Colors.white.withValues(alpha: 0.55)
      : const Color(0xFF1E1B4B).withValues(alpha: 0.5);
  Color get _cardBg =>
      _isDark ? Colors.white.withValues(alpha: 0.07) : Colors.white.withValues(alpha: 0.85);
  Color get _cardBorder => _isDark
      ? Colors.white.withValues(alpha: 0.12)
      : const Color(0xFF6366F1).withValues(alpha: 0.15);
  Color get _iconBg => _isDark
      ? Colors.white.withValues(alpha: 0.12)
      : const Color(0xFF6366F1).withValues(alpha: 0.10);
  Color get _iconColor => _isDark ? Colors.white : const Color(0xFF4338CA);
  Color get _inputFill => _isDark
      ? Colors.white.withValues(alpha: 0.08)
      : const Color(0xFF6366F1).withValues(alpha: 0.06);
  Color get _inputBorder => _isDark
      ? Colors.white.withValues(alpha: 0.15)
      : const Color(0xFF6366F1).withValues(alpha: 0.2);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _launchEmail(
      List<String> emails, String subject, String body) async {
    if (emails.isEmpty) return;
    final Uri mailtoUri;
    if (emails.length == 1) {
      mailtoUri = Uri(
        scheme: 'mailto',
        path: emails.first,
        queryParameters: {
          if (subject.isNotEmpty) 'subject': subject,
          if (body.isNotEmpty) 'body': body,
        },
      );
    } else {
      mailtoUri = Uri(
        scheme: 'mailto',
        path: '',
        queryParameters: {
          'bcc': emails.join(','),
          if (subject.isNotEmpty) 'subject': subject,
          if (body.isNotEmpty) 'body': body,
        },
      );
    }
    if (await canLaunchUrl(mailtoUri)) {
      await launchUrl(mailtoUri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No email client found')),
        );
      }
    }
  }

  void _toggleSelection(CustomerModel customer) {
    setState(() {
      if (_selectedCustomerIds.contains(customer.customerId)) {
        _selectedCustomerIds.remove(customer.customerId);
        _selectedCustomers.remove(customer.customerId);
      } else {
        _selectedCustomerIds.add(customer.customerId);
        _selectedCustomers[customer.customerId] = customer;
      }
    });
  }

  void _selectAllCustomers(List<CustomerModel> customers) {
    setState(() {
      _selectedCustomerIds.clear();
      _selectedCustomers.clear();
      for (var customer in customers) {
        _selectedCustomerIds.add(customer.customerId);
        _selectedCustomers[customer.customerId] = customer;
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedCustomerIds.clear();
      _selectedCustomers.clear();
    });
  }

  List<CustomerModel> _getFilteredCustomers(CustomerViewmodel provider) {
    var customers = provider.customerList;
    if (_searchQuery.isNotEmpty) {
      customers = customers
          .where((c) =>
              '${c.firstName} ${c.lastName}'
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              (c.email ?? '')
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              (c.phone ?? '').contains(_searchQuery))
          .toList();
    }
    return customers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Consumer<CustomerViewmodel>(
          builder: (context, provider, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _iconBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.arrow_back_ios_new_rounded,
                        color: _iconColor, size: 16),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Client Mail',
                          style: TextStyle(
                              color: _fg,
                              fontSize: 16,
                              fontWeight: FontWeight.w800)),
                      Text(
                        _selectedCustomers.isEmpty
                            ? 'Select clients to send mail'
                            : '${_selectedCustomers.length} selected',
                        style: TextStyle(color: _fgMuted, fontSize: 10.5),
                      ),
                    ],
                  ),
                ),
              ]),
            ],
          ),
        ),
        actions: [
          if (_selectedCustomers.isNotEmpty) ...[
            GestureDetector(
              onTap: _clearSelection,
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.all(8),
                child: Icon(Icons.close_rounded, color: _fgMuted, size: 18),
              ),
            ),
            GestureDetector(
              onTap: () {
                final emails = _selectedCustomers.values
                    .where((c) => c.email.isNotEmpty == true)
                    .map((c) => c.email)
                    .toList();
                if (emails.isNotEmpty) {
                  _launchEmail(emails, 'Hello from Pokak Billing', '');
                }
              },
              child: Container(
                margin: const EdgeInsets.only(right: 14),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF818CF8)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.send_rounded, color: Colors.white, size: 15),
                    SizedBox(width: 4),
                    Text('Send',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          ],
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              style: TextStyle(color: _fg, fontSize: 12),
              decoration: InputDecoration(
                hintText: 'Search clients by name, email or phone…',
                hintStyle: TextStyle(fontSize: 12, color: _fgMuted),
                prefixIcon: Icon(Icons.search_rounded,
                    size: 18, color: _iconColor.withValues(alpha: 0.8)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? GestureDetector(
                        onTap: () => setState(() => _searchQuery = ''),
                        child: Icon(Icons.close_rounded,
                            size: 16, color: _fgMuted),
                      )
                    : null,
                filled: true,
                fillColor: _inputFill,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: _inputBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: _inputBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: Color(0xFF818CF8), width: 1.5),
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "new_mail",
            onPressed: _showNewMailComposer,
            backgroundColor: const Color(0xFF6366F1),
            elevation: 4,
            child:
                const Icon(Icons.edit_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: "select_all",
            mini: true,
            onPressed: () {
              final provider =
                  Provider.of<CustomerViewmodel>(context, listen: false);
              final filtered = _getFilteredCustomers(provider);
              if (_selectedCustomerIds.length == filtered.length) {
                _clearSelection();
              } else {
                _selectAllCustomers(filtered);
              }
            },
            backgroundColor: _selectedCustomers.isNotEmpty
                ? const Color(0xFF10B981)
                : const Color(0xFFF59E0B),
            child: Icon(
              _selectedCustomerIds.length ==
                      _getFilteredCustomers(Provider.of<CustomerViewmodel>(
                              context,
                              listen: false))
                          .length
                  ? Icons.deselect
                  : Icons.select_all,
              color: Colors.white,
              size: 18,
            ),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCustomerMailList(),
          _buildEmptyTab('Unread messages will appear here'),
          _buildEmptyTab('Sent emails history'),
        ],
      ),
    );
  }

  Widget _buildCustomerMailList() {
    return Consumer<CustomerViewmodel>(
      builder: (context, provider, child) {
        if (provider.getCustomerLoader) {
          return Center(
            child: SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: _fg.withValues(alpha: 0.7),
              ),
            ),
          );
        }
        final filteredCustomers = _getFilteredCustomers(provider);
        if (filteredCustomers.isEmpty) {
          return _emptyState('No clients match your search');
        }
        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 100),
          itemCount: filteredCustomers.length,
          itemBuilder: (context, index) {
            final customer = filteredCustomers[index];
            final hasEmail = (customer.email ?? '').isNotEmpty;
            final isSelected =
                _selectedCustomerIds.contains(customer.customerId);
            return _CustomerMailCard(
              customer: customer,
              isSelected: isSelected,
              hasEmail: hasEmail,
              isDark: _isDark,
              cardBg: _cardBg,
              cardBorder: _cardBorder,
              fg: _fg,
              fgMuted: _fgMuted,
              onTap: () => _toggleSelection(customer),
              onQuickSend: () {
                if (hasEmail) {
                  _launchEmail([customer.email],
                      'Quick message to ${customer.firstName}', '');
                }
              },
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyTab(String message) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mail_outline_rounded, color: _fgMuted, size: 48),
            const SizedBox(height: 12),
            Text(message, style: TextStyle(color: _fgMuted, fontSize: 14)),
          ],
        ),
      );

  Widget _emptyState(String message) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: _iconBg,
                shape: BoxShape.circle,
                border: Border.all(color: _cardBorder, width: 1),
              ),
              child:
                  Icon(Icons.people_outline_rounded, color: _fgMuted, size: 28),
            ),
            const SizedBox(height: 14),
            Text(message,
                style: TextStyle(
                    color: _fgMuted,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text('Try a different search or add new clients.',
                style:
                    TextStyle(color: _fgMuted.withValues(alpha: 0.6), fontSize: 11)),
          ],
        ),
      );

  void _showNewMailComposer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _NewMailComposer(
        selectedCustomers: _selectedCustomers.values.toList(),
        onSend: _launchEmail,
        isDark: _isDark,
        fg: _fg,
        fgMuted: _fgMuted,
        cardBg: _cardBg,
        iconBg: _iconBg,
        iconColor: _iconColor,
        inputFill: _inputFill,
        inputBorder: _inputBorder,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CUSTOMER MAIL CARD  (unchanged)
// ─────────────────────────────────────────────────────────────────────────────
class _CustomerMailCard extends StatelessWidget {
  final CustomerModel customer;
  final bool isSelected;
  final bool hasEmail;
  final bool isDark;
  final Color cardBg;
  final Color cardBorder;
  final Color fg;
  final Color fgMuted;
  final VoidCallback onTap;
  final VoidCallback onQuickSend;

  const _CustomerMailCard({
    required this.customer,
    required this.isSelected,
    required this.hasEmail,
    required this.isDark,
    required this.cardBg,
    required this.cardBorder,
    required this.fg,
    required this.fgMuted,
    required this.onTap,
    required this.onQuickSend,
  });

  @override
  Widget build(BuildContext context) {
    final fullName = '${customer.firstName} ${customer.lastName ?? ''}'.trim();
    final initials = fullName.isNotEmpty
        ? '${fullName[0]}${fullName.length > 1 ? fullName[1] : ''}'
            .toUpperCase()
        : '?';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color:
              isSelected ? const Color(0xFF6366F1).withValues(alpha: 0.12) : cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF6366F1) : cardBorder,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          child: Row(children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color:
                    isSelected ? const Color(0xFF6366F1) : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isSelected ? Colors.white : fgMuted,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
            const SizedBox(width: 12),
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF818CF8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(initials,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 17)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(fullName,
                      style: TextStyle(
                          color: fg, fontSize: 14, fontWeight: FontWeight.w700),
                      overflow: TextOverflow.ellipsis),
                  if (hasEmail) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.email_outlined, size: 12, color: fgMuted),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(customer.email,
                              style: TextStyle(fontSize: 12, color: fgMuted),
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (hasEmail)
              GestureDetector(
                onTap: onQuickSend,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF34D399)]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.send_rounded,
                      color: Colors.white, size: 16),
                ),
              ),
          ]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NEW MAIL COMPOSER  — original theme colors, redesigned fields only
// ─────────────────────────────────────────────────────────────────────────────
class _NewMailComposer extends StatefulWidget {
  final List<CustomerModel> selectedCustomers;
  final Function(List<String>, String, String) onSend;
  final bool isDark;
  final Color fg;
  final Color fgMuted;
  final Color cardBg;
  final Color iconBg;
  final Color iconColor;
  final Color inputFill;
  final Color inputBorder;

  const _NewMailComposer({
    required this.selectedCustomers,
    required this.onSend,
    required this.isDark,
    required this.fg,
    required this.fgMuted,
    required this.cardBg,
    required this.iconBg,
    required this.iconColor,
    required this.inputFill,
    required this.inputBorder,
  });

  @override
  State<_NewMailComposer> createState() => _NewMailComposerState();
}

class _NewMailComposerState extends State<_NewMailComposer> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  final FocusNode _subjectFocus = FocusNode();
  final FocusNode _bodyFocus = FocusNode();
  bool _subjectFocused = false;
  bool _bodyFocused = false;

  static const Color _accent = Color(0xFF6366F1);
  static const Color _accentLight = Color(0xFF818CF8);

  @override
  void initState() {
    super.initState();
    _subjectFocus.addListener(
        () => setState(() => _subjectFocused = _subjectFocus.hasFocus));
    _bodyFocus
        .addListener(() => setState(() => _bodyFocused = _bodyFocus.hasFocus));
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _bodyController.dispose();
    _subjectFocus.dispose();
    _bodyFocus.dispose();
    super.dispose();
  }

  // ── Labeled left-strip field (used for Subject) ───────────────────────────
  Widget _stripField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool isFocused,
    required String hint,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: widget.inputFill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isFocused ? _accent : widget.inputBorder,
          width: isFocused ? 1.8 : 1,
        ),
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: _accent.withValues(alpha: widget.isDark ? 0.22 : 0.10),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ]
            : [],
      ),
      child: Row(
        children: [
          // ── Left label strip ─────────────────────────────────────────
          Container(
            width: 68,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: isFocused
                      ? _accent.withValues(alpha: 0.30)
                      : widget.inputBorder,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon,
                    size: 15, color: isFocused ? _accent : widget.fgMuted),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: isFocused ? _accent : widget.fgMuted,
                  ),
                ),
              ],
            ),
          ),
          // ── Text input ───────────────────────────────────────────────
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              style: TextStyle(
                color: widget.fg,
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: widget.fgMuted.withValues(alpha: 0.55),
                  fontSize: 13,
                ),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Floating-label body field ────────────────────────────────────────────
  Widget _bodyField() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: widget.inputFill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _bodyFocused ? _accent : widget.inputBorder,
          width: _bodyFocused ? 1.8 : 1,
        ),
        boxShadow: _bodyFocused
            ? [
                BoxShadow(
                  color: _accent.withValues(alpha: widget.isDark ? 0.22 : 0.10),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Floating label at top
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 11, 14, 0),
            child: Row(
              children: [
                Icon(Icons.notes_rounded,
                    size: 13, color: _bodyFocused ? _accent : widget.fgMuted),
                const SizedBox(width: 5),
                Text(
                  'MESSAGE',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: _bodyFocused ? _accent : widget.fgMuted,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TextField(
              controller: _bodyController,
              focusNode: _bodyFocus,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: TextStyle(
                color: widget.fg,
                fontSize: 13.5,
                height: 1.55,
              ),
              decoration: InputDecoration(
                hintText: 'Type your message here…',
                hintStyle: TextStyle(
                  color: widget.fgMuted.withValues(alpha: 0.55),
                  fontSize: 13,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Single recipient row ─────────────────────────────────────────────────
  Widget _singleRecipientRow(String email) {
    return Container(
      decoration: BoxDecoration(
        color: widget.inputFill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: widget.inputBorder, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        child: Row(
          children: [
            Container(
              width: 68,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: widget.inputBorder, width: 1),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person_outline_rounded,
                      size: 15, color: widget.fgMuted),
                  const SizedBox(height: 3),
                  Text(
                    'TO',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: widget.fgMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [_accent, _accentLight]),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  email.isNotEmpty ? email[0].toUpperCase() : '?',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                email,
                style: TextStyle(
                    color: widget.fg,
                    fontSize: 13,
                    fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: _accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('To',
                  style: TextStyle(
                      color: _accentLight,
                      fontSize: 10,
                      fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  // ── BCC multi-recipient chips ────────────────────────────────────────────
  Widget _bccRecipientsBox(List<String> emails) {
    return Container(
      decoration: BoxDecoration(
        color: widget.inputFill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: widget.inputBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 11, 12, 8),
            child: Row(
              children: [
                Icon(Icons.groups_2_outlined,
                    size: 13, color: Colors.teal.shade400),
                const SizedBox(width: 5),
                Text(
                  'BCC · ${emails.length} recipients',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: Colors.teal.shade400,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.teal.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    'Hidden from each other',
                    style: TextStyle(
                        color: Colors.teal.shade400,
                        fontSize: 8.5,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          Divider(
              height: 1,
              thickness: 1,
              color: widget.inputBorder,
              indent: 14,
              endIndent: 14),
          Container(
            constraints: const BoxConstraints(maxHeight: 78),
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: emails.map((email) {
                  final name = email.split('@').first;
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: _accent.withValues(alpha: widget.isDark ? 0.16 : 0.07),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _accent.withValues(alpha: 0.28),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            gradient:
                                LinearGradient(colors: [_accent, _accentLight]),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : '?',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          name,
                          style: TextStyle(
                              color: widget.fg,
                              fontSize: 11,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final emails = widget.selectedCustomers
        .where((c) => c.email.isNotEmpty == true)
        .map((c) => c.email)
        .toList();

    final isSingle = emails.length == 1;
    final hasRecipients = emails.isNotEmpty;

    // Sheet background — respects original theme
    final sheetBg = widget.isDark
        ? Color.lerp(Colors.black, const Color(0xFF1E1B4B), 0.6)!
        : Colors.white;
    final dividerColor = widget.isDark
        ? Colors.white.withValues(alpha: 0.07)
        : const Color(0xFF6366F1).withValues(alpha: 0.07);

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.86,
        decoration: BoxDecoration(
          color: sheetBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 28,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: widget.fgMuted.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: widget.iconBg,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(Icons.edit_rounded,
                        color: widget.iconColor, size: 17),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isSingle ? 'New Message' : 'Compose Broadcast',
                          style: TextStyle(
                            color: widget.fg,
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isSingle
                              ? 'Single recipient'
                              : '${emails.length} recipients · sent via BCC',
                          style: TextStyle(color: widget.fgMuted, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: widget.iconBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.close_rounded,
                          color: widget.fgMuted, size: 17),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Divider(color: dividerColor, height: 1, thickness: 1),
            ),

            const SizedBox(height: 14),

            // Recipients
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: isSingle
                  ? _singleRecipientRow(emails.first)
                  : _bccRecipientsBox(emails),
            ),

            const SizedBox(height: 10),

            // Subject
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _stripField(
                label: 'SUBJECT',
                icon: Icons.drive_file_rename_outline_rounded,
                controller: _subjectController,
                focusNode: _subjectFocus,
                isFocused: _subjectFocused,
                hint: 'What\'s this about?',
              ),
            ),

            const SizedBox(height: 10),

            // Body
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _bodyField(),
              ),
            ),

            const SizedBox(height: 12),

            // Send button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: GestureDetector(
                  onTap: !hasRecipients
                      ? null
                      : () {
                          widget.onSend(emails, _subjectController.text,
                              _bodyController.text);
                          Navigator.pop(context);
                        },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      gradient: hasRecipients
                          ? const LinearGradient(
                              colors: [_accent, _accentLight],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            )
                          : null,
                      color: hasRecipients ? null : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: hasRecipients
                          ? [
                              BoxShadow(
                                color: _accent.withValues(alpha: 0.32),
                                blurRadius: 18,
                                offset: const Offset(0, 6),
                              ),
                            ]
                          : [],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.send_rounded,
                            color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          isSingle ? 'Send Email' : 'Send BCC to All',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
