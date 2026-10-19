import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pokakbilling/core/navigations.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/access_viewmodel.dart';
import 'package:pokakbilling/viewmodels/activity/all_activityviewmodel.dart';
import 'package:pokakbilling/viewmodels/profile_viewmodel.dart';
import 'package:pokakbilling/viewmodels/login_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/followup_viewmodel.dart';
import 'package:pokakbilling/views/Screens/auth/login_screen.dart';
import 'package:pokakbilling/views/bottom_bar/profile_screen.dart';
import 'package:pokakbilling/views/Screens/inbox/inbox_home.dart';
import 'package:pokakbilling/views/Screens/invoice/Invoice_main.dart';
import 'package:pokakbilling/views/Screens/leads/follow_up/follow_up.dart';
import 'package:pokakbilling/views/Screens/leads/lead_screens/create_lead.dart';
import 'package:pokakbilling/views/Screens/leads/lead_screens/leads.dart';
import 'package:pokakbilling/views/Screens/leads/lead_screens/leadsnewscreen.dart';
import 'package:pokakbilling/views/Screens/leads/meeting/addmeetingscreen.dart';
import 'package:pokakbilling/views/Screens/leads/meeting/meeting.dart';
import 'package:pokakbilling/views/Screens/leads/my_activity/my_activity_screen.dart';
import 'package:pokakbilling/views/Screens/leads/my_activity/new_activity.dart';
import 'package:pokakbilling/views/Screens/leads/reminder/add_new_reminder.dart';
import 'package:pokakbilling/views/Screens/quotation/add/add_quotation.dart';
import 'package:pokakbilling/views/Screens/sales_person/sales_person_main.dart';
import 'package:pokakbilling/views/call_activity/call_homepage.dart';
import 'package:pokakbilling/views/newScreens/communication/communication.dart';
import 'package:pokakbilling/views/newScreens/whatsappScreen/WhatsappConnectScreen.dart';
import 'package:provider/provider.dart';
import 'package:pokakbilling/views/commonWidgets/popups/logout_popup.dart';
import 'package:pokakbilling/viewmodels/customer_viewmodel.dart';
import 'package:pokakbilling/viewmodels/lead_viewmodel.dart';

// ─── WhatsApp SVG ─────────────────────────────────────────────────────────────
const String _kWhatsAppSvg = '''
<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
  <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347z"/>
  <path d="M12 0C5.373 0 0 5.373 0 12c0 2.125.558 4.122 1.528 5.855L.057 23.885a.5.5 0 00.611.611l6.101-1.459A11.945 11.945 0 0012 24c6.627 0 12-5.373 12-12S18.627 0 12 0zm0 21.818a9.818 9.818 0 01-5.012-1.378l-.36-.214-3.724.89.908-3.64-.235-.374A9.818 9.818 0 0112 2.182c5.428 0 9.818 4.39 9.818 9.818 0 5.429-4.39 9.818-9.818 9.818z"/>
</svg>
''';

