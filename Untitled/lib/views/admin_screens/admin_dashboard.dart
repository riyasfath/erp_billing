import 'package:ecommerce_app/admin/admin_model/admin_stats_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../admin/admin_viewmodel/admin_dashboard_viewmodel.dart';
import 'admin_order_detail_screen.dart';
import 'admin_orders_screen.dart';
import 'admin_payment_screen.dart';
import 'admin_returns_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  static const Color _accent = Color(0xFF6366F1);
  static const Color _textDark = Color(0xFF0F172A);
  static const Color _textGrey = Color(0xFF64748B);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminDashboardViewModel>().fetchStats();
    });
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'delivered':
      case 'completed':
        return const Color(0xFF16A34A);
      case 'cancelled':
        return const Color(0xFFEF4444);
      default:
        return _textGrey;
    }
  }

  void _goTo(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  /// Orders/Returns/Payments screens are normally shown as a tab inside
  /// AdminShell, which supplies the AppBar (back/title/drawer) — they
  /// have no Scaffold of their own. Pushed directly from a dashboard
  /// card like this, they need that wrapper or there's no back button.
  void _goToTab(String title, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: const Color(0xFFF5F6FA),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            foregroundColor: _textDark,
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
          body: SafeArea(child: screen),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AdminDashboardViewModel>();

    if (viewModel.isLoading && viewModel.stats == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (viewModel.error != null && viewModel.stats == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(viewModel.error!, style: const TextStyle(color: _textGrey)),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: () => viewModel.fetchStats(), child: const Text('Retry')),
          ],
        ),
      );
    }

    final stats = viewModel.stats;
    if (stats == null) return const SizedBox.shrink();

    return RefreshIndicator(
      onRefresh: () => viewModel.fetchStats(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          _statCardsRow(stats),
          const SizedBox(height: 22),
          _sectionCard(
            title: 'Sales This Week',
            child: _salesChart(stats.salesChart),
          ),
          const SizedBox(height: 18),
          _sectionCard(
            title: 'Top Brands',
            child: _topBrandsList(stats.topBrands),
          ),
          const SizedBox(height: 18),
          _sectionCard(
            title: 'Recent Orders',
            onSeeAll: () => _goToTab('Orders', const AdminOrdersScreen()),
            child: _recentOrdersList(stats.recentOrders),
          ),
        ],
      ),
    );
  }

  Widget _statCardsRow(DashboardStatsModel stats) {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            label: 'Sales Today',
            value: '\$${stats.salesToday.toStringAsFixed(2)}',
            icon: Icons.payments_rounded,
            color: const Color(0xFF16A34A),
            onTap: () => _goToTab('Payments', const AdminPaymentsScreen()),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            label: 'Orders Today',
            value: '${stats.ordersToday}',
            icon: Icons.receipt_long_rounded,
            color: _accent,
            onTap: () => _goToTab('Orders', const AdminOrdersScreen()),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            label: 'Pending Tickets',
            value: '${stats.pendingTickets}',
            icon: Icons.support_agent_rounded,
            color: const Color(0xFFF59E0B),
            onTap: () => _goToTab('Returns', const AdminReturnsScreen()),
          ),
        ),
      ],
    );
  }

  Widget _statCard({required String label, required String value, required IconData icon, required Color color, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 6))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 19),
              ),
              const SizedBox(height: 12),
              Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: _textDark)),
              const SizedBox(height: 3),
              Text(label, style: const TextStyle(fontSize: 11, color: _textGrey), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child, VoidCallback? onSeeAll}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _textDark))),
              if (onSeeAll != null)
                GestureDetector(
                  onTap: onSeeAll,
                  child: const Text('See All', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _accent)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _salesChart(List<SalesChartPoint> points) {
    if (points.isEmpty) {
      return const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Text('No sales data yet', style: TextStyle(color: _textGrey)));
    }
    final double maxSales = points.map((p) => p.sales).fold<double>(0, (a, b) => b > a ? b : a);

    return SizedBox(
      height: 150,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: points.map((p) {
          final double ratio = maxSales <= 0 ? 0 : (p.sales / maxSales);
          final bool isPeak = p.sales == maxSales && maxSales > 0;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (p.sales > 0)
                    Text(
                      p.sales >= 1000 ? '${(p.sales / 1000).toStringAsFixed(1)}k' : p.sales.toStringAsFixed(0),
                      style: TextStyle(fontSize: 9, color: isPeak ? _accent : _textGrey, fontWeight: FontWeight.w700),
                    ),
                  const SizedBox(height: 4),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: ratio),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) => Container(
                      height: 100 * value + 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: isPeak
                              ? [_accent, _accent.withOpacity(0.6)]
                              : [_accent.withOpacity(0.35), _accent.withOpacity(0.18)],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(p.date, style: const TextStyle(fontSize: 10, color: _textGrey)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _topBrandsList(List<TopBrandStat> brands) {
    if (brands.isEmpty) {
      return const Text('No brand data yet', style: TextStyle(color: _textGrey));
    }
    final int maxCount = brands.map((b) => b.count).fold<int>(0, (a, b) => b > a ? b : a);

    return Column(
      children: brands.map((b) {
        final double ratio = maxCount == 0 ? 0 : b.count / maxCount;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              SizedBox(width: 60, child: Text(b.brand, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _textDark))),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: ratio),
                    duration: const Duration(milliseconds: 700),
                    builder: (context, value, _) => Stack(
                      children: [
                        Container(height: 10, color: const Color(0xFFF1F5F9)),
                        FractionallySizedBox(
                          widthFactor: value.clamp(0, 1),
                          child: Container(
                            height: 10,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(colors: [_accent, Color(0xFF8B5CF6)]),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(width: 28, child: Text('${b.count}', textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, color: _textGrey))),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _recentOrdersList(List<RecentOrderStat> orders) {
    if (orders.isEmpty) {
      return const Text('No recent orders', style: TextStyle(color: _textGrey));
    }
    return Column(
      children: orders.map((o) {
        final color = _statusColor(o.status);
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _goTo(AdminOrderDetailScreen(orderId: o.id)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(o.orderId, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _textDark)),
                        const SizedBox(height: 2),
                        Text('${o.customer} · ${o.date}', style: const TextStyle(fontSize: 11, color: _textGrey)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('\$${o.amount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _textDark)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                        child: Text(o.status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
                      ),
                    ],
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right_rounded, size: 18, color: _textGrey),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}