class QuotationModel {
  int quotationId;
  int? lead;
  String? leadName;
  int? client;
  String? clientName;
  String? clientNameDisplay;
  String? projectName;
  String? companyLocation;
  String? companyAddress;
  int? contractId;
  String? contractText;
  String? contractName;
  String quotationNumber;
  String date;
  String? validUntil;
  String status;
  String subtotal;
  String taxTotal;
  String grandTotal;
  List<QuotationItem> items;
  int createdBy;
  String? introduction;
  String? termsAndConditions;
  int? termsTemplateId;
  String? notes;

  QuotationModel({
    required this.quotationId,
    this.lead,
    this.leadName,
    this.client,
    this.clientName,
    this.clientNameDisplay,
    this.projectName,
    this.companyLocation,
    this.companyAddress,
    this.contractId,
    this.contractText,
    this.contractName,
    required this.quotationNumber,
    required this.date,
    this.validUntil,
    required this.status,
    required this.subtotal,
    required this.taxTotal,
    required this.grandTotal,
    required this.items,
    required this.createdBy,
    this.introduction,
    this.termsAndConditions,
    this.termsTemplateId,
    this.notes,
  });

  factory QuotationModel.fromJson(Map<String, dynamic> json) {
    int? parsedContractId;
    String? parsedContractText;
    if (json['contract'] != null) {
      final value = json['contract'].toString();
      if (int.tryParse(value) != null) {
        parsedContractId = int.parse(value);
      } else {
        parsedContractText = value;
      }
    }

    int? contractTemplateId;
    if (json['contract_templates'] is List &&
        (json['contract_templates'] as List).isNotEmpty) {
      contractTemplateId = int.tryParse(
        (json['contract_templates'] as List).first.toString(),
      );
    }

    int? termsTemplateId;
    if (json['terms_template'] != null) {
      termsTemplateId = int.tryParse(json['terms_template'].toString());
    }

    return QuotationModel(
      quotationId: json['id'] ?? 0,
      lead: json['lead'],
      leadName: json['lead_name'],
      client: json['client'],
      clientName: json['client_name'],
      clientNameDisplay: json['client_name_display'],
      projectName: json['project_name'],
      companyLocation: json['company_location'],
      companyAddress: json['company_address'],
      contractId: contractTemplateId ?? parsedContractId,
      contractText: parsedContractText,
      contractName: json['contract_name'],
      quotationNumber: json['quotation_number'] ?? '',
      date: json['date'] ?? '',
      validUntil: json['valid_until'],
      status: json['status'] ?? '',
      subtotal: json['subtotal'] ?? "0",
      taxTotal: json['tax_total'] ?? "0",
      grandTotal: json['grand_total'] ?? "0",
      items: json['items'] != null
          ? List<QuotationItem>.from(
              json['items'].map((x) => QuotationItem.fromJson(x)))
          : [],
      createdBy: json['created_by'] ?? 0,
      introduction: json['introduction'],
      termsAndConditions: json['terms_and_conditions'],
      termsTemplateId: termsTemplateId,
      notes: json['notes'],
    );
  }

