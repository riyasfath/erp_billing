class ProductModel {
  int productId;
  String productName;
  String unitName;
  String category;
  String unitPrice;
  int stock;
  String productdescription;
  String sgst;
  String cgst;

  ProductModel({
    required this.productId,
    required this.productName,
    required this.unitName,
    required this.category,
    required this.unitPrice,
    required this.stock,
    required this.productdescription,
    required this.sgst,
    required this.cgst,
  });
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      productId: json['id'] ?? 0,
      productName: json['name'] ?? '',
      unitName: json['unit'] ?? '',
      category: json['category'] ?? '',
      unitPrice:
          json['unit_price']?.toString() ?? '0', // convert to string safely
      stock: json['stock'] ?? 0,
      productdescription: json['description'] ?? '',
      sgst: json['sgst']?.toString() ?? '0',
      cgst: json['cgst']?.toString() ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': productId,
      'name': productName,
      'unit': unitName,
      'category': category,
      'unit_price': unitPrice,
      'stock': stock,
      'description': productdescription,
      'sgst': sgst,
      'cgst': cgst,
    };
  }
}
