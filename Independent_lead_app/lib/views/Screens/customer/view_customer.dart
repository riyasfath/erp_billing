import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/core/utils/text_utils.dart';
import 'package:pokakbilling/models/data-models/customer_model.dart';

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

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final topPad = MediaQuery.of(context).padding.top;
    final user = widget.user;

    final initials = '${user.firstName.isNotEmpty ? user.firstName[0] : ''}'
            '${user.lastName.isNotEmpty ? user.lastName[0] : ''}'
        .toUpperCase();

    return Scaffold(
      backgroundColor: AppColors.white,
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
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 13,
                        ),
                        Transform.translate(
                          offset: const Offset(0, -8),
                          child: Column(
                            children: [
                              _buildInfoCard(
                                icon: Icons.person_outline_rounded,
                                title: 'Personal Details',
                                rows: [
                                  _InfoRow(Icons.badge_outlined, 'First Name',
                                      user.firstName),
                                  _InfoRow(Icons.badge_outlined, 'Last Name',
                                      user.lastName),
                                  _InfoRow(Icons.business_outlined, 'Company',
                                      user.companyName),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildInfoCard(
                                icon: Icons.location_on_outlined,
                                title: 'Location',
                                rows: [
                                  _InfoRow(Icons.flag_outlined, 'Country',
                                      user.country),
                                  _InfoRow(Icons.location_city_outlined,
                                      'State', user.state),
                                  _InfoRow(Icons.home_outlined, 'Address',
                                      user.address),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildInfoCard(
                                icon: Icons.contact_phone_outlined,
                                title: 'Contact Details',
                                rows: [
                                  _InfoRow(Icons.email_outlined, 'Email',
                                      user.email),
                                  _InfoRow(Icons.phone_outlined, 'Phone',
                                      user.phoneNumber),
                                  _InfoRow(Icons.smartphone_outlined, 'Mobile',
                                      user.mobileNumber),
                                ],
                              ),
                              const SizedBox(height: 20),
                              _buildExitButton(context),
                            ],
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
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: topPad + 12,
        bottom: 40,
        left: sw * 0.045,
        right: sw * 0.045,
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
          // Back + title row
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.cxl,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.cborder),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColors.c3,
                    size: 15,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Client View',
                style: TextStyle(
                  color: AppColors.cdark,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Avatar + name row
          Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: AppColors.cxl,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.cborder),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: AppColors.c1,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${user.firstName} ${user.lastName}'.trim().toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.cdark,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (user.companyName.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(
                            Icons.business_outlined,
                            size: 12,
                            color: AppColors.c1,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              user.companyName[0].toUpperCase() +
                                  user.companyName.substring(1),
                              style: const TextStyle(
                                color: AppColors.ctext,
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (user.email.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.email_outlined,
                              size: 12, color: AppColors.red),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              user.email,
                              style: const TextStyle(
                                color: AppColors.ctext,
                                fontSize: 11,
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
        ],
      ),
    );
  }

  // ── Contact type badge ────────────────────────────────────────────────────
  Widget _buildTypeBadge(String type) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cborder),
          boxShadow: [
            BoxShadow(
              color: AppColors.c1.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.c1,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              type.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.cdark,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Info card ─────────────────────────────────────────────────────────────
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required List<_InfoRow> rows,
  }) {
    final visibleRows = rows.where((r) => r.value.isNotEmpty).toList();
    if (visibleRows.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cborder),
        boxShadow: [
          BoxShadow(
            color: AppColors.c1.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.c1.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: AppColors.c1, size: 16),
                ),
                const SizedBox(width: 10),
                Text(
                  capitalizeWords(title),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.cdark,
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            height: 1,
            thickness: 1,
            color: AppColors.cborder,
          ),

          // Field rows
          ...visibleRows.asMap().entries.map((entry) {
            final i = entry.key;
            final row = entry.value;
            return Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: AppColors.cxl,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.cborder),
                        ),
                        child: Icon(row.icon, size: 14, color: AppColors.c1),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              row.label,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.ctext,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              row.value[0].toUpperCase() +
                                  row.value.substring(1),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.cdark,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (i < visibleRows.length - 1)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.cborder,
                    indent: 56,
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  // ── Exit / Go Back button ─────────────────────────────────────────────────
  Widget _buildExitButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.c1,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: AppColors.c1.withOpacity(0.25),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppColors.white, size: 14),
              SizedBox(width: 8),
              Text(
                'Go Back',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
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

// ─── Data class for info rows ─────────────────────────────────────────────────
class _InfoRow {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(this.icon, this.label, this.value);
}
