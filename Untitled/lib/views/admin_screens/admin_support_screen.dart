import 'package:ecommerce_app/views/admin_screens/admin_support_ticket_detail.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../admin/admin_model/admin_support_model.dart';
import '../../admin/admin_viewmodel/admin_support_viewmodel.dart';

const Color _accent = Color(0xFF6366F1);
const Color _textDark = Color(0xFF0F172A);
const Color _textGrey = Color(0xFF64748B);
const Color _bg = Color(0xFFF5F6FA);

// Best-guess status set — API only confirmed "new", "in_progress",
// "resolved" in samples, but stats also track rejected/spam counts.
Color ticketStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'new':
      return const Color(0xFF3B82F6);
    case 'in_progress':
      return const Color(0xFFF59E0B);
    case 'resolved':
      return const Color(0xFF16A34A);
    case 'rejected':
      return const Color(0xFFEF4444);
    case 'spam':
      return _textGrey;
    default:
      return _textGrey;
  }
}

IconData ticketStatusIcon(String status) {
  switch (status.toLowerCase()) {
    case 'new':
      return Icons.fiber_new_rounded;
    case 'in_progress':
      return Icons.autorenew_rounded;
    case 'resolved':
      return Icons.task_alt_rounded;
    case 'rejected':
      return Icons.cancel_rounded;
    case 'spam':
      return Icons.report_gmailerrorred_rounded;
    default:
      return Icons.circle;
  }
}

class AdminSupportScreen extends StatefulWidget {
  const AdminSupportScreen({super.key});

  @override
  State<AdminSupportScreen> createState() => _AdminSupportScreenState();
}

class _AdminSupportScreenState extends State<AdminSupportScreen> {
  String _filter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminSupportViewModel>().fetchAll();
    });
  }

  Future<void> _openTicket(int id) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => AdminSupportTicketDetailScreen(ticketId: id)));
    if (mounted) context.read<AdminSupportViewModel>().fetchAll();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AdminSupportViewModel>();

    if (viewModel.isLoading && viewModel.stats == null) {
      return const Center(child: CircularProgressIndicator(color: _accent));
    }
    if (viewModel.error != null && viewModel.stats == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 44, color: _textGrey),
            const SizedBox(height: 14),
            Text(viewModel.error!, style: const TextStyle(color: _textGrey)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => viewModel.fetchAll(),
              style: ElevatedButton.styleFrom(backgroundColor: _accent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    final stats = viewModel.stats;
    final filtered = _filter == 'All' ? viewModel.tickets : viewModel.tickets.where((t) => t.status.toLowerCase() == _filter).toList();

    return Container(
      color: _bg,
      child: RefreshIndicator(
        color: _accent,
        onRefresh: () => viewModel.fetchAll(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            if (stats != null) _statsGrid(stats),
            const SizedBox(height: 20),
            _filterBar(),
            const SizedBox(height: 14),
            if (filtered.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(child: Text('No tickets found', style: const TextStyle(color: _textGrey))),
              )
            else
              ...filtered.map((t) => Padding(padding: const EdgeInsets.only(bottom: 12), child: _ticketTile(t))),
          ],
        ),
      ),
    );
  }

  Widget _statsGrid(AdminSupportStatsModel stats) {
    final items = [
      ('Total', stats.totalTickets, Icons.confirmation_number_rounded, _accent),
      ('New', stats.newTickets, Icons.fiber_new_rounded, const Color(0xFF3B82F6)),
      ('Pending', stats.pendingTickets, Icons.hourglass_top_rounded, const Color(0xFFF59E0B)),
      ('Resolved Today', stats.resolvedToday, Icons.task_alt_rounded, const Color(0xFF16A34A)),
      ('Rejected', stats.rejectedTickets, Icons.cancel_rounded, const Color(0xFFEF4444)),
      ('Spam', stats.spamTickets, Icons.report_gmailerrorred_rounded, _textGrey),
    ];

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.95,
      children: items.map((item) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 14, offset: const Offset(0, 6))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(color: (item.$4 as Color).withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                child: Icon(item.$3 as IconData, size: 16, color: item.$4 as Color),
              ),
              const Spacer(),
              Text('${item.$2}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _textDark)),
              Text(item.$1 as String, style: const TextStyle(fontSize: 10, color: _textGrey), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _filterBar() {
    const filters = ['All', 'new', 'in_progress', 'resolved', 'rejected', 'spam'];
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final f = filters[i];
          final selected = f == _filter;
          final color = f == 'All' ? _accent : ticketStatusColor(f);
          return GestureDetector(
            onTap: () => setState(() => _filter = f),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: selected ? LinearGradient(colors: [color, color.withOpacity(0.75)]) : null,
                color: selected ? null : Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: selected ? [BoxShadow(color: color.withOpacity(0.35), blurRadius: 10, offset: const Offset(0, 4))] : null,
              ),
              child: Text(
                f == 'All' ? 'All' : f.replaceAll('_', ' '),
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: selected ? Colors.white : _textGrey),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _ticketTile(AdminSupportTicketModel ticket) {
    final color = ticketStatusColor(ticket.status);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _openTicket(ticket.id),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 6))],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                child: Icon(ticketStatusIcon(ticket.status), color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ticket.subject, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _textDark)),
                    const SizedBox(height: 3),
                    Text(ticket.fullName, style: const TextStyle(fontSize: 12, color: _textGrey)),
                    const SizedBox(height: 2),
                    Text(ticket.message, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: _textGrey)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                    child: Text(ticket.statusDisplay, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
                  ),
                  const SizedBox(height: 6),
                  Text(ticket.createdAtFmt, style: const TextStyle(fontSize: 10, color: _textGrey)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}