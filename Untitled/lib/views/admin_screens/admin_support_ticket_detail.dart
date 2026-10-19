import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../admin/admin_model/admin_support_model.dart';
import '../../admin/admin_viewmodel/admin_support_viewmodel.dart';
import 'admin_support_screen.dart' show ticketStatusColor, ticketStatusIcon;

const Color _accent = Color(0xFF6366F1);
const Color _textDark = Color(0xFF0F172A);
const Color _textGrey = Color(0xFF64748B);
const Color _bg = Color(0xFFF5F6FA);

// Best-guess status set — see note in admin_support_screen.dart.
const List<String> _statusOptions = ['new', 'in_progress', 'resolved', 'rejected', 'spam'];

class AdminSupportTicketDetailScreen extends StatefulWidget {
  final int ticketId;
  const AdminSupportTicketDetailScreen({super.key, required this.ticketId});

  @override
  State<AdminSupportTicketDetailScreen> createState() => _AdminSupportTicketDetailScreenState();
}

class _AdminSupportTicketDetailScreenState extends State<AdminSupportTicketDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminSupportViewModel>().fetchDetail(widget.ticketId);
    });
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? const Color(0xFFEF4444) : const Color(0xFF16A34A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
      ),
    );
  }

  Future<void> _changeStatus(AdminSupportViewModel viewModel, String status) async {
    final success = await viewModel.updateStatus(widget.ticketId, status);
    if (!mounted) return;
    if (success) {
      _showSnack('Ticket marked as ${status.replaceAll('_', ' ')}');
    } else {
      _showSnack(viewModel.detailError ?? 'Could not update ticket', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AdminSupportViewModel>();
    final ticket = viewModel.selectedTicket;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: _textDark,
        title: const Text('Support Ticket', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: viewModel.isLoadingDetail
          ? const Center(child: CircularProgressIndicator(color: _accent))
          : viewModel.detailError != null && ticket == null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(viewModel.detailError!, style: const TextStyle(color: _textGrey)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => viewModel.fetchDetail(widget.ticketId),
                        style: ElevatedButton.styleFrom(backgroundColor: _accent),
                        child: const Text('Retry', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                )
              : ticket == null
                  ? const SizedBox.shrink()
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                      children: [
                        _statusHeader(ticket),
                        const SizedBox(height: 16),
                        _card(title: 'Subject', icon: Icons.subject_rounded, iconColor: _accent, child: Text(ticket.subject, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _textDark))),
                        const SizedBox(height: 16),
                        _card(title: 'Message', icon: Icons.message_rounded, iconColor: const Color(0xFF06B6D4), child: Text(ticket.message, style: const TextStyle(fontSize: 13, color: _textGrey, height: 1.6))),
                        const SizedBox(height: 16),
                        _card(title: 'Customer', icon: Icons.person_rounded, iconColor: const Color(0xFFF59E0B), child: _customerInfo(ticket)),
                        const SizedBox(height: 16),
                        _card(title: 'Timeline', icon: Icons.schedule_rounded, iconColor: const Color(0xFF8B5CF6), child: _timelineInfo(ticket)),
                        const SizedBox(height: 16),
                        _card(title: 'Change Status', icon: Icons.edit_rounded, iconColor: _accent, child: _statusForm(viewModel)),
                      ],
                    ),
    );
  }

  Widget _statusHeader(AdminSupportTicketModel ticket) {
    final color = ticketStatusColor(ticket.status);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [color, color.withOpacity(0.7)]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: color.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
            child: Icon(ticketStatusIcon(ticket.status), color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ticket.statusDisplay.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17, letterSpacing: 0.5)),
                const SizedBox(height: 2),
                Text('Ticket #${ticket.id}', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required String title, required IconData icon, required Color iconColor, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(color: iconColor.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, size: 16, color: iconColor),
              ),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _textDark)),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _customerInfo(AdminSupportTicketModel ticket) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoRow(Icons.badge_outlined, 'Name', ticket.fullName),
        _infoRow(Icons.mail_outline_rounded, 'Email', ticket.email),
        _infoRow(Icons.call_outlined, 'Phone', ticket.phoneNumber),
      ],
    );
  }

  Widget _timelineInfo(AdminSupportTicketModel ticket) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoRow(Icons.add_circle_outline_rounded, 'Created', ticket.createdAtFmt),
        _infoRow(Icons.update_rounded, 'Last Updated', ticket.updatedAtFmt),
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, size: 14, color: _textGrey),
          const SizedBox(width: 8),
          SizedBox(width: 90, child: Text(label, style: const TextStyle(fontSize: 12, color: _textGrey))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _textDark))),
        ],
      ),
    );
  }

  Widget _statusForm(AdminSupportViewModel viewModel) {
    final current = viewModel.selectedTicket?.status;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _statusOptions.map((s) {
            final color = ticketStatusColor(s);
            final isCurrent = s == current;
            return Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: (viewModel.isUpdating || isCurrent) ? null : () => _changeStatus(viewModel, s),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: isCurrent ? LinearGradient(colors: [color, color.withOpacity(0.75)]) : null,
                    color: isCurrent ? null : color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: isCurrent ? null : Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(ticketStatusIcon(s), size: 14, color: isCurrent ? Colors.white : color),
                      const SizedBox(width: 6),
                      Text(s.replaceAll('_', ' '), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: isCurrent ? Colors.white : color)),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (viewModel.isUpdating) ...[
          const SizedBox(height: 14),
          const Center(child: CircularProgressIndicator(color: _accent)),
        ],
      ],
    );
  }
}