// ── Fixed column widths shared by header + data rows ──────────────────────────
const double _kIconCol = 28.0;
const double _kTimeCol = 48.0;
const double _kActionCol = 64.0;

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  bool _sessionDialogShown = false;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 480));
    _fade = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, .04), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();

    Future.microtask(() {
      if (!mounted) return;
      Provider.of<AllActivityViewModel>(context, listen: false)
          .fetchActivities();
      Provider.of<FollowupViewmodel>(context, listen: false).fetchFollowups();
      Provider.of<LeadViewmodel>(context, listen: false).getAllLeads();
      Provider.of<ProfileViewmodel>(context, listen: false).getAllProfile();
      _checkSession();
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _checkSession() async {
    if (!mounted) return;
    final accessVm = Provider.of<AccessViewModel>(context, listen: false);
    await accessVm.checkLoginStatus();
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
      builder: (ctx) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: AppColors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                    color: AppColors.tagRedBg, shape: BoxShape.circle),
                child: const Icon(Icons.lock_outline_rounded,
                    color: AppColors.tagRed, size: 28),
              ),
              const SizedBox(height: 16),
              const Text('Session Expired',
                  style: TextStyle(
                      color: AppColors.cdark,
                      fontSize: 17,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              const Text(
                  'Your session has expired or you have been logged out. Please log in again to continue.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: AppColors.ctext, fontSize: 13, height: 1.5)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    if (!mounted) return;
                    final loginVm =
                        Provider.of<LoginViewModel>(context, listen: false);
                    final profileVm =
                        Provider.of<ProfileViewmodel>(context, listen: false);
                    final accessVm =
                        Provider.of<AccessViewModel>(context, listen: false);
                    await loginVm.clearUserData();
                    await profileVm.clearCachedProfile();
                    await accessVm.isLogout();
                    if (!mounted) return;
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.c1,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                            color: AppColors.c1.withOpacity(.25),
                            blurRadius: 8,
                            offset: const Offset(0, 3)),
                      ],
                    ),
                    child: const Center(
                      child: Text('Re-login',
                          style: TextStyle(
                              color: AppColors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).then((_) => _sessionDialogShown = false);
  }

  // ── Workspace cards ─────────────────────────────────────────────────────────
  List<Map<String, dynamic>> _cards() => [
        {
          'title': 'Chat',
          'icon': Icons.mark_chat_read_rounded,
          'color': const Color(0xFF6366F1),
          'page': const InboxScreen()
        },
        {
          'title': 'Leads',
          'icon': Icons.insights_rounded,
          'color': const Color(0xFF10B981),
          'page': const LeadScreen()
        },
        {
          'title': 'Contacts',
          'icon': Icons.perm_phone_msg_rounded,
          'color': const Color(0xFF3B82F6),
          'page': const CommunicationScreen()
        },
        {
          'title': 'Call Activity',
          'icon': Icons.phone_in_talk_rounded,
          'color': const Color(0xFFF59E0B),
          'page': const CallActivityScreen()
        },
        {
          'title': 'Meetings',
          'icon': Icons.groups_2_rounded,
          'color': const Color(0xFFEC4899),
          'page': const MeetingScreen()
        },
        {
          'title': 'Invoice',
          'icon': Icons.request_quote_rounded,
          'color': const Color(0xFF8B5CF6),
          'page': const InvoiceMain()
        },
      ];

  List<Map<String, dynamic>> _adminCards() => [
        {
          'title': 'Inbox',
          'icon': Icons.mark_chat_read_rounded,
          'color': const Color(0xFF6366F1),
          'page': const InboxScreen()
        },
        {
          'title': 'Communication',
          'icon': Icons.perm_phone_msg_rounded,
          'color': const Color(0xFF3B82F6),
          'page': const CommunicationScreen()
        },
        {
          'title': 'Leads',
          'icon': Icons.insights_rounded,
          'color': const Color(0xFF10B981),
          'page': const LeadScreen()
        },
        {
          'title': 'Call Activity',
          'icon': Icons.phone_in_talk_rounded,
          'color': const Color(0xFFF59E0B),
          'page': const CallActivityScreen()
        },
        {
          'title': 'Meetings',
          'icon': Icons.groups_2_rounded,
          'color': const Color(0xFFEC4899),
          'page': const MeetingScreen()
        },
        {
          'title': 'Sales Person',
          'icon': Icons.supervised_user_circle_rounded,
          'color': const Color(0xFFEF4444),
          'page': const SalesPersonMain(),
          'adminOnly': true
        },
        {
          'title': 'Invoice',
          'icon': Icons.request_quote_rounded,
          'color': const Color(0xFF8B5CF6),
          'page': const InvoiceMain()
        },
      ];

  // ── Quick access ────────────────────────────────────────────────────────────
  List<Map<String, dynamic>> _quickChips() => [
        {
          'label': 'WhatsApp',
          'useWhatsApp': true,
          'icon': Icons.chat_rounded,
          'bgColor': const Color(0xFF25D366).withOpacity(.14),
          'iconColor': const Color(0xFF25D366),
          'page': const ConnectScreen()
        },
        {
          'label': 'New Lead',
          'icon': Icons.person_add_alt_1_rounded,
          'bgColor': AppColors.c1.withOpacity(.14),
          'iconColor': AppColors.c1,
          'page': const CreateLead(isEdit: false)
        },
        {
          'label': 'New Meeting',
          'icon': Icons.video_call_rounded,
          'bgColor': const Color(0xFFCA8A04).withOpacity(.14),
          'iconColor': const Color(0xFFCA8A04),
          'page': const AddMeetingScreen()
        },
        {
          'label': 'Set Reminder',
          'icon': Icons.notifications_active_rounded,
          'bgColor': AppColors.tagRed.withOpacity(.14),
          'iconColor': AppColors.tagRed,
          'page': const AddReminderScreen()
        },
        {
          'label': 'New Quote',
          'icon': Icons.request_page_rounded,
          'bgColor': const Color(0xFF7C3AED).withOpacity(.14),
          'iconColor': const Color(0xFF7C3AED),
          'page': const AddQuotation(quotationNumber: '', isEdit: false)
        },
        {
          'label': 'New Organizer',
          'icon': Icons.calendar_month_rounded,
          'bgColor': AppColors.c3.withOpacity(.14),
          'iconColor': AppColors.c3,
          'page': const NewActivityScreen()
        },
      ];

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;
    final top = mq.padding.top;
    final bot = mq.padding.bottom;

    return Consumer<AccessViewModel>(
      builder: (context, accessVm, _) {
        if (!accessVm.checkingIsLoggedIn && !_sessionDialogShown) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showSessionExpiredDialog();
          });
        }

        return Consumer<LoginViewModel>(
          builder: (context, loginVm, _) {
            final isAdmin = loginVm.isAdmin;
            return Scaffold(
              backgroundColor: AppColors.white,
              body: Column(
                children: [
                  _buildAppBar(context, sw, top, isAdmin, loginVm, accessVm),
                  Expanded(
                    child: FadeTransition(
                      opacity: _fade,
                      child: SlideTransition(
                        position: _slide,
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Container(
                            color: AppColors.white,
                            padding: EdgeInsets.fromLTRB(
                                sw * .035, 8, sw * .035, bot + 12),
                            child: isAdmin
                                ? _buildAdminBody(context, loginVm)
                                : _buildRegularBody(context),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ─── AppBar ─────────────────────────────────────────────────────────────────
  Widget _buildAppBar(
    BuildContext context,
    double sw,
    double top,
    bool isAdmin,
    LoginViewModel loginVm,
    AccessViewModel accessVm,
  ) {
    return Consumer<ProfileViewmodel>(
      builder: (context, profileVm, _) {
        String firstName = '';
        String lastName = '';
        String email = loginVm.loggedInEmail ?? '';
        String profilePicture = '';

        if (profileVm.profileList.isNotEmpty) {
          final user = profileVm.profileList.first;
          firstName = user.firstName;
          lastName = user.lastName;
          if (email.isEmpty) email = user.emailId;
          profilePicture = user.profilePicture;
        }

        String name = '$firstName $lastName'.trim();
        if (name.isEmpty) name = loginVm.loggedInUsername ?? '';
        if (name.isEmpty) name = email.isNotEmpty ? email : 'User';

        String initials;
        if (firstName.isNotEmpty && lastName.isNotEmpty) {
          initials = '${firstName}${lastName}'.toUpperCase();
        } else if (firstName.isNotEmpty) {
          initials = firstName.toUpperCase();
        } else if (name.isNotEmpty) {
          initials = name.toUpperCase();
        } else {
          initials = 'U';
        }

        return Container(
          width: double.infinity,
          padding: EdgeInsets.only(
              top: top + 8, bottom: 12, left: sw * .035, right: sw * .035),
          decoration: const BoxDecoration(
            color: AppColors.white,
            border: Border(
                bottom: BorderSide(color: AppColors.cborder, width: 1.5)),
          ),
          child: Row(children: [
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                ),
                child: Row(children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.c1.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.c1.withOpacity(0.30),
                        width: 1.5,
                      ),
                    ),
                    child: ClipOval(
                      child: profilePicture.isNotEmpty
                          ? Image.network(profilePicture,
                              width: 38,
                              height: 38,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Center(
                                  child: Text(initials,
                                      style: const TextStyle(
                                          color: AppColors.cdark,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14))))
                          : Center(
                              child: Text(initials,
                                  style: const TextStyle(
                                      color: AppColors.cdark,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14))),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(children: [
                            Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                    color: Color(0xFF4CAF50),
                                    shape: BoxShape.circle)),
                            const SizedBox(width: 4),
                            if (isAdmin)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: AppColors.amber.withOpacity(.15),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                      color: AppColors.amber.withOpacity(.4)),
                                ),
                                child: const Text('ADMIN',
                                    style: TextStyle(
                                        color: AppColors.amber,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.8)),
                              )
                            else
                              const Text('Online',
                                  style: TextStyle(
                                      color: AppColors.ctext,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600)),
                          ]),
                          const SizedBox(height: 2),
                          Text(name,
                              style: const TextStyle(
                                  color: AppColors.cdark,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1),
                        ]),
                  ),
                ]),
              ),
            ),
            _iconBtn(
              accessVm.checkingIsLoggedIn
                  ? Icons.logout_rounded
                  : Icons.login_rounded,
              () => accessVm.checkingIsLoggedIn
                  ? showLogoutDialog(context)
                  : pushNavigation(context, const LoginScreen()),
              iconColor:
                  accessVm.checkingIsLoggedIn ? AppColors.tagRed : AppColors.c3,
              bgColor: accessVm.checkingIsLoggedIn
                  ? AppColors.tagRedBg
                  : AppColors.cxl,
            ),
          ]),
        );
      },
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap,
          {Color? iconColor, Color? bgColor}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
              color: bgColor ?? AppColors.cxl, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor ?? AppColors.c3, size: 17),
        ),
      );

  Widget _buildRegularBody(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _buildBanner(),
      const SizedBox(height: 8),
      _sectionLabel('STATS OVERVIEW'),
      const SizedBox(height: 5),
      _buildStats(context),
      const SizedBox(height: 10),
      _sectionLabel("TODAY'S ORGANIZER"),
      const SizedBox(height: 5),
      _buildPlanner(context),
      const SizedBox(height: 8),
      _sectionLabel('WORKSPACE'),
      const SizedBox(height: 6),
      _buildCardsGrid(context),
      const SizedBox(height: 8),
      _sectionLabel('QUICK ACCESS'),
      const SizedBox(height: 6),
      _buildQuickAccessRow(context),
      const SizedBox(height: 4),
    ]);
  }

  Widget _buildAdminBody(BuildContext context, LoginViewModel loginVm) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _buildAdminBanner(loginVm),
      const SizedBox(height: 10),
      _buildAdminLeadStats(context),
      const SizedBox(height: 10),
      _sectionLabel("TODAY'S ORGANIZER"),
      const SizedBox(height: 5),
      _buildPlanner(context),
      const SizedBox(height: 8),
      _sectionLabel('WORKSPACE'),
      const SizedBox(height: 6),
      _buildAdminCardsGrid(context),
      const SizedBox(height: 8),
      _sectionLabel('QUICK ACCESS'),
      const SizedBox(height: 6),
      _buildQuickAccessRow(context),
      const SizedBox(height: 4),
    ]);
  }

  Widget _sectionLabel(String text) => Text(text,
      style: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w800,
          color: AppColors.cdark,
          letterSpacing: 1.0));

  // ─── Banner ─────────────────────────────────────────────────────────────────
  Widget _buildBanner() => IntrinsicHeight(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: AppColors.cl,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.cborder),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('Manage',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: AppColors.cdark,
                            height: 1.22)),
                    Text('Marketing Status',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: AppColors.cdark,
                            height: 1.22)),
                  ]),
            ),
            const SizedBox(width: 10),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                  color: const Color(0x333BBCD9),
                  borderRadius: BorderRadius.circular(15)),
              child: const Icon(Icons.grid_view_rounded,
                  color: AppColors.c3, size: 27),
            ),
          ]),
        ),
      );

  Widget _buildAdminBanner(LoginViewModel loginVm) {
    final name = loginVm.loggedInUsername ?? loginVm.loggedInEmail ?? 'Admin';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.cl,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cborder),
      ),
      child: Row(children: [
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.amber.withOpacity(.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.amber.withOpacity(.40)),
              ),
              child: const Text('👑  ADMIN DASHBOARD',
                  style: TextStyle(
                      color: AppColors.amber,
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8)),
            ),
            const SizedBox(height: 6),
            Text('Welcome, $name',
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.cdark,
                    height: 1.2),
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 3),
            const Text('Full access -  Manage your team & pipeline',
                style: TextStyle(fontSize: 9, color: AppColors.ctext)),
          ]),
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
              color: AppColors.c1.withOpacity(.15),
              borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.admin_panel_settings_rounded,
              color: AppColors.c1, size: 22),
        ),
      ]),
    );
  }

  Widget _buildStats(BuildContext context) =>
      Consumer2<FollowupViewmodel, LeadViewmodel>(
        builder: (ctx, followupVm, lVM, _) {
          return Consumer<AllActivityViewModel>(
            builder: (ctx2, activityVm, _) {
              final items = [
                {
                  'label': 'Follow Up',
                  'value': '${followupVm.followups.length}',
                  'color': AppColors.c1,
                  'page': const FollowUp()
                },
                {
                  'label': 'Leads',
                  'value': '${lVM.leadList.length}',
                  'color': AppColors.c2,
                  'page': const LeadsNewScreen()
                },
                {
                  'label': 'Organizer',
                  'value': '${activityVm.activities.length}',
                  'color': AppColors.c3,
                  'page': const ActivityScreen()
                },
              ];

              return SizedBox(
                height: 72,
                child: Row(
                  children: List.generate(items.length, (i) {
                    final borderRadius = i.isEven
                        ? const BorderRadius.only(
                            topLeft: Radius.circular(14),
                            bottomRight: Radius.circular(14))
                        : const BorderRadius.only(
                            topRight: Radius.circular(14),
                            bottomLeft: Radius.circular(14));

                    return Expanded(
                      child: _StatTile(
                        value: items[i]['value'] as String,
                        label: items[i]['label'] as String,
                        color: items[i]['color'] as Color,
                        borderRadius: borderRadius,
                        margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => items[i]['page'] as Widget)),
                      ),
                    );
                  }),
                ),
              );
            },
          );
        },
      );

  Widget _buildAdminLeadStats(BuildContext context) {
    return Consumer<LeadViewmodel>(
      builder: (ctx, lVM, _) {
        final now = DateTime.now();
        final daily = lVM.leadList.where((l) {
          try {
            final d = DateTime.tryParse(l.createdAt);
            return d != null &&
                d.year == now.year &&
                d.month == now.month &&
                d.day == now.day;
          } catch (_) {
            return false;
          }
        }).toList();
        final weekStart = now.subtract(const Duration(days: 7));
        final weekly = lVM.leadList.where((l) {
          try {
            final d = DateTime.tryParse(l.createdAt);
            return d != null && d.isAfter(weekStart);
          } catch (_) {
            return false;
          }
        }).toList();
        final monthly = lVM.leadList.where((l) {
          try {
            final d = DateTime.tryParse(l.createdAt);
            return d != null && d.year == now.year && d.month == now.month;
          } catch (_) {
            return false;
          }
        }).toList();

        final stats = [
          {
            'label': 'Today',
            'count': daily.length,
            'leads': daily,
            'color': AppColors.c1
          },
          {
            'label': 'This Week',
            'count': weekly.length,
            'leads': weekly,
            'color': AppColors.c2
          },
          {
            'label': 'This Month',
            'count': monthly.length,
            'leads': monthly,
            'color': AppColors.c3
          },
        ];

        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _sectionLabel('LEAD OVERVIEW'),
          const SizedBox(height: 8),
          SizedBox(
            height: 78,
            child: Row(
              children: List.generate(stats.length, (i) {
                final borderRadius = i.isEven
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(14),
                        bottomRight: Radius.circular(14))
                    : const BorderRadius.only(
                        topRight: Radius.circular(14),
                        bottomLeft: Radius.circular(14));
                return Expanded(
                  child: GestureDetector(
                    onTap: () => _showLeadNamesSheet(context,
                        stats[i]['label'] as String, stats[i]['leads'] as List),
                    child: Container(
                      margin: EdgeInsets.only(right: i < 2 ? 7 : 0),
                      decoration: BoxDecoration(
                          color: stats[i]['color'] as Color,
                          borderRadius: borderRadius),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('${stats[i]['count']}',
                                style: const TextStyle(
                                    fontSize: 29,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.white)),
                            const SizedBox(height: 3),
                            Text(stats[i]['label'] as String,
                                style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.white.withOpacity(.9))),
                          ]),
                    ),
                  ),
                );
              }),
            ),
          ),
        ]);
      },
    );
  }

  void _showLeadNamesSheet(BuildContext context, String period, List leads) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height * .60),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 10),
            decoration: BoxDecoration(
                color: AppColors.cborder,
                borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: AppColors.cxl,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.cborder)),
                child: Text(period,
                    style: const TextStyle(
                        color: AppColors.c1,
                        fontSize: 12,
                        fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: 8),
              const Text('Leads',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.cdark)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: AppColors.cxl,
                    borderRadius: BorderRadius.circular(10)),
                child: Text('${leads.length}',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.cdark)),
              ),
            ]),
          ),
          const SizedBox(height: 10),
          const Divider(color: AppColors.cborder, height: 1),
          Flexible(
            child: leads.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.inbox_rounded,
                          size: 40, color: AppColors.cborder),
                      const SizedBox(height: 10),
                      Text('No leads for $period',
                          style: const TextStyle(
                              color: AppColors.ctext, fontSize: 13)),
                    ]),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    itemCount: leads.length,
                    separatorBuilder: (_, __) =>
                        const Divider(color: AppColors.cborder, height: 1),
                    itemBuilder: (_, i) {
                      final lead = leads[i];
                      String name = '', phone = '', status = '';
                      try {
                        name = (lead.name ?? '').toString();
                        phone = (lead.phone ?? '').toString();
                        status = (lead.status ?? '').toString();
                      } catch (_) {
                        if (lead is Map) {
                          name = lead['name']?.toString() ?? '';
                          phone = lead['phone']?.toString() ?? '';
                          status = lead['status']?.toString() ?? '';
                        }
                      }
                      final initials =
                          name.isNotEmpty ? name.toUpperCase() : 'L';
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        child: Row(children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                                color: AppColors.cxl, shape: BoxShape.circle),
                            child: Center(
                                child: Text(initials,
                                    style: const TextStyle(
                                        color: AppColors.c1,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14))),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(name.isEmpty ? 'Unknown' : name,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.cdark)),
                                  if (phone.isNotEmpty)
                                    Text(phone,
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.ctext)),
                                ]),
                          ),
                          if (status.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: status.toUpperCase() == 'CONVERTED'
                                    ? const Color(0xFF10B981).withOpacity(.12)
                                    : AppColors.cxl,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: status.toUpperCase() == 'CONVERTED'
                                        ? const Color(0xFF10B981)
                                            .withOpacity(.3)
                                        : AppColors.cborder),
                              ),
                              child: Text(status,
                                  style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: status.toUpperCase() == 'CONVERTED'
                                          ? const Color(0xFF10B981)
                                          : AppColors.c1)),
                            ),
                        ]),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 12),
        ]),
      ),
    );
  }

  Widget _buildPlanner(BuildContext context) {
    return Consumer<AllActivityViewModel>(
      builder: (ctx, vm, _) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final sorted = [...vm.activities]..sort((a, b) {
            try {
              return (b.dueDate as DateTime).compareTo(a.dueDate as DateTime);
            } catch (_) {
              return 0;
            }
          });
        final latest = sorted.take(4).toList();

        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: AppColors.cborder, width: 1.5),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4)),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(11, 10, 11, 9),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text("⚡ Today's Organizer",
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.cdark)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: AppColors.cl,
                    borderRadius: BorderRadius.circular(7)),
                child: Text(_todayDate(),
                    style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ctext)),
              ),
            ]),
            const SizedBox(height: 7),
            Row(children: [
              SizedBox(width: _kIconCol),
              const SizedBox(width: 6),
              const Expanded(
                child: Text('CLIENT',
                    style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF94A3B8),
                        letterSpacing: .5)),
              ),
              SizedBox(
                width: _kTimeCol,
                child: const Text('TIME',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF94A3B8),
                        letterSpacing: .5)),
              ),
              const SizedBox(width: 4),
              SizedBox(
                width: _kActionCol,
                child: const Text('ACTION',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF94A3B8),
                        letterSpacing: .5)),
              ),
            ]),
            const Divider(height: 9, thickness: .5, color: AppColors.cborder),
            if (vm.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Center(
                    child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 1.5, color: AppColors.c1))),
              )
            else if (latest.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(
                    child: Text('No activities yet',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ctext))),
              )
            else
              ..._buildPlannerRows(latest, today),
            const Divider(height: 9, thickness: .5, color: AppColors.cborder),
            const SizedBox(height: 2),
            GestureDetector(
              onTap: () => pushNavigation(context, const ActivityScreen()),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.c1,
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.c1.withOpacity(.30),
                        blurRadius: 10,
                        offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('View All Organizer',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.white)),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_forward_rounded,
                        size: 19, color: AppColors.white),
                  ],
                ),
              ),
            ),
          ]),
        );
      },
    );
  }

  String _todayDate() {
    final n = DateTime.now();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${n.day} ${months[n.month - 1]} ${n.year}';
  }

  List<Widget> _buildPlannerRows(List<dynamic> activities, DateTime today) {
    return activities.map((item) {
      final type = (item.activityType as String).toUpperCase();
      final status = (item.status as String).toUpperCase();
      final done = status == 'COMPLETED';
      final typeStyle = _typeStyleFor(type);

      final String tagLabel;
      final Color tagBg;
      final Color tagFg;
      if (status == 'COMPLETED') {
        tagLabel = 'Done';
        tagBg = AppColors.cxl;
        tagFg = AppColors.cdark;
      } else if (status == 'OVERDUE') {
        tagLabel = 'Overdue';
        tagBg = AppColors.tagRedBg;
        tagFg = AppColors.tagRed;
      } else {
        tagLabel = _typeLabel(type);
        tagBg = AppColors.tagGreenBg;
        tagFg = AppColors.tagGreen;
      }

      String timeStr = '--:--';
      try {
        final due = item.dueDate as DateTime;
        timeStr =
            '${due.hour.toString().padLeft(2, '0')}:${due.minute.toString().padLeft(2, '0')}';
      } catch (_) {}

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          SizedBox(
            width: _kIconCol,
            height: _kIconCol,
            child: Container(
              decoration: BoxDecoration(
                  color: typeStyle['bg'] as Color,
                  borderRadius: BorderRadius.circular(7)),
              child: Center(
                  child: Text(typeStyle['emoji'] as String,
                      style: const TextStyle(fontSize: 12))),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(item.title ?? '',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: done
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF334155),
                    decoration: done
                        ? TextDecoration.lineThrough
                        : TextDecoration.none),
                overflow: TextOverflow.ellipsis),
          ),
          SizedBox(
              width: _kTimeCol,
              child: Text(timeStr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ctext))),
          const SizedBox(width: 4),
          SizedBox(
            width: _kActionCol,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                  color: tagBg, borderRadius: BorderRadius.circular(6)),
              child: Text(tagLabel,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: tagFg)),
            ),
          ),
        ]),
      );
    }).toList();
  }

  Map<String, dynamic> _typeStyleFor(String type) {
    switch (type) {
      case 'MEETING':
        return {'emoji': '🎥', 'bg': AppColors.tagGreenBg};
      case 'CALL':
        return {'emoji': '📞', 'bg': AppColors.cxl};
      case 'EMAIL':
        return {'emoji': '✉️', 'bg': AppColors.cxl};
      case 'WHATSAPP':
        return {'emoji': '💬', 'bg': AppColors.tagGreenBg};
      case 'FOLLOW_UP':
        return {'emoji': '🔁', 'bg': AppColors.tagRedBg};
      case 'REMINDER':
        return {'emoji': '⏰', 'bg': AppColors.tagRedBg};
      default:
        return {'emoji': '📌', 'bg': AppColors.cgray};
    }
  }

  String _typeLabel(String type) {
    const m = {
      'MEETING': 'Meeting',
      'CALL': 'Call',
      'EMAIL': 'Email',
      'WHATSAPP': 'WhatsApp',
      'FOLLOW_UP': 'Follow-up',
      'REMINDER': 'Reminder'
    };
    return m[type] ?? type;
  }

  Widget _buildCardsGrid(BuildContext context) {
    final cards = _cards();

    return Consumer<CustomerViewmodel>(
      builder: (ctx, cVM, _) {
        return GridView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,

            // Square cards, slightly more compact grid
            childAspectRatio: 1.0,
          ),
          itemBuilder: (context, i) {
            final item = cards[i];

            return _AnimatedTile(
              delay: Duration(milliseconds: 60 + i * 50),
              child: _WorkspaceCard(
                title: item['title'] as String,
                icon: item['icon'] as IconData,
                color: item['color'] as Color,
                badge: (i == 0 && cVM.customerList.isNotEmpty)
                    ? '${cVM.customerList.length}'
                    : null,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => item['page'] as Widget,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAdminCardsGrid(BuildContext context) {
    final cards = _adminCards();

    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,

        // Square cards, slightly more compact grid
        childAspectRatio: 1.0,
      ),
      itemBuilder: (context, i) {
        final item = cards[i];

        return _AnimatedTile(
          delay: Duration(milliseconds: 60 + i * 50),
          child: _WorkspaceCard(
            title: item['title'] as String,
            icon: item['icon'] as IconData,
            color: item['color'] as Color,
            isAdminOnly: item['adminOnly'] as bool? ?? false,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => item['page'] as Widget,
              ),
            ),
          ),
        );
      },
    );
  }

  // ─── Quick Access: 4-per-row compact grid, icons/text kept full size ────────
  // Grid cell size is reduced (smaller tile footprint) but the icon chip
  // (38x38) and label font size stay exactly the same as before. If the
  // number of quick-access items isn't a multiple of 4, the leftover slots
  // in the last row are filled with blank "placeholder" tiles that show a
  // "Coming Soon" popup when tapped.
  Widget _buildQuickAccessRow(BuildContext context) {
    final chips = _quickChips();
    const int columns = 4;
    final int totalSlots = ((chips.length + columns - 1) ~/ columns) * columns;

    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: totalSlots,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        // Reduced cell footprint (smaller box); icon/text sizes inside
        // _QuickAccessSquare are also reduced slightly to match.
        childAspectRatio: 0.88,
      ),
      itemBuilder: (context, i) {
        if (i < chips.length) {
          final chip = chips[i];
          final useWA = chip['useWhatsApp'] as bool? ?? false;

          return _AnimatedTile(
            delay: Duration(milliseconds: 60 + i * 40),
            child: _QuickAccessSquare(
              label: chip['label'] as String,
              icon: chip['icon'] as IconData,
              bgColor: chip['bgColor'] as Color,
              iconColor: chip['iconColor'] as Color,
              useWhatsAppIcon: useWA,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => chip['page'] as Widget,
                ),
              ),
            ),
          );
        }

        // Empty slot — shows a small popup on tap.
        return _AnimatedTile(
          delay: Duration(milliseconds: 60 + i * 40),
          child: _QuickAccessPlaceholder(
            onTap: () => _showComingSoonPopup(context),
          ),
        );
      },
    );
  }

  void _showComingSoonPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        backgroundColor: AppColors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: AppColors.c1.withOpacity(.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  color: AppColors.c1, size: 26),
            ),
            const SizedBox(height: 14),
            const Text('Coming Soon',
                style: TextStyle(
                    color: AppColors.cdark,
                    fontSize: 16,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            const Text('This feature is on its way. Stay tuned!',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: AppColors.ctext, fontSize: 12.5, height: 1.4)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: () => Navigator.of(ctx).pop(),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.c1,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text('Got it',
                        style: TextStyle(
                            color: AppColors.white,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700)),
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

// ─── Stat Tile ────────────────────────────────────────────────────────────────
class _StatTile extends StatefulWidget {
  final String value;
  final String label;
  final Color color;
  final BorderRadius borderRadius;
  final EdgeInsets margin;
  final VoidCallback onTap;

  const _StatTile({
    required this.value,
    required this.label,
    required this.color,
    required this.borderRadius,
    required this.margin,
    required this.onTap,
  });

  @override
  State<_StatTile> createState() => _StatTileState();
}

class _StatTileState extends State<_StatTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 90),
        lowerBound: 0,
        upperBound: 1);
    _scale = Tween<double>(begin: 1.0, end: 0.94).animate(_ctrl);
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
          margin: widget.margin,
          height: 72,
          decoration: BoxDecoration(
              color: widget.color, borderRadius: widget.borderRadius),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(widget.value,
                style: const TextStyle(
                    fontSize: 29,
                    fontWeight: FontWeight.w900,
                    color: AppColors.white)),
            const SizedBox(height: 2),
            Text(widget.label,
                style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white.withOpacity(.9))),
          ]),
        ),
      ),
    );
  }
}

