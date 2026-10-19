import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pokakbilling/core/navigations.dart';
import 'package:pokakbilling/models/staff_lead/staff_lead_model.dart';
import 'package:pokakbilling/viewmodels/access_viewmodel.dart';
import 'package:pokakbilling/viewmodels/activity_leads/activity_viewmodel.dart';
import 'package:pokakbilling/viewmodels/profile_viewmodel.dart';
import 'package:pokakbilling/viewmodels/login_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/followup_viewmodel.dart';
import 'package:pokakbilling/viewmodels/lead_viewmodel.dart';
import 'package:pokakbilling/viewmodels/meeting_viewmodel.dart';
import 'package:pokakbilling/viewmodels/reminder/reminder_viewmodel.dart';
import 'package:pokakbilling/viewmodels/staff_lead/staff_lead_viewmodel.dart';
import 'package:pokakbilling/views/NewScreens/communicationScreen.dart';
import 'package:pokakbilling/views/NewScreens/whatsappLeadsScreen.dart';
import 'package:pokakbilling/views/Screens/auth/login_screen.dart';
import 'package:pokakbilling/views/Screens/inbox/inbox.dart';
import 'package:pokakbilling/views/Screens/invoice/Invoice_main.dart';
import 'package:pokakbilling/views/Screens/leads/follow_up/follow_up.dart';
import 'package:pokakbilling/views/Screens/leads/lead_screens/create_lead.dart';
import 'package:pokakbilling/views/Screens/leads/lead_screens/leads.dart';
import 'package:pokakbilling/views/Screens/leads/lead_screens/leadsnewscreen.dart';
import 'package:pokakbilling/views/Screens/leads/lead_screens/myactivityscreen.dart';
import 'package:pokakbilling/views/Screens/leads/lead_screens/newActivityScreen.dart';
import 'package:pokakbilling/views/Screens/leads/meeting/addmeetingscreen.dart';
import 'package:pokakbilling/views/Screens/leads/meeting/meeting.dart';
import 'package:pokakbilling/views/Screens/leads/reminder/add_new_reminder.dart';
import 'package:pokakbilling/views/Screens/leads/reminder/lead_reminder.dart';
import 'package:pokakbilling/views/Screens/quotation/add/add_quotation.dart';
import 'package:pokakbilling/views/academy/academy_home_screen.dart';
import 'package:pokakbilling/views/bottom_bar/product_screen.dart';
import 'package:pokakbilling/views/commonWidgets/popups/logout_popup.dart';
import 'package:pokakbilling/views/staff_lead/staff_lead_dashboard.dart';
import 'package:provider/provider.dart';

// ═════════════════════════════════════════════════════════════════════════════
// Colour scheme (same as Academy dashboard)
//   • Header         → Cyan gradient
//   • Stat cards     → Pink / Violet / Green
//   • Workspace      → Cyan / Violet / Blue / Amber / Green / Orange
// ═════════════════════════════════════════════════════════════════════════════
const Color _kPageBg = Color(0xFFF0FAFD);
const Color _kInk = Color(0xFF0F172A);
const Color _kSlate = Color(0xFF64748B);
const Color _kLine = Color(0xFFD9ECF2);

const Color _kCyan = Color(0xFF06B6D4);
const Color _kCyanLight = Color(0xFF67E8F9);
const Color _kCyanDeep = Color(0xFF0E7490);
const Color _kBlue = Color(0xFF3B82F6);
const Color _kOrange = Color(0xFFF97316);
const Color _kViolet = Color(0xFF8B5CF6);
const Color _kGreen = Color(0xFF16A34A);
const Color _kPink = Color(0xFFEC4899);
const Color _kAmber = Color(0xFFF59E0B);
const Color _kRed = Color(0xFFEF4444);
const Color _kWhatsApp = Color(0xFF25D366);

const LinearGradient _kHeaderGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [_kCyanDeep, _kCyan, _kCyanLight],
);

