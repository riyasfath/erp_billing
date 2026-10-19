import 'package:flutter/material.dart';
import 'package:pokakbilling/viewmodels/customer_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

// ─── Color palette ────────────────────────────────────────────────────────────
class _C {
  _C._();
  static const Color navy = Color(0xFF2C354B);
  static const Color navy2 = Color(0xFF38496A);
  static const Color cyan = Color(0xFF3BBCD9);
  static const Color cyan1 = Color(0xFF5DD6EE);
  static const Color cyan2 = Color(0xFF2A9BB8);
  static const Color cyan3 = Color(0xFF1E7A94);
  static const Color ice = Color(0xFFE8EEF6);
  static const Color white = Color(0xFFFFFFFF);
  static const Color red = Colors.red;
}

// ─── ClientMailScreen ─────────────────────────────────────────────────────────
class ClientMailScreen extends StatefulWidget {
  const ClientMailScreen({super.key});

  @override
  State<ClientMailScreen> createState() => _ClientMailScreenState();
}

class _ClientMailScreenState extends State<ClientMailScreen>
    with TickerProviderStateMixin {
  // ── Animations ────────────────────────────────────────────────────────────
  late final AnimationController _headerCtrl;
  late final AnimationController _bodyCtrl;
  late final Animation<double> _headerFade;
  late final Animation<Offset> _headerSlide;
  late final Animation<double> _bodyFade;
  late final Animation<Offset> _bodySlide;

  // ── State ─────────────────────────────────────────────────────────────────
  final Set<int> _selectedIds = {};
  bool _selectAll = false;
  String _searchTerm = '';
  final TextEditingController _searchCtrl = TextEditingController();
  final TextEditingController _subjectCtrl = TextEditingController();
  final TextEditingController _bodyCtrl2 = TextEditingController();

  @override
  void initState() {
    super.initState();

    _headerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _headerFade = CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(
            begin: const Offset(0, -0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut));

    _bodyCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _bodyFade = CurvedAnimation(parent: _bodyCtrl, curve: Curves.easeOut);
    _bodySlide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _bodyCtrl, curve: Curves.easeOut));

    _headerCtrl.forward();
    Future.delayed(
        const Duration(milliseconds: 180), () => _bodyCtrl.forward());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = Provider.of<CustomerViewmodel>(context, listen: false);
      if (vm.customerList.isEmpty && !vm.getCustomerLoader) {
        vm.getAllCustomers();
      }
    });
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    _bodyCtrl.dispose();
    _searchCtrl.dispose();
    _subjectCtrl.dispose();
    _bodyCtrl2.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  String _initials(String first, String last) {
    final f = first.isNotEmpty ? first[0].toUpperCase() : '';
    final l = last.isNotEmpty ? last[0].toUpperCase() : '';
    return '$f$l';
  }

  void _toggleSelectAll(List customers) {
    setState(() {
      if (_selectAll) {
        _selectedIds.clear();
        _selectAll = false;
      } else {
        _selectedIds.addAll(customers.map<int>((c) => c.customerId as int));
        _selectAll = true;
      }
    });
  }

  void _toggleCustomer(int id, List customers) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
      _selectAll = _selectedIds.length == customers.length;
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // NEW CLIENT bottom sheet — enter name + email → compose mail to them
  // ─────────────────────────────────────────────────────────────────────────
  void _showNewClientSheet(BuildContext context) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(sheetCtx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_C.navy2, _C.navy],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: StatefulBuilder(
                builder: (ctx, setS) => Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // drag handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _C.cyan.withOpacity(0.40),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // title row
                    Row(children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: _C.cyan.withOpacity(0.20),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: const Icon(Icons.person_add_rounded,
                            color: _C.cyan1, size: 17),
                      ),
                      const SizedBox(width: 10),
                      const Text('New Client Mail',
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: _C.ice)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.pop(sheetCtx),
                        child: Icon(Icons.close_rounded,
                            color: _C.ice.withOpacity(0.50), size: 20),
                      ),
                    ]),

                    Divider(height: 20, color: _C.cyan.withOpacity(0.20)),

                    // Name field
                    _SheetLabel(label: 'Client Name'),
                    const SizedBox(height: 6),
                    _SheetTextField(
                      controller: nameCtrl,
                      hint: 'e.g. John Smith',
                      icon: Icons.person_rounded,
                      keyboardType: TextInputType.name,
                      onChanged: (_) => setS(() {}),
                    ),

                    const SizedBox(height: 14),

                    // Email field
                    _SheetLabel(label: 'Email Address'),
                    const SizedBox(height: 6),
                    _SheetTextField(
                      controller: emailCtrl,
                      hint: 'e.g. client@example.com',
                      icon: Icons.email_rounded,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (_) => setS(() {}),
                    ),

                    const SizedBox(height: 22),

                    // Compose Mail button — disabled until email is filled
                    SizedBox(
                      width: double.infinity,
                      child: GestureDetector(
                        onTap: emailCtrl.text.trim().isEmpty
                            ? null
                            : () {
                                final email = emailCtrl.text.trim();
                                final name = nameCtrl.text.trim().isEmpty
                                    ? email
                                    : nameCtrl.text.trim();
                                Navigator.pop(sheetCtx);
                                _showQuickComposeSheet(context,
                                    name: name, email: email);
                              },
                        child: Opacity(
                          opacity: emailCtrl.text.trim().isEmpty ? 0.40 : 1.0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [_C.cyan1, _C.cyan3],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: emailCtrl.text.trim().isEmpty
                                  ? null
                                  : [
                                      BoxShadow(
                                        color: _C.cyan.withOpacity(0.35),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      )
                                    ],
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.mail_rounded,
                                    color: _C.white, size: 18),
                                SizedBox(width: 8),
                                Text('Compose Mail',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: _C.white)),
                              ],
                            ),
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
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // QUICK COMPOSE — for a single one-off client entered via New Client sheet
  // ─────────────────────────────────────────────────────────────────────────
  void _showQuickComposeSheet(
    BuildContext context, {
    required String name,
    required String email,
  }) {
    final subCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_C.navy2, _C.navy],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // drag handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _C.cyan.withOpacity(0.40),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // header
                    Row(children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _C.cyan.withOpacity(0.20),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.mail_rounded,
                            color: _C.cyan1, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Compose Mail',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: _C.ice)),
                            Text('To: $name',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: _C.ice.withOpacity(0.55))),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: Icon(Icons.close_rounded,
                            color: _C.ice.withOpacity(0.55), size: 20),
                      ),
                    ]),

                    const SizedBox(height: 16),
                    Divider(height: 1, color: _C.cyan.withOpacity(0.20)),
                    const SizedBox(height: 16),

                    // recipient chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _C.cyan.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _C.cyan.withOpacity(0.40)),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: _C.cyan.withOpacity(0.30),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : '?',
                              style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: _C.cyan1),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(name,
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _C.ice)),
                        const SizedBox(width: 4),
                        Text('($email)',
                            style: TextStyle(
                                fontSize: 10, color: _C.ice.withOpacity(0.45))),
                      ]),
                    ),

                    const SizedBox(height: 16),

                    _sheetLabel('Subject'),
                    const SizedBox(height: 6),
                    _sheetTextField(
                        controller: subCtrl,
                        hint: 'Enter email subject…',
                        maxLines: 1),

                    const SizedBox(height: 14),

                    _sheetLabel('Message'),
                    const SizedBox(height: 6),
                    _sheetTextField(
                        controller: bodyCtrl,
                        hint: 'Type your message here…',
                        maxLines: 5),

                    const SizedBox(height: 20),

                    // Send button
                    SizedBox(
                      width: double.infinity,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(ctx);
                          _sendSingleMail(
                            email: email,
                            subject: subCtrl.text.trim(),
                            body: bodyCtrl.text.trim(),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [_C.cyan1, _C.cyan3],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: _C.cyan.withOpacity(0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.send_rounded,
                                  color: _C.white, size: 18),
                              SizedBox(width: 8),
                              Text('Send Mail',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: _C.white)),
                            ],
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
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // COMPOSE sheet — for selected clients from the list
  // ─────────────────────────────────────────────────────────────────────────
  void _showComposeSheet(BuildContext context, List selectedCustomers) {
    _subjectCtrl.clear();
    _bodyCtrl2.clear();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_C.navy2, _C.navy],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _C.cyan.withOpacity(0.40),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    Row(children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _C.cyan.withOpacity(0.20),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.mail_rounded,
                            color: _C.cyan1, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Compose Mail',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: _C.ice)),
                            Text(
                              'To: ${selectedCustomers.length} client${selectedCustomers.length != 1 ? 's' : ''}',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: _C.ice.withOpacity(0.55)),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: Icon(Icons.close_rounded,
                            color: _C.ice.withOpacity(0.55), size: 20),
                      ),
                    ]),

                    const SizedBox(height: 16),
                    Divider(height: 1, color: _C.cyan.withOpacity(0.20)),
                    const SizedBox(height: 16),

                    // Client chips
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: selectedCustomers.map((c) {
                        final name = '${c.firstName} ${c.lastName}';
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: _C.cyan.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(20),
                            border:
                                Border.all(color: _C.cyan.withOpacity(0.40)),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: _C.cyan.withOpacity(0.30),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  _initials(c.firstName, c.lastName),
                                  style: const TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.w800,
                                      color: _C.cyan1),
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(name,
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: _C.ice)),
                          ]),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),

                    _sheetLabel('Subject'),
                    const SizedBox(height: 6),
                    _sheetTextField(
                        controller: _subjectCtrl,
                        hint: 'Enter email subject…',
                        maxLines: 1),

                    const SizedBox(height: 14),

                    _sheetLabel('Message'),
                    const SizedBox(height: 6),
                    _sheetTextField(
                        controller: _bodyCtrl2,
                        hint: 'Type your message here…',
                        maxLines: 5),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(ctx);
                          _sendMails(selectedCustomers);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [_C.cyan1, _C.cyan3],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: _C.cyan.withOpacity(0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.send_rounded,
                                  color: _C.white, size: 18),
                              SizedBox(width: 8),
                              Text('Send Mail',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: _C.white)),
                            ],
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
    );
  }

  // ── Sheet label + text field helpers ──────────────────────────────────────
  Widget _sheetLabel(String text) => Text(
        text,
        style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: _C.ice.withOpacity(0.65),
            letterSpacing: 0.5),
      );

  Widget _sheetTextField({
    required TextEditingController controller,
    required String hint,
    required int maxLines,
  }) =>
      Container(
        decoration: BoxDecoration(
          color: _C.navy2.withOpacity(0.80),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _C.cyan.withOpacity(0.25)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        child: TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 13, color: _C.ice),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 13, color: _C.ice.withOpacity(0.35)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      );

  // ── Send single mail (New Client flow) ────────────────────────────────────
  Future<void> _sendSingleMail({
    required String email,
    required String subject,
    required String body,
  }) async {
    final params = <String>[];
    if (subject.isNotEmpty)
      params.add('subject=${Uri.encodeComponent(subject)}');
    if (body.isNotEmpty) params.add('body=${Uri.encodeComponent(body)}');

    final rawUri =
        'mailto:$email${params.isNotEmpty ? '?${params.join('&')}' : ''}';

    bool launched = false;
    try {
      launched = await launchUrl(Uri.parse(rawUri),
          mode: LaunchMode.externalApplication);
    } catch (_) {}
    if (launched) return;
    try {
      launched =
          await launchUrl(Uri.parse(rawUri), mode: LaunchMode.platformDefault);
    } catch (_) {}
    if (!launched) _snack('No mail app found. Please install Gmail.');
  }

  // ── Send to multiple selected clients ─────────────────────────────────────
  Future<void> _sendMails(List selectedCustomers) async {
    final emails = selectedCustomers
        .map((c) => (c.email ?? '').toString().trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (emails.isEmpty) {
      _snack('No email addresses found for selected clients');
      return;
    }

    final subject = _subjectCtrl.text.trim();
    final body = _bodyCtrl2.text.trim();
    final firstEmail = emails.first;
    final ccEmails = emails.length > 1 ? emails.skip(1).join(',') : '';

    final params = <String>[];
    if (ccEmails.isNotEmpty) params.add('cc=$ccEmails');
    if (subject.isNotEmpty)
      params.add('subject=${Uri.encodeComponent(subject)}');
    if (body.isNotEmpty) params.add('body=${Uri.encodeComponent(body)}');

    final rawUri =
        'mailto:$firstEmail${params.isNotEmpty ? '?${params.join('&')}' : ''}';

    bool launched = false;
    try {
      launched = await launchUrl(Uri.parse(rawUri),
          mode: LaunchMode.externalApplication);
    } catch (_) {}
    if (launched) return;

    try {
      launched =
          await launchUrl(Uri.parse(rawUri), mode: LaunchMode.platformDefault);
    } catch (_) {}
    if (launched) return;

    try {
      launched = await launchUrl(Uri.parse('mailto:$firstEmail'),
          mode: LaunchMode.externalApplication);
    } catch (_) {}
    if (launched) return;

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _C.navy2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('No Mail App Found',
            style: TextStyle(
                color: _C.ice, fontSize: 15, fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please install Gmail or any email app.\n\nRecipients:',
              style: TextStyle(color: _C.ice.withOpacity(0.70), fontSize: 13),
            ),
            const SizedBox(height: 8),
            ...emails.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: SelectableText(e,
                      style: const TextStyle(
                          color: _C.cyan1,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close',
                style: TextStyle(color: _C.cyan, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final topPad = MediaQuery.of(context).padding.top;

    return Consumer<CustomerViewmodel>(
      builder: (context, vm, _) {
        final allClients = vm.customerList.where((c) {
          if (_searchTerm.isEmpty) return true;
          final q = _searchTerm.toLowerCase();
          final name = '${c.firstName} ${c.lastName}'.toLowerCase();
          final mail = (c.email ?? '').toLowerCase();
          return name.contains(q) || mail.contains(q);
        }).toList();

        final selectedCustomers = vm.customerList
            .where((c) => _selectedIds.contains(c.customerId))
            .toList();

        return Scaffold(
          backgroundColor: _C.navy,
          floatingActionButton: _selectedIds.isNotEmpty
              ? GestureDetector(
                  onTap: () => _showComposeSheet(context, selectedCustomers),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_C.cyan1, _C.cyan3],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: _C.cyan.withOpacity(0.40),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.mail_rounded,
                            color: _C.white, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Compose  (${_selectedIds.length})',
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: _C.white),
                        ),
                      ],
                    ),
                  ),
                )
              : null,
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_C.cyan1, _C.cyan, _C.cyan2, _C.cyan3],
                stops: [0.0, 0.35, 0.65, 1.0],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                FadeTransition(
                  opacity: _headerFade,
                  child: SlideTransition(
                    position: _headerSlide,
                    child: _buildHeader(context, topPad, sw, allClients.length),
                  ),
                ),
                Expanded(
                  child: FadeTransition(
                    opacity: _bodyFade,
                    child: SlideTransition(
                      position: _bodySlide,
                      child: Container(
                        decoration: BoxDecoration(
                          color: _C.navy.withOpacity(0.55),
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
                                margin:
                                    const EdgeInsets.only(top: 12, bottom: 4),
                                decoration: BoxDecoration(
                                  color: _C.cyan.withOpacity(0.40),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              _buildSelectAllBar(allClients),
                              Expanded(
                                child: vm.getCustomerLoader
                                    ? const Center(
                                        child: CircularProgressIndicator(
                                            color: _C.cyan1, strokeWidth: 2.5))
                                    : allClients.isEmpty
                                        ? _buildEmptyState()
                                        : ListView.builder(
                                            padding: const EdgeInsets.fromLTRB(
                                                14, 4, 14, 100),
                                            physics:
                                                const BouncingScrollPhysics(),
                                            itemCount: allClients.length,
                                            itemBuilder: (ctx, i) {
                                              final c = allClients[i];
                                              return _ClientTile(
                                                firstName: c.firstName,
                                                lastName: c.lastName,
                                                email: c.email ?? '',
                                                isSelected: _selectedIds
                                                    .contains(c.customerId),
                                                delay: Duration(
                                                    milliseconds: 40 + i * 40),
                                                onTap: () => _toggleCustomer(
                                                    c.customerId, allClients),
                                              );
                                            },
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
          ),
        );
      },
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(
      BuildContext context, double topPad, double sw, int count) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: topPad + 14,
        bottom: 28,
        left: sw * 0.05,
        right: sw * 0.05,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_C.navy, _C.navy2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                  color: _C.cyan.withOpacity(0.08), shape: BoxShape.circle),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                // Back
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: _C.cyan.withOpacity(0.20),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: _C.ice, size: 16),
                  ),
                ),
                const SizedBox(width: 12),

                // Title + subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Clients Mail',
                          style: TextStyle(
                              color: _C.ice,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3)),
                      const SizedBox(height: 2),
                      Text(
                        '$count client${count != 1 ? 's' : ''} available',
                        style: TextStyle(
                            color: _C.ice.withOpacity(0.60), fontSize: 12),
                      ),
                    ],
                  ),
                ),

                // ── NEW CLIENT button (same style as communication.dart) ──
                GestureDetector(
                  onTap: () => _showNewClientSheet(context),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_C.cyan, _C.cyan2],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: _C.cyan.withOpacity(0.30),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_rounded, color: _C.white, size: 15),
                        SizedBox(width: 4),
                        Text('New',
                            style: TextStyle(
                                color: _C.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
              ]),

              const SizedBox(height: 16),

              // Search bar
              Container(
                height: 44,
                decoration: BoxDecoration(
                  color: _C.navy2.withOpacity(0.70),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _C.cyan.withOpacity(0.25)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(children: [
                  Icon(Icons.search_rounded,
                      color: _C.ice.withOpacity(0.50), size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (v) => setState(() => _searchTerm = v),
                      style: const TextStyle(fontSize: 13, color: _C.ice),
                      decoration: InputDecoration(
                        hintText: 'Search by name or email…',
                        hintStyle: TextStyle(
                            color: _C.ice.withOpacity(0.35), fontSize: 13),
                        border: InputBorder.none,
                        isCollapsed: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                    ),
                  ),
                  if (_searchTerm.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchCtrl.clear();
                        setState(() => _searchTerm = '');
                      },
                      child: Icon(Icons.close_rounded,
                          size: 16, color: _C.ice.withOpacity(0.50)),
                    ),
                ]),
              ),

              // Selected badge
              if (_selectedIds.isNotEmpty) ...[
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _C.cyan.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _C.cyan.withOpacity(0.55)),
                    ),
                    child: Text(
                      '${_selectedIds.length} selected',
                      style: const TextStyle(
                          color: _C.ice,
                          fontSize: 11,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ── Select-all bar ────────────────────────────────────────────────────────
  Widget _buildSelectAllBar(List allClients) {
    return GestureDetector(
      onTap: () => _toggleSelectAll(allClients),
      child: Container(
        margin: const EdgeInsets.fromLTRB(14, 8, 14, 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: _selectAll
              ? _C.cyan.withOpacity(0.22)
              : _C.navy2.withOpacity(0.60),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _selectAll
                ? _C.cyan.withOpacity(0.55)
                : _C.cyan.withOpacity(0.20),
          ),
        ),
        child: Row(children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: _selectAll ? _C.cyan : Colors.transparent,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: _selectAll ? _C.cyan : _C.ice.withOpacity(0.35),
                width: 1.5,
              ),
            ),
            child: _selectAll
                ? const Icon(Icons.check_rounded, color: _C.white, size: 13)
                : null,
          ),
          const SizedBox(width: 10),
          Text(
            _selectAll ? 'Deselect All' : 'Select All',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _selectAll ? _C.cyan1 : _C.ice,
            ),
          ),
          const Spacer(),
          Text('${allClients.length} clients',
              style: TextStyle(fontSize: 11, color: _C.ice.withOpacity(0.45))),
        ]),
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────────
  Widget _buildEmptyState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                  color: _C.cyan.withOpacity(0.15), shape: BoxShape.circle),
              child: Icon(Icons.people_alt_outlined,
                  color: _C.cyan1.withOpacity(0.70), size: 32),
            ),
            const SizedBox(height: 16),
            const Text('No Clients Found',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700, color: _C.ice)),
            const SizedBox(height: 6),
            Text('Try adjusting your search',
                style:
                    TextStyle(fontSize: 13, color: _C.ice.withOpacity(0.50))),
          ],
        ),
      );
}