// ─── Workspace Card ── BOTIM-style flat soft-tint card ───────────────────────
class _WorkspaceCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String? badge;
  final bool isAdminOnly;
  final VoidCallback onTap;

  const _WorkspaceCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
    this.badge,
    this.isAdminOnly = false,
  });

  @override
  State<_WorkspaceCard> createState() => _WorkspaceCardState();
}

class _WorkspaceCardState extends State<_WorkspaceCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      lowerBound: 0,
      upperBound: 1,
    );

    _scale = Tween<double>(
      begin: 1.0,
      end: 0.94,
    ).animate(_ctrl);
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
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.cl,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: AppColors.cborder,
              width: 1.5,
            ),
          ),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            children: [
              if (widget.isAdminOnly)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 13,
                    height: 13,
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(.20),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        '👑',
                        style: TextStyle(fontSize: 6.5),
                      ),
                    ),
                  ),
                ),
              if (widget.badge != null)
                Positioned(
                  top: 6,
                  right: widget.isAdminOnly ? 22 : 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1.5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(.85),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      widget.badge!,
                      style: TextStyle(
                        fontSize: 7,
                        fontWeight: FontWeight.w800,
                        color: widget.color,
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 7, 7, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(.65),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Center(
                        child: Icon(
                          widget.icon,
                          color: widget.color,
                          size: 26,
                        ),
                      ),
                    ),
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.cdark,
                        height: 1.12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Quick Access Square — icon (42x42) and label font size are FIXED,      ──
// they never shrink even though the surrounding grid cell gets smaller.
class _QuickAccessSquare extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color bgColor;
  final Color iconColor;
  final bool useWhatsAppIcon;
  final VoidCallback onTap;

  const _QuickAccessSquare({
    required this.label,
    required this.icon,
    required this.bgColor,
    required this.iconColor,
    required this.onTap,
    this.useWhatsAppIcon = false,
  });

  @override
  State<_QuickAccessSquare> createState() => _QuickAccessSquareState();
}