Color _shade(Color c, double amt) => Color.lerp(c, Colors.black, amt)!;
Color _tint(Color c, double amt) => Color.lerp(c, Colors.white, amt)!;

// ─── WhatsApp SVG ─────────────────────────────────────────────────────────────
const String _kWhatsAppSvg = '''
<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
  <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347z"/>
  <path d="M12 0C5.373 0 0 5.373 0 12c0 2.125.558 4.122 1.528 5.855L.057 23.885a.5.5 0 00.611.611l6.101-1.459A11.945 11.945 0 0012 24c6.627 0 12-5.373 12-12S18.627 0 12 0zm0 21.818a9.818 9.818 0 01-5.012-1.378l-.36-.214-3.724.89.908-3.64-.235-.374A9.818 9.818 0 0112 2.182c5.428 0 9.818 4.39 9.818 9.818 0 5.429-4.39 9.818-9.818 9.818z"/>
</svg>
''';

// Runs a viewmodel fetch whether it returns void or a Future.
Future<dynamic> _run(dynamic Function() f) => Future.sync(f);

// ═════════════════════════════════════════════════════════════════════════════
// ERP Home Page
// ═════════════════════════════════════════════════════════════════════════════
class ErpHomePage extends StatefulWidget {
  const ErpHomePage({super.key});
  @override
  State<ErpHomePage> createState() => _ErpHomePageState();
}

