import 'package:erp_user/core/widgets/section_headers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../viewmodels/home_viewmodel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // load data once when screen opens
    WidgetsBinding.instance
        .addPostFrameCallback((_) => context.read<HomeViewModel>().load());
  }

  BoxDecoration get _card => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 10)
      ]);

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();
    if (vm.loading) return const Center(child: CircularProgressIndicator());

    final up = vm.upcoming!;
    final cont = vm.continueItem!;

    return ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 24), children: [
      // Header
      Row(children: [
        const CircleAvatar(
            radius: 24,
            backgroundColor: Color(0xFFDDE3FA),
            child: Icon(Icons.person, color: AppColors.primary)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Good Morning, ${vm.userName} 👋',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const Text('Ready to continue learning?',
                style: TextStyle(fontSize: 12, color: AppColors.muted)),
          ]),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration:
              const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: const Icon(Icons.notifications_none, size: 22),
        ),
      ]),
      const SizedBox(height: 18),

      // Upcoming class card
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
            color: AppColors.primary, borderRadius: BorderRadius.circular(22)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: const Color(0xFF6FA8FF),
                  borderRadius: BorderRadius.circular(8)),
              child: const Text('UPCOMING',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ),
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                  color: const Color(0xFF1B1B2F),
                  borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.palette, color: Colors.white),
            ),
          ]),
          const SizedBox(height: 8),
          Text(up.title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(up.subtitle,
                    style: const TextStyle(color: Colors.white, fontSize: 14)),
                const SizedBox(height: 8),
                Row(children: [
                  const CircleAvatar(
                      radius: 17,
                      backgroundColor: Color(0xFFDDE3FA),
                      child: Icon(Icons.person, size: 18)),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(up.instructor,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12)),
                          Row(children: [
                            const Icon(Icons.calendar_today_outlined,
                                size: 11, color: Colors.white70),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(up.time,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 11)),
                            ),
                          ]),
                        ]),
                  ),
                ]),
              ]),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              const Text('Starts in',
                  style: TextStyle(color: Colors.white70, fontSize: 11)),
              Text(vm.countdown,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600)),
            ]),
          ]),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              child: const Text('Join Now',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ]),
      ),
      const SizedBox(height: 16),

      // Continue Learning
      Container(
        padding: const EdgeInsets.all(16),
        decoration: _card,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionHeader('Continue Learning'),
          const SizedBox(height: 12),
          Row(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 92,
                height: 82,
                color: const Color(0xFFB9C8E8), // TODO: Image.asset
                child: const Icon(Icons.image_outlined, color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(cont.module,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.muted)),
                const SizedBox(height: 4),
                Text(cont.title,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.play_circle_outline,
                      size: 14, color: AppColors.muted),
                  const SizedBox(width: 4),
                  Text(cont.duration,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.muted)),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: cont.progress / 100,
                        minHeight: 4,
                        backgroundColor: const Color(0xFFE5E7EB),
                        color: AppColors.button,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${cont.progress}%',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.muted)),
                ]),
              ]),
            ),
          ]),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.button,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
              child: const Text('Continue Learning',
                  style: TextStyle(fontSize: 13)),
            ),
          ),
        ]),
      ),
      const SizedBox(height: 16),

      // My Courses
      Container(
        padding: const EdgeInsets.all(16),
        decoration: _card,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionHeader('My Courses'),
          const SizedBox(height: 12),
          Row(
            children: vm.courses
                .map((c) => Expanded(
                      child: Container(
                        margin: EdgeInsets.only(
                            right: c == vm.courses.last ? 0 : 10),
                        decoration: BoxDecoration(
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(12)),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12)),
                                child: Container(
                                  height: 84,
                                  width: double.infinity,
                                  color: c.color, // TODO: Image.asset
                                  child: const Icon(Icons.image_outlined,
                                      color: Colors.white),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(c.title,
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700)),
                                      const SizedBox(height: 10),
                                      Row(children: [
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            child: LinearProgressIndicator(
                                              value: c.progress / 100,
                                              minHeight: 4,
                                              backgroundColor:
                                                  const Color(0xFFE5E7EB),
                                              color: AppColors.button,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text('${c.progress}%',
                                            style: const TextStyle(
                                                fontSize: 10,
                                                color: AppColors.muted)),
                                      ]),
                                    ]),
                              ),
                            ]),
                      ),
                    ))
                .toList(),
          ),
        ]),
      ),
      const SizedBox(height: 16),

      // Recent Activity
      Container(
        padding: const EdgeInsets.all(16),
        decoration: _card,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionHeader('Recent Activity'),
          const SizedBox(height: 8),
          ...vm.activity.map((a) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(children: [
                  CircleAvatar(
                      radius: 19,
                      backgroundColor: a.color,
                      child: Icon(a.icon, color: Colors.white, size: 20)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(a.title,
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600)),
                          Text(a.subtitle,
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.muted)),
                        ]),
                  ),
                  Text(a.time,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.muted)),
                  const Icon(Icons.chevron_right,
                      size: 16, color: AppColors.muted),
                ]),
              )),
        ]),
      ),
    ]);
  }
}