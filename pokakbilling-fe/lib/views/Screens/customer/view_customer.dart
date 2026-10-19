import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pokakbilling/ERP_UI_KIT.dart';
import 'package:pokakbilling/models/data-models/customer_model.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewCustomer extends StatefulWidget {
  final CustomerModel user;
  const ViewCustomer({super.key, required this.user});

  @override
  State<ViewCustomer> createState() => _ViewCustomerState();
}

class _ViewCustomerState extends State<ViewCustomer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  // ── Quick contact actions ─────────────────────────────────────────────────
  String get _bestPhone {
    final u = widget.user;
    return (u.mobile.isNotEmpty ? u.mobile : u.phone)
        .replaceAll(RegExp(r'[^0-9+]'), '');
  }

  Future<void> _call() async {
    final p = _bestPhone;
    if (p.isEmpty) {
      erpToast(context, 'No phone number available',
          color: ErpColors.red, icon: Icons.error_outline_rounded);
      return;
    }
    final uri = Uri(scheme: 'tel', path: p);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _whatsapp() async {
    var p = _bestPhone.replaceAll('+', '');
    if (p.isEmpty) {
      erpToast(context, 'No phone number available',
          color: ErpColors.red, icon: Icons.error_outline_rounded);
      return;
    }
    if (p.length == 10) p = '91$p';
    final uri = Uri.parse('https://wa.me/$p');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _email() async {
    final e = widget.user.email.trim();
    if (e.isEmpty) {
      erpToast(context, 'No email address available',
          color: ErpColors.red, icon: Icons.error_outline_rounded);
      return;
    }
    final uri = Uri(scheme: 'mailto', path: e);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final topPad = MediaQuery.of(context).padding.top;
    final user = widget.user;

    final initials = '${user.firstName.isNotEmpty ? user.firstName[0] : ''}'
            '${user.lastName.isNotEmpty ? user.lastName[0] : ''}'
        .toUpperCase();

    return Scaffold(
      backgroundColor: ErpColors.pageBg,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            _buildHeader(context, sw, topPad, user, initials),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(sw * 0.04, 18, sw * 0.04,
                        MediaQuery.of(context).padding.bottom + 28),
                    child: Column(
                      children: [
                        // ── Quick actions ─────────────────────────────────
                        ErpFadeIn(
                          index: 0,
                          child: Row(children: [
                            Expanded(
                              child: _QuickAction(
                                icon: Icons.call_rounded,
                                label: 'Call',
                                color: ErpColors.cyan,
                                onTap: _call,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _QuickAction(
                                icon: ErpIcons.whatsapp,
                                label: 'WhatsApp',
                                color: ErpColors.whatsapp,
                                onTap: _whatsapp,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _QuickAction(
                                icon: Icons.email_rounded,
                                label: 'Email',
                                color: ErpColors.violet,
                                onTap: _email,
                              ),
                            ),
                          ]),
                        ),
                        const SizedBox(height: 14),
                        ErpFadeIn(
                          index: 1,
                          child: _buildInfoCard(
                            icon: Icons.person_rounded,
                            color: ErpColors.cyan,
                            title: 'Personal Details',
                            rows: [
                              _InfoRow(Icons.badge_rounded, 'First Name',
                                  user.firstName),
                              _InfoRow(Icons.badge_rounded, 'Last Name',
                                  user.lastName),
                              _InfoRow(Icons.business_rounded, 'Company',
                                  user.companyName),
                              _InfoRow(Icons.receipt_long_rounded,
                                  'GST Number', user.gstNumber,
                                  copy: true),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        ErpFadeIn(
                          index: 2,
                          child: _buildInfoCard(
                            icon: Icons.location_on_rounded,
                            color: ErpColors.orange,
                            title: 'Location',
                            rows: [
                              _InfoRow(
                                  Icons.flag_rounded, 'Country', user.country),
                              _InfoRow(Icons.location_city_rounded, 'State',
                                  user.state),
                              _InfoRow(
                                  Icons.home_rounded, 'Address', user.address),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        ErpFadeIn(
                          index: 3,
                          child: _buildInfoCard(
                            icon: Icons.contact_phone_rounded,
                            color: ErpColors.violet,
                            title: 'Contact Details',
                            rows: [
                              _InfoRow(Icons.email_rounded, 'Email',
                                  user.email,
                                  copy: true),
                              _InfoRow(Icons.phone_rounded, 'Phone',
                                  user.phone,
                                  copy: true),
                              _InfoRow(Icons.smartphone_rounded, 'Mobile',
                                  user.mobile,
                                  copy: true),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        ErpFadeIn(
                          index: 4,
                          child: _buildInfoCard(
                            icon: Icons.support_agent_rounded,
                            color: ErpColors.green,
                            title: 'Sales Person',
                            rows: [
                              _InfoRow(Icons.support_agent_rounded,
                                  'Sales Person', user.salesPersonName),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),
                        ErpFadeIn(
                          index: 5,
                          child: ErpPrimaryButton(
                            text: 'Go Back',
                            icon: Icons.arrow_back_rounded,
                            onTap: () => Navigator.pop(context),
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

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, double sw, double topPad,
      CustomerModel user, String initials) {
    final isLead = user.moduleType == 'lead';
    final typeColor = isLead ? ErpColors.violet : ErpColors.green;

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
              bottom: 22,
              left: sw * 0.045,
              right: sw * 0.045,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back + title row
                Row(
                  children: [
                    ErpPressable(
                      onTap: () => Navigator.pop(context),
                      child: const ErpGlassCircle(
                          icon: Icons.arrow_back_ios_new_rounded,
                          iconSize: 19),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Customer View',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.40)),
                      ),
                      child: Text(
                        'ID #${user.customerId}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Profile card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: ErpColors.cyanDeep.withValues(alpha: 0.22),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: ErpColors.headerGradient,
                          borderRadius: BorderRadius.circular(19),
                          boxShadow: [
                            BoxShadow(
                              color: ErpColors.cyan.withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            initials.isEmpty ? '?' : initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${user.firstName} ${user.lastName}'
                                        .trim()
                                        .toUpperCase(),
                                    style: const TextStyle(
                                      color: ErpColors.ink,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.3,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                ErpStatusChip(
                                  label: isLead ? 'Lead' : 'Client',
                                  color: typeColor,
                                ),
                              ],
                            ),
                            if (user.companyName.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.business_rounded,
                                      size: 13, color: ErpColors.cyanDeep),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      user.companyName[0].toUpperCase() +
                                          user.companyName.substring(1),
                                      style: const TextStyle(
                                        color: ErpColors.slate,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12.5,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            if (user.email.isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  const Icon(Icons.email_rounded,
                                      size: 13, color: ErpColors.violet),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      user.email,
                                      style: const TextStyle(
                                        color: ErpColors.slate,
                                        fontSize: 12,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
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

  // ── Info card ─────────────────────────────────────────────────────────────
  Widget _buildInfoCard({
    required IconData icon,
    required Color color,
    required String title,
    required List<_InfoRow> rows,
  }) {
    final visibleRows = rows.where((r) => r.value.isNotEmpty).toList();
    if (visibleRows.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: ErpColors.line),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Row(
              children: [
                ErpGradientTile(icon: icon, color: color, size: 38),
                const SizedBox(width: 11),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: ErpColors.ink,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: ErpColors.line),

          // Field rows
          ...visibleRows.asMap().entries.map((entry) {
            final i = entry.key;
            final row = entry.value;
            return Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(row.icon,
                            size: 16, color: ErpColors.shade(color, 0.15)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              row.label,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: ErpColors.slate,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              row.value[0].toUpperCase() +
                                  row.value.substring(1),
                              style: const TextStyle(
                                fontSize: 14,
                                color: ErpColors.ink,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (row.copy)
                        ErpPressable(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: row.value));
                            erpToast(context, '${row.label} copied',
                                icon: Icons.copy_rounded);
                          },
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: ErpColors.pageBg,
                              borderRadius: BorderRadius.circular(9),
                              border: Border.all(color: ErpColors.line),
                            ),
                            child: const Icon(Icons.copy_rounded,
                                size: 15, color: ErpColors.slate),
                          ),
                        ),
                    ],
                  ),
                ),
                if (i < visibleRows.length - 1)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: ErpColors.line,
                    indent: 58,
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// ─── Quick action tile ────────────────────────────────────────────────────────
class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => ErpPressable(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: ErpColors.line),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.12),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(children: [
            ErpGradientTile(icon: icon, color: color, size: 42, circle: true),
            const SizedBox(height: 7),
            Text(label,
                style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: ErpColors.shade(color, 0.15))),
          ]),
        ),
      );
}

// ─── Data class for info rows ─────────────────────────────────────────────────
class _InfoRow {
  final IconData icon;
  final String label;
  final String value;
  final bool copy;
  const _InfoRow(this.icon, this.label, this.value, {this.copy = false});
}