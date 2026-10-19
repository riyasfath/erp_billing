/// Raw shape of GET /api/products/categories/ — just id + name.
/// Display-ready data (icon, color, product count, rating) is derived
/// separately in CategoryModel.fromApi, since the API doesn't provide it.
class CategoryApiModel {
  final int id;
  final String name;

  CategoryApiModel({required this.id, required this.name});

  factory CategoryApiModel.fromJson(Map<String, dynamic> json) {
    return CategoryApiModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }
}