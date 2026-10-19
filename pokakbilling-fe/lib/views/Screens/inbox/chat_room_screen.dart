// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';

// import 'package:pokakbilling/core/themes/app_colors.dart';
// import 'package:pokakbilling/models/data-models/chat/chat_message.dart';
// import 'package:pokakbilling/models/services/chat_message_service.dart';
// import 'package:pokakbilling/viewmodels/chat_viewmodel.dart';

// // ─────────────────────────────────────────────────────────────────────────────
// // IN-APP MESSAGE BANNER  (logic unchanged, colours from AppColors)
// // ─────────────────────────────────────────────────────────────────────────────
// class InAppMessageBanner {
//   static OverlayEntry? _entry;
//   static Timer? _timer;

//   static void show(
//     BuildContext context, {
//     required String senderName,
//     required String message,
//     String? avatarInitial,
//     VoidCallback? onTap,
//     Duration duration = const Duration(seconds: 4),
//   }) {
//     dismiss();
//     final overlay = Overlay.of(context);

//     _entry = OverlayEntry(
//       builder: (_) => _BannerWidget(
//         senderName: senderName,
//         message: message,
//         avatarInitial: avatarInitial ?? senderName[0].toUpperCase(),
//         onTap: () {
//           dismiss();
//           onTap?.call();
//         },
//         onDismiss: dismiss,
//       ),
//     );

//     overlay.insert(_entry!);
//     _timer = Timer(duration, dismiss);
//   }

//   static void dismiss() {
//     _timer?.cancel();
//     _timer = null;
//     _entry?.remove();
//     _entry = null;
//   }
// }

// class _BannerWidget extends StatefulWidget {
//   const _BannerWidget({
//     required this.senderName,
//     required this.message,
//     required this.avatarInitial,
//     required this.onTap,
//     required this.onDismiss,
//   });

//   final String senderName;
//   final String message;
//   final String avatarInitial;
//   final VoidCallback onTap;
//   final VoidCallback onDismiss;

//   @override
//   State<_BannerWidget> createState() => _BannerWidgetState();
// }

// class _BannerWidgetState extends State<_BannerWidget>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _ctrl;
//   late Animation<Offset> _slide;
//   late Animation<double> _fade;

//   @override
//   void initState() {
//     super.initState();
//     _ctrl = AnimationController(
//         vsync: this, duration: const Duration(milliseconds: 350));
//     _slide = Tween<Offset>(begin: const Offset(0, -1.5), end: Offset.zero)
//         .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
//     _fade = Tween<double>(begin: 0, end: 1).animate(_ctrl);
//     _ctrl.forward();
//   }

//   @override
//   void dispose() {
//     _ctrl.dispose();
//     super.dispose();
//   }

