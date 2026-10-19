class CustomerTypeModel {
  final int id;
  final String name;
  final String? description;
  final bool isActive;
  final DateTime? createdAt;

  CustomerTypeModel({
    required this.id,
    required this.name,
    this.description,
    required this.isActive,
    this.createdAt,
  });

  factory CustomerTypeModel.fromJson(Map<String, dynamic> json) {
    return CustomerTypeModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }
}
