import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/models/data-models/chat/chat_data.dart';
import 'package:provider/provider.dart';
import 'package:pokakbilling/viewmodels/chat_viewmodel.dart';
import 'package:pokakbilling/viewmodels/login_viewmodel.dart';
import 'package:pokakbilling/views/Screens/inbox/chat_screen.dart';
import 'package:pokakbilling/views/Screens/inbox/chat_widgets.dart';
import 'package:pokakbilling/views/Screens/inbox/createGroupscreen.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen>
    with TickerProviderStateMixin {
  late final AnimationController _hCtrl, _bCtrl;
  late final Animation<double> _hFade, _bFade;
  late final Animation<Offset> _hSlide, _bSlide;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
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
    Future.delayed(const Duration(milliseconds: 180), () => _bCtrl.forward());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final loginVm = context.read<LoginViewModel>();
      final chatVm = context.read<ChatViewModel>();

      // ── FIX: Seed the current user identity from LoginViewModel immediately
      // so DM names resolve correctly before/without an API round-trip.
      chatVm.seedCurrentUser(
        userId: loginVm.loggedInId,
        username: loginVm.loggedInUsername ?? loginVm.loggedInEmail,
      );

      chatVm.fetchConversations();
    });
  }

  @override
  void dispose() {
    _hCtrl.dispose();
    _bCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Pin/unpin with snackbar ─────────────────────────────────────
  void _togglePin(ChatConversation conv) async {
    final vm = context.read<ChatViewModel>();
    final wasPinned = conv.isPinned;
    await vm.togglePin(conv.id);
    if (!mounted) return;
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
        content: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.c1.withOpacity(0.20),
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
          ],
        ),
      ),
    );
  }

  void _showNewDmSheet() {
    context.read<ChatViewModel>().fetchUsers();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) {
        // ── FIX: Capture logged-in user id & username to filter from list
        final loginVm = context.read<LoginViewModel>();
        final myId = loginVm.loggedInId;
        final myUsername =
            (loginVm.loggedInUsername ?? loginVm.loggedInEmail ?? '')
                .toLowerCase()
                .trim();

        return Container(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * .75),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: AppColors.c1.withOpacity(.15),
                blurRadius: 40,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: Column(children: [
            Container(
              width: 44,
              height: 4,
              margin: const EdgeInsets.only(top: 14, bottom: 20),
              decoration: BoxDecoration(
                  color: AppColors.cborder,
                  borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 16, 16),
              child: Row(children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.c1.withOpacity(.12),
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
                    Text('Start a direct conversation',
                        style: TextStyle(fontSize: 12, color: AppColors.ctext)),
                  ],
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(sheetCtx),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.cxl,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded,
                        color: AppColors.ctext, size: 16),
                  ),
                ),
              ]),
            ),
            Divider(height: 1, color: AppColors.cborder.withOpacity(.6)),
            Expanded(
              child: Consumer<ChatViewModel>(
                builder: (ctx, vm, _) {
                  if (vm.loadingUsers) {
                    return Center(
                        child: CircularProgressIndicator(
                            color: AppColors.c1, strokeWidth: 2));
                  }

                  // ── FIX: Filter out the logged-in user from the DM list
                  final users = vm.users.where((u) {
                    if (myId != null && myId != -1 && u.id == myId) {
                      return false;
                    }
                    if (myUsername.isNotEmpty &&
                        u.username.toLowerCase().trim() == myUsername) {
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
                              color: AppColors.c1.withOpacity(.3), size: 48),
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
                        onTap: () async {
                          Navigator.pop(sheetCtx);
                          final conv = await context
                              .read<ChatViewModel>()
                              .createDm(user.id);
                          if (conv != null && mounted) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        ChatScreen(conversation: conv)));
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
      },
    );
  }

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
              color: AppColors.c1.withOpacity(.12),
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
              const SizedBox(height: 10),
              _SheetOptionCard(
                icon: Icons.group_rounded,
                label: 'New Group',
                sub: 'Create a group chat',
                color: AppColors.c2,
                onTap: () async {
                  Navigator.pop(context);
                  final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const CreateGroupScreen()));
                  if (result != null && result is ChatConversation && mounted) {
                    context.read<ChatViewModel>().fetchConversations();
                  }
                },
              ),
              const SizedBox(height: 8),
            ]),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final topPad = mq.padding.top;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(children: [
        FadeTransition(
          opacity: _hFade,
          child: SlideTransition(
              position: _hSlide,
              child: _buildHeader(context, topPad, mq.size.width)),
        ),
        Expanded(
          child: FadeTransition(
            opacity: _bFade,
            child: SlideTransition(
              position: _bSlide,
              child: Column(children: [
                _buildTabs(),
                Consumer<ChatViewModel>(
                  builder: (ctx, vm, _) {
                    if (vm.error == null) return const SizedBox.shrink();
                    return Container(
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.red.withOpacity(.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: AppColors.red.withOpacity(.25), width: 1),
                      ),
                      child: Row(children: [
                        Icon(Icons.wifi_off_rounded,
                            color: AppColors.red, size: 16),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text('Could not load. Tap retry.',
                              style: TextStyle(
                                  color: AppColors.ctext, fontSize: 12)),
                        ),
                        GestureDetector(
                          onTap: () => vm.fetchConversations(),
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
                Expanded(child: _buildConversationList()),
              ]),
            ),
          ),
        ),
      ]),
      floatingActionButton: _AnimatedFab(onTap: _showOptions),
    );
  }

  Widget _buildConversationList() {
    return Consumer<ChatViewModel>(
      builder: (ctx, vm, _) {
        if (vm.loadingConversations) {
          return Center(
              child: CircularProgressIndicator(
                  color: AppColors.c1, strokeWidth: 2.5));
        }

        final allConvs = vm.conversations;
        if (allConvs.isEmpty) return _buildEmpty();

        final pinned = allConvs.where((c) => c.isPinned).toList();
        final unpinned = allConvs.where((c) => !c.isPinned).toList();
        final sorted = [...pinned, ...unpinned];

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(0, 4, 0, 100),
          physics: const BouncingScrollPhysics(),
          itemCount: sorted.length + (pinned.isNotEmpty ? 1 : 0),
          itemBuilder: (ctx, i) {
            if (pinned.isNotEmpty && i == 0) {
              return _SectionHeader(
                icon: Icons.push_pin_rounded,
                label: 'Pinned',
              );
            }

            final convIndex = pinned.isNotEmpty ? i - 1 : i;
            final conv = sorted[convIndex];

            final bool showAllHeader = pinned.isNotEmpty &&
                convIndex == pinned.length &&
                unpinned.isNotEmpty;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showAllHeader) ...[
                  _SectionHeader(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: 'All Chats',
                  ),
                ],
                _ConvTile(
                  conversation: conv,
                  currentUserId: vm.currentUserId,
                  delay: Duration(milliseconds: 30 + convIndex * 35),
                  onTap: () async {
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ChatScreen(conversation: conv)));
                    vm.fetchConversations();
                  },
                  onPinToggle: () => _togglePin(conv),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, double topPad, double sw) {
    return Consumer<ChatViewModel>(
      builder: (ctx, vm, _) => Container(
        width: double.infinity,
        padding: EdgeInsets.only(
            top: topPad + 16, bottom: 16, left: sw * .05, right: sw * .05),
        color: AppColors.white,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
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
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Text('Inbox',
                          style: TextStyle(
                              color: AppColors.cdark,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.8)),
                      const SizedBox(width: 10),
                      Consumer<ChatViewModel>(
                        builder: (_, vm, __) {
                          final unread = vm.totalUnread;
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
              onTap: () => vm.fetchConversations(),
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
                  color: AppColors.ctext.withOpacity(.5), size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: vm.setSearch,
                  style:
                      const TextStyle(fontSize: 13.5, color: AppColors.ctext),
                  decoration: InputDecoration(
                    hintText: 'Search conversations…',
                    hintStyle: TextStyle(
                        color: AppColors.ctext.withOpacity(.4), fontSize: 13.5),
                    border: InputBorder.none,
                    isCollapsed: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              if (vm.search.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    _searchCtrl.clear();
                    vm.setSearch('');
                  },
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.ctext.withOpacity(.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close_rounded,
                        size: 12, color: AppColors.ctext.withOpacity(.7)),
                  ),
                ),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _buildTabs() {
    return Consumer<ChatViewModel>(
      builder: (ctx, vm, _) {
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
              final active = vm.tab == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => vm.setTab(i),
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
                                : AppColors.ctext.withOpacity(.5)),
                        const SizedBox(width: 6),
                        Text(labels[i],
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight:
                                    active ? FontWeight.w700 : FontWeight.w500,
                                color: active
                                    ? AppColors.white
                                    : AppColors.ctext.withOpacity(.5))),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildEmpty() => Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.c1.withOpacity(.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.mark_chat_unread_outlined,
                color: AppColors.c1.withOpacity(.6), size: 36),
          ),
          const SizedBox(height: 20),
          const Text('No conversations yet',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.cdark,
                  letterSpacing: -0.3)),
          const SizedBox(height: 8),
          Text('Tap ✏️ below to start chatting',
              style: TextStyle(
                  fontSize: 13, color: AppColors.ctext.withOpacity(.7))),
        ]),
      );
}

// ─── Section header (Pinned / All Chats) ─────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SectionHeader({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 4),
      child: Row(children: [
        Icon(icon, size: 12, color: AppColors.c1.withOpacity(.6)),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.c1.withOpacity(.6),
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Divider(
            height: 1,
            color: AppColors.c1.withOpacity(.12),
          ),
        ),
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
                color: AppColors.c1.withOpacity(.45),
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

// ─── User tile in DM sheet ────────────────────────────────────────────────────
class _UserTile extends StatelessWidget {
  final ChatUser user;
  final VoidCallback onTap;
  const _UserTile({required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
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
          ChatAvatar(
              initials: user.initials, imageUrl: user.profilePicture, size: 46),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.fullName,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.cdark)),
                if (user.department != null)
                  Text(user.department!,
                      style: TextStyle(
                          fontSize: 11,
                          color: AppColors.ctext.withOpacity(.7))),
              ],
            ),
          ),
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: AppColors.c1.withOpacity(.1),
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
          color: color.withOpacity(.06),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(.18), width: 1),
        ),
        child: Row(children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withOpacity(.15),
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
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.cdark)),
                const SizedBox(height: 2),
                Text(sub,
                    style: TextStyle(
                        fontSize: 12, color: AppColors.ctext.withOpacity(.7))),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded,
              color: color.withOpacity(.6), size: 22),
        ]),
      ),
    );
  }
}

