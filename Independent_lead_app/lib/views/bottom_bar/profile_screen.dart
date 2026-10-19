import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/access_viewmodel.dart';
import 'package:pokakbilling/viewmodels/global_viewmodel.dart';
import 'package:pokakbilling/viewmodels/login_viewmodel.dart';
import 'package:pokakbilling/viewmodels/profile_viewmodel.dart';
import 'package:pokakbilling/views/Screens/auth/login_screen.dart';
import 'package:pokakbilling/views/bottom_bar/bottomNavigationBar/edit_profile.dart';
import 'package:pokakbilling/views/bottom_bar/home_screen.dart';
import 'package:pokakbilling/views/commonWidgets/popups/logout_popup.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  // When ProfileScreen is used as a BottomBar tab, the parent passes this
  // callback to switch back to the Home tab (instead of Navigator popping,
  // which caused a black screen because there's no route underneath a tab).
  // Leave it null when pushing ProfileScreen as a normal route (e.g. from
  // HomePage's avatar tap) — in that case normal Navigator.pop is used.
  final VoidCallback? onBack;
  const ProfileScreen({super.key, this.onBack});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  late AnimationController _slideCtrl;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.10),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut));
    _slideCtrl.forward();

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

  String _getInitials(String first, String last, String fallback) {
    if (first.isNotEmpty && last.isNotEmpty) {
      return '${first[0]}${last[0]}'.toUpperCase();
    }
    if (first.isNotEmpty) return first[0].toUpperCase();
    if (fallback.isNotEmpty) return fallback[0].toUpperCase();
    return '?';
  }

  String _formatUserType(String raw) {
    return raw
        .split('_')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  // Handles both the AppBar back-button tap and the system/gesture back
  // press. If this screen was given an `onBack` callback (i.e. it's a
  // BottomBar tab), use that to switch tabs without touching the Navigator.
  // Otherwise fall back to normal push/pop behaviour for when ProfileScreen
  // was pushed as its own route (e.g. from HomePage's avatar tap).
  void _goBack() {
    if (widget.onBack != null) {
      widget.onBack!();
      return;
    }
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomePage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: Stack(
        children: [
          _buildBgBlobs(),
          SafeArea(
            child: Consumer2<ProfileViewmodel, LoginViewModel>(
              builder: (context, profileVm, loginVm, _) {
                String firstName = '';
                String lastName = '';
                String email = loginVm.loggedInEmail ?? '';
                int? userId = loginVm.loggedInId;
                String userType = loginVm.loggedInUserType ?? '';
                bool isVerified = loginVm.loggedInIsVerified;
                bool hasSub = loginVm.loggedInHasSubscription;
                String phoneNumber = '';
                String gender = '';
                String dob = '';
                String address = '';
                String profilePicture = '';

                if (profileVm.profileList.isNotEmpty) {
                  final u = profileVm.profileList.first;
                  firstName = u.firstName;
                  lastName = u.lastName;
                  if (email.isEmpty) email = u.emailId;
                  phoneNumber = u.phoneNumber;
                  gender = u.gender;
                  dob = u.dob;
                  address = u.address;
                  profilePicture = u.profilePicture;
                }

                final name = '$firstName $lastName'.trim();
                final initials = _getInitials(firstName, lastName, email);

                return SlideTransition(
                  position: _slideAnim,
                  child: FadeTransition(
                    opacity: _slideCtrl,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(
                            name: name,
                            email: email,
                            initials: initials,
                            isLoading:
                                profileVm.getProfileLoader && name.isEmpty,
                            profilePicture: profilePicture,
                          ),
                          const SizedBox(height: 24),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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
                                    if (phoneNumber.isNotEmpty)
                                      _RowData(
                                        label: 'Phone Number',
                                        value: phoneNumber,
                                        icon: Icons.phone_outlined,
                                      ),
                                    if (userId != null)
                                      _RowData(
                                        label: 'User ID',
                                        value: '#$userId',
                                        icon: Icons.tag_rounded,
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _SectionCard(
                                  title: 'Personal Details',
                                  icon: Icons.manage_accounts_outlined,
                                  rows: [
                                    if (gender.isNotEmpty)
                                      _RowData(
                                        label: 'Gender',
                                        value: gender,
                                        icon: Icons.male_outlined,
                                      ),
                                    if (dob.isNotEmpty)
                                      _RowData(
                                        label: 'Date of Birth',
                                        value: dob,
                                        icon: Icons.calendar_today_outlined,
                                      ),
                                    if (address.isNotEmpty)
                                      _RowData(
                                        label: 'Address',
                                        value: address,
                                        icon: Icons.home_outlined,
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _SectionCard(
                                  title: 'Account Details',
                                  icon: Icons.security_outlined,
                                  rows: [
                                    if (userType.isNotEmpty)
                                      _RowData(
                                        label: 'User Type',
                                        value: _formatUserType(userType),
                                        icon:
                                            Icons.admin_panel_settings_outlined,
                                      ),
                                    _RowData(
                                      label: 'Verified',
                                      value: isVerified
                                          ? 'Verified'
                                          : 'Not Verified',
                                      icon: isVerified
                                          ? Icons.verified_outlined
                                          : Icons.cancel_outlined,
                                      valueColor: isVerified
                                          ? const Color(0xFF2E7D32)
                                          : const Color(0xFFE53935),
                                    ),
                                    _RowData(
                                      label: 'Subscription',
                                      value: hasSub ? 'Active' : 'Inactive',
                                      icon: hasSub
                                          ? Icons.workspace_premium_outlined
                                          : Icons.block_outlined,
                                      valueColor: hasSub
                                          ? const Color(0xFF2E7D32)
                                          : const Color(0xFFE53935),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
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
                                Consumer<GlobalViewmodel>(
                                  builder: (_, gVm, __) => Center(
                                    child: Text(
                                      'Version ${gVm.appVersion}',
                                      style: TextStyle(
                                        color: AppColors.ctext.withOpacity(.4),
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

    // Tab mode (onBack provided): let the parent BottomBar's own
    // WillPopScope handle system/gesture back — it already switches to the
    // Home tab correctly. Standalone push mode: intercept back ourselves so
    // popping with nothing underneath doesn't leave a black screen.
    if (widget.onBack != null) {
      return scaffold;
    }

    return WillPopScope(
      onWillPop: () async {
        if (Navigator.of(context).canPop()) {
          return true;
        }
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomePage()),
          (route) => false,
        );
        return false;
      },
      child: scaffold,
    );
  }

  Widget _buildHeader({
    required String name,
    required String email,
    required String initials,
    required bool isLoading,
    required String profilePicture,
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
            color: AppColors.c1.withOpacity(0.07),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // ── Back button so the user can easily return, since this
              // screen is pushed above the bottom nav bar ────────────────
              InkWell(
                onTap: _goBack,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.c1.withOpacity(.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    size: 20,
                    color: AppColors.cdark,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Profile',
                style: const TextStyle(
                  color: AppColors.cdark,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditProfileScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.c1.withOpacity(.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        size: 16,
                        color: AppColors.c1,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Edit',
                        style: TextStyle(
                          color: AppColors.c1,
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
          const SizedBox(height: 24),
          AnimatedBuilder(
            animation: _pulseAnim,
            builder: (_, __) => Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.c1.withOpacity(_pulseAnim.value),
                    AppColors.cdark,
                    AppColors.c1.withOpacity(_pulseAnim.value),
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
                    : profilePicture.isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              profilePicture,
                              width: 88,
                              height: 88,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Text(
                                  initials,
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                  ),
                                );
                              },
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
                  color: AppColors.c1.withOpacity(.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  email,
                  style: TextStyle(
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
                color: AppColors.c1.withOpacity(0.05 * _pulseAnim.value),
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
                color: AppColors.c1.withOpacity(0.04 * _pulseAnim.value),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RowData {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;
  const _RowData({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });
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
            border: Border.all(color: AppColors.cborder.withOpacity(.6)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.03),
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
                    color: AppColors.cborder.withOpacity(.5),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

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
              color: AppColors.c1.withOpacity(.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              data.icon,
              size: 17,
              color: AppColors.c1.withOpacity(.8),
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
                    color: AppColors.ctext.withOpacity(.5),
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
              : AppColors.c1.withOpacity(.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isLoggedIn
                ? const Color(0xFFFFCCCC)
                : AppColors.c1.withOpacity(.2),
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