// ─── Sheet helper widgets ─────────────────────────────────────────────────────

class _SheetLabel extends StatelessWidget {
  final String label;
  const _SheetLabel({required this.label});
  @override
  Widget build(BuildContext context) => Text(
        label,
        style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _C.ice.withOpacity(0.60),
            letterSpacing: 0.4),
      );
}

class _SheetTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  final ValueChanged<String> onChanged;

  const _SheetTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.keyboardType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Container(
        height: 48,
        decoration: BoxDecoration(
          color: _C.navy2.withOpacity(0.80),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _C.cyan.withOpacity(0.25)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(children: [
          Icon(icon, color: _C.cyan.withOpacity(0.70), size: 17),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              keyboardType: keyboardType,
              style: const TextStyle(fontSize: 13, color: _C.ice),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle:
                    TextStyle(color: _C.ice.withOpacity(0.35), fontSize: 13),
                border: InputBorder.none,
                isCollapsed: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ]),
      );
}

// ─── Single client tile ───────────────────────────────────────────────────────
class _ClientTile extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email;
  final bool isSelected;
  final Duration delay;
  final VoidCallback onTap;

  const _ClientTile({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.isSelected,
    required this.delay,
    required this.onTap,
  });

  @override
  State<_ClientTile> createState() => _ClientTileState();
}

