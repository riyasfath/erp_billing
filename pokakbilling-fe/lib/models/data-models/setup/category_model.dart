class CategoryModel {
  int categoryId;
  String categoryName;
  String categoryDescription;

  CategoryModel({
    required this.categoryId,
    required this.categoryName,
    required this.categoryDescription,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      categoryId: json['id'] ?? 0,
      categoryName: json['name'] ?? '',
      categoryDescription: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': categoryId,
      'name': categoryName,
      'description': categoryDescription,
    };
  }
}
