// lib/models/data-models/marketing_model/location.dart

class Location {
  final int id;
  final String name;
  // optional categories for nested structures (when locations come from nested API)
  final List<CategorySimple> categories;

  Location({
    required this.id,
    required this.name,
    this.categories = const [],
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: (json['id'] is int)
          ? json['id'] as int
          : int.tryParse('${json['id']}') ?? 0,
      name: json['name']?.toString() ?? '',
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => CategorySimple.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location_id': id,
      'name': name,
      'categories': categories.map((c) => c.toJson()).toList(),
    };
  }
}

// lightweight category used inside Location model when list is nested
class CategorySimple {
  final int id;
  final String name;

  CategorySimple({
    required this.id,
    required this.name,
  });

  factory CategorySimple.fromJson(Map<String, dynamic> json) {
    return CategorySimple(
      id: (json['id'] is int)
          ? json['id'] as int
          : int.tryParse('${json['id']}') ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category_id': id,
      'name': name,
    };
  }
}
