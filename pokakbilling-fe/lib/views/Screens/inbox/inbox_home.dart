import 'package:flutter/material.dart';
import 'package:pokakbilling/views/Screens/inbox/inbox_bottombar.dart';
import 'package:pokakbilling/views/bottom_bar/bottomNavigationBar/bottom_bar.dart';
import 'package:provider/provider.dart';

import 'package:pokakbilling/models/data-models/chat/chat_user.dart';
import 'package:pokakbilling/models/services/chat_room_service.dart';
import 'package:pokakbilling/viewmodels/chat_users_viewmodel.dart';
import 'package:pokakbilling/viewmodels/login_viewmodel.dart';
import 'package:pokakbilling/views/Screens/inbox/chat_room_screen.dart';
import 'package:pokakbilling/views/Screens/inbox/inbox.dart';

const Color _kAccent = Color(0xFF818CF8);
const Color _kPrimary = Color(0xFF6366F1);

class InboxHomeScreen extends StatefulWidget {
  const InboxHomeScreen({super.key});

  @override
  State<InboxHomeScreen> createState() => _InboxHomeScreenState();
}

class _InboxHomeScreenState extends State<InboxHomeScreen>
    with WidgetsBindingObserver {
  final TextEditingController _searchCtrl = TextEditingController();

  String? _currentEmail;
  int _currentId = 0;

  VoidCallback? _usersListener;
  VoidCallback? _loginListener;

  // ── Theme helpers ─────────────────────────────────────────────────────────
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _bg => Theme.of(context).scaffoldBackgroundColor;
  Color get _fg => _isDark ? Colors.white : const Color(0xFF1E1B4B);
  Color get _fgMuted => _isDark
      ? Colors.white.withValues(alpha: 0.5)
      : const Color(0xFF1E1B4B).withValues(alpha: 0.5);
  Color get _cardBg => _isDark ? Colors.white.withValues(alpha: 0.07) : Colors.white;
  Color get _cardBorder => _isDark
      ? Colors.white.withValues(alpha: 0.12)
      : const Color(0xFF6366F1).withValues(alpha: 0.12);
  Color get _searchBg => _isDark
      ? Colors.white.withValues(alpha: 0.08)
      : const Color(0xFF6366F1).withValues(alpha: 0.07);
  Color get _iconBg => _isDark
      ? Colors.white.withValues(alpha: 0.12)
      : const Color(0xFF6366F1).withValues(alpha: 0.10);
  Color get _iconColor => _isDark ? Colors.white : const Color(0xFF4338CA);

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final usersVM = context.read<ChatUsersViewModel>();
      final loginVM = context.read<LoginViewModel>();

      _loginListener = () {
        _resolveCurrentUser(loginVM, usersVM);
        if (mounted) setState(() {});
      };
      _usersListener = () {
        _resolveCurrentUser(loginVM, usersVM);
        if (mounted) setState(() {});
      };
      loginVM.addListener(_loginListener!);
      usersVM.addListener(_usersListener!);

      _searchCtrl.text = usersVM.query;
      _searchCtrl.addListener(() {
        if (mounted) {
          context.read<ChatUsersViewModel>().setQuery(_searchCtrl.text);
        }
      });

      // Try resolving immediately (covers case where data already loaded)
      _resolveCurrentUser(loginVM, usersVM);

      if (!usersVM.loading && usersVM.users.isEmpty) {
        await usersVM.fetch();
      } else {
        _resolveCurrentUser(loginVM, usersVM);
        if (mounted) setState(() {});
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final usersVM = context.read<ChatUsersViewModel>();
      final loginVM = context.read<LoginViewModel>();
      if (!usersVM.loading) {
        usersVM.fetch().then((_) {
          _resolveCurrentUser(loginVM, usersVM);
          if (mounted) setState(() {});
        });
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchCtrl.dispose();
    final usersVM = context.read<ChatUsersViewModel>();
    final loginVM = context.read<LoginViewModel>();
    if (_usersListener != null) usersVM.removeListener(_usersListener!);
    if (_loginListener != null) loginVM.removeListener(_loginListener!);
    super.dispose();
  }

  void _resolveCurrentUser(LoginViewModel loginVM, ChatUsersViewModel usersVM) {
    final loggedEmail = loginVM.loggedInEmail?.trim().toLowerCase();
    if (loggedEmail == null || loggedEmail.isEmpty) return;
    if (usersVM.users.isEmpty) return;
    final me = usersVM.users.firstWhere(
      (u) => u.email.trim().toLowerCase() == loggedEmail,
      orElse: () => ChatUser(id: 0, email: ''),
    );
    if (me.id != 0) {
      _currentEmail = loggedEmail;
      _currentId = me.id;
    }
  }

  Future<void> _openChatForUser(ChatUser user) async {
    if (_currentId == 0) {
      _resolveCurrentUser(
          context.read<LoginViewModel>(), context.read<ChatUsersViewModel>());
    }
    if (_currentId == 0) {
      await Future.delayed(const Duration(milliseconds: 400));
      if (mounted) {
        _resolveCurrentUser(
            context.read<LoginViewModel>(), context.read<ChatUsersViewModel>());
      }
    }
    if (_currentId == 0 || !mounted) return;

    try {
      final room = await ChatRoomService.createOrGetOneToOne(
        currentUserId: _currentId,
        peerUserId: user.id,
      );
      final email = user.email;
      final userName = email.split('@').first;
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatRoomScreen(
            roomId: room.id,
            userEmail: email,
            userName: userName,
            currentUserId: _currentId,
          ),
        ),
      );
      if (mounted) {
        final usersVM = context.read<ChatUsersViewModel>();
        final loginVM = context.read<LoginViewModel>();
        await usersVM.fetch();
        _resolveCurrentUser(loginVM, usersVM);
        if (mounted) setState(() {});
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to open chat: $e')));
    }
  }

  Future<void> _submitSearch() async =>
      context.read<ChatUsersViewModel>().fetch(search: _searchCtrl.text.trim());

  // ── User row card (unchanged) ─────────────────────────────────────────────
  Widget _userRow(ChatUser user) {
    final email = user.email;
    final initial = (email.isNotEmpty ? email[0] : 'U').toUpperCase();
    final userName = email.split('@').first;

    return GestureDetector(
      onTap: () => _openChatForUser(user),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _cardBorder, width: 1),
        ),
        child: Row(children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _kAccent.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(initial,
                style: const TextStyle(
                    color: _kAccent,
                    fontSize: 17,
                    fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userName,
                    style: TextStyle(
                        color: _fg, fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(email,
                    style: TextStyle(color: _fgMuted, fontSize: 12),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: _fgMuted, size: 20),
        ]),
      ),
    );
  }

  // ── Body ──────────────────────────────────────────────────────────────────
  Widget _body() {
    return Consumer2<LoginViewModel, ChatUsersViewModel>(
      builder: (context, loginVM, vm, _) {
        _resolveCurrentUser(loginVM, vm);

        if (vm.loading) {
          return const Center(child: CircularProgressIndicator(color: _kAccent));
        }
        if (vm.error != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(vm.error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFFEF4444))),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => vm.fetch(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: _kAccent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('Retry',
                          style: TextStyle(
                              color: _kAccent, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final myEmail = _currentEmail;
        final filtered = vm.users
            .where((u) =>
                myEmail == null ||
                myEmail.isEmpty ||
                u.email.trim().toLowerCase() != myEmail)
            .toList();

        if (filtered.isEmpty) {
          return Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: _cardBg,
                  shape: BoxShape.circle,
                  border: Border.all(color: _cardBorder),
                ),
                child: Icon(Icons.people_outline, color: _fgMuted, size: 28),
              ),
              const SizedBox(height: 14),
              Text('No users found.',
                  style: TextStyle(
                      color: _fg, fontSize: 14, fontWeight: FontWeight.w600)),
            ]),
          );
        }

        return RefreshIndicator(
          color: _kAccent,
          onRefresh: () => vm.fetch(),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.only(bottom: 100, top: 4),
            itemCount: filtered.length,
            itemBuilder: (_, i) => _userRow(filtered[i]),
          ),
        );
      },
    );
  }

  // ── BUILD (unchanged) ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      bottomNavigationBar: InboxBottomBar(
        activeIndex: 2,
        onTapHome: () => Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const ErpBottomBar(index: 0)),
          (route) => false,
        ),
        onTapInbox: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const InboxScreen()),
        ),
        onTapAllContacts: () {},
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: _bg,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ErpBottomBar(index: 0)),
                    (route) => false,
                  ),
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
                  child: Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: _searchBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _cardBorder, width: 1),
                    ),
                    child: Row(children: [
                      Icon(Icons.search, color: _fgMuted, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchCtrl,
                          style: TextStyle(color: _fg, fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Search staff…',
                            hintStyle: TextStyle(color: _fgMuted, fontSize: 13),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 10),
                          ),
                          textInputAction: TextInputAction.search,
                          onSubmitted: (_) => _submitSearch(),
                        ),
                      ),
                      if (_searchCtrl.text.isNotEmpty)
                        GestureDetector(
                          onTap: () async {
                            _searchCtrl.clear();
                            await context.read<ChatUsersViewModel>().clearAll();
                          },
                          child: Icon(Icons.close, color: _fgMuted, size: 16),
                        ),
                    ]),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF818CF8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Icon(Icons.people_rounded,
                        color: Colors.white, size: 18),
                  ),
                ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 4),
              child: Row(children: [
                Container(
                  width: 3,
                  height: 14,
                  decoration: BoxDecoration(
                      color: _kAccent, borderRadius: BorderRadius.circular(3)),
                ),
                const SizedBox(width: 7),
                Text('All Staffs',
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w800, color: _fg)),
              ]),
            ),
            Expanded(child: _body()),
          ],
        ),
      ),
    );
  }
}