class _ErpHomePageState extends State<ErpHomePage> {
  bool _sessionDialogShown = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      _loadAll();
      _checkSession();
    });
  }

  Future<void> _loadAll() async {
    if (!mounted) return;
    final followupVm = Provider.of<FollowupViewmodel>(context, listen: false);
    final meetingVm = Provider.of<MeetingViewmodel>(context, listen: false);
    final reminderVm = Provider.of<ReminderViewmodel>(context, listen: false);
    final leadVm = Provider.of<LeadViewmodel>(context, listen: false);
    final profileVm = Provider.of<ProfileViewmodel>(context, listen: false);
    final activityVm =
        Provider.of<ActivityScreenViewmodel>(context, listen: false);
    final staffLeadVm =
        Provider.of<StaffLeadViewmodel>(context, listen: false);

    await Future.wait([
      _run(followupVm.fetchFollowups),
      _run(meetingVm.getAllMeetings),
      _run(reminderVm.fetchReminders),
      _run(leadVm.getAllLeads),
      _run(profileVm.getAllProfile),
      _run(activityVm.fetchActivities),
      _run(staffLeadVm.refresh), // staff lead banner counts
    ]);
  }

  void _go(Widget page) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));

  /// The ONLY place that decides whether to show the "Session Expired" dialog.
  Future<void> _checkSession() async {
    if (!mounted) return;
    final accessVm = Provider.of<AccessViewModel>(context, listen: false);
    await accessVm.checkLoginStatus();
    if (!mounted) return;
    if (!accessVm.checkingIsLoggedIn && !_sessionDialogShown) {
      _showSessionExpiredDialog();
    }
  }

  void _showSessionExpiredDialog() {
    if (!mounted || _sessionDialogShown) return;
    _sessionDialogShown = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_tint(_kRed, 0.25), _kRed],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _kRed.withValues(alpha: 0.32),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(Icons.lock_outline_rounded,
                    color: Colors.white, size: 30),
              ),
              const SizedBox(height: 18),
              const Text('Session Expired',
                  style: TextStyle(
                      color: _kInk,
                      fontSize: 19,
                      fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              const Text(
                'Your session has expired or you have been logged out. Please log in again to continue.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _kSlate, fontSize: 13.5, height: 1.5),
              ),
              const SizedBox(height: 24),
              _Pressable(
                onTap: () async {
                  Navigator.of(ctx).pop();
                  if (!mounted) return;
                  final loginVm =
                      Provider.of<LoginViewModel>(context, listen: false);
                  final profileVm =
                      Provider.of<ProfileViewmodel>(context, listen: false);
                  final accessVm =
                      Provider.of<AccessViewModel>(context, listen: false);
                  final staffLeadVm =
                      Provider.of<StaffLeadViewmodel>(context, listen: false);
                  await loginVm.logout();
                  profileVm.reset();
                  staffLeadVm.clearData();
                  await accessVm.isLogout();
                  if (!mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [_kCyanDeep, _kCyan]),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: _kCyan.withValues(alpha: .35),
                          blurRadius: 12,
                          offset: const Offset(0, 5))
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.login_rounded, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text('Re-login',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).then((_) => _sessionDialogShown = false);
  }

  // ── Workspace cards (3 + 3 grid) ─────────────────────────────────────────────
  List<_WorkspaceItem> _cards() => const [
        _WorkspaceItem('Inbox', 'Internal chat', Icons.chat_rounded, _kCyan,
            InboxScreen()),
        _WorkspaceItem('Leads', 'Track prospects', Icons.trending_up_rounded,
            _kViolet, LeadScreen()),
        _WorkspaceItem('Communication', 'Call, WA, Mail', Icons.phone_rounded,
            _kBlue, CommunicationScreen()),
        _WorkspaceItem('Reminder', 'Set reminders', Icons.alarm_rounded,
            _kAmber, LeadReminder()),
        _WorkspaceItem('Meetings', 'Scheduled', Icons.handshake_rounded,
            _kGreen, MeetingScreen()),
        _WorkspaceItem('Invoice', 'Create invoice', Icons.receipt_long_rounded,
            _kOrange, InvoiceMain()),
      ];

  // ── Quick access chips ───────────────────────────────────────────────────────
  List<_QuickItem> _quickChips() => const [
        _QuickItem('WhatsApp', Icons.chat_rounded, _kWhatsApp,
            WhatsAppLeadsScreen(),
            useWhatsApp: true),
        _QuickItem('New Lead', Icons.person_add_rounded, _kCyan,
            CreateLead(isEdit: false)),
        _QuickItem('Meeting', Icons.handshake_rounded, _kAmber,
            AddMeetingScreen()),
        _QuickItem(
            'Reminder', Icons.alarm_add_rounded, _kRed, AddReminderScreen()),
        _QuickItem('Quote', Icons.description_rounded, _kViolet,
            AddQuotation(quotationNumber: '')),
        _QuickItem('Organizer', Icons.event_note_rounded, _kBlue,
            NewActivityScreen()),
      ];

  // ─── Build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;

    return Consumer2<AccessViewModel, LoginViewModel>(
      builder: (context, accessVm, loginVm, _) {
        return Scaffold(
          backgroundColor: _kPageBg,
          body: Column(children: [
            _Header(loginVm: loginVm, accessVm: accessVm),
            Expanded(
              child: RefreshIndicator(
                color: _kCyan,
                onRefresh: _loadAll,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics()),
                  padding: EdgeInsets.fromLTRB(
                      sw * .04, 18, sw * .04, mq.padding.bottom + 28),
                  children: [
                    // ── Stats ───────────────────────────────────────────
                    const _SectionLabel(text: 'STATS OVERVIEW', color: _kCyan),
                    const SizedBox(height: 10),
                    _buildStats(),

                    // ── Staff lead dashboard ────────────────────────────
                    const SizedBox(height: 22),
                    const _SectionLabel(
                        text: 'STAFF LEAD DASHBOARD', color: _kPink),
                    const SizedBox(height: 12),
                    _FadeIn(
                      index: 3,
                      child: _StaffLeadBanner(
                        onTap: () => _go(const StaffLeadDashboardScreen()),
                      ),
                    ),

                    // ── Workspace ───────────────────────────────────────
                    const SizedBox(height: 22),
                    const _SectionLabel(text: 'WORKSPACE', color: _kViolet),
                    const SizedBox(height: 12),
                    _buildCardsGrid(),

                    // ── Academy ─────────────────────────────────────────
                    const SizedBox(height: 10),
                    const _SectionLabel(text: 'ACADEMY', color: _kBlue),
                    const SizedBox(height: 12),
                    _FadeIn(
                      index: 6,
                      child: _AcademyBanner(
                        onTap: () => _go(const AcademyDashboardScreen()),
                      ),
                    ),

                    // ── Quick access ────────────────────────────────────
                    const SizedBox(height: 22),
                    const _SectionLabel(text: 'QUICK ACCESS', color: _kOrange),
                    const SizedBox(height: 12),
                    _buildQuickAccess(),
                  ],
                ),
              ),
            ),
          ]),
        );
      },
    );
  }

  // ─── Stats ────────────────────────────────────────────────────────────────────
  Widget _buildStats() {
    return Consumer4<FollowupViewmodel, LeadViewmodel, MeetingViewmodel,
        ReminderViewmodel>(
      builder: (ctx, followupVm, leadVm, meetingVm, reminderVm, _) {
        final organizerCount = followupVm.followups.length +
            meetingVm.meetingList.length +
            reminderVm.reminders.length;

        final items = [
          _StatItem('Follow Up', followupVm.followups.length, _kPink,
              Icons.replay_rounded, const FollowUp()),
          _StatItem('Leads', leadVm.leadList.length, _kViolet,
              Icons.trending_up_rounded, const LeadsNewScreen()),
          _StatItem('Organizer', organizerCount, _kGreen,
              Icons.event_note_rounded, const MyOrganizerScreen()),
        ];

        return Row(
          children: List.generate(items.length, (i) {
            final it = items[i];
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i < items.length - 1 ? 10 : 0),
                child: _FadeIn(
                  index: i,
                  child: _StatCard(item: it, onTap: () => _go(it.page)),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  // ─── Workspace grid ───────────────────────────────────────────────────────────
  Widget _buildCardsGrid() {
    final cards = _cards();
    const int cols = 3;
    const double gap = 10;

    return Column(
      children: List.generate((cards.length / cols).ceil(), (rowIndex) {
        final start = rowIndex * cols;
        final end = (start + cols > cards.length) ? cards.length : start + cols;
        final rowItems = cards.sublist(start, end);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: List.generate(cols, (i) {
              if (i >= rowItems.length) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: i < cols - 1 ? gap : 0),
                    child: const SizedBox.shrink(),
                  ),
                );
              }
              final item = rowItems[i];
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i < cols - 1 ? gap : 0),
                  child: _FadeIn(
                    index: start + i,
                    child: _WorkspaceCard(
                        item: item, onTap: () => _go(item.page)),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  // ─── Quick access ─────────────────────────────────────────────────────────────
  Widget _buildQuickAccess() {
    final chips = _quickChips();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kLine),
        boxShadow: [
          BoxShadow(
            color: _kOrange.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(chips.length, (i) {
          final chip = chips[i];
          return Expanded(
            child: _FadeIn(
              index: i,
              child: _QuickAccessTile(
                  item: chip, onTap: () => _go(chip.page)),
            ),
          );
        }),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Data holders
// ═════════════════════════════════════════════════════════════════════════════
class _WorkspaceItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget page;
  const _WorkspaceItem(
      this.title, this.subtitle, this.icon, this.color, this.page);
}

class _QuickItem {
  final String label;
  final IconData icon;
  final Color color;
  final Widget page;
  final bool useWhatsApp;
  const _QuickItem(this.label, this.icon, this.color, this.page,
      {this.useWhatsApp = false});
}

class _StatItem {
  final String label;
  final int value;
  final Color color;
  final IconData icon;
  final Widget page;
  const _StatItem(this.label, this.value, this.color, this.icon, this.page);
}

// ═════════════════════════════════════════════════════════════════════════════
// Header (cyan gradient, same look as Academy header)
// ═════════════════════════════════════════════════════════════════════════════
class _Header extends StatelessWidget {
  final LoginViewModel loginVm;
  final AccessViewModel accessVm;
  const _Header({required this.loginVm, required this.accessVm});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;
    final loggedIn = accessVm.checkingIsLoggedIn;

    return Consumer<ProfileViewmodel>(
      builder: (context, profileVm, _) {
        String firstName = '';
        String lastName = '';
        String email = loginVm.loggedInEmail ?? '';

        if (profileVm.profileList.isNotEmpty) {
          final user = profileVm.profileList.first;
          firstName = user.firstName;
          lastName = user.lastName;
          if (email.isEmpty) email = user.emailId;
        }

        String name = '$firstName $lastName'.trim();
        if (name.isEmpty) name = email.isNotEmpty ? email : 'User';

        String initials;
        if (firstName.isNotEmpty && lastName.isNotEmpty) {
          initials = '${firstName[0]}${lastName[0]}'.toUpperCase();
        } else if (firstName.isNotEmpty) {
          initials = firstName[0].toUpperCase();
        } else if (name.isNotEmpty) {
          initials = name[0].toUpperCase();
        } else {
          initials = 'U';
        }

        return Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            gradient: _kHeaderGradient,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: _kCyan.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: Stack(children: [
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
              right: 56,
              top: mq.padding.top + 2,
              child: Transform.rotate(
                angle: -0.25,
                child: Icon(Icons.grid_view_rounded,
                    size: 90, color: Colors.white.withValues(alpha: 0.12)),
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
                  top: mq.padding.top + 10,
                  bottom: 20,
                  left: sw * .045,
                  right: sw * .045),
              child: Column(children: [
                Row(children: [
                  // Avatar
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.5),
                          width: 1.5),
                    ),
                    child: Stack(children: [
                      Center(
                        child: Text(initials,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 16)),
                      ),
                      Positioned(
                        right: 1,
                        bottom: 1,
                        child: Container(
                          width: 11,
                          height: 11,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4ADE80),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_greeting(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.88),
                                  fontSize: 13)),
                          const SizedBox(height: 1),
                          Text(name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 21,
                                  fontWeight: FontWeight.w900)),
                        ]),
                  ),
                  const SizedBox(width: 8),
                  _Pressable(
                    onTap: () => loggedIn
                        ? showLogoutDialog(context)
                        : pushNavigation(context, const LoginScreen()),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.4)),
                      ),
                      child: Icon(
                        loggedIn ? Icons.logout_rounded : Icons.login_rounded,
                        color: Colors.white,
                        size: 19,
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 16),
                // Glass banner
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.30)),
                  ),
                  child: Row(children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Easily Manage ERP Operations',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white)),
                          const SizedBox(height: 2),
                          Text('Track orders, inventory & supply chain',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      Colors.white.withValues(alpha: 0.88))),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.grid_view_rounded,
                          color: _kCyanDeep, size: 21),
                    ),
                  ]),
                ),
              ]),
            ),
          ]),
        );
      },
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Section label / header (coloured bar)
// ═════════════════════════════════════════════════════════════════════════════
class _SectionLabel extends StatelessWidget {
  final String text;
  final Color color;
  const _SectionLabel({required this.text, required this.color});

