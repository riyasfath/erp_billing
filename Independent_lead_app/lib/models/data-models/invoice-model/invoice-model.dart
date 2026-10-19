class InvoiceModel {
  final int id;
  final int quotation;
  final String quotationNumber;
  final int client;
  final String clientName;
  final String clientNameDisplay;
  final String projectName;
  final String companyLocation;
  final String companyAddress;
  final String invoiceNumber;
  final String date;
  final String dueDate;
  final String invoiceType;
  final String status;
  final String paymentStatus;
  final String paymentMethod;
  final String paidAmount;
  final String balanceAmount;
  final String paymentDate;
  final String subtotal;
  final String totalDiscount;
  final String taxableAmount;
  final String taxTotal;
  final String roundOff;
  final String grandTotal;
  final int createdBy;
  final String createdAt;
  final String? notes;
  final String? termsAndConditions;
  final List<ProductItemModel> items;

  InvoiceModel({
    required this.id,
    required this.quotation,
    required this.quotationNumber,
    required this.client,
    required this.clientName,
    required this.clientNameDisplay,
    required this.projectName,
    required this.companyLocation,
    required this.companyAddress,
    required this.invoiceNumber,
    required this.date,
    required this.dueDate,
    required this.invoiceType,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.paidAmount,
    required this.balanceAmount,
    required this.paymentDate,
    required this.subtotal,
    required this.totalDiscount,
    required this.taxableAmount,
    required this.taxTotal,
    required this.roundOff,
    required this.grandTotal,
    required this.createdBy,
    required this.createdAt,
    this.notes,
    this.termsAndConditions,
    required this.items,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: int.tryParse('${json['id']}') ?? 0,
      quotation: int.tryParse('${json['quotation']}') ?? 0,
      quotationNumber: json['quotation_number']?.toString() ?? '',
      client: int.tryParse('${json['client']}') ?? 0,

      clientName: json['client_name']?.toString() ?? '',
      clientNameDisplay: json['client_name_display']?.toString() ?? '',

      projectName: json['project_name']?.toString() ?? '',
      companyLocation: json['company_location']?.toString() ?? '',
      companyAddress: json['company_address']?.toString() ?? '',

      invoiceNumber: json['invoice_number']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      dueDate: json['due_date']?.toString() ?? '',

      invoiceType: json['invoice_type']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      paymentStatus: json['payment_status']?.toString() ?? '',
      paymentMethod: json['payment_method']?.toString() ?? '',

      paidAmount: json['paid_amount']?.toString() ?? '0',
      balanceAmount: json['balance_amount']?.toString() ?? '0',
      paymentDate: json['payment_date']?.toString() ?? '',

      subtotal: json['subtotal']?.toString() ?? '0',
      totalDiscount: json['total_discount']?.toString() ?? '0',
      taxableAmount: json['taxable_amount']?.toString() ?? '0',
      taxTotal: json['tax_total']?.toString() ?? '0',
      roundOff: json['round_off']?.toString() ?? '0',
      grandTotal: json['grand_total']?.toString() ?? '0',

      createdBy: int.tryParse('${json['created_by']}') ?? 0,
      createdAt: json['created_at']?.toString() ?? '',

      notes: json['notes']?.toString(), // ✅ nullable safe
      termsAndConditions:
          json['terms_and_conditions']?.toString(), // ✅ nullable safe

      items: (json['items'] as List<dynamic>? ?? [])
          .asMap()
          .entries
          .map((entry) => ProductItemModel.fromJson(
                entry.value,
                entry.key,
              ))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quotation': quotation,
      'client': client,
      'client_name': clientName,
      'client_name_display': clientNameDisplay,
      'project_name': projectName,
      'company_location': companyLocation,
      'company_address': companyAddress,
      'invoice_number': invoiceNumber,
      'date': date,
      'due_date': dueDate,
      'invoice_type': invoiceType,
      'status': status,
      'payment_status': paymentStatus,
      'payment_method': paymentMethod,
      'paid_amount': paidAmount,
      'balance_amount': balanceAmount,
      'payment_date': paymentDate,
      'subtotal': subtotal,
      'total_discount': totalDiscount,
      'taxable_amount': taxableAmount,
      'tax_total': taxTotal,
      'round_off': roundOff,
      'grand_total': grandTotal,
      'created_by': createdBy,
      'created_at': createdAt,
      'notes': notes,
      'terms_and_conditions': termsAndConditions,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}

class ProductItemModel {
  int itemNumber;
  int? itemRowId;
  int? productId;

  String productName;
  String description;

  String quantity;
  String unitPrice;
  String unit;

  String discount;
  String sgst;
  String cgst;
  String igst;

  String taxAmount;
  String total;

  // ✅ ADD THESE TWO
  String selectedProduct;
  String subTotal;

  ProductItemModel({
    required this.itemNumber,
    this.itemRowId,
    this.productId,
    this.productName = '',
    this.description = '',
    this.quantity = '0',
    this.unitPrice = '0',
    this.unit = '',
    this.discount = '0',
    this.sgst = '0',
    this.cgst = '0',
    this.igst = '0',
    this.taxAmount = '0',
    this.total = '0',

    // ✅ ADD HERE
    this.selectedProduct = '',
    this.subTotal = '0',
  });

  // ================= FROM JSON =================
  factory ProductItemModel.fromJson(Map<String, dynamic> json, int index) {
    return ProductItemModel(
      itemNumber: index + 1,
      itemRowId: int.tryParse('${json['id']}') ?? 0,
      productId: int.tryParse('${json['product_id']}') ?? 0,
      productName: json['product_name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      quantity: json['quantity']?.toString() ?? '0',
      unitPrice: json['unit_price']?.toString() ?? '0',
      unit: json['unit']?.toString() ?? '',
      discount: json['discount']?.toString() ?? '0',
      sgst: json['sgst']?.toString() ?? '0',
      cgst: json['cgst']?.toString() ?? '0',
      igst: json['igst']?.toString() ?? '0',
      taxAmount: json['tax_amount']?.toString() ?? '0',
      total: json['total']?.toString() ?? '0',

      // ✅ IMPORTANT (for edit screen)
      selectedProduct: json['product_id']?.toString() ?? '',
      subTotal: json['total']?.toString() ?? '0',
    );
  }

  // ================= TO JSON =================
  Map<String, dynamic> toJson() {
    return {
      "product_id": productId,
      "quantity": int.tryParse(quantity) ?? 0,
      "unit_price": double.tryParse(unitPrice) ?? 0,
      "sgst": double.tryParse(sgst) ?? 0,
      "cgst": double.tryParse(cgst) ?? 0,
    };
  }
}
