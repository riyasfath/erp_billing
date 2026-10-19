import 'package:erp_academy/core/app_colors.dart';
import 'package:erp_academy/viewmodels/shedule_live_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../services/live_service.dart';

class ScheduleLiveScreen extends StatelessWidget {
  const ScheduleLiveScreen({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (_) => ScheduleLiveViewModel(LiveService()),
        child: const _Body(),
      );
}

class _Body extends StatefulWidget {
  const _Body();
  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  static const _fieldBg = Color(0xFFF1F3FC);
  static const _cardBg = Color(0xFFEEF0FE);

  final _title = TextEditingController(
      text: 'Deep Learning & Neural Networks: Architecture Mastery');
  final _subtitle = TextEditingController(
      text: 'Master consensus, cloud native fault tolerance, and more');

  @override
  void initState() {
    super.initState();
    _title.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _title.dispose();
    _subtitle.dispose();
    super.dispose();
  }

  Future<void> _submit(bool schedule) async {
    final vm = context.read<ScheduleLiveViewModel>();
    final ok = schedule
        ? await vm.schedule(_title.text, _subtitle.text)
        : await vm.saveDraft(_title.text, _subtitle.text);
    if (!mounted || !ok) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(schedule ? 'Live scheduled' : 'Draft saved')));
    if (schedule) Navigator.pop(context);
  }

  Future<void> _pickDate() async {
    final vm = context.read<ScheduleLiveViewModel>();
    final now = DateTime.now();
    final d = await showDatePicker(
        context: context,
        initialDate: vm.date,
        firstDate: now,
        lastDate: now.add(const Duration(days: 365)));
    if (d != null) vm.setCustomDate(d);
  }

  Future<void> _pickTime() async {
    final vm = context.read<ScheduleLiveViewModel>();
    final t = await showTimePicker(context: context, initialTime: vm.start);
    if (t != null) vm.setTime(t);
  }

  InputDecoration _dec() => InputDecoration(
        filled: true,
        fillColor: _fieldBg,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none),
      );

  Widget _label(String t, {bool required = false, String? trailing}) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text.rich(TextSpan(
              text: t,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              children: [
                if (required)
                  const TextSpan(
                      text: ' *', style: TextStyle(color: AppColors.red))
              ])),
          if (trailing != null)
            Text(trailing,
                style: const TextStyle(fontSize: 12, color: AppColors.muted)),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ScheduleLiveViewModel>();
    const dayLabels = ['Today', 'Tomorrow', 'Custom'];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
              child:
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.chevron_left, size: 24),
                    Text('Courses',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                  ]),
                ),
                const SizedBox(height: 24),
                const Text('Live operation suite',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                const Text(
                    'Set up an interactive live broadcast or lecture session\nfor enrolled students across your academic cohorts.',
                    style: TextStyle(fontSize: 12, color: AppColors.muted)),
                const SizedBox(height: 22),
                _label('Session Title',
                    required: true, trailing: '${_title.text.length}/80'),
                TextField(
                    controller: _title,
                    inputFormatters: [LengthLimitingTextInputFormatter(80)],
                    decoration: _dec()),
                const SizedBox(height: 18),
                _label('Catalog Subtitle'),
                TextField(controller: _subtitle, decoration: _dec()),
                const SizedBox(height: 18),
                _label('Curriculum Milestone'),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: vm.milestone,
                  items: vm.milestones
                      .map((m) => DropdownMenuItem(
                          value: m,
                          child: Text(m, overflow: TextOverflow.ellipsis)))
                      .toList(),
                  onChanged: vm.setMilestone,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  decoration: _dec().copyWith(
                      prefixIcon: const Icon(Icons.edit_note, size: 22)),
                ),
                const SizedBox(height: 28),
                const Text('Date, Time & Cluster Region',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Row(
                    children: List.generate(3, (i) {
                  final sel = vm.dayIndex == i;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => i == 2 ? _pickDate() : vm.setDay(i),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                            color: sel
                                ? const Color(0xFF0B1220)
                                : const Color(0xFFE9ECFB),
                            borderRadius: BorderRadius.circular(8)),
                        child: Row(children: [
                          if (i == 2) ...[
                            Icon(Icons.edit_calendar_outlined,
                                size: 14,
                                color: sel ? Colors.white : AppColors.text),
                            const SizedBox(width: 4),
                          ],
                          Text(dayLabels[i],
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      sel ? Colors.white : AppColors.text)),
                        ]),
                      ),
                    ),
                  );
                })),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: const Color(0xFFF7F8FF),
                      border: Border.all(color: const Color(0xFFDDE1F5)),
                      borderRadius: BorderRadius.circular(12)),
                  child: Row(children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.calendar_month,
                          color: AppColors.primary),
                    ),
                    const SizedBox(width: 14),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(vm.dateTitle,
                              style: const TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w700)),
                          Text(vm.dateSub,
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.muted)),
                        ]),
                  ]),
                ),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickTime,
                      child: _infoCard('START TIME', Icons.access_time,
                          vm.startLabel, 'EST (UTC-5)'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _infoCard('DURATION', Icons.timer_outlined,
                        '${vm.duration} Min', 'Ends at ${vm.endLabel}'),
                  ),
                ]),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                      color: const Color(0xFFEEF0FE),
                      borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: ScheduleLiveViewModel.durations.map((d) {
                      final sel = vm.duration == d;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => vm.setDuration(d),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: sel ? Colors.white : null,
                                borderRadius: BorderRadius.circular(8)),
                            child: Text('${d}m',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: sel
                                        ? FontWeight.w700
                                        : FontWeight.w400)),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Low-Latency Media Region',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: _cardBg, borderRadius: BorderRadius.circular(10)),
                  child: Row(children: [
                    const Icon(Icons.circle, size: 10, color: AppColors.primary),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(ScheduleLiveViewModel.region,
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700)),
                            SizedBox(height: 2),
                            Text('18ms median latency • Zero Packet Loss',
                                style: TextStyle(fontSize: 11)),
                          ]),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                      child: const Text('Optimal',
                          style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFF0284C7),
                              fontWeight: FontWeight.w600)),
                    ),
                  ]),
                ),
              ]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Row(children: [
              Expanded(
                flex: 4,
                child: ElevatedButton.icon(
                  onPressed: vm.busy ? null : () => _submit(false),
                  icon: const Icon(Icons.bookmark_border, size: 18),
                  label: const Text('Save Draft'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE3E4E8),
                      foregroundColor: AppColors.text,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 6,
                child: ElevatedButton(
                  onPressed: vm.busy ? null : () => _submit(true),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0B1220),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  child: vm.busy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                              Text('Schedule'),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, size: 18),
                            ]),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _infoCard(String label, IconData icon, String value, String sub) =>
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: _cardBg, borderRadius: BorderRadius.circular(10)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 10, letterSpacing: .6, color: AppColors.muted)),
          const SizedBox(height: 8),
          Row(children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: 6),
            Flexible(
                child: Text(value,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700))),
          ]),
          const SizedBox(height: 6),
          Text(sub,
              style: const TextStyle(fontSize: 10, color: AppColors.muted)),
        ]),
      );
}