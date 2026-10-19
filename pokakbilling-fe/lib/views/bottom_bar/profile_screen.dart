
import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/access_viewmodel.dart';
import 'package:pokakbilling/viewmodels/global_viewmodel.dart';
import 'package:pokakbilling/viewmodels/profile_viewmodel.dart';
import 'package:pokakbilling/views/Screens/auth/login_screen.dart';
import 'package:pokakbilling/views/commonWidgets/popups/logout_popup.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  // ── Animations ─────────────────────────────────────────────────────────────
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  late AnimationController _slideCtrl;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    // Pulsing gradient ring on avatar
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    // Entry slide + fade
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.10),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut));
    _slideCtrl.forward();

    // ERP: ProfileViewmodel uses getAllProfile()
    Future.microtask(() {
      if (mounted) {
        Provider.of<ProfileViewmodel>(context, listen: false).getAllProfile();
      }
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  String _getInitials(String first, String last, String fallback) {
    if (first.isNotEmpty && last.isNotEmpty) {
      return '${first[0]}${last[0]}'.toUpperCase();
    }
    if (first.isNotEmpty) return first[0].toUpperCase();
    if (fallback.isNotEmpty) return fallback[0].toUpperCase();
    return '?';
  }

  // ══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: Stack(
        children: [
          _buildBgBlobs(),
          SafeArea(
            child: Consumer<ProfileViewmodel>(
              builder: (context, profileVm, _) {
                // ── Extract ERP profile fields ──────────────────────────────
                // ERP ProfileModel has: firstName, lastName, emailId
                // (no phone, gender, dob, address, profilePicture, no LoginViewModel)
                String firstName = '';
                String lastName = '';
                String email = '';

                if (profileVm.profileList.isNotEmpty) {
                  final p = profileVm.profileList.first;
                  firstName = p.firstName;
                  lastName = p.lastName;
                  email = p.emailId;
                }

                final name = '$firstName $lastName'.trim();
                final initials = _getInitials(firstName, lastName, email);
                final isLoading = profileVm.getProfileLoader && name.isEmpty;

                return SlideTransition(
                  position: _slideAnim,
                  child: FadeTransition(
                    opacity: _slideCtrl,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Header with avatar ───────────────────────────
                          _buildHeader(
                            name: name,
                            email: email,
                            initials: initials,
                            isLoading: isLoading,
                          ),
                          const SizedBox(height: 24),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ── Profile Information card ─────────────
                                _SectionCard(
                                  title: 'Profile Information',
                                  icon: Icons.person_outline_rounded,
                                  rows: [
                                    if (firstName.isNotEmpty)
                                      _RowData(
                                        label: 'First Name',
                                        value: firstName,
                                        icon: Icons.badge_outlined,
                                      ),
                                    if (lastName.isNotEmpty)
                                      _RowData(
                                        label: 'Last Name',
                                        value: lastName,
                                        icon: Icons.badge_outlined,
                                      ),
                                    if (email.isNotEmpty)
                                      _RowData(
                                        label: 'Email',
                                        value: email,
                                        icon: Icons.email_outlined,
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 24),

                                // ── Logout button ────────────────────────
                                Consumer<AccessViewModel>(
                                  builder: (_, accessVm, __) => _LogoutButton(
                                    isLoggedIn: accessVm.checkingIsLoggedIn,
                                    onTap: () {
                                      accessVm.checkingIsLoggedIn
                                          ? showLogoutDialog(context)
                                          : Navigator.of(context)
                                              .pushAndRemoveUntil(
                                              MaterialPageRoute(
                                                  builder: (_) =>
                                                      const LoginScreen()),
                                              (route) => false,
                                            );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // ── Version text ─────────────────────────
                                Consumer<GlobalViewmodel>(
                                  builder: (_, gVm, __) => Center(
                                    child: Text(
                                      'Version ${gVm.appVersion}',
                                      style: TextStyle(
                                        color: AppColors.ctext.withValues(alpha: 0.4),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 32),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader({
    required String name,
    required String email,
    required String initials,
    required bool isLoading,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.c1.withValues(alpha: 0.07),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Title row — no Edit button in ERP (no EditProfileScreen)
          const Row(
            children: [
              Text(
                'Profile',
                style: TextStyle(
                  color: AppColors.cdark,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Pulsing gradient avatar ring with initials
          AnimatedBuilder(
            animation: _pulseAnim,
            builder: (_, __) => Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.c1.withValues(alpha: _pulseAnim.value),
                    AppColors.cdark,
                    AppColors.c1.withValues(alpha: _pulseAnim.value),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: CircleAvatar(
                radius: 44,
                backgroundColor: AppColors.cdark,
                child: isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : Text(
                        initials,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Name + email badge
          if (!isLoading) ...[
            if (name.isNotEmpty)
              Text(
                name,
                style: const TextStyle(
                  color: AppColors.cdark,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            if (email.isNotEmpty) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.c1.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  email,
                  style: const TextStyle(
                    color: AppColors.c1,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  // ── Background blobs ────────────────────────────────────────────────────────
  Widget _buildBgBlobs() {
    return Stack(
      children: [
        Positioned(
          top: -80,
          right: -80,
          child: AnimatedBuilder(
            animation: _pulseAnim,
            builder: (_, __) => Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.c1.withValues(alpha: 0.05 * _pulseAnim.value),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -100,
          left: -80,
          child: AnimatedBuilder(
            animation: _pulseAnim,
            builder: (_, __) => Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.c1.withValues(alpha: 0.04 * _pulseAnim.value),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Section card ──────────────────────────────────────────────────────────────
class _RowData {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const _RowData({
    required this.label,
    required this.value,
    required this.icon,
  }) : valueColor = null;
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<_RowData> rows;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Row(
            children: [
              Icon(icon, size: 15, color: AppColors.c1),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.cdark,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.cborder.withValues(alpha: 0.6)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              for (int i = 0; i < rows.length; i++) ...[
                _InfoRow(data: rows[i]),
                if (i < rows.length - 1)
                  Divider(
                    height: 1,
                    indent: 64,
                    color: AppColors.cborder.withValues(alpha: 0.5),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Info row ──────────────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final _RowData data;
  const _InfoRow({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.c1.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              data.icon,
              size: 17,
              color: AppColors.c1.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.label,
                  style: TextStyle(
                    color: AppColors.ctext.withValues(alpha: 0.5),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.value,
                  style: TextStyle(
                    color: data.valueColor ?? AppColors.cdark,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Logout button ─────────────────────────────────────────────────────────────
class _LogoutButton extends StatelessWidget {
  final bool isLoggedIn;
  final VoidCallback onTap;
  const _LogoutButton({required this.isLoggedIn, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: isLoggedIn
              ? const Color(0xFFFFEEEE)
              : AppColors.c1.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isLoggedIn
                ? const Color(0xFFFFCCCC)
                : AppColors.c1.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isLoggedIn ? Icons.logout_rounded : Icons.login_rounded,
              color: isLoggedIn ? const Color(0xFFE53935) : AppColors.c1,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              isLoggedIn ? 'Logout' : 'Login',
              style: TextStyle(
                color: isLoggedIn ? const Color(0xFFE53935) : AppColors.c1,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
