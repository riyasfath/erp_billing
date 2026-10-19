import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:pokakbilling/viewmodels/chat_viewmodel.dart';
import 'package:pokakbilling/views/Screens/inbox/chat_widgets.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fade;
  final TextEditingController _nameCtrl = TextEditingController();
  final Set<int> _selected = {};
  int _step = 1;
  bool _creating = false;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();

    // Load users for selection
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatViewModel>().fetchUsers();
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  void _toggle(int id) => setState(
      () => _selected.contains(id) ? _selected.remove(id) : _selected.add(id));

  void _next() {
    if (_selected.isEmpty) {
      _snack('Select at least one member');
      return;
    }
    setState(() => _step = 2);
  }

  Future<void> _create() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      _snack('Enter a group name');
      return;
    }
    setState(() => _creating = true);
    final conv = await context.read<ChatViewModel>().createGroup(
          name: name,
          userIds: _selected.toList(),
        );
    if (!mounted) return;
    setState(() => _creating = false);
    if (conv != null) {
      Navigator.pop(context, conv);
    } else {
      _snack('Failed to create group. Please try again.');
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: AppColors.white,
      resizeToAvoidBottomInset: true,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: FadeTransition(
          opacity: _fade,
          child: Column(children: [
            _buildHeader(context, mq.padding.top, mq.size.width),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28)),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28)),
                  child: Column(children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(top: 12, bottom: 6),
                      decoration: BoxDecoration(
                          color: AppColors.c1.withOpacity(.40),
                          borderRadius: BorderRadius.circular(2)),
                    ),
                    _buildStepIndicator(),
                    const SizedBox(height: 4),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 280),
                        transitionBuilder: (c, a) =>
                            FadeTransition(opacity: a, child: c),
                        child: _step == 1
                            ? _buildSelectMembers()
                            : _buildNameGroup(),
                      ),
                    ),
                    _buildBtn(mq.padding.bottom),
                  ]),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double topPad, double sw) =>
      Container(
        padding: EdgeInsets.only(
            top: topPad + 10, bottom: 14, left: sw * .045, right: sw * .045),
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(
            bottom: BorderSide(color: AppColors.cborder, width: 1.5),
          ),
        ),
        child: Row(children: [
          GestureDetector(
            onTap: () {
              if (_step == 2) {
                setState(() => _step = 1);
              } else {
                Navigator.pop(context);
              }
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.cxl,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cborder),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppColors.c3, size: 15),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('New Group',
                  style: TextStyle(
                      color: AppColors.cdark,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3)),
              const SizedBox(height: 2),
              Text(
                  _step == 1
                      ? '${_selected.length} member${_selected.length != 1 ? 's' : ''} selected'
                      : 'Name your group',
                  style: TextStyle(
                      color: AppColors.cdark.withOpacity(.60), fontSize: 12)),
            ]),
          ),
        ]),
      );

  Widget _buildStepIndicator() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        child: Row(children: [
          _StepDot(
              label: '1',
              title: 'Add Members',
              active: _step == 1,
              done: _step > 1),
          Expanded(
              child: Container(
                  height: 1.5, color: _step > 1 ? AppColors.c1 : AppColors.c1)),
          _StepDot(
              label: '2', title: 'Group Name', active: _step == 2, done: false),
        ]),
      );

  Widget _buildSelectMembers() {
    return Consumer<ChatViewModel>(
      key: const ValueKey(1),
      builder: (ctx, vm, _) {
        if (vm.loadingUsers) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.c1));
        }
        final users = vm.users;
        if (users.isEmpty) {
          return const Center(
              child: Text('No users found',
                  style: TextStyle(color: AppColors.ctext, fontSize: 14)));
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 20),
          physics: const BouncingScrollPhysics(),
          itemCount: users.length,
          separatorBuilder: (_, __) =>
              const Divider(height: 1, color: AppColors.cborder),
          itemBuilder: (ctx, i) {
            final user = users[i];
            final isSel = _selected.contains(user.id);
            return GestureDetector(
              onTap: () => _toggle(user.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                decoration: BoxDecoration(
                  color: isSel
                      ? AppColors.c1.withOpacity(.08)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(children: [
                  ChatAvatar(
                    initials: user.initials,
                    imageUrl: user.profilePicture,
                    size: 46,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.fullName,
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight:
                                      isSel ? FontWeight.w700 : FontWeight.w500,
                                  color:
                                      isSel ? AppColors.c1 : AppColors.cdark)),
                          if (user.department != null)
                            Text(user.department!,
                                style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.cdark.withOpacity(.50))),
                        ]),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      gradient: isSel
                          ? const LinearGradient(
                              colors: [AppColors.c1, AppColors.c1],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight)
                          : null,
                      color: isSel ? null : Colors.transparent,
                      shape: BoxShape.circle,
                      border: isSel
                          ? null
                          : Border.all(
                              color: AppColors.c1.withOpacity(.40), width: 1.5),
                    ),
                    child: isSel
                        ? const Icon(Icons.check_rounded,
                            color: AppColors.white, size: 14)
                        : null,
                  ),
                ]),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNameGroup() {
    return Consumer<ChatViewModel>(
      key: const ValueKey(2),
      builder: (ctx, vm, _) {
        final selected = vm.users.where((u) => _selected.contains(u.id));
        return SingleChildScrollView(
          padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20),
          physics: const BouncingScrollPhysics(),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [AppColors.c1, AppColors.c1],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.c1.withOpacity(.30),
                        blurRadius: 16,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: const Icon(Icons.group_rounded,
                    color: AppColors.white, size: 36),
              ),
            ),
            const SizedBox(height: 20),
            Text('Group Name',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.cdark.withOpacity(.60),
                    letterSpacing: 0.4)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.cxl,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cborder),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                controller: _nameCtrl,
                autofocus: true,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.cdark),
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: 'e.g. Sales Team, HR Crew…',
                  hintStyle: TextStyle(
                      color: AppColors.cdark.withOpacity(.35),
                      fontSize: 14,
                      fontWeight: FontWeight.w400),
                  border: InputBorder.none,
                  isCollapsed: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Members (${_selected.length + 1})',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.cdark.withOpacity(.60),
                    letterSpacing: 0.4)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                const _MemberChip(name: 'You', initials: 'ME', isMe: true),
                ...selected.map((u) => _MemberChip(
                      name: u.firstName,
                      initials: u.initials,
                      imageUrl: u.profilePicture,
                      onRemove: () => setState(() => _selected.remove(u.id)),
                    )),
              ],
            ),
          ]),
        );
      },
    );
  }

  Widget _buildBtn(double botPad) => Container(
        color: AppColors.white,
        padding: EdgeInsets.fromLTRB(20, 12, 20, botPad > 0 ? botPad : 16),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: GestureDetector(
            onTap: _creating ? null : (_step == 1 ? _next : _create),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                  color: AppColors.c1,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.c1.withOpacity(0.06),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ]),
              child: Center(
                child: _creating
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: AppColors.white, strokeWidth: 2.5))
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                              _step == 1
                                  ? Icons.arrow_forward_rounded
                                  : Icons.check_rounded,
                              color: AppColors.c1,
                              size: 18),
                          const SizedBox(width: 8),
                          Text(
                              _step == 1
                                  ? 'Continue  (${_selected.length} selected)'
                                  : 'Create Group',
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.white)),
                        ],
                      ),
              ),
            ),
          ),
        ),
      );
}

