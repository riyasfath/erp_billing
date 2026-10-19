// lib/models/data-models/marketing_model/category.dart

class CategoryMarketing {
  final int id;
  final String name;
  final int source;

  CategoryMarketing({
    required this.id,
    required this.name,
    required this.source,
  });

  factory CategoryMarketing.fromJson(Map<String, dynamic> json) {
    return CategoryMarketing(
      id: (json['id'] is int)
          ? json['id'] as int
          : int.tryParse('${json['id']}') ?? 0,
      name: json['name']?.toString() ?? '',
      source: (json['source'] is int)
          ? json['source'] as int
          : int.tryParse('${json['source']}') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'source': source,
    };
  }
}
