import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/models/data-models/chat/chat_inbox_item.dart';
import 'package:pokakbilling/models/data-models/chat/chat_user.dart';
import 'package:pokakbilling/viewmodels/chat_users_viewmodel.dart';
import 'package:pokakbilling/viewmodels/chat_viewmodel.dart';
import 'package:pokakbilling/viewmodels/login_viewmodel.dart';
import 'package:pokakbilling/views/Screens/inbox/chat_room_screen.dart';
import 'package:pokakbilling/views/bottom_bar/bottomNavigationBar/bottom_bar.dart';

// ─── In-memory pin store (session-scoped, no backend needed) ─────────────────
class _PinnedStore {
  static final Set<int> _pinned = {};
  static bool isPinned(int id) => _pinned.contains(id);
  static void toggle(int id) =>
      _pinned.contains(id) ? _pinned.remove(id) : _pinned.add(id);
}

// ─── Helper: derive display name from email ───────────────────────────────────
// e.g. "john.doe@company.com" → "John"
String _nameFromEmail(String email) {
  final local = email.split('@').first; // "john.doe"
  final first = local.split(RegExp(r'[._\-]')).first; // "john"
  if (first.isEmpty) return local;
  return first[0].toUpperCase() + first.substring(1).toLowerCase();
}

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final TextEditingController _searchCtrl = TextEditingController();
  int _currentUserId = 0;
  String _currentUserEmail = '';
  bool _bootstrapped = false;
  int _tab = 0; // 0=All, 1=Direct, 2=Groups

  late AnimationController _hCtrl, _bCtrl;
  late Animation<double> _hFade, _bFade;
  late Animation<Offset> _hSlide, _bSlide;

  VoidCallback? _loginListener;
  VoidCallback? _usersListener;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _hCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _hFade = CurvedAnimation(parent: _hCtrl, curve: Curves.easeOut);
    _hSlide = Tween<Offset>(begin: const Offset(0, -0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: _hCtrl, curve: Curves.easeOut));

    _bCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _bFade = CurvedAnimation(parent: _bCtrl, curve: Curves.easeOut);
    _bSlide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _bCtrl, curve: Curves.easeOut));

    _hCtrl.forward();
    Future.delayed(const Duration(milliseconds: 180), () {
      if (mounted) _bCtrl.forward();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _initLoad());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _reloadInbox(silent: true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchCtrl.dispose();
    _hCtrl.dispose();
    _bCtrl.dispose();
    if (_loginListener != null) {
      context.read<LoginViewModel>().removeListener(_loginListener!);
    }
    if (_usersListener != null) {
      context.read<ChatUsersViewModel>().removeListener(_usersListener!);
    }
    context.read<ChatInboxViewModel>().stopPolling();
    super.dispose();
  }

  // ── Init ──────────────────────────────────────────────────────────────────
  Future<void> _initLoad() async {
    if (!mounted) return;
    final loginVM = context.read<LoginViewModel>();
    final usersVM = context.read<ChatUsersViewModel>();

    _loginListener = () {
      if (mounted) _tryBootstrap();
    };
    _usersListener = () {
      if (mounted) _tryBootstrap();
    };
    loginVM.addListener(_loginListener!);
    usersVM.addListener(_usersListener!);

    if (usersVM.users.isEmpty && !usersVM.loading) {
      await usersVM.fetch();
    }
    _tryBootstrap();
  }

  Future<void> _tryBootstrap() async {
    if (_bootstrapped || !mounted) return;

    final loginVM = context.read<LoginViewModel>();
    final usersVM = context.read<ChatUsersViewModel>();
    _resolveCurrentUser(loginVM, usersVM);
    if (_currentUserId == 0) return;

    _bootstrapped = true;

    final inboxVM = context.read<ChatInboxViewModel>();
    _searchCtrl.text = inboxVM.query;
    _searchCtrl.addListener(() {
      if (mounted) {
        context.read<ChatInboxViewModel>().setQuery(_searchCtrl.text);
      }
    });

    await _reloadInbox();
    if (!mounted) return;
    inboxVM.startPolling(intervalSeconds: 8);
    setState(() {});
  }

  void _resolveCurrentUser(LoginViewModel loginVM, ChatUsersViewModel usersVM) {
    final email = loginVM.loggedInEmail?.trim().toLowerCase();
    if (email == null || email.isEmpty) return;
    _currentUserEmail = email;
    if (usersVM.users.isEmpty) return;
    final me = usersVM.users.firstWhere(
      (u) => u.email.trim().toLowerCase() == email,
      orElse: () => ChatUser(id: 0, email: ''),
    );
    if (me.id != 0 && mounted) {
      setState(() => _currentUserId = me.id);
    }
  }

  Future<void> _reloadInbox({bool silent = false}) async {
    if (_currentUserId == 0) return;
    await context
        .read<ChatInboxViewModel>()
        .fetchFor(_currentUserId, silent: silent);
  }

  // ── Pin / unpin ───────────────────────────────────────────────────────────
  void _togglePin(ChatInboxItem item) {
    final wasPinned = _PinnedStore.isPinned(item.id);
    _PinnedStore.toggle(item.id);
    setState(() {});
    _showPinSnackbar(!wasPinned);
  }

  void _showPinSnackbar(bool pinned) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        backgroundColor: AppColors.cdark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 2),
        content: Row(children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: AppColors.c1.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              pinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
              color: AppColors.c1,
              size: 15,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            pinned ? 'Chat pinned' : 'Chat unpinned',
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ]),
      ),
    );
  }

  // ── Open chat room ────────────────────────────────────────────────────────
  Future<void> _openChatRoom(ChatInboxItem item) async {
    if (_currentUserId == 0) {
      _resolveCurrentUser(
          context.read<LoginViewModel>(), context.read<ChatUsersViewModel>());
      if (_currentUserId == 0) return;
    }

    context.read<ChatInboxViewModel>().markRoomAsRead(item.id);

    // Resolve display name: look up in users list, fall back to email prefix
    final usersVM = context.read<ChatUsersViewModel>();
    final matchedUser = usersVM.users.cast<ChatUser?>().firstWhere(
          (u) => u!.email.toLowerCase() == item.email.toLowerCase(),
          orElse: () => null,
        );
    final displayName = matchedUser != null
        ? _nameFromEmail(matchedUser.email)
        : _nameFromEmail(item.email);

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatRoomScreen(
          userName: displayName,
          userEmail: item.email,
          roomId: item.id,
          currentUserId: _currentUserId,
          otherUserId: matchedUser?.id,
        ),
      ),
    );

    await _reloadInbox(silent: true);
  }

  // ── New DM sheet (shows ALL users) ───────────────────────────────────────
  void _showNewDmSheet() {
    final usersVM = context.read<ChatUsersViewModel>();
    if (usersVM.users.isEmpty && !usersVM.loading) usersVM.fetch();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) {
        return StatefulBuilder(builder: (ctx, setSheetState) {
          return Container(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * .75),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(32)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.c1.withValues(alpha: .15),
                  blurRadius: 40,
                  offset: const Offset(0, -8),
                ),
              ],
            ),
            child: Column(children: [
              // Handle
              Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(top: 14, bottom: 20),
                decoration: BoxDecoration(
                    color: AppColors.cborder,
                    borderRadius: BorderRadius.circular(2)),
              ),
              // Title row
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 16, 16),
                child: Row(children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.c1.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.person_add_rounded,
                        color: AppColors.c1, size: 18),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('New Message',
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.cdark,
                              letterSpacing: -0.3)),
                      Text('Choose someone to message',
                          style:
                              TextStyle(fontSize: 12, color: AppColors.ctext)),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(sheetCtx),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                          color: AppColors.cxl, shape: BoxShape.circle),
                      child: const Icon(Icons.close_rounded,
                          color: AppColors.ctext, size: 16),
                    ),
                  ),
                ]),
              ),
              Divider(height: 1, color: AppColors.cborder.withValues(alpha: .6)),
              // User list
              Expanded(
                child: Consumer<ChatUsersViewModel>(
                  builder: (ctx, vm, _) {
                    if (vm.loading) {
                      return const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.c1, strokeWidth: 2));
                    }

                    // Filter out self
                    final users = vm.users.where((u) {
                      if (_currentUserEmail.isNotEmpty &&
                          u.email.trim().toLowerCase() == _currentUserEmail) {
                        return false;
                      }
                      if (_currentUserId != 0 && u.id == _currentUserId) {
                        return false;
                      }
                      return true;
                    }).toList();

                    if (users.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline_rounded,
                                color: AppColors.c1.withValues(alpha: .3), size: 48),
                            const SizedBox(height: 12),
                            const Text('No users found',
                                style: TextStyle(
                                    color: AppColors.ctext, fontSize: 14)),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: users.length,
                      itemBuilder: (ctx, i) {
                        final user = users[i];
                        return _UserTile(
                          user: user,
                          displayName: _nameFromEmail(user.email),
                          onTap: () async {
                            Navigator.pop(sheetCtx);

                            // Check if a room already exists for this user
                            final inboxVM = context.read<ChatInboxViewModel>();
                            final existing =
                                inboxVM.items.cast<ChatInboxItem?>().firstWhere(
                                      (item) =>
                                          item!.email.toLowerCase() ==
                                          user.email.toLowerCase(),
                                      orElse: () => null,
                                    );

                            if (existing != null) {
                              await _openChatRoom(existing);
                            } else {
                              // No existing room: open with roomId=0,
                              // ChatRoomScreen creates it on first send
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatRoomScreen(
                                    userName: _nameFromEmail(user.email),
                                    userEmail: user.email,
                                    roomId: 0,
                                    currentUserId: _currentUserId,
                                    otherUserId: user.id, // ← added
                                  ),
                                ),
                              );
                              await _reloadInbox(silent: true);
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ]),
          );
        });
      },
    );
  }

  // ── Options sheet (✏️ FAB) ────────────────────────────────────────────────
  // ── Options sheet (✏️ FAB) ────────────────────────────────────────────────
  void _showOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: AppColors.c1.withValues(alpha: .12),
              blurRadius: 40,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                    color: AppColors.cborder,
                    borderRadius: BorderRadius.circular(2)),
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text('Create',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.cdark,
                          letterSpacing: -0.5)),
                ),
              ),
              _SheetOptionCard(
                icon: Icons.chat_bubble_rounded,
                label: 'New Message',
                sub: 'Start a direct conversation',
                color: AppColors.c1,
                onTap: () {
                  Navigator.pop(context);
                  _showNewDmSheet();
                },
              ),
              // ── "New Group" option — hidden for now ──────────────────────
              // const SizedBox(height: 10),
              // _SheetOptionCard(
              //   icon: Icons.group_rounded,
              //   label: 'New Group',
              //   sub: 'Create a group chat',
              //   color: AppColors.c2,
              //   onTap: () {
              //     Navigator.pop(context);
              //     ScaffoldMessenger.of(context).showSnackBar(
              //       SnackBar(
              //         behavior: SnackBarBehavior.floating,
              //         margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              //         backgroundColor: AppColors.cdark,
              //         shape: RoundedRectangleBorder(
              //             borderRadius: BorderRadius.circular(16)),
              //         content: const Text('Group chats coming soon',
              //             style: TextStyle(color: AppColors.white)),
              //       ),
              //     );
              //   },
              // ),
              const SizedBox(height: 8),
            ]),
          ),
        ),
      ),
    );
  }

  // ── Timestamp ─────────────────────────────────────────────────────────────
  String _formatLastAt(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    final isToday =
        dt.year == now.year && dt.month == now.month && dt.day == now.day;
    if (isToday) return DateFormat('HH:mm').format(dt);
    if (dt.year == now.year) return DateFormat('MMM d').format(dt);
    return DateFormat('dd/MM/yy').format(dt);
  }

  // ── Tab filter ────────────────────────────────────────────────────────────
  // All/Direct both show messaged items (ERP has DMs only).
  // Groups shows empty until backend supports it.
  List<ChatInboxItem> _filtered(List<ChatInboxItem> items) {
    if (_tab == 2) return [];
    return items; // tab 0 = All, tab 1 = Direct — same data for now
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(children: [
        FadeTransition(
          opacity: _hFade,
          child: SlideTransition(
            position: _hSlide,
            child: _buildHeader(mq.padding.top, mq.size.width),
          ),
        ),
        Expanded(
          child: FadeTransition(
            opacity: _bFade,
            child: SlideTransition(
              position: _bSlide,
              child: Column(children: [
                _buildTabs(),
                // Error banner
                Consumer<ChatInboxViewModel>(
                  builder: (_, vm, __) {
                    if (vm.error == null || vm.items.isNotEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Container(
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.red.withValues(alpha: .08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: AppColors.red.withValues(alpha: .25), width: 1),
                      ),
                      child: Row(children: [
                        const Icon(Icons.wifi_off_rounded,
                            color: AppColors.red, size: 16),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text('Could not load. Tap retry.',
                              style: TextStyle(
                                  color: AppColors.ctext, fontSize: 12)),
                        ),
                        GestureDetector(
                          onTap: _reloadInbox,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.c1,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text('Retry',
                                style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ]),
                    );
                  },
                ),
                Expanded(child: _buildBody()),
              ]),
            ),
          ),
        ),
      ]),
      floatingActionButton: _AnimatedFab(onTap: _showOptions),
    );
  }

  // ── HEADER ────────────────────────────────────────────────────────────────
  Widget _buildHeader(double topPad, double sw) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
          top: topPad + 16, bottom: 16, left: sw * .05, right: sw * .05),
      color: AppColors.white,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          GestureDetector(
            onTap: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const ErpBottomBar(index: 0)),
              (route) => false,
            ),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.cxl,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cborder, width: 1.2),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppColors.c3, size: 14),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Text('Inbox',
                    style: TextStyle(
                        color: AppColors.cdark,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.8)),
                const SizedBox(width: 10),
                Consumer<ChatInboxViewModel>(
                  builder: (_, vm, __) {
                    final unread =
                        vm.items.fold<int>(0, (s, i) => s + i.unreadCount);
                    if (unread == 0) return const SizedBox.shrink();
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.c1,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('$unread',
                          style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800)),
                    );
                  },
                ),
              ]),
              const Text('Internal Chat',
                  style: TextStyle(color: AppColors.ctext, fontSize: 12)),
            ]),
          ),
          GestureDetector(
            onTap: () => _reloadInbox(),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.cxl,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cborder, width: 1.2),
              ),
              child: const Icon(Icons.refresh_rounded,
                  color: AppColors.c3, size: 18),
            ),
          ),
        ]),
        const SizedBox(height: 18),
        // Search bar
        Container(
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.cxl,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cborder, width: 1.2),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(children: [
            Icon(Icons.search_rounded,
                color: AppColors.ctext.withValues(alpha: .5), size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                style: const TextStyle(fontSize: 13.5, color: AppColors.ctext),
                decoration: InputDecoration(
                  hintText: 'Search conversations…',
                  hintStyle: TextStyle(
                      color: AppColors.ctext.withValues(alpha: .4), fontSize: 13.5),
                  border: InputBorder.none,
                  isCollapsed: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            if (_searchCtrl.text.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchCtrl.clear();
                  context.read<ChatInboxViewModel>().clearQuery();
                },
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.ctext.withValues(alpha: .15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close_rounded,
                      size: 12, color: AppColors.ctext.withValues(alpha: .7)),
                ),
              ),
          ]),
        ),
      ]),
    );
  }

  // ── TABS ──────────────────────────────────────────────────────────────────
  Widget _buildTabs() {
    const labels = ['All', 'Direct', 'Groups'];
    const icons = [
      Icons.all_inbox_rounded,
      Icons.person_rounded,
      Icons.group_rounded,
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: Row(
        children: List.generate(3, (i) {
          final active = _tab == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _tab = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                height: 40,
                margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                decoration: BoxDecoration(
                  color: active ? AppColors.c1 : AppColors.cxl,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: active ? AppColors.c1 : AppColors.cborder,
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icons[i],
                        size: 14,
                        color: active
                            ? AppColors.white
                            : AppColors.ctext.withValues(alpha: .5)),
                    const SizedBox(width: 6),
                    Text(labels[i],
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight:
                                active ? FontWeight.w700 : FontWeight.w500,
                            color: active
                                ? AppColors.white
                                : AppColors.ctext.withValues(alpha: .5))),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── BODY / LIST ───────────────────────────────────────────────────────────
  Widget _buildBody() {
    return Consumer2<ChatInboxViewModel, ChatUsersViewModel>(
      builder: (_, inboxVM, usersVM, __) {
        if (_currentUserId == 0) {
          return Center(
            child: SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                  strokeWidth: 2.5, color: AppColors.c1.withValues(alpha: 0.6)),
            ),
          );
        }

        if (inboxVM.loading && inboxVM.items.isEmpty) {
          return const Center(
              child: CircularProgressIndicator(
                  color: AppColors.c1, strokeWidth: 2.5));
        }

        final filtered = _filtered(inboxVM.items);

        if (filtered.isEmpty) {
          return _buildEmpty(inboxVM.query.trim().isEmpty
              ? (_tab == 2 ? 'No group chats yet' : 'No conversations yet')
              : 'No matches for "${inboxVM.query}"');
        }

        // Build email→name map from users list for name resolution
        final nameMap = <String, String>{
          for (final u in usersVM.users)
            u.email.toLowerCase(): _nameFromEmail(u.email),
        };

        // Split pinned vs unpinned
        final pinned =
            filtered.where((c) => _PinnedStore.isPinned(c.id)).toList();
        final unpinned =
            filtered.where((c) => !_PinnedStore.isPinned(c.id)).toList();
        final sorted = [...pinned, ...unpinned];

        return RefreshIndicator(
          color: AppColors.c1,
          onRefresh: _reloadInbox,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.fromLTRB(0, 4, 0, 100),
            itemCount: sorted.length + (pinned.isNotEmpty ? 1 : 0),
            itemBuilder: (_, i) {
              // Pinned section header
              if (pinned.isNotEmpty && i == 0) {
                return const _SectionHeader(
                    icon: Icons.push_pin_rounded, label: 'Pinned');
              }

              final convIndex = pinned.isNotEmpty ? i - 1 : i;
              final item = sorted[convIndex];
              final isPinned = _PinnedStore.isPinned(item.id);

              final showAllHeader = pinned.isNotEmpty &&
                  convIndex == pinned.length &&
                  unpinned.isNotEmpty;

              // Resolve display name
              final displayName = nameMap[item.email.toLowerCase()] ??
                  _nameFromEmail(item.email);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showAllHeader)
                    const _SectionHeader(
                        icon: Icons.chat_bubble_outline_rounded,
                        label: 'All Chats'),
                  _ConvTile(
                    key: ValueKey(item.id),
                    item: item,
                    displayName: displayName,
                    isPinned: isPinned,
                    timeStr: _formatLastAt(item.lastAt),
                    delay: Duration(milliseconds: 30 + convIndex * 35),
                    onTap: () => _openChatRoom(item),
                    onPinToggle: () => _togglePin(item),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  // ── EMPTY STATE ───────────────────────────────────────────────────────────
  Widget _buildEmpty(String msg) => Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.c1.withValues(alpha: .08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.mark_chat_unread_outlined,
                color: AppColors.c1.withValues(alpha: .6), size: 36),
          ),
          const SizedBox(height: 20),
          Text(msg,
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.cdark,
                  letterSpacing: -0.3)),
          const SizedBox(height: 8),
          Text('Tap ✏️ below to start chatting',
              style: TextStyle(
                  fontSize: 13, color: AppColors.ctext.withValues(alpha: .7))),
        ]),
      );
}

// ─── Section header ───────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SectionHeader({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 4),
      child: Row(children: [
        Icon(icon, size: 12, color: AppColors.c1.withValues(alpha: .6)),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.c1.withValues(alpha: .6),
              letterSpacing: 0.4,
            )),
        const SizedBox(width: 8),
        Expanded(
            child: Divider(height: 1, color: AppColors.c1.withValues(alpha: .12))),
      ]),
    );
  }
}

