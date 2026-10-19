class ProductModel {
  int productId;
  String productName;
  String productDescription;
  int unitId;
  String unitName;
  String unitPrice;
  String categoryName;
  int categoryId;
  int stock;
  String sgst;
  String cgst;
  int? totalTaxPercentage;
  int? taxSetting;

  ProductModel({
    required this.productId,
    required this.productName,
    required this.productDescription,
    required this.unitId,
    required this.unitName,
    required this.unitPrice,
    required this.categoryName,
    required this.categoryId,
    required this.stock,
    required this.sgst,
    required this.cgst,
    this.totalTaxPercentage,
    this.taxSetting,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      productId: json['id'] ?? 0,
      productName: json['name'] ?? '',
      productDescription: json['product_description'] ?? '',
      unitId: json['unit_id'] ?? 0,
      unitName: json['unit_name'] ?? '',
      unitPrice: json['unit_price']?.toString() ?? '0.00',
      categoryName: json['category_name'] ?? '',
      categoryId: json['category_id'] ?? 0,
      stock: json["stock"] ?? 0,
      sgst: json['sgst']?.toString() ?? '0',
      cgst: json['cgst']?.toString() ?? '0',
      totalTaxPercentage: json['total_tax_percentage'],
      taxSetting: json['tax_setting'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': productId,
      'name': productName,
      'product_description': productDescription,
      'unit_id': unitId,
      'unit_name': unitName,
      'unit_price': unitPrice,
      'category_name': categoryName,
      'category_id': categoryId,
      'stock': stock,
      'sgst': sgst,
      'cgst': cgst,
      'total_tax_percentage': totalTaxPercentage,
      'tax_setting': taxSetting,
    };
  }
}