  static List<QuotationModel> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((e) => QuotationModel.fromJson(e)).toList();
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class QuotationItem {
  int id; // ✅ item row ID (e.g. 153) — used for delete
  int productId; // ✅ actual product ID (e.g. 26) — used for edit PATCH
  String? productName;
  String? description;
  int quantity;
  String unitPrice;
  String? unit;
  String sgst;
  String cgst;
  String taxAmount;
  String total;

  QuotationItem({
    required this.id,
    required this.productId, // ✅ NEW
    this.productName,
    this.description,
    required this.quantity,
    required this.unitPrice,
    this.unit,
    required this.sgst,
    required this.cgst,
    required this.taxAmount,
    required this.total,
  });

  factory QuotationItem.fromJson(Map<String, dynamic> json) {
    return QuotationItem(
      id: json['id'] ?? 0,
      productId: json['product_id'] ?? 0, // ✅ maps product_id from API
      productName: json['product_name'],
      description: json['description'],
      quantity: json['quantity'] ?? 0,
      unitPrice: json['unit_price'] ?? "0",
      unit: json['unit'],
      sgst: json['sgst'] ?? "0",
      cgst: json['cgst'] ?? "0",
      taxAmount: json['tax_amount'] ?? "0",
      total: json['total'] ?? "0",
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class AddProductQuotationModel {
  int tabId;
  int itemNumber;
  int itemRowId; // ✅ item row ID from API (used for delete)
  int productId; // ✅ actual product ID (used in PATCH payload)
  String selectedProduct;
  String quantity;
  String unitPrice;
  String total;
  String sgst;
  String cgst;
  String subTotal;

  AddProductQuotationModel({
    this.tabId = 0,
    required this.itemNumber,
    this.itemRowId = 0, // ✅ NEW
    this.productId = 0,
    this.selectedProduct = "",
    this.quantity = "",
    this.unitPrice = "",
    this.total = "",
    this.sgst = "",
    this.cgst = "",
    this.subTotal = "",
  });
}

// ─────────────────────────────────────────────────────────────────────────────

class ContractModel {
  final int? id;
  final String name;
  final bool isActive;
  final List<ContractSection> sections;

  ContractModel({
    this.id,
    required this.name,
    required this.isActive,
    required this.sections,
  });

  factory ContractModel.fromJson(Map<String, dynamic> json) {
    return ContractModel(
      id: json['id'],
      name: json['name'],
      isActive: json['is_active'],
      sections: (json['sections'] as List? ?? [])
          .map((e) => ContractSection.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "is_active": isActive,
      "sections": sections.map((e) => e.toJson()).toList(),
    };
  }
}

class ContractSection {
  final String title;
  final int order;
  final List<ContractPoint> points;

  ContractSection({
    required this.title,
    required this.order,
    required this.points,
  });

  factory ContractSection.fromJson(Map<String, dynamic> json) {
    return ContractSection(
      title: json['title'],
      order: json['order'],
      points: (json['points'] as List? ?? [])
          .map((e) => ContractPoint.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "order": order,
      "points": points.map((e) => e.toJson()).toList(),
    };
  }
}

class ContractPoint {
  final String content;
  final int order;

  ContractPoint({
    required this.content,
    required this.order,
  });

  factory ContractPoint.fromJson(Map<String, dynamic> json) {
    return ContractPoint(
      content: json['content'],
      order: json['order'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "content": content,
      "order": order,
    };
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class ContractHeadingModel {
  int contractId;
  String contractHeading;
  String createdAt;

  ContractHeadingModel({
    required this.contractId,
    required this.contractHeading,
    required this.createdAt,
  });

  factory ContractHeadingModel.fromJson(Map<String, dynamic> json) {
    return ContractHeadingModel(
      contractId: json['id'] ?? 0,
      contractHeading: json['title'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': contractId,
      'title': contractHeading,
      'created_at': createdAt,
    };
  }
}

class ContractSubHeadingModel {
  int id;
  String title;
  int contract;

  ContractSubHeadingModel({
    required this.id,
    required this.title,
    required this.contract,
  });

  factory ContractSubHeadingModel.fromJson(Map<String, dynamic> json) =>
      ContractSubHeadingModel(
        id: json["id"],
        title: json["title"],
        contract: json["contract"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "contract": contract,
      };
}

class ContractPointsModel {
  int id;
  String points;
  int section;

  ContractPointsModel({
    required this.id,
    required this.points,
    required this.section,
  });

  factory ContractPointsModel.fromJson(Map<String, dynamic> json) =>
      ContractPointsModel(
        id: json["id"],
        points: json["points"],
        section: json["section"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "points": points,
        "section": section,
      };
}
