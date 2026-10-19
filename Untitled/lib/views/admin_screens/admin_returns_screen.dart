import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../admin/admin_model/admin_return_model.dart';
import '../../admin/admin_viewmodel/admin_return_viewmodel.dart';
import 'admin_orders_screen.dart' show statusColor, statusIcon;
import 'admin_return_details.dart';

const Color _accent = Color(0xFF6366F1);
const Color _textDark = Color(0xFF0F172A);
const Color _textGrey = Color(0xFF64748B);
const Color _bg = Color(0xFFF5F6FA);

class AdminReturnsScreen extends StatefulWidget {
  const AdminReturnsScreen({super.key});

  @override
  State<AdminReturnsScreen> createState() => _AdminReturnsScreenState();
}

class _AdminReturnsScreenState extends State<AdminReturnsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminReturnViewModel>().fetchReturns();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AdminReturnViewModel>();

    return Container(
      color: _bg,
      child: _buildBody(viewModel),
    );
  }

  Widget _buildBody(AdminReturnViewModel viewModel) {
    if (viewModel.isLoading && viewModel.returns.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: _accent));
    }
    if (viewModel.error != null && viewModel.returns.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 44, color: _textGrey),
            const SizedBox(height: 14),
            Text(viewModel.error!, style: const TextStyle(color: _textGrey)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => viewModel.fetchReturns(),
              style: ElevatedButton.styleFrom(backgroundColor: _accent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
    if (viewModel.returns.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(color: _accent.withOpacity(0.08), shape: BoxShape.circle),
              child: const Icon(Icons.assignment_return_rounded, size: 40, color: _accent),
            ),
            const SizedBox(height: 16),
            const Text('No returns found', style: TextStyle(color: _textGrey, fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: _accent,
      onRefresh: () => viewModel.fetchReturns(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        itemCount: viewModel.returns.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) => _returnTile(context, viewModel.returns[index]),
      ),
    );
  }

  Widget _returnTile(BuildContext context, AdminReturnModel ret) {
    final color = statusColor(ret.status);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AdminReturnDetailScreen(returnId: ret.id))),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 6))],
          ),
          clipBehavior: Clip.antiAlias,
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(width: 5, color: color),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            width: 58,
                            height: 58,
                            child: ret.imageUrl != null
                                ? Image.network(ret.imageUrl!, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(color: _bg))
                                : Container(color: _bg, child: const Icon(Icons.image_outlined, color: _textGrey)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ret.returnId, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _textDark)),
                              const SizedBox(height: 3),
                              Text(ret.productName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: _textGrey)),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(8)),
                                child: Text(_reasonLabel(ret.reason), style: const TextStyle(fontSize: 10, color: _textGrey, fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('\$${ret.refundAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _textDark)),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                              decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(statusIcon(ret.status), size: 11, color: color),
                                  const SizedBox(width: 4),
                                  Text(ret.status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _reasonLabel(String reason) => reason.split('_').map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}').join(' ');
}