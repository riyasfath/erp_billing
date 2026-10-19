// lib/models/data-models/marketing_model/marketing_report.dart

class MarketingReport {
  final int id;
  final String date;
  final int salespersonId;
  final String salesperson;
  final int sourceId;
  final String source;
  final int locationId;
  final String location;
  final int categoryId;
  final String category;
  final int calls;
  final int leads;

  MarketingReport({
    required this.id,
    required this.date,
    required this.salespersonId,
    required this.salesperson,
    required this.sourceId,
    required this.source,
    required this.locationId,
    required this.location,
    required this.categoryId,
    required this.category,
    required this.calls,
    required this.leads,
  });

  factory MarketingReport.fromJson(Map<String, dynamic> json) {
    return MarketingReport(
      id: (json['id'] is int)
          ? json['id'] as int
          : int.tryParse('${json['id']}') ?? 0,
      date: json['date']?.toString() ?? '',
      salespersonId: (json['salesperson_id'] is int)
          ? json['salesperson_id'] as int
          : int.tryParse('${json['salesperson_id']}') ?? 0,
      salesperson: json['salesperson']?.toString() ?? '',
      sourceId: (json['source_id'] is int)
          ? json['source_id'] as int
          : int.tryParse('${json['source_id']}') ?? 0,
      source: json['source']?.toString() ?? '',
      locationId: (json['location_id'] is int)
          ? json['location_id'] as int
          : int.tryParse('${json['location_id']}') ?? 0,
      location: json['location']?.toString() ?? '',
      categoryId: (json['category_id'] is int)
          ? json['category_id'] as int
          : int.tryParse('${json['category_id']}') ?? 0,
      category: json['category']?.toString() ?? '',
      calls: (json['calls'] is int)
          ? json['calls'] as int
          : int.tryParse('${json['calls']}') ?? 0,
      leads: (json['leads'] is int)
          ? json['leads'] as int
          : int.tryParse('${json['leads']}') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'salesperson_id': salespersonId,
      'salesperson': salesperson,
      'source_id': sourceId,
      'source': source,
      'location_id': locationId,
      'location': location,
      'category_id': categoryId,
      'category': category,
      'calls': calls,
      'leads': leads,
    };
  }
}