// ─── Animated FAB ─────────────────────────────────────────────────────────────
class _AnimatedFab extends StatefulWidget {
  final VoidCallback onTap;
  const _AnimatedFab({required this.onTap});

  @override
  State<_AnimatedFab> createState() => _AnimatedFabState();
}

class _AnimatedFabState extends State<_AnimatedFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1.0, end: 0.92)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
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
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: AppColors.c1,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.c1.withValues(alpha: .45),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child:
              const Icon(Icons.edit_rounded, color: AppColors.white, size: 22),
        ),
      ),
    );
  }
}

// ─── User tile in New Message sheet ──────────────────────────────────────────
class _UserTile extends StatelessWidget {
  final ChatUser user;
  final String displayName;
  final VoidCallback onTap;

  const _UserTile({
    required this.user,
    required this.displayName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.cxl,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cborder, width: 1),
        ),
        child: Row(children: [
          // Avatar
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.c1, AppColors.c3],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(initial,
                style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(displayName,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.cdark)),
                Text(user.email,
                    style: TextStyle(
                        fontSize: 11, color: AppColors.ctext.withValues(alpha: .7))),
              ],
            ),
          ),
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: AppColors.c1.withValues(alpha: .1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_forward_ios_rounded,
                size: 12, color: AppColors.c1),
          ),
        ]),
      ),
    );
  }
}