// ─── Conversation tile ────────────────────────────────────────────────────────
class _ConvTile extends StatefulWidget {
  final ChatConversation conversation;
  final int? currentUserId;
  final Duration delay;
  final VoidCallback onTap;
  final VoidCallback onPinToggle;

  const _ConvTile({
    required this.conversation,
    required this.currentUserId,
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

  String _buildPreview(ChatConversation conv, ChatMessageModel? last) {
    if (last == null) return 'No messages yet';

    final myId = widget.currentUserId;
    final isMine = myId != null && myId != -1 && last.sender.id == myId;

    if (isMine) {
      return 'You: ${last.text}';
    }

    if (conv.isGroup) {
      final senderName = last.sender.firstName.isNotEmpty
          ? last.sender.firstName
          : last.sender.username;
      return '$senderName: ${last.text}';
    }

    return last.text;
  }

  @override
  Widget build(BuildContext context) {
    final conv = widget.conversation;
    final last = conv.lastMessage;
    final hasUnread = conv.unreadCount > 0;
    final isPinned = conv.isPinned;

    final preview = _buildPreview(conv, last);
    final otherParticipant = conv.otherParticipant;

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
          onLongPress: widget.onPinToggle,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: _pressed
                  ? AppColors.c1.withOpacity(.05)
                  : isPinned
                      ? AppColors.c1.withOpacity(.06)
                      : hasUnread
                          ? AppColors.c1.withOpacity(.04)
                          : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isPinned
                    ? AppColors.c1.withOpacity(.18)
                    : hasUnread
                        ? AppColors.c1.withOpacity(.12)
                        : Colors.transparent,
                width: 1,
              ),
            ),
            child: Row(children: [
              Stack(
                children: [
                  ChatAvatar(
                    initials: conv.isGroup
                        ? conv.avatarInitials
                        : (otherParticipant?.initials ?? '??'),
                    imageUrl: conv.isGroup
                        ? conv.image
                        : otherParticipant?.profilePicture,
                    isGroup: conv.isGroup,
                    size: 52,
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
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        if (isPinned) ...[
                          Icon(Icons.push_pin_rounded,
                              size: 11, color: AppColors.c1),
                          const SizedBox(width: 4),
                        ],
                        Expanded(
                          child: Text(conv.name,
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
                        if (last != null) ...[
                          const SizedBox(width: 8),
                          Text(chatFormatTime(last.timestamp),
                              style: TextStyle(
                                  fontSize: 11,
                                  color: hasUnread
                                      ? AppColors.c1
                                      : AppColors.ctext.withOpacity(.5),
                                  fontWeight: hasUnread
                                      ? FontWeight.w700
                                      : FontWeight.w400)),
                        ],
                      ]),
                      const SizedBox(height: 4),
                      Row(children: [
                        Expanded(
                          child: Text(preview,
                              style: TextStyle(
                                  fontSize: 12.5,
                                  color: hasUnread
                                      ? AppColors.ctext
                                      : AppColors.ctext.withOpacity(.55),
                                  fontWeight: hasUnread
                                      ? FontWeight.w500
                                      : FontWeight.w400),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1),
                        ),
                        if (conv.isMuted)
                          Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: Icon(Icons.notifications_off_rounded,
                                size: 13,
                                color: AppColors.ctext.withOpacity(.3)),
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
                              child: Text('${conv.unreadCount}',
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
              GestureDetector(
                onTap: widget.onPinToggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isPinned
                        ? AppColors.c1.withOpacity(.14)
                        : AppColors.cxl,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isPinned
                          ? AppColors.c1.withOpacity(.30)
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
