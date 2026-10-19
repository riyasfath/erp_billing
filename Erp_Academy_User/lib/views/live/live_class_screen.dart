import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../models/chat_message.dart';
import '../../services/live_class_service.dart';
import '../../viewmodels/live_class_viewmodel.dart';

class LiveClassScreen extends StatelessWidget {
  const LiveClassScreen({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (_) => LiveClassViewModel(LiveClassService()),
        child: const _Body(),
      );
}

class _Body extends StatefulWidget {
  const _Body();
  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  final _input = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send() {
    context.read<LiveClassViewModel>().send(_input.text);
    _input.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut);
      }
    });
  }

  void _showParticipants(LiveClassViewModel vm) {
    showModalBottomSheet(
      context: context,
      builder: (_) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Participants',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ...vm.participants.map((n) => ListTile(
                leading: CircleAvatar(
                    backgroundColor: AppColors.chip,
                    child: Text(n[0],
                        style: const TextStyle(color: AppColors.indigo))),
                title: Text(n),
              )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LiveClassViewModel>();

    return Scaffold(
      backgroundColor: AppColors.page,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Column(children: [
            const SizedBox(height: 8),
            Row(children: [
              InkWell(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.close, size: 20),
                ),
              ),
              const Expanded(
                child: Center(
                  child: Text('Live Class',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 38),
            ]),
            const SizedBox(height: 12),
            _video(vm),
            const SizedBox(height: 10),
            Expanded(
              child: vm.loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      controller: _scroll,
                      itemCount: vm.messages.length,
                      itemBuilder: (_, i) => _message(vm.messages[i]),
                    ),
            ),
            const SizedBox(height: 8),
            _inputBar(),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                  child: _action(
                      Icons.forum_outlined, 'Chat', true, () {})),
              const SizedBox(width: 10),
              Expanded(
                  child: _action(Icons.back_hand_outlined, 'Raise Hand',
                      vm.handRaised, vm.toggleHand)),
              const SizedBox(width: 10),
              Expanded(
                  child: _action(Icons.people_outline, 'Participants', false,
                      () => _showParticipants(vm))),
            ]),
            const SizedBox(height: 12),
          ]),
        ),
      ),
    );
  }

  Widget _video(LiveClassViewModel vm) => ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 200,
          width: double.infinity,
          color: const Color(0xFF7A8794), // TODO: real video player
          child: Stack(children: [
            const Center(
                child: Icon(Icons.person, size: 90, color: Colors.white54)),
            Positioned(
              left: 10,
              top: 10,
              child: Row(children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(8)),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.circle, size: 7, color: Colors.white),
                    SizedBox(width: 4),
                    Text('LIVE',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700)),
                  ]),
                ),
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.people_outline,
                        size: 13, color: Colors.white),
                    const SizedBox(width: 4),
                    Text('${vm.watching} watching',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 11)),
                  ]),
                ),
              ]),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 18, 12, 10),
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54])),
                child: Row(children: [
                  Expanded(
                    child: Text(vm.title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700)),
                  ),
                  const Icon(Icons.fullscreen, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  const Icon(Icons.more_horiz, color: Colors.white, size: 20),
                ]),
              ),
            ),
          ]),
        ),
      );

  Widget _message(ChatMessage m) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: const Color(0xFFF1F2F7),
            borderRadius: BorderRadius.circular(12)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          CircleAvatar(
              radius: 19,
              backgroundColor: m.color,
              child: Text(m.name[0],
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600))),
          const SizedBox(width: 10),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(m.name,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(m.text, style: const TextStyle(fontSize: 13)),
            ]),
          ),
          Text(m.time,
              style: const TextStyle(fontSize: 11, color: AppColors.muted)),
        ]),
      );

  Widget _inputBar() => Container(
        padding: const EdgeInsets.fromLTRB(14, 4, 6, 4),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          Expanded(
            child: TextField(
              controller: _input,
              onSubmitted: (_) => _send(),
              decoration: const InputDecoration(
                  hintText: 'Ask a question...',
                  hintStyle: TextStyle(color: AppColors.muted, fontSize: 14),
                  border: InputBorder.none),
            ),
          ),
          InkWell(
            onTap: _send,
            child: Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                  color: AppColors.indigo, shape: BoxShape.circle),
              child: const Icon(Icons.send_outlined,
                  color: Colors.white, size: 20),
            ),
          ),
        ]),
      );

  Widget _action(
          IconData icon, String label, bool selected, VoidCallback onTap) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
              color: selected ? AppColors.chip : Colors.white,
              borderRadius: BorderRadius.circular(12)),
          child: Column(children: [
            Icon(icon,
                size: 24,
                color: selected ? AppColors.chipText : const Color(0xFF374151)),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color:
                        selected ? AppColors.chipText : AppColors.text)),
          ]),
        ),
      );
}