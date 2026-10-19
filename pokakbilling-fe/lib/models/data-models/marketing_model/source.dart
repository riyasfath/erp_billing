// lib/models/data-models/marketing_model/source.dart

import 'package:pokakbilling/models/data-models/marketing_model/category.dart';
import 'package:pokakbilling/models/data-models/marketing_model/location.dart';

class Source {
  final int id;
  final String name;
  final List<Location> locations;
  final List<CategoryMarketing>
      categories; // if API returns top-level categories linked to source

  Source({
    required this.id,
    required this.name,
    this.locations = const [],
    this.categories = const [],
  });

  factory Source.fromJson(Map<String, dynamic> json) {
    return Source(
      id: (json['id'] is int)
          ? json['id'] as int
          : int.tryParse('${json['id']}') ?? 0,
      name: json['name']?.toString() ?? '',
      locations: (json['locations'] as List<dynamic>?)
              ?.map((e) => Location.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      categories: (json['categories'] as List<dynamic>?)
              ?.map(
                  (e) => CategoryMarketing.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'source_id': id,
      'name': name,
      'locations': locations.map((l) => l.toJson()).toList(),
      'categories': categories.map((c) => c.toJson()).toList(),
    };
  }
}
