class SalesChartPoint {
  final String date;
  final double sales;

  SalesChartPoint({required this.date, required this.sales});

  factory SalesChartPoint.fromJson(Map<String, dynamic> json) => SalesChartPoint(
        date: json['date']?.toString() ?? '',
        sales: json['sales'] is num ? (json['sales'] as num).toDouble() : double.tryParse('${json['sales']}') ?? 0,
      );
}

class TopBrandStat {
  final String brand;
  final int count;

  TopBrandStat({required this.brand, required this.count});

  factory TopBrandStat.fromJson(Map<String, dynamic> json) => TopBrandStat(
        brand: json['brand']?.toString() ?? '',
        count: json['count'] is int ? json['count'] as int : int.tryParse('${json['count']}') ?? 0,
      );
}

class RecentOrderStat {
  final int id;
  final String orderId;
  final String customer;
  final String date;
  final double amount;
  final String status;

  RecentOrderStat({
    required this.id,
    required this.orderId,
    required this.customer,
    required this.date,
    required this.amount,
    required this.status,
  });

  factory RecentOrderStat.fromJson(Map<String, dynamic> json) => RecentOrderStat(
        id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
        orderId: json['order_id']?.toString() ?? '',
        customer: json['customer']?.toString() ?? '',
        date: json['date']?.toString() ?? '',
        amount: json['amount'] is num ? (json['amount'] as num).toDouble() : double.tryParse('${json['amount']}') ?? 0,
        status: json['status']?.toString() ?? '',
      );
}

class DashboardStatsModel {
  final double salesToday;
  final int ordersToday;
  final int pendingTickets;
  final List<SalesChartPoint> salesChart;
  final List<TopBrandStat> topBrands;
  final List<RecentOrderStat> recentOrders;

  DashboardStatsModel({
    required this.salesToday,
    required this.ordersToday,
    required this.pendingTickets,
    required this.salesChart,
    required this.topBrands,
    required this.recentOrders,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      salesToday: json['sales_today'] is num ? (json['sales_today'] as num).toDouble() : double.tryParse('${json['sales_today']}') ?? 0,
      ordersToday: json['orders_today'] is int ? json['orders_today'] as int : int.tryParse('${json['orders_today']}') ?? 0,
      pendingTickets:
          json['pending_tickets'] is int ? json['pending_tickets'] as int : int.tryParse('${json['pending_tickets']}') ?? 0,
      salesChart: (json['sales_chart'] as List? ?? []).map((e) => SalesChartPoint.fromJson(e as Map<String, dynamic>)).toList(),
      topBrands: (json['top_brands'] as List? ?? []).map((e) => TopBrandStat.fromJson(e as Map<String, dynamic>)).toList(),
      recentOrders:
          (json['recent_orders'] as List? ?? []).map((e) => RecentOrderStat.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}