  @override
  Widget build(BuildContext context) => Row(children: [
        Container(
          width: 4,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 7),
        Text(text,
            style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: _kSlate,
                letterSpacing: 1.1)),
      ]);
}

// ═════════════════════════════════════════════════════════════════════════════
// Stat card (white, colour wash, bottom bar, count-up)
// ═════════════════════════════════════════════════════════════════════════════
class _StatCard extends StatelessWidget {
  final _StatItem item;
  final VoidCallback onTap;
  const _StatCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = item.color;
    return _Pressable(
      onTap: onTap,
      child: Container(
        height: 118,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: c.withValues(alpha: 0.18)),
          boxShadow: [
            BoxShadow(
              color: c.withValues(alpha: 0.16),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.center,
                    colors: [
                      c.withValues(alpha: 0.10),
                      Colors.white.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [_tint(c, 0.25), c]),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 0, 6, 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [_tint(c, 0.22), c],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: c.withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(item.icon, size: 20, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: TweenAnimationBuilder<double>(
                        key: ValueKey('${item.label}_${item.value}'),
                        tween: Tween<double>(
                            begin: 0, end: item.value.toDouble()),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeOutCubic,
                        builder: (_, v, __) => Text('${v.round()}',
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: _kInk,
                                height: 1.1)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  SizedBox(
                    width: double.infinity,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(item.label,
                          maxLines: 1,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _shade(c, 0.1))),
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Workspace card (white, gradient icon tile, coloured underline)
// ═════════════════════════════════════════════════════════════════════════════
class _WorkspaceCard extends StatelessWidget {
  final _WorkspaceItem item;
  final VoidCallback onTap;
  const _WorkspaceCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = item.color;
    return _Pressable(
      onTap: onTap,
      child: Container(
        height: 108,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _kLine),
          boxShadow: [
            BoxShadow(
              color: c.withValues(alpha: 0.12),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(children: [
            Positioned(
              right: -16,
              top: -16,
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: c.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [_tint(c, 0.25), c]),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 0, 6, 4),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [_tint(c, 0.22), c],
                        ),
                        borderRadius: BorderRadius.circular(13),
                        boxShadow: [
                          BoxShadow(
                            color: c.withValues(alpha: 0.32),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(item.icon, color: Colors.white, size: 21),
                    ),
                    const SizedBox(height: 8),
                    Text(item.title,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: _kInk)),
                    const SizedBox(height: 1),
                    Text(item.subtitle,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            const TextStyle(fontSize: 10.5, color: _kSlate)),
                  ],
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Academy banner (cyan gradient, like the Academy header)
// ═════════════════════════════════════════════════════════════════════════════
class _AcademyBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _AcademyBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _Pressable(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 82,
        decoration: BoxDecoration(
          gradient: _kHeaderGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _kCyan.withValues(alpha: 0.32),
              blurRadius: 16,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(children: [
            Positioned(
              right: -20,
              top: -30,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.10),
                ),
              ),
            ),
            Positioned(
              left: -18,
              bottom: -36,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              right: 50,
              bottom: -12,
              child: Transform.rotate(
                angle: -0.25,
                child: Icon(Icons.school_rounded,
                    size: 70, color: Colors.white.withValues(alpha: 0.14)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.40)),
                  ),
                  child: const Icon(Icons.school_rounded,
                      color: Colors.white, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Academy',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Colors.white)),
                      const SizedBox(height: 2),
                      Text('Registrations · Admissions · Receipts',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.9))),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_forward_rounded,
                      size: 18, color: _kCyanDeep),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Staff Lead Dashboard banner — live counts from StaffLeadViewmodel
// ═════════════════════════════════════════════════════════════════════════════
class _StaffLeadBanner extends StatefulWidget {
  final VoidCallback onTap;
  const _StaffLeadBanner({required this.onTap});

  @override
  State<_StaffLeadBanner> createState() => _StaffLeadBannerState();
}

class _StaffLeadBannerState extends State<_StaffLeadBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shine = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2600))
    ..repeat();

  @override
  void dispose() {
    _shine.dispose();
    super.dispose();
  }

  static const _kIndigo = Color(0xFF6366F1);

  @override
  Widget build(BuildContext context) {
    final counts = context.watch<StaffLeadViewmodel>().counts;
    final pending = counts[LeadStage.priorityPending] ?? 0;
    final prospects = counts[LeadStage.prospects] ?? 0;
    final rnr = counts[LeadStage.rnr] ?? 0;

    return _Pressable(
      onTap: widget.onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_kIndigo, _kViolet, _kPink],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: _kViolet.withValues(alpha: 0.38),
              blurRadius: 20,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(children: [
            // decorative bubbles
            Positioned(
              right: -30,
              top: -40,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.10),
                ),
              ),
            ),
            Positioned(
              left: -24,
              bottom: -40,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              right: 14,
              top: 34,
              child: Transform.rotate(
                angle: -0.2,
                child: Icon(Icons.layers_rounded,
                    size: 78, color: Colors.white.withValues(alpha: 0.13)),
              ),
            ),
            // moving shine
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _shine,
                builder: (_, __) => Align(
                  alignment: Alignment(-1.6 + _shine.value * 3.2, 0),
                  child: Transform.rotate(
                    angle: 0.35,
                    child: Container(
                      width: 46,
                      height: 420,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          Colors.white.withValues(alpha: 0),
                          Colors.white.withValues(alpha: 0.16),
                          Colors.white.withValues(alpha: 0),
                        ]),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.40)),
                      ),
                      child: const Icon(Icons.dashboard_customize_rounded,
                          color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            const Flexible(
                              child: Text('Staff Lead Dashboard',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white)),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text('NEW',
                                  style: TextStyle(
                                      fontSize: 9,
                                      letterSpacing: 0.6,
                                      fontWeight: FontWeight.w900,
                                      color: _kPink)),
                            ),
                          ]),
                          const SizedBox(height: 2),
                          Text('Academic leads · Courses · Statuses',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withValues(alpha: 0.9))),
                        ],
                      ),
                    ),
                  ]),
                  const SizedBox(height: 14),

                  // mini stats (live from API counts)
                  Row(children: [
                    _bannerStat(
                        '$pending', 'Pending', Icons.priority_high_rounded),
                    const SizedBox(width: 8),
                    _bannerStat('$prospects', 'Prospects',
                        Icons.local_fire_department_rounded),
                    const SizedBox(width: 8),
                    _bannerStat('$rnr', 'RNR', Icons.phone_missed_rounded),
                  ]),
                  const SizedBox(height: 14),

                  // CTA
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.10),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Open Dashboard',
                            style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w900,
                                color: _kViolet)),
                        const SizedBox(width: 8),
                        Container(
                          width: 26,
                          height: 26,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                                colors: [_kIndigo, _kViolet, _kPink]),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_forward_rounded,
                              size: 16, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _bannerStat(String value, String label, IconData icon) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
          ),
          child: Row(children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value,
                      style: const TextStyle(
                          fontSize: 16,
                          height: 1.1,
                          fontWeight: FontWeight.w900,
                          color: Colors.white)),
                  Text(label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withValues(alpha: 0.9))),
                ],
              ),
            ),
          ]),
        ),
      );
}