class _QuickAccessSquareState extends State<_QuickAccessSquare>
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
    _scale = Tween<double>(begin: 1.0, end: 0.93).animate(_ctrl);
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
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.cl,
            borderRadius: BorderRadius.circular(13),
          ),
          // Reduced padding gives a smaller outer tile while the icon
          // chip / text below are also trimmed a touch to match.
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                    color: widget.bgColor,
                    borderRadius: BorderRadius.circular(12)),
                child: Center(
                  child: widget.useWhatsAppIcon
                      ? SvgPicture.string(_kWhatsAppSvg,
                          width: 25,
                          height: 25,
                          colorFilter: ColorFilter.mode(
                              widget.iconColor, BlendMode.srcIn))
                      : Icon(widget.icon, color: widget.iconColor, size: 25),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                widget.label,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.cdark,
                    height: 1.15),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Quick Access Placeholder — blank slot for incomplete rows ──────────────
// Shown when the number of quick-access items doesn't fill a full row of 4.
// Tapping it opens a small "Coming Soon" popup instead of navigating.
class _QuickAccessPlaceholder extends StatefulWidget {
  final VoidCallback onTap;
  const _QuickAccessPlaceholder({required this.onTap});

  @override
  State<_QuickAccessPlaceholder> createState() =>
      _QuickAccessPlaceholderState();
}

class _QuickAccessPlaceholderState extends State<_QuickAccessPlaceholder>
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
    _scale = Tween<double>(begin: 1.0, end: 0.93).animate(_ctrl);
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
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.cl.withOpacity(.5),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: AppColors.cborder,
              width: 1.2,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.cborder.withOpacity(.35),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child:
                      Icon(Icons.add_rounded, color: AppColors.ctext, size: 24),
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'More',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ctext,
                    height: 1.15),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Staggered tile animation ─────────────────────────────────────────────────
class _AnimatedTile extends StatefulWidget {
  final Widget child;
  final Duration delay;
  const _AnimatedTile({required this.child, required this.delay});
  @override
  State<_AnimatedTile> createState() => _AnimatedTileState();
}

class _AnimatedTileState extends State<_AnimatedTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 320));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, .08), end: Offset.zero)
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

  @override
  Widget build(BuildContext context) => FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child));
}