class _ClientTileState extends State<_ClientTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 380));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String get _initials {
    final f =
        widget.firstName.isNotEmpty ? widget.firstName[0].toUpperCase() : '';
    final l =
        widget.lastName.isNotEmpty ? widget.lastName[0].toUpperCase() : '';
    return '$f$l';
  }

  @override
  Widget build(BuildContext context) {
    final hasEmail = widget.email.isNotEmpty;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            margin: const EdgeInsets.only(bottom: 9),
            decoration: BoxDecoration(
              color: widget.isSelected ? _C.navy2 : _C.navy2.withOpacity(0.75),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: widget.isSelected
                    ? _C.cyan.withOpacity(0.55)
                    : _C.cyan.withOpacity(0.15),
                width: widget.isSelected ? 1.5 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.isSelected
                      ? _C.cyan.withOpacity(0.18)
                      : _C.navy.withOpacity(0.25),
                  blurRadius: widget.isSelected ? 14 : 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                // top accent bar
                Container(
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: widget.isSelected
                          ? [_C.cyan1, _C.cyan2]
                          : [_C.cyan2, _C.cyan3],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      topRight: Radius.circular(14),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
                  child: Row(children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: widget.isSelected
                            ? _C.cyan.withOpacity(0.22)
                            : _C.cyan3.withOpacity(0.22),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(_initials,
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: widget.isSelected ? _C.cyan1 : _C.ice)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.firstName} ${widget.lastName}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: widget.isSelected ? _C.cyan1 : _C.ice,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Row(children: [
                            Icon(
                              hasEmail
                                  ? Icons.email_rounded
                                  : Icons.email_outlined,
                              size: 11,
                              color: hasEmail
                                  ? _C.cyan.withOpacity(0.80)
                                  : _C.ice.withOpacity(0.30),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                hasEmail ? widget.email : 'No email address',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: hasEmail
                                      ? _C.ice.withOpacity(0.55)
                                      : _C.ice.withOpacity(0.28),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ]),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: widget.isSelected ? _C.cyan : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: widget.isSelected
                              ? _C.cyan
                              : _C.ice.withOpacity(0.30),
                          width: 1.5,
                        ),
                      ),
                      child: widget.isSelected
                          ? const Icon(Icons.check_rounded,
                              color: _C.white, size: 14)
                          : null,
                    ),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