class _StepDot extends StatelessWidget {
  final String label;
  final String title;
  final bool active;
  final bool done;
  const _StepDot(
      {required this.label,
      required this.title,
      required this.active,
      required this.done});

  @override
  Widget build(BuildContext context) => Column(children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            gradient: (active || done)
                ? const LinearGradient(
                    colors: [AppColors.c1, AppColors.c1],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight)
                : null,
            color: (active || done) ? null : AppColors.c1,
            shape: BoxShape.circle,
            border: Border.all(
                color: (active || done) ? AppColors.c1 : AppColors.c1,
                width: 1.5),
          ),
          child: Center(
            child: done
                ? const Icon(Icons.check_rounded,
                    color: AppColors.white, size: 14)
                : Text(label,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: active ? AppColors.white : AppColors.white)),
          ),
        ),
        const SizedBox(height: 4),
        Text(title,
            style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: (active || done)
                    ? AppColors.c1
                    : AppColors.cdark.withOpacity(.40))),
      ]);
}

class _MemberChip extends StatelessWidget {
  final String name;
  final String initials;
  final String? imageUrl;
  final bool isMe;
  final VoidCallback? onRemove;

  const _MemberChip({
    required this.name,
    required this.initials,
    this.imageUrl,
    this.isMe = false,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isMe
              ? AppColors.c1.withOpacity(.20)
              : AppColors.c1.withOpacity(.20),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isMe
                  ? AppColors.c1.withOpacity(.50)
                  : AppColors.c1.withOpacity(.20)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          ChatAvatar(initials: initials, imageUrl: imageUrl, size: 20),
          const SizedBox(width: 6),
          Text(name,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isMe ? AppColors.c1 : AppColors.c1)),
          if (onRemove != null) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onRemove,
              child: Icon(Icons.close_rounded,
                  size: 13, color: AppColors.cdark.withOpacity(.50)),
            ),
          ],
        ]),
      );
}