//   Future<void> _dismiss() async {
//     await _ctrl.reverse();
//     widget.onDismiss();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Positioned(
//       top: MediaQuery.of(context).padding.top + 8,
//       left: 12,
//       right: 12,
//       child: FadeTransition(
//         opacity: _fade,
//         child: SlideTransition(
//           position: _slide,
//           child: GestureDetector(
//             onTap: widget.onTap,
//             onVerticalDragEnd: (d) {
//               if (d.primaryVelocity != null && d.primaryVelocity! < 0) {
//                 _dismiss();
//               }
//             },
//             child: Material(
//               color: Colors.transparent,
//               child: Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//                 decoration: BoxDecoration(
//                   color: AppColors.cdark,
//                   borderRadius: BorderRadius.circular(16),
//                   border: Border.all(
//                       color: AppColors.c1.withOpacity(0.35), width: 1.2),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.18),
//                       blurRadius: 20,
//                       offset: const Offset(0, 6),
//                     ),
//                   ],
//                 ),
//                 child: Row(children: [
//                   // Avatar
//                   Container(
//                     width: 42,
//                     height: 42,
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [AppColors.c1, AppColors.c3],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                       ),
//                       shape: BoxShape.circle,
//                     ),
//                     alignment: Alignment.center,
//                     child: Text(
//                       widget.avatarInitial,
//                       style: const TextStyle(
//                           color: AppColors.white,
//                           fontSize: 16,
//                           fontWeight: FontWeight.w800),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   // Text
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Row(children: [
//                           Expanded(
//                             child: Text(
//                               widget.senderName,
//                               style: const TextStyle(
//                                   color: AppColors.white,
//                                   fontSize: 13,
//                                   fontWeight: FontWeight.w800),
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                           Text(
//                             DateFormat('HH:mm').format(DateTime.now()),
//                             style: TextStyle(
//                                 color: AppColors.white.withOpacity(.55),
//                                 fontSize: 10.5),
//                           ),
//                         ]),
//                         const SizedBox(height: 2),
//                         Text(
//                           widget.message,
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                           style: TextStyle(
//                               color: AppColors.white.withOpacity(.7),
//                               fontSize: 12),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   GestureDetector(
//                     onTap: _dismiss,
//                     child: Container(
//                       width: 28,
//                       height: 28,
//                       decoration: BoxDecoration(
//                         color: AppColors.white.withOpacity(.12),
//                         shape: BoxShape.circle,
//                       ),
//                       child: Icon(Icons.close_rounded,
//                           color: AppColors.white.withOpacity(.7), size: 14),
//                     ),
//                   ),
//                 ]),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────────────────
// // CHAT ROOM SCREEN
// // ─────────────────────────────────────────────────────────────────────────────
// class ChatRoomScreen extends StatefulWidget {
//   final int roomId;
//   final String userEmail;
//   final String userName;
//   final int? currentUserId;

//   const ChatRoomScreen({
//     super.key,
//     required this.roomId,
//     required this.userEmail,
//     required this.userName,
//     this.currentUserId,
//   });

//   @override
//   State<ChatRoomScreen> createState() => _ChatRoomScreenState();
// }

// class _ChatRoomScreenState extends State<ChatRoomScreen>
//     with SingleTickerProviderStateMixin, WidgetsBindingObserver {
//   final TextEditingController _messageController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();

//   // Fade-in animation (CRM-style)
//   late final AnimationController _fadeCtrl;
//   late final Animation<double> _fade;

//   List<ChatMessage> _messages = [];
//   bool _loading = true;
//   bool _canSend = false;
//   Timer? _poller;

//   int _lastMessageCount = 0;
//   bool _isFirstLoad = true;

//   int get _currentUserId => widget.currentUserId ?? 0;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);

//     _fadeCtrl = AnimationController(
//         vsync: this, duration: const Duration(milliseconds: 400));
//     _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
//     _fadeCtrl.forward();

//     _messageController.addListener(() {
//       final can = _messageController.text.trim().isNotEmpty;
//       if (can != _canSend) setState(() => _canSend = can);
//     });

//     _fetch();
//     _poller = Timer.periodic(const Duration(seconds: 5), (_) => _fetch());
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) _fetch();
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     _poller?.cancel();
//     _fadeCtrl.dispose();
//     _messageController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   // ── Fetch / Poll ──────────────────────────────────────────────────────────
//   Future<void> _fetch() async {
//     try {
//       final msgs = await ChatMessageService.fetchMessages(widget.roomId);
//       if (!mounted) return;

//       final newCount = msgs.length;
//       if (!_isFirstLoad && newCount > _lastMessageCount) {
//         final newest = msgs.last;
//         if (newest.senderId != _currentUserId) {
//           InAppMessageBanner.show(
//             context,
//             senderName: widget.userName,
//             message: newest.content,
//             avatarInitial: widget.userName.isNotEmpty
//                 ? widget.userName[0].toUpperCase()
//                 : 'U',
//           );
//         }
//       }

//       _lastMessageCount = newCount;
//       _isFirstLoad = false;

//       setState(() {
//         _messages = msgs;
//         _loading = false;
//       });
//       _scrollToBottom();

//       // Refresh inbox so lastAt updates → conversation sorts to top
//       if (mounted && _currentUserId != 0) {
//         final inboxVM = Provider.of<ChatInboxViewModel>(context, listen: false);
//         if (inboxVM.currentUserId != null) {
//           await inboxVM.fetchFor(inboxVM.currentUserId!, silent: true);
//         }
//       }
//     } catch (_) {
//       if (!mounted) return;
//       setState(() => _loading = false);
//     }
//   }

//   void _scrollToBottom() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!_scrollController.hasClients) return;
//       _scrollController.animateTo(
//         _scrollController.position.maxScrollExtent,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeOut,
//       );
//     });
//   }

//   // ── Send ──────────────────────────────────────────────────────────────────
//   Future<void> _sendMessage() async {
//     final content = _messageController.text.trim();
//     if (content.isEmpty) return;

//     final now = DateTime.now();
//     final optimistic = ChatMessage(
//       id: -now.millisecondsSinceEpoch,
//       chatId: widget.roomId,
//       senderId: _currentUserId,
//       content: content,
//       createdAt: now,
//     );

//     setState(() => _messages = List.of(_messages)..add(optimistic));
//     _lastMessageCount = _messages.length;
//     _messageController.clear();
//     _scrollToBottom();

//     if (mounted) {
//       final inboxVM = Provider.of<ChatInboxViewModel>(context, listen: false);
//       inboxVM.updateRoomLastMessage(
//         roomId: widget.roomId,
//         lastText: content,
//         lastAt: now,
//       );
//     }

//     try {
//       await ChatMessageService.sendMessage(
//           roomId: widget.roomId, content: content);
//       await _fetch();
//     } catch (_) {}
//   }

//   // ── Helpers ───────────────────────────────────────────────────────────────
//   String _formatTime(DateTime time) => DateFormat('HH:mm').format(time);

//   String _formatDate(DateTime dt) {
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
//     final msgDay = DateTime(dt.year, dt.month, dt.day);
//     final diff = today.difference(msgDay).inDays;
//     if (diff == 0) return 'Today';
//     if (diff == 1) return 'Yesterday';
//     const months = [
//       'Jan',
//       'Feb',
//       'Mar',
//       'Apr',
//       'May',
//       'Jun',
//       'Jul',
//       'Aug',
//       'Sep',
//       'Oct',
//       'Nov',
//       'Dec'
//     ];
//     return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
//   }

//   bool _showDateLabel(int i) {
//     if (i == 0) return true;
//     final p = _messages[i - 1].createdAt.toLocal();
//     final c = _messages[i].createdAt.toLocal();
//     return c.day != p.day || c.month != p.month || c.year != p.year;
//   }

//   bool _isMe(ChatMessage msg) =>
//       _currentUserId != 0 && msg.senderId == _currentUserId;

//   // ── BUILD ─────────────────────────────────────────────────────────────────
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.white,
//       resizeToAvoidBottomInset: true,
//       body: SafeArea(
//         child: Column(children: [
//           _buildAppBar(),
//           Expanded(
//             child: FadeTransition(
//               opacity: _fade,
//               child: _loading
//                   ? Center(
//                       child: CircularProgressIndicator(
//                           color: AppColors.c1, strokeWidth: 2.5))
//                   : _buildMessageList(),
//             ),
//           ),
//           _buildInputBar(),
//         ]),
//       ),
//     );
//   }

//   // ── APP BAR ───────────────────────────────────────────────────────────────
//   Widget _buildAppBar() {
//     final initial =
//         widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : 'U';

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//       decoration: BoxDecoration(
//         color: AppColors.white,
//         border: Border(
//           bottom:
//               BorderSide(color: AppColors.cborder.withOpacity(.6), width: 1),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.c1.withOpacity(0.04),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(children: [
//         GestureDetector(
//           onTap: () => Navigator.pop(context),
//           child: Container(
//             width: 38,
//             height: 38,
//             decoration: BoxDecoration(
//               color: AppColors.cxl,
//               shape: BoxShape.circle,
//               border: Border.all(color: AppColors.cborder, width: 1.2),
//             ),
//             child: const Icon(Icons.arrow_back_ios_new_rounded,
//                 color: AppColors.c3, size: 14),
//           ),
//         ),
//         const SizedBox(width: 10),
//         // Avatar with online dot
//         Stack(children: [
//           Container(
//             width: 42,
//             height: 42,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [AppColors.c1, AppColors.c3],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.circular(14),
//             ),
//             alignment: Alignment.center,
//             child: Text(initial,
//                 style: const TextStyle(
//                     color: AppColors.white,
//                     fontSize: 16,
//                     fontWeight: FontWeight.w700)),
//           ),
//           Positioned(
//             bottom: 1,
//             right: 1,
//             child: Container(
//               width: 11,
//               height: 11,
//               decoration: BoxDecoration(
//                 color: AppColors.tagGreen,
//                 shape: BoxShape.circle,
//                 border: Border.all(color: AppColors.white, width: 2),
//               ),
//             ),
//           ),
//         ]),
//         const SizedBox(width: 10),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 widget.userName,
//                 style: const TextStyle(
//                   color: AppColors.cdark,
//                   fontSize: 15.5,
//                   fontWeight: FontWeight.w800,
//                   letterSpacing: -0.3,
//                 ),
//                 overflow: TextOverflow.ellipsis,
//               ),
//               const SizedBox(height: 2),
//               Text(
//                 widget.userEmail,
//                 style: TextStyle(
//                     color: AppColors.ctext.withOpacity(.65), fontSize: 11.5),
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ],
//           ),
//         ),
//       ]),
//     );
//   }

//   // ── MESSAGE LIST ──────────────────────────────────────────────────────────
//   Widget _buildMessageList() {
//     if (_messages.isEmpty) return _emptyChat();

//     return ListView.builder(
//       controller: _scrollController,
//       padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
//       physics: const BouncingScrollPhysics(),
//       itemCount: _messages.length,
//       itemBuilder: (_, i) {
//         final msg = _messages[i];
//         final isMe = _isMe(msg);

//         final isFirst = i == 0 || _messages[i - 1].senderId != msg.senderId;
//         final isLast = i == _messages.length - 1 ||
//             _messages[i + 1].senderId != msg.senderId;

//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             if (_showDateLabel(i))
//               _DateDivider(label: _formatDate(msg.createdAt)),
//             _BubbleTile(
//               msg: msg,
//               isMe: isMe,
//               timeStr: _formatTime(msg.createdAt),
//               isFirst: isFirst,
//               isLast: isLast,
//               senderInitial: widget.userName.isNotEmpty
//                   ? widget.userName[0].toUpperCase()
//                   : 'U',
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // ── INPUT BAR ─────────────────────────────────────────────────────────────
//   Widget _buildInputBar() {
//     return Container(
//       decoration: BoxDecoration(
//         color: AppColors.white,
//         border: Border(
//           top: BorderSide(color: AppColors.cborder.withOpacity(.6), width: 1),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.c1.withOpacity(0.04),
//             blurRadius: 10,
//             offset: const Offset(0, -3),
//           ),
//         ],
//       ),
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           Expanded(
//             child: Container(
//               constraints: const BoxConstraints(maxHeight: 120),
//               decoration: BoxDecoration(
//                 color: AppColors.cxl,
//                 borderRadius: BorderRadius.circular(26),
//                 border: Border.all(color: AppColors.cborder, width: 1.5),
//               ),
//               padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
//               child: TextField(
//                 controller: _messageController,
//                 maxLines: null,
//                 textAlignVertical: TextAlignVertical.center,
//                 style: const TextStyle(
//                     fontSize: 14, color: AppColors.cdark, height: 1.4),
//                 textCapitalization: TextCapitalization.sentences,
//                 decoration: InputDecoration(
//                   hintText: 'Type a message…',
//                   hintStyle: TextStyle(
//                       color: AppColors.ctext.withOpacity(.4), fontSize: 14),
//                   border: InputBorder.none,
//                   isCollapsed: true,
//                   contentPadding: EdgeInsets.zero,
//                 ),
//                 onSubmitted: (_) => _sendMessage(),
//               ),
//             ),
//           ),
//           const SizedBox(width: 8),
//           AnimatedSwitcher(
//             duration: const Duration(milliseconds: 200),
//             transitionBuilder: (child, anim) =>
//                 ScaleTransition(scale: anim, child: child),
//             child: _canSend
//                 ? GestureDetector(
//                     key: const ValueKey('send'),
//                     onTap: _sendMessage,
//                     child: Container(
//                       width: 48,
//                       height: 48,
//                       decoration: BoxDecoration(
//                         color: AppColors.c1,
//                         shape: BoxShape.circle,
//                         boxShadow: [
//                           BoxShadow(
//                             color: AppColors.c1.withOpacity(.35),
//                             blurRadius: 14,
//                             offset: const Offset(0, 4),
//                           ),
//                         ],
//                       ),
//                       child: const Icon(Icons.send_rounded,
//                           color: AppColors.white, size: 20),
//                     ),
//                   )
//                 : const SizedBox(key: ValueKey('idle'), width: 48, height: 48),
//           ),
//         ],
//       ),
//     );
//   }

//   // ── EMPTY ─────────────────────────────────────────────────────────────────
//   Widget _emptyChat() => Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 80,
//               height: 80,
//               decoration: BoxDecoration(
//                 color: AppColors.c1.withOpacity(.08),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(Icons.waving_hand_rounded,
//                   color: AppColors.c1.withOpacity(.55), size: 34),
//             ),
//             const SizedBox(height: 20),
//             const Text('Say hello!',
//                 style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w800,
//                     color: AppColors.cdark,
//                     letterSpacing: -0.3)),
//             const SizedBox(height: 6),
//             Text('Be the first to break the ice 👋',
//                 style: TextStyle(
//                     fontSize: 13, color: AppColors.ctext.withOpacity(.55))),
//           ],
//         ),
//       );
// }

// // ─── Date divider ─────────────────────────────────────────────────────────────
// class _DateDivider extends StatelessWidget {
//   final String label;
//   const _DateDivider({required this.label});

//   @override
//   Widget build(BuildContext context) => Padding(
//         padding: const EdgeInsets.symmetric(vertical: 16),
//         child: Row(children: [
//           Expanded(
//               child:
//                   Divider(color: AppColors.cborder.withOpacity(.5), height: 1)),
//           Container(
//             margin: const EdgeInsets.symmetric(horizontal: 12),
//             padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
//             decoration: BoxDecoration(
//               color: AppColors.cxl,
//               borderRadius: BorderRadius.circular(20),
//               border: Border.all(
//                   color: AppColors.cborder.withOpacity(.8), width: 1),
//             ),
//             child: Text(label,
//                 style: TextStyle(
//                     fontSize: 11,
//                     fontWeight: FontWeight.w600,
//                     color: AppColors.ctext.withOpacity(.7))),
//           ),
//           Expanded(
//               child:
//                   Divider(color: AppColors.cborder.withOpacity(.5), height: 1)),
//         ]),
//       );
// }

// // ─── Bubble tile ──────────────────────────────────────────────────────────────
// class _BubbleTile extends StatelessWidget {
//   final ChatMessage msg;
//   final bool isMe;
//   final String timeStr;
//   final bool isFirst;
//   final bool isLast;
//   final String senderInitial;

//   const _BubbleTile({
//     required this.msg,
//     required this.isMe,
//     required this.timeStr,
//     required this.isFirst,
//     required this.isLast,
//     required this.senderInitial,
//   });

//   @override
//   Widget build(BuildContext context) {
//     const double r = 20;
//     const double rSmall = 5;

//     // CRM-style grouped corner radii
//     final radius = isMe
//         ? BorderRadius.only(
//             topLeft: const Radius.circular(r),
//             topRight: Radius.circular(isFirst ? r : rSmall),
//             bottomLeft: const Radius.circular(r),
//             bottomRight: Radius.circular(isLast ? rSmall : r),
//           )
//         : BorderRadius.only(
//             topLeft: Radius.circular(isFirst ? r : rSmall),
//             topRight: const Radius.circular(r),
//             bottomLeft: Radius.circular(isLast ? rSmall : r),
//             bottomRight: const Radius.circular(r),
//           );

//     final bubbleDecor = isMe
//         ? BoxDecoration(
//             color: AppColors.c1,
//             borderRadius: radius,
//             boxShadow: [
//               BoxShadow(
//                 color: AppColors.c1.withOpacity(.22),
//                 blurRadius: 10,
//                 offset: const Offset(0, 3),
//               ),
//             ],
//           )
//         : BoxDecoration(
//             color: AppColors.cdark,
//             borderRadius: radius,
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(.12),
//                 blurRadius: 10,
//                 offset: const Offset(0, 3),
//               ),
//             ],
//           );

//     return Padding(
//       padding: EdgeInsets.only(
//         bottom: isLast ? 8 : 2,
//         top: isFirst ? 2 : 0,
//       ),
//       child: Row(
//         mainAxisAlignment:
//             isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           // Other-side avatar
//           if (!isMe) ...[
//             if (isLast)
//               Container(
//                 width: 28,
//                 height: 28,
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [AppColors.c1, AppColors.c3],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                   shape: BoxShape.circle,
//                 ),
//                 alignment: Alignment.center,
//                 child: Text(senderInitial,
//                     style: const TextStyle(
//                         color: AppColors.white,
//                         fontSize: 11,
//                         fontWeight: FontWeight.w700)),
//               )
//             else
//               const SizedBox(width: 28),
//             const SizedBox(width: 8),
//           ],

//           Flexible(
//             child: Column(
//               crossAxisAlignment:
//                   isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   constraints: BoxConstraints(
//                       maxWidth: MediaQuery.of(context).size.width * .72),
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//                   decoration: bubbleDecor,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         msg.content,
//                         style: const TextStyle(
//                           fontSize: 14,
//                           height: 1.45,
//                           color: AppColors.white,
//                           letterSpacing: 0.1,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 if (isLast)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 5, left: 4, right: 4),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Text(timeStr,
//                             style: TextStyle(
//                                 fontSize: 10,
//                                 color: AppColors.ctext.withOpacity(.45))),
//                         if (isMe) ...[
//                           const SizedBox(width: 4),
//                           Icon(Icons.done_all_rounded,
//                               size: 13, color: AppColors.c1),
//                         ],
//                       ],
//                     ),
//                   ),
//               ],
//             ),
//           ),

//           // My-side avatar
//           if (isMe) ...[
//             const SizedBox(width: 8),
//             if (isLast)
//               Container(
//                 width: 28,
//                 height: 28,
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [AppColors.c1, AppColors.c3],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                   shape: BoxShape.circle,
//                 ),
//                 alignment: Alignment.center,
//                 child: const Icon(Icons.person_rounded,
//                     color: AppColors.white, size: 14),
//               )
//             else
//               const SizedBox(width: 28),
//           ],
//         ],
//       ),
//     );
//   }
// }
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/models/data-models/chat/chat_message.dart';
import 'package:pokakbilling/models/services/chat_message_service.dart';
import 'package:pokakbilling/models/services/chat_inbox_service.dart';
import 'package:pokakbilling/viewmodels/chat_viewmodel.dart';

// ─────────────────────────────────────────────────────────────────────────────
// IN-APP MESSAGE BANNER  (logic unchanged, colours from AppColors)
// ─────────────────────────────────────────────────────────────────────────────
class InAppMessageBanner {
  static OverlayEntry? _entry;
  static Timer? _timer;

  static void show(
    BuildContext context, {
    required String senderName,
    required String message,
    String? avatarInitial,
    VoidCallback? onTap,
    Duration duration = const Duration(seconds: 4),
  }) {
    dismiss();
    final overlay = Overlay.of(context);

    _entry = OverlayEntry(
      builder: (_) => _BannerWidget(
        senderName: senderName,
        message: message,
        avatarInitial: avatarInitial ?? senderName[0].toUpperCase(),
        onTap: () {
          dismiss();
          onTap?.call();
        },
        onDismiss: dismiss,
      ),
    );

    overlay.insert(_entry!);
    _timer = Timer(duration, dismiss);
  }

  static void dismiss() {
    _timer?.cancel();
    _timer = null;
    _entry?.remove();
    _entry = null;
  }
}

class _BannerWidget extends StatefulWidget {
  const _BannerWidget({
    required this.senderName,
    required this.message,
    required this.avatarInitial,
    required this.onTap,
    required this.onDismiss,
  });

  final String senderName;
  final String message;
  final String avatarInitial;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  @override
  State<_BannerWidget> createState() => _BannerWidgetState();
}

class _BannerWidgetState extends State<_BannerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _slide = Tween<Offset>(begin: const Offset(0, -1.5), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _fade = Tween<double>(begin: 0, end: 1).animate(_ctrl);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    await _ctrl.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 12,
      right: 12,
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: GestureDetector(
            onTap: widget.onTap,
            onVerticalDragEnd: (d) {
              if (d.primaryVelocity != null && d.primaryVelocity! < 0) {
                _dismiss();
              }
            },
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.cdark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppColors.c1.withValues(alpha: 0.35), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(children: [
                  // Avatar
                  Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.c1, AppColors.c3],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      widget.avatarInitial,
                      style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(children: [
                          Expanded(
                            child: Text(
                              widget.senderName,
                              style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            DateFormat('HH:mm').format(DateTime.now()),
                            style: TextStyle(
                                color: AppColors.white.withValues(alpha: .55),
                                fontSize: 10.5),
                          ),
                        ]),
                        const SizedBox(height: 2),
                        Text(
                          widget.message,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: AppColors.white.withValues(alpha: .7),
                              fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _dismiss,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: .12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close_rounded,
                          color: AppColors.white.withValues(alpha: .7), size: 14),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CHAT ROOM SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class ChatRoomScreen extends StatefulWidget {
  final int roomId;
  final String userEmail;
  final String userName;
  final int? currentUserId;

  /// The OTHER participant's numeric user id.
  /// Required to create a room when [roomId] is 0 (brand-new conversation).
  final int? otherUserId;

  const ChatRoomScreen({
    super.key,
    required this.roomId,
    required this.userEmail,
    required this.userName,
    this.currentUserId,
    this.otherUserId,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Fade-in animation (CRM-style)
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fade;

  List<ChatMessage> _messages = [];
  bool _loading = true;
  bool _canSend = false;
  bool _creatingRoom = false;
  Timer? _poller;

  int _lastMessageCount = 0;
  bool _isFirstLoad = true;

  /// The real room id. Starts as widget.roomId (may be 0 for a brand-new
  /// conversation) and gets replaced with the server-assigned id the moment
  /// a room is created on first send.
  late int _effectiveRoomId;

  int get _currentUserId => widget.currentUserId ?? 0;
  bool get _isNewConversation => _effectiveRoomId == 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _effectiveRoomId = widget.roomId;

    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();

    _messageController.addListener(() {
      final can = _messageController.text.trim().isNotEmpty;
      if (can != _canSend) setState(() => _canSend = can);
    });

    if (_isNewConversation) {
      // Nothing to fetch yet — no room exists.
      _loading = false;
    } else {
      _fetch();
    }

    _poller = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_isNewConversation) _fetch();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_isNewConversation) _fetch();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _poller?.cancel();
    _fadeCtrl.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ── Fetch / Poll ──────────────────────────────────────────────────────────
  Future<void> _fetch() async {
    if (_isNewConversation) return; // no room yet — nothing to fetch

    try {
      final msgs = await ChatMessageService.fetchMessages(_effectiveRoomId);
      if (!mounted) return;

      final newCount = msgs.length;
      if (!_isFirstLoad && newCount > _lastMessageCount) {
        final newest = msgs.last;
        if (newest.senderId != _currentUserId) {
          InAppMessageBanner.show(
            context,
            senderName: widget.userName,
            message: newest.content,
            avatarInitial: widget.userName.isNotEmpty
                ? widget.userName[0].toUpperCase()
                : 'U',
          );
        }
      }

      _lastMessageCount = newCount;
      _isFirstLoad = false;

      setState(() {
        _messages = msgs;
        _loading = false;
      });
      _scrollToBottom();

      // Refresh inbox so lastAt updates → conversation sorts to top
      if (mounted && _currentUserId != 0) {
        final inboxVM = Provider.of<ChatInboxViewModel>(context, listen: false);
        if (inboxVM.currentUserId != null) {
          await inboxVM.fetchFor(inboxVM.currentUserId!, silent: true);
        }
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  // ── Send ──────────────────────────────────────────────────────────────────
  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty || _creatingRoom) return;

    // Brand-new conversation: create the room first.
    if (_isNewConversation) {
      if (widget.otherUserId == null) {
        _showSendError('Cannot start this conversation: missing recipient id.');
        return;
      }

      setState(() => _creatingRoom = true);
      try {
        final newRoomId = await ChatInboxService.createRoom(
          otherUserId: widget.otherUserId!,
          otherUserEmail: widget.userEmail,
        );
        if (!mounted) return;
        setState(() {
          _effectiveRoomId = newRoomId;
          _creatingRoom = false;
        });
      } catch (e) {
        if (!mounted) return;
        setState(() => _creatingRoom = false);
        _showSendError('Could not start conversation: $e');
        return;
      }
    }

    final now = DateTime.now();
    final tempId = -now.millisecondsSinceEpoch;
    final optimistic = ChatMessage(
      id: tempId,
      chatId: _effectiveRoomId,
      senderId: _currentUserId,
      content: content,
      createdAt: now,
    );

    setState(() => _messages = List.of(_messages)..add(optimistic));
    _lastMessageCount = _messages.length;
    _messageController.clear();
    _scrollToBottom();

    if (mounted) {
      final inboxVM = Provider.of<ChatInboxViewModel>(context, listen: false);
      inboxVM.updateRoomLastMessage(
        roomId: _effectiveRoomId,
        lastText: content,
        lastAt: now,
        senderId: _currentUserId,
      );
    }

    try {
      await ChatMessageService.sendMessage(
          roomId: _effectiveRoomId, content: content);
      await _fetch();
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages = _messages.where((m) => m.id != tempId).toList();
          _lastMessageCount = _messages.length;
        });
        _showSendError('Failed to send message: $e');
      }
    }
  }

  void _showSendError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        backgroundColor: AppColors.cdark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Text(message, style: const TextStyle(color: AppColors.white)),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  String _formatTime(DateTime time) => DateFormat('HH:mm').format(time);

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDay = DateTime(dt.year, dt.month, dt.day);
    final diff = today.difference(msgDay).inDays;
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
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  bool _showDateLabel(int i) {
    if (i == 0) return true;
    final p = _messages[i - 1].createdAt.toLocal();
    final c = _messages[i].createdAt.toLocal();
    return c.day != p.day || c.month != p.month || c.year != p.year;
  }

  bool _isMe(ChatMessage msg) =>
      _currentUserId != 0 && msg.senderId == _currentUserId;

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(children: [
          _buildAppBar(),
          Expanded(
            child: FadeTransition(
              opacity: _fade,
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.c1, strokeWidth: 2.5))
                  : _buildMessageList(),
            ),
          ),
          _buildInputBar(),
        ]),
      ),
    );
  }

  // ── APP BAR ───────────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    final initial =
        widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : 'U';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom:
              BorderSide(color: AppColors.cborder.withValues(alpha: .6), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.c1.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(children: [
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
        const SizedBox(width: 10),
        // Avatar with online dot
        Stack(children: [
          Container(
            width: 42,
            height: 42,
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
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
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
        ]),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.userName,
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
                widget.userEmail,
                style: TextStyle(
                    color: AppColors.ctext.withValues(alpha: .65), fontSize: 11.5),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ]),
    );
  }

  // ── MESSAGE LIST ──────────────────────────────────────────────────────────
  Widget _buildMessageList() {
    if (_messages.isEmpty) return _emptyChat();

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
      physics: const BouncingScrollPhysics(),
      itemCount: _messages.length,
      itemBuilder: (_, i) {
        final msg = _messages[i];
        final isMe = _isMe(msg);

        final isFirst = i == 0 || _messages[i - 1].senderId != msg.senderId;
        final isLast = i == _messages.length - 1 ||
            _messages[i + 1].senderId != msg.senderId;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_showDateLabel(i))
              _DateDivider(label: _formatDate(msg.createdAt)),
            _BubbleTile(
              msg: msg,
              isMe: isMe,
              timeStr: _formatTime(msg.createdAt),
              isFirst: isFirst,
              isLast: isLast,
              senderInitial: widget.userName.isNotEmpty
                  ? widget.userName[0].toUpperCase()
                  : 'U',
            ),
          ],
        );
      },
    );
  }

  // ── INPUT BAR ─────────────────────────────────────────────────────────────
  Widget _buildInputBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.cborder.withValues(alpha: .6), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.c1.withValues(alpha: 0.04),
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
                controller: _messageController,
                maxLines: null,
                textAlignVertical: TextAlignVertical.center,
                style: const TextStyle(
                    fontSize: 14, color: AppColors.cdark, height: 1.4),
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Type a message…',
                  hintStyle: TextStyle(
                      color: AppColors.ctext.withValues(alpha: .4), fontSize: 14),
                  border: InputBorder.none,
                  isCollapsed: true,
                  contentPadding: EdgeInsets.zero,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: _creatingRoom
                ? const SizedBox(
                    key: ValueKey('creating'),
                    width: 48,
                    height: 48,
                    child: Padding(
                      padding: EdgeInsets.all(14),
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: AppColors.c1),
                    ),
                  )
                : _canSend
                    ? GestureDetector(
                        key: const ValueKey('send'),
                        onTap: _sendMessage,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.c1,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.c1.withValues(alpha: .35),
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
                        key: ValueKey('idle'), width: 48, height: 48),
          ),
        ],
      ),
    );
  }

  // ── EMPTY ─────────────────────────────────────────────────────────────────
  Widget _emptyChat() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.c1.withValues(alpha: .08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.waving_hand_rounded,
                  color: AppColors.c1.withValues(alpha: .55), size: 34),
            ),
            const SizedBox(height: 20),
            const Text('Say hello!',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.cdark,
                    letterSpacing: -0.3)),
            const SizedBox(height: 6),
            Text('Be the first to break the ice 👋',
                style: TextStyle(
                    fontSize: 13, color: AppColors.ctext.withValues(alpha: .55))),
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
                  Divider(color: AppColors.cborder.withValues(alpha: .5), height: 1)),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.cxl,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: AppColors.cborder.withValues(alpha: .8), width: 1),
            ),
            child: Text(label,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ctext.withValues(alpha: .7))),
          ),
          Expanded(
              child:
                  Divider(color: AppColors.cborder.withValues(alpha: .5), height: 1)),
        ]),
      );
}

