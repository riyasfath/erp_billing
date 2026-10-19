import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/models/data-models/chat/chat_data.dart';
import 'package:provider/provider.dart';
import 'package:pokakbilling/viewmodels/chat_viewmodel.dart';
import 'package:pokakbilling/viewmodels/login_viewmodel.dart';
import 'package:pokakbilling/views/Screens/inbox/chat_widgets.dart';

class ChatScreen extends StatefulWidget {
  final ChatConversation conversation;
  const ChatScreen({super.key, required this.conversation});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fade;
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  bool _canSend = false;
  Timer? _pollTimer;
  int _lastMessageCount = 0;

  bool _pinTapped = false;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();

    _msgCtrl.addListener(() {
      final can = _msgCtrl.text.trim().isNotEmpty;
      if (can != _canSend) setState(() => _canSend = can);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final loginVm = context.read<LoginViewModel>();
      final vm = context.read<ChatViewModel>();

      // ── Seed identity from LoginViewModel so names resolve immediately
      // without waiting for the API round-trip in ensureCurrentUser().
      vm.seedCurrentUser(
        userId: loginVm.loggedInId,
        username: loginVm.loggedInUsername ?? loginVm.loggedInEmail,
      );

      await vm.ensureCurrentUser();
      if (mounted) {
        await vm.fetchMessages(widget.conversation.id);
        _startPolling();
      }
    });
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      final vm = context.read<ChatViewModel>();
      vm.refreshMessages(widget.conversation.id).then((_) {
        if (!mounted) return;
        final updated = vm.messagesFor(widget.conversation.id);
        if (updated.length != _lastMessageCount) {
          _lastMessageCount = updated.length;
          _scrollToBottom();
        }
      });
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _fadeCtrl.dispose();
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _send() {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    _msgCtrl.clear();
    setState(() => _canSend = false);
    context
        .read<ChatViewModel>()
        .sendMessage(widget.conversation.id, text)
        .then((_) {
      if (mounted) _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients && _scrollCtrl.position.hasContentDimensions) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _togglePin(bool currentlyPinned) async {
    setState(() => _pinTapped = true);
    await Future.delayed(const Duration(milliseconds: 150));
    if (mounted) setState(() => _pinTapped = false);

    final vm = context.read<ChatViewModel>();
    await vm.togglePin(widget.conversation.id);
    if (!mounted) return;
    _showPinSnackbar(!currentlyPinned);
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

  bool _showDateLabel(List<ChatMessageModel> msgs, int i) {
    if (i == 0) return true;
    final p = msgs[i - 1].timestamp.toLocal();
    final c = msgs[i].timestamp.toLocal();
    return c.day != p.day || c.month != p.month || c.year != p.year;
  }

  String _dateLabel(DateTime dt) {
    final local = dt.toLocal();
    final now = DateTime.now();
    final diff = DateTime(now.year, now.month, now.day)
        .difference(DateTime(local.year, local.month, local.day))
        .inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
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
    return '${local.day} ${months[local.month - 1]} ${local.year}';
  }

  String _timeStr(DateTime dt) {
    final local = dt.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  bool _isMe(ChatMessageModel msg) {
    final chatVm = context.read<ChatViewModel>();
    if (chatVm.currentUserId != null && chatVm.currentUserId != -1) {
      return msg.sender.id == chatVm.currentUserId;
    }
    final loginVm = context.read<LoginViewModel>();
    final loggedIn = (loginVm.loggedInUsername ?? '').toLowerCase().trim();
    if (loggedIn.isEmpty) return false;
    return msg.sender.username.toLowerCase().trim() == loggedIn;
  }

  @override
  Widget build(BuildContext context) {
    final conv = widget.conversation;

    return Scaffold(
      backgroundColor: AppColors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(children: [
          _buildAppBar(context, conv),
          Expanded(
            child: FadeTransition(
              opacity: _fade,
              child: _buildMessageList(conv),
            ),
          ),
          _buildInputBar(),
        ]),
      ),
    );
  }

  Widget _buildMessageList(ChatConversation conv) {
    return Consumer<ChatViewModel>(
      builder: (ctx, vm, _) {
        if (vm.isLoadingMessages(conv.id)) {
          return Center(
            child: CircularProgressIndicator(
                color: AppColors.c1, strokeWidth: 2.5),
          );
        }
        final msgs = vm.messagesFor(conv.id);

        if (_lastMessageCount == 0 && msgs.isNotEmpty) {
          _lastMessageCount = msgs.length;
          WidgetsBinding.instance
              .addPostFrameCallback((_) => _scrollToBottom());
        }

        if (msgs.isEmpty) return _emptyChat();

        return ListView.builder(
          controller: _scrollCtrl,
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
          physics: const BouncingScrollPhysics(),
          itemCount: msgs.length,
          itemBuilder: (ctx, i) {
            final msg = msgs[i];
            final isMe = _isMe(msg);
            final showName = conv.isGroup &&
                !isMe &&
                (i == 0 || msgs[i - 1].sender.id != msg.sender.id);

            final isFirst = i == 0 || msgs[i - 1].sender.id != msg.sender.id;
            final isLast =
                i == msgs.length - 1 || msgs[i + 1].sender.id != msg.sender.id;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_showDateLabel(msgs, i))
                  _DateDivider(label: _dateLabel(msg.timestamp)),
                _BubbleTile(
                  msg: msg,
                  isMe: isMe,
                  timeStr: _timeStr(msg.timestamp),
                  showSenderName: showName,
                  isFirst: isFirst,
                  isLast: isLast,
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext ctx, ChatConversation conv) {
    // ── For DM subtitle, show the other person's name (not self)
    String subtitle;
    if (conv.isGroup) {
      final names = conv.participants.map((p) => p.firstName).join(', ');
      subtitle = '${conv.participants.length} members · $names';
    } else {
      final other = conv.otherParticipant;
      subtitle = other?.fullName ?? '';
    }

    final other = conv.otherParticipant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom:
              BorderSide(color: AppColors.cborder.withOpacity(.6), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.c1.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(children: [
        GestureDetector(
          onTap: () => Navigator.pop(ctx),
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
        const SizedBox(width: 10),
        Stack(
          children: [
            ChatAvatar(
              initials: conv.isGroup
                  ? conv.avatarInitials
                  : (other?.initials ?? '??'),
              imageUrl: conv.isGroup ? conv.image : other?.profilePicture,
              isGroup: conv.isGroup,
              size: 42,
            ),
            Positioned(
              bottom: 1,
              right: 1,
              child: Container(
                width: 11,
                height: 11,
                decoration: BoxDecoration(
                  color: AppColors.tagGreen,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                conv.name,
                style: const TextStyle(
                  color: AppColors.cdark,
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: AppColors.ctext.withOpacity(.65),
                  fontSize: 11.5,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),

        // ── PIN BUTTON ─────────────────────────────────────────────
        Consumer<ChatViewModel>(
          builder: (_, vm, __) {
            final liveConv = vm.conversations.firstWhere(
              (c) => c.id == widget.conversation.id,
              orElse: () => widget.conversation,
            );
            final isPinned = liveConv.isPinned;

            return GestureDetector(
              onTap: () => _togglePin(isPinned),
              child: AnimatedScale(
                scale: _pinTapped ? 0.82 : 1.0,
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOut,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isPinned
                        ? AppColors.c1.withOpacity(.15)
                        : AppColors.cxl,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isPinned
                          ? AppColors.c1.withOpacity(.45)
                          : AppColors.cborder,
                      width: 1.4,
                    ),
                    boxShadow: isPinned
                        ? [
                            BoxShadow(
                              color: AppColors.c1.withOpacity(.22),
                              blurRadius: 8,
                              spreadRadius: 0,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : [],
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    transitionBuilder: (child, anim) => ScaleTransition(
                      scale: CurvedAnimation(
                          parent: anim, curve: Curves.easeOutBack),
                      child: child,
                    ),
                    child: Icon(
                      isPinned
                          ? Icons.push_pin_rounded
                          : Icons.push_pin_outlined,
                      key: ValueKey(isPinned),
                      color: isPinned ? AppColors.c1 : AppColors.c3,
                      size: 16,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        // ── END PIN BUTTON ─────────────────────────────────────────
      ]),
    );
  }

  Widget _buildInputBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.cborder.withOpacity(.6), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.c1.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: AppColors.cxl,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: AppColors.cborder, width: 1.5),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
              child: TextField(
                controller: _msgCtrl,
                maxLines: null,
                textAlignVertical: TextAlignVertical.center,
                style: const TextStyle(
                    fontSize: 14, color: AppColors.cdark, height: 1.4),
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Type a message…',
                  hintStyle: TextStyle(
                      color: AppColors.ctext.withOpacity(.4), fontSize: 14),
                  border: InputBorder.none,
                  isCollapsed: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: _canSend
                ? GestureDetector(
                    key: const ValueKey('send'),
                    onTap: _send,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.c1,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.c1.withOpacity(.35),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.send_rounded,
                          color: AppColors.white, size: 20),
                    ),
                  )
                : const SizedBox(
                    key: ValueKey('idle'),
                    width: 48,
                    height: 48,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _emptyChat() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.c1.withOpacity(.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.waving_hand_rounded,
                  color: AppColors.c1.withOpacity(.55), size: 34),
            ),
            const SizedBox(height: 20),
            const Text(
              'Say hello!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.cdark,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Be the first to break the ice 👋',
              style: TextStyle(
                  fontSize: 13, color: AppColors.ctext.withOpacity(.55)),
            ),
          ],
        ),
      );
}

// ─── Date divider ─────────────────────────────────────────────────────────────
class _DateDivider extends StatelessWidget {
  final String label;
  const _DateDivider({required this.label});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(children: [
          Expanded(
              child:
                  Divider(color: AppColors.cborder.withOpacity(.5), height: 1)),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.cxl,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: AppColors.cborder.withOpacity(.8), width: 1),
            ),
            child: Text(
              label,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ctext.withOpacity(.7)),
            ),
          ),
          Expanded(
              child:
                  Divider(color: AppColors.cborder.withOpacity(.5), height: 1)),
        ]),
      );
}

// ─── Bubble tile ──────────────────────────────────────────────────────────────
class _BubbleTile extends StatelessWidget {
  final ChatMessageModel msg;
  final bool isMe;
  final String timeStr;
  final bool showSenderName;
  final bool isFirst;
  final bool isLast;

  const _BubbleTile({
    required this.msg,
    required this.isMe,
    required this.timeStr,
    required this.showSenderName,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    const double r = 20;
    const double rSmall = 5;

    final radius = isMe
        ? BorderRadius.only(
            topLeft: const Radius.circular(r),
            topRight: Radius.circular(isFirst ? r : rSmall),
            bottomLeft: const Radius.circular(r),
            bottomRight: Radius.circular(isLast ? rSmall : r),
          )
        : BorderRadius.only(
            topLeft: Radius.circular(isFirst ? r : rSmall),
            topRight: const Radius.circular(r),
            bottomLeft: Radius.circular(isLast ? rSmall : r),
            bottomRight: const Radius.circular(r),
          );

    final bubbleDecor = isMe
        ? BoxDecoration(
            color: AppColors.c1,
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: AppColors.c1.withOpacity(.22),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          )
        : BoxDecoration(
            color: const Color(0xFF1B3347),
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.12),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          );

    return Padding(
      padding: EdgeInsets.only(
        bottom: isLast ? 8 : 2,
        top: (isFirst && !showSenderName) ? 2 : 0,
      ),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            if (isLast)
              ChatAvatar(
                  initials: msg.sender.initials,
                  imageUrl: msg.sender.profilePicture,
                  size: 28)
            else
              const SizedBox(width: 28),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (showSenderName)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 4),
                    child: Text(
                      msg.sender.fullName,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.c1.withOpacity(.8)),
                    ),
                  ),
                Container(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * .72),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: bubbleDecor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        msg.text,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.45,
                          color: AppColors.white,
                          letterSpacing: 0.1,
                        ),
                      ),
                      if (msg.attachment != null &&
                          msg.attachment!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Row(children: [
                          Icon(Icons.attach_file_rounded,
                              size: 13, color: AppColors.white.withOpacity(.6)),
                          const SizedBox(width: 4),
                          Text(
                            'Attachment',
                            style: TextStyle(
                                fontSize: 11,
                                color: AppColors.white.withOpacity(.6)),
                          ),
                        ]),
                      ],
                    ],
                  ),
                ),
                if (isLast)
                  Padding(
                    padding: const EdgeInsets.only(top: 5, left: 4, right: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          timeStr,
                          style: TextStyle(
                              fontSize: 10,
                              color: AppColors.ctext.withOpacity(.45)),
                        ),
                        if (isMe) ...[
                          const SizedBox(width: 4),
                          Icon(
                            msg.isRead
                                ? Icons.done_all_rounded
                                : Icons.done_rounded,
                            size: 13,
                            color: msg.isRead
                                ? AppColors.c1
                                : AppColors.ctext.withOpacity(.4),
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
    );
  }
}
