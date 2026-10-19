// lib/models/data-models/invoice/invoice_model.dart

class InvoiceItemModel {
  final int id;
  final int? product;
  final String productName;
  final String quantity;
  final String unitPrice;
  final String sgstPercentage;
  final String cgstPercentage;
  final String subTotal;

  InvoiceItemModel({
    required this.id,
    this.product,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.sgstPercentage,
    required this.cgstPercentage,
    required this.subTotal,
  });

  factory InvoiceItemModel.fromJson(Map<String, dynamic> json) {
    return InvoiceItemModel(
      id: (json['id'] is int)
          ? json['id'] as int
          : int.tryParse('${json['id']}') ?? 0,
      product: json['product'] is int
          ? json['product'] as int
          : int.tryParse('${json['product'] ?? ''}'),
      productName: json['product_name']?.toString() ?? '',
      quantity: json['quantity']?.toString() ?? '0',
      unitPrice: json['unit_price']?.toString() ?? '0',
      sgstPercentage: json['sgst_percentage']?.toString() ?? '0',
      cgstPercentage: json['cgst_percentage']?.toString() ?? '0',
      subTotal: json['sub_total']?.toString() ?? '0',
    );
  }
}

class InvoiceModel {
  final int id;
  final String invoiceType;
  final String invoiceNumber;
  final String invoiceDate;
  final String remark;
  final String grandTotal;
  final String status;

  // Client
  final int? client;
  final String clientName;
  final int? termsAndConditions;
  final List<InvoiceItemModel> items;

  // Intern
  final int? intern;
  final String internName;
  final int? course;
  final String courseName;
  final String feeAmount;
  final String sgstPercentage;
  final String cgstPercentage;
  final String description;

  // Extra API fields
  final double? pendingAmount;
  final double? taxAmount;
  final double? totalAmountWithoutTax;

  InvoiceModel({
    required this.id,
    required this.invoiceType,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.remark,
    required this.grandTotal,
    required this.status,
    this.client,
    required this.clientName,
    this.termsAndConditions,
    required this.items,
    this.intern,
    required this.internName,
    this.course,
    required this.courseName,
    required this.feeAmount,
    required this.sgstPercentage,
    required this.cgstPercentage,
    required this.description,
    this.pendingAmount,
    this.taxAmount,
    this.totalAmountWithoutTax,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    List<InvoiceItemModel> parsedItems = [];
    if (json['items'] != null && json['items'] is List) {
      parsedItems = (json['items'] as List)
          .map((e) => InvoiceItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    // grand total: API returns "invoice_grand_total" in list, "grand_total" in detail
    final grandTotal =
        (json['invoice_grand_total'] ?? json['grand_total'] ?? '0').toString();

    // client_name: may be null in API
    final clientName = json['client_name']?.toString() ?? '';

    // intern_name: may be null in API
    final internName = json['intern_name']?.toString() ?? '';

    return InvoiceModel(
      id: (json['id'] is int)
          ? json['id'] as int
          : int.tryParse('${json['id']}') ?? 0,
      invoiceType: json['invoice_type']?.toString() ?? 'client',
      invoiceNumber: json['invoice_number']?.toString() ?? '',
      invoiceDate: json['invoice_date']?.toString() ?? '',
      remark: json['remark']?.toString() ?? '',
      grandTotal: grandTotal,
      status: json['status']?.toString() ?? '',
      client: json['client'] is int
          ? json['client'] as int
          : int.tryParse('${json['client'] ?? ''}'),
      clientName: clientName,
      termsAndConditions: json['termsandconditions'] is int
          ? json['termsandconditions'] as int
          : int.tryParse('${json['termsandconditions'] ?? ''}'),
      items: parsedItems,
      intern: json['intern'] is int
          ? json['intern'] as int
          : int.tryParse('${json['intern'] ?? ''}'),
      internName: internName,
      course: json['course'] is int
          ? json['course'] as int
          : int.tryParse('${json['course'] ?? ''}'),
      courseName: json['course_name']?.toString() ?? '',
      feeAmount: json['fee_amount']?.toString() ?? '0',
      sgstPercentage: json['sgst_percentage']?.toString() ?? '0',
      cgstPercentage: json['cgst_percentage']?.toString() ?? '0',
      description: json['description']?.toString() ?? '',
      pendingAmount: (json['pending_amount'] as num?)?.toDouble(),
      taxAmount: (json['tax_amount'] as num?)?.toDouble(),
      totalAmountWithoutTax:
          (json['total_amount_without_tax'] as num?)?.toDouble(),
    );
  }
}
