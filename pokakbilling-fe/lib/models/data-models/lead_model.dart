class LeadModel {
  final int leadId;
  final String? leadStatusDisplay;
  final String? salespersonFirstName;
  final String? salespersonLastName;
  final String? quotationNumber;
  final String? qoutationGrandTotal;
  final String? leadType;
  final String? leadCategory;
  final String?
      otherCategoryDetail; // ← stores free-text when category = 'other'
  final int? course; // ← internship course id (when category = 'intern')
  final String name;
  final String? emailId;
  final String phone;
  final String enquiry;
  final String? projectRequirement;
  final String? company;
  final String? address;
  final String leadNumber;
  final String leadStatus;
  final String notes;
  final String createdAt;
  final int? customUser;
  final int? location;
  final int? leadSource;
  final int? salesperson;

  /// Filled when lead_status == 'lost'
  final String? reasonNote; // ← NEW

  /// Filled when lead_status == 'other'
  final String? otherNote; // ← NEW

  /// The user-entered date (from 'lead_date' field in API response).
  /// Falls back to 'date', then 'created_at' if neither is set.
  final String date;

  LeadModel({
    required this.leadId,
    this.leadStatusDisplay,
    this.salespersonFirstName,
    this.salespersonLastName,
    this.quotationNumber,
    this.qoutationGrandTotal,
    this.leadType,
    this.leadCategory,
    this.otherCategoryDetail,
    this.course,
    required this.name,
    this.emailId,
    required this.phone,
    required this.enquiry,
    this.projectRequirement,
    this.company,
    this.address,
    required this.leadNumber,
    required this.leadStatus,
    required this.notes,
    required this.createdAt,
    this.customUser,
    this.location,
    this.leadSource,
    this.salesperson,
    this.reasonNote, // ← NEW
    this.otherNote, // ← NEW
    required this.date,
  });

  factory LeadModel.fromJson(Map<String, dynamic> json) {
    int? toInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is String) return int.tryParse(v);
      try {
        return int.parse(v.toString());
      } catch (_) {
        return null;
      }
    }

    String pick(List<String> keys) {
      for (final k in keys) {
        final v = json[k];
        if (v != null && v.toString().trim().isNotEmpty) return v.toString();
      }
      return '';
    }

    final String userDate = pick(['lead_date', 'date', 'created_at']);

    return LeadModel(
      leadId: json['id'] is int
          ? json['id'] as int
          : int.tryParse('${json['id']}') ?? 0,
      leadStatusDisplay: json['lead_status_display']?.toString(),
      salespersonFirstName: json['salesperson_first_name']?.toString(),
      salespersonLastName: json['salesperson_last_name']?.toString(),
      quotationNumber: json['quotation_number']?.toString(),
      qoutationGrandTotal: json['qoutation_grand_total']?.toString(),
      leadType: json['lead_type']?.toString(),
      leadCategory: json['lead_category']?.toString(),
      otherCategoryDetail: json['other_category_detail']?.toString(),
      course: toInt(json['course']),
      name: json['name']?.toString() ?? '',
      emailId: json['email']?.toString(),
      phone: json['phone']?.toString() ?? '',
      enquiry: json['enquiry']?.toString() ?? '',
      projectRequirement: json['project_requirement']?.toString(),
      company: json['company']?.toString(),
      address: json['address']?.toString(),
      leadNumber: json['lead_number']?.toString() ?? '',
      leadStatus: json['lead_status']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      customUser: toInt(json['CustomUser']),
      location: toInt(json['location']),
      leadSource: toInt(json['lead_source']),
      salesperson: toInt(json['salesperson']),
      reasonNote: json['reason_note']?.toString(), // ← NEW
      otherNote: json['other_note']?.toString(), // ← NEW
      date: userDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': leadId,
      'lead_status_display': leadStatusDisplay,
      'salesperson_first_name': salespersonFirstName,
      'salesperson_last_name': salespersonLastName,
      'quotation_number': quotationNumber,
      'qoutation_grand_total': qoutationGrandTotal,
      'lead_type': leadType,
      'lead_category': leadCategory,
      'other_category_detail': otherCategoryDetail,
      'course': course,
      'name': name,
      'email': emailId,
      'phone': phone,
      'enquiry': enquiry,
      'project_requirement': projectRequirement,
      'company': company,
      'address': address,
      'lead_number': leadNumber,
      'lead_status': leadStatus,
      'notes': notes,
      'created_at': createdAt,
      'lead_date': date,
      'CustomUser': customUser,
      'location': location,
      'lead_source': leadSource,
      'salesperson': salesperson,
      'reason_note': reasonNote, // ← NEW
      'other_note': otherNote, // ← NEW
    };
  }
}