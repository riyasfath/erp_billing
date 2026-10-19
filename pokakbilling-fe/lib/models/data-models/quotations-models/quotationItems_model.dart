class QuotationitemsModel {
  final int id;
  final String clientName;
  final int clientId;
  final String address;
  final String deliveryLocation;
  final String quotationNumber;
  final int termsAndConditionsId;
  final String termsAndConditionsTitle;
  final String quotationDate;
  final double grandTotal;
  final int salesperson;
  final String salespersonName;
  final int contractId;
  final String contractTitle;
  final String projectName;
  final List<TermsAndCondition> termsAndConditions;
  final Contract contract;
  final List<QuotationItem> items;

  QuotationitemsModel({
    required this.id,
    required this.clientName,
    required this.clientId,
    required this.address,
    required this.deliveryLocation,
    required this.quotationNumber,
    required this.termsAndConditionsId,
    required this.termsAndConditionsTitle,
    required this.quotationDate,
    required this.grandTotal,
    required this.salesperson,
    required this.salespersonName,
    required this.contractId,
    required this.contractTitle,
    required this.projectName,
    required this.termsAndConditions,
    required this.contract,
    required this.items,
  });

  factory QuotationitemsModel.fromJson(Map<String, dynamic> json) {
    return QuotationitemsModel(
      id: json['id'],
      clientName: json['client_name'],
      clientId: json['client_id'],
      address: json['address'],
      deliveryLocation: json['delivery_location'],
      quotationNumber: json['quotation_number'],
      termsAndConditionsId: json['termsandconditions_id'],
      termsAndConditionsTitle: json['termsandcondtions_title'],
      quotationDate: json['quotation_date'],
      grandTotal: json['grand_total'],
      salesperson: json['selesperson'],
      salespersonName: json['salesperson_name'],
      contractId: json['contract_id'],
      contractTitle: json['contract_title'],
      projectName: json['project_name'] ?? "",
      termsAndConditions: (json['termsandconditions'] as List)
          .map((e) => TermsAndCondition.fromJson(e))
          .toList(),
      contract: Contract.fromJson(json['contract']),
      items: (json['items'] as List)
          .map((e) => QuotationItem.fromJson(e))
          .toList(),
    );
  }
}

class TermsAndCondition {
  final int id;
  final int termsAndConditions;
  final String termsAndConditionsTitle;
  final String point;
  final String createdAt;

  TermsAndCondition({
    required this.id,
    required this.termsAndConditions,
    required this.termsAndConditionsTitle,
    required this.point,
    required this.createdAt,
  });

  factory TermsAndCondition.fromJson(Map<String, dynamic> json) {
    return TermsAndCondition(
      id: json['id'],
      termsAndConditions: json['terms_and_conditions'],
      termsAndConditionsTitle: json['terms_and_conditions_title'],
      point: json['point'],
      createdAt: json['created_at'],
    );
  }
}

class Contract {
  final int id;
  final String title;
  final String createdAt;
  final List<ContractSection> sections;

  Contract({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.sections,
  });

  factory Contract.fromJson(Map<String, dynamic> json) {
    return Contract(
      id: json['id'],
      title: json['title'],
      createdAt: json['created_at'],
      sections: (json['sections'] as List)
          .map((e) => ContractSection.fromJson(e))
          .toList(),
    );
  }
}

class ContractSection {
  final int id;
  final String title;
  final int contract;
  final List<ContractPoint> points;

  ContractSection({
    required this.id,
    required this.title,
    required this.contract,
    required this.points,
  });

  factory ContractSection.fromJson(Map<String, dynamic> json) {
    return ContractSection(
      id: json['id'],
      title: json['title'],
      contract: json['contract'],
      points: (json['points'] as List)
          .map((e) => ContractPoint.fromJson(e))
          .toList(),
    );
  }
}

class ContractPoint {
  final int id;
  final String points;
  final int section;

  ContractPoint({
    required this.id,
    required this.points,
    required this.section,
  });

  factory ContractPoint.fromJson(Map<String, dynamic> json) {
    return ContractPoint(
      id: json['id'],
      points: json['points'],
      section: json['section'],
    );
  }
}

class QuotationItem {
  final int id;
  final String name;
  final int productId;
  final double quantity;
  final double unitPrice;
  final double total;
  final double sgst;
  final double cgst;
  final double sgstPercentage;
  final double cgstPercentage;
  final double subTotal;

  QuotationItem({
    required this.id,
    required this.name,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.total,
    required this.sgst,
    required this.cgst,
    required this.sgstPercentage,
    required this.cgstPercentage,
    required this.subTotal,
  });

  factory QuotationItem.fromJson(Map<String, dynamic> json) {
    return QuotationItem(
      id: json['id'],
      name: json['name'],
      productId: json['product_id'],
      quantity: (json['quantity'] as num).toDouble(),
      unitPrice: (json['unit_price'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      sgst: (json['sgst'] as num).toDouble(),
      cgst: (json['cgst'] as num).toDouble(),
      sgstPercentage: (json['sgst_percentage'] as num).toDouble(),
      cgstPercentage: (json['cgst_percentage'] as num).toDouble(),
      subTotal: (json['sub_total'] as num).toDouble(),
    );
  }
}