// ─── Bubble tile ──────────────────────────────────────────────────────────────
class _BubbleTile extends StatelessWidget {
  final ChatMessage msg;
  final bool isMe;
  final String timeStr;
  final bool isFirst;
  final bool isLast;
  final String senderInitial;

  const _BubbleTile({
    required this.msg,
    required this.isMe,
    required this.timeStr,
    required this.isFirst,
    required this.isLast,
    required this.senderInitial,
  });

  @override
  Widget build(BuildContext context) {
    const double r = 20;
    const double rSmall = 5;

    // CRM-style grouped corner radii
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
                color: AppColors.c1.withValues(alpha: .22),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          )
        : BoxDecoration(
            color: AppColors.cdark,
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .12),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          );

    return Padding(
      padding: EdgeInsets.only(
        bottom: isLast ? 8 : 2,
        top: isFirst ? 2 : 0,
      ),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Other-side avatar
          if (!isMe) ...[
            if (isLast)
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.c1, AppColors.c3],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(senderInitial,
                    style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
              )
            else
              const SizedBox(width: 28),
            const SizedBox(width: 8),
          ],

          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
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
                        msg.content,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.45,
                          color: AppColors.white,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isLast)
                  Padding(
                    padding: const EdgeInsets.only(top: 5, left: 4, right: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(timeStr,
                            style: TextStyle(
                                fontSize: 10,
                                color: AppColors.ctext.withValues(alpha: .45))),
                        if (isMe) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.done_all_rounded,
                              size: 13, color: AppColors.c1),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // My-side avatar
          if (isMe) ...[
            const SizedBox(width: 8),
            if (isLast)
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.c1, AppColors.c3],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.person_rounded,
                    color: AppColors.white, size: 14),
              )
            else
              const SizedBox(width: 28),
          ],
        ],
      ),
    );
  }
}