// ─── Sheet option card ────────────────────────────────────────────────────────
class _SheetOptionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  final Color color;
  final VoidCallback onTap;

  const _SheetOptionCard({
    required this.icon,
    required this.label,
    required this.sub,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .06),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: .18), width: 1),
        ),
        child: Row(children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.cdark)),
                const SizedBox(height: 2),
                Text(sub,
                    style: TextStyle(
                        fontSize: 12, color: AppColors.ctext.withValues(alpha: .7))),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded,
              color: color.withValues(alpha: .6), size: 22),
        ]),
      ),
    );
  }
}

// ─── Conversation tile ────────────────────────────────────────────────────────
class _ConvTile extends StatefulWidget {
  final ChatInboxItem item;
  final String displayName; // resolved first name
  final bool isPinned;
  final String timeStr;
  final Duration delay;
  final VoidCallback onTap;
  final VoidCallback onPinToggle;

  const _ConvTile({
    super.key,
    required this.item,
    required this.displayName,
    required this.isPinned,
    required this.timeStr,
    required this.delay,
    required this.onTap,
    required this.onPinToggle,
  });

  @override
  State<_ConvTile> createState() => _ConvTileState();
}

class _ConvTileState extends State<_ConvTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(.03, 0), end: Offset.zero)
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
  Widget build(BuildContext context) {
    final item = widget.item;
    final name = widget.displayName;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
    final hasUnread = item.unreadCount > 0;
    final isPinned = widget.isPinned;
    final lastMsg =
        (item.lastText ?? '').isNotEmpty ? item.lastText! : item.email;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) {
            setState(() => _pressed = false);
            widget.onTap();
          },
          onTapCancel: () => setState(() => _pressed = false),
          onLongPress: widget.onPinToggle, // long press = pin
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: _pressed
                  ? AppColors.c1.withValues(alpha: .05)
                  : isPinned
                      ? AppColors.c1.withValues(alpha: .06)
                      : hasUnread
                          ? AppColors.c1.withValues(alpha: .04)
                          : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isPinned
                    ? AppColors.c1.withValues(alpha: .18)
                    : hasUnread
                        ? AppColors.c1.withValues(alpha: .12)
                        : Colors.transparent,
                width: 1,
              ),
            ),
            child: Row(children: [
              // Avatar with unread dot
              Stack(children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.c1, AppColors.c3],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(initial,
                        style: const TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 20)),
                  ),
                ),
                if (hasUnread)
                  Positioned(
                    right: 1,
                    top: 1,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.c1,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.white, width: 2),
                      ),
                    ),
                  ),
              ]),
              const SizedBox(width: 14),
              // Content
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        if (isPinned) ...[
                          const Icon(Icons.push_pin_rounded,
                              size: 11, color: AppColors.c1),
                          const SizedBox(width: 4),
                        ],
                        Expanded(
                          child: Text(name,
                              style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: (hasUnread || isPinned)
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                  color: (hasUnread || isPinned)
                                      ? AppColors.cdark
                                      : AppColors.ctext,
                                  letterSpacing: -0.2),
                              overflow: TextOverflow.ellipsis),
                        ),
                        if (widget.timeStr.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text(widget.timeStr,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: hasUnread
                                      ? AppColors.c1
                                      : AppColors.ctext.withValues(alpha: .5),
                                  fontWeight: hasUnread
                                      ? FontWeight.w700
                                      : FontWeight.w400)),
                        ],
                      ]),
                      const SizedBox(height: 4),
                      Row(children: [
                        Expanded(
                          child: Text(lastMsg,
                              style: TextStyle(
                                  fontSize: 12.5,
                                  color: hasUnread
                                      ? AppColors.ctext
                                      : AppColors.ctext.withValues(alpha: .55),
                                  fontWeight: hasUnread
                                      ? FontWeight.w500
                                      : FontWeight.w400),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1),
                        ),
                        if (hasUnread) ...[
                          const SizedBox(width: 8),
                          Container(
                            constraints: const BoxConstraints(minWidth: 20),
                            height: 20,
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                              color: AppColors.c1,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                  item.unreadCount > 99
                                      ? '99+'
                                      : '${item.unreadCount}',
                                  style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.white)),
                            ),
                          ),
                        ],
                      ]),
                    ]),
              ),
              const SizedBox(width: 8),
              // Pin button (tap to pin, long press on tile also pins)
              GestureDetector(
                onTap: widget.onPinToggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isPinned
                        ? AppColors.c1.withValues(alpha: .14)
                        : AppColors.cxl,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isPinned
                          ? AppColors.c1.withValues(alpha: .30)
                          : AppColors.cborder,
                      width: 1.2,
                    ),
                  ),
                  child: Icon(
                    isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                    size: 14,
                    color: isPinned ? AppColors.c1 : AppColors.c3,
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