// ═════════════════════════════════════════════════════════════════════════════
// Quick access tile
// ═════════════════════════════════════════════════════════════════════════════
class _QuickAccessTile extends StatelessWidget {
  final _QuickItem item;
  final VoidCallback onTap;
  const _QuickAccessTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = item.color;
    return _Pressable(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: c.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: c.withValues(alpha: 0.25)),
            ),
            child: Center(
              child: item.useWhatsApp
                  ? SvgPicture.string(
                      _kWhatsAppSvg,
                      width: 22,
                      height: 22,
                      colorFilter: ColorFilter.mode(c, BlendMode.srcIn),
                    )
                  : Icon(item.icon, color: _shade(c, 0.05), size: 22),
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(item.label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: _kSlate)),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Shared helpers: press-scale + staggered fade-in
// ═════════════════════════════════════════════════════════════════════════════
class _Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _Pressable({required this.child, required this.onTap});

  @override
  State<_Pressable> createState() => _PressableState();
}

class _PressableState extends State<_Pressable>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 90));
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}

class _FadeIn extends StatefulWidget {
  final Widget child;
  final int index;
  const _FadeIn({required this.child, required this.index});

  @override
  State<_FadeIn> createState() => _FadeInState();
}

class _FadeInState extends State<_FadeIn> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 380));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, .08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(Duration(milliseconds: 60 + widget.index * 60), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child));
}