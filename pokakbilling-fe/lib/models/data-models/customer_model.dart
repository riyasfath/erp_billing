class CustomerModel {
  int customerId;
  String moduleType; // 'lead' | 'client'
  String firstName;
  String lastName;
  String companyName;
  String address;
  String email;
  String phone;
  String mobile;
  String country;
  String state;
  String salesPersonName;
  int salesPersonId;
  String gstNumber;
  int? leadId; // only set when moduleType == 'lead'
  String createdDate;

  // kept for backward-compat (some screens may still read it)
  String get customerType => moduleType;

  CustomerModel({
    required this.customerId,
    required this.moduleType,
    required this.firstName,
    required this.lastName,
    required this.companyName,
    required this.address,
    required this.email,
    required this.phone,
    required this.mobile,
    required this.country,
    required this.state,
    required this.salesPersonName,
    required this.salesPersonId,
    this.gstNumber = '',
    this.leadId,
    String? createdDate,
  }) : createdDate = createdDate ?? DateTime.now().toString().split(' ')[0];

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      customerId: json['id'] ?? 0,
      moduleType: json['module_type'] ?? json['customer_type'] ?? 'client',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      companyName: json['company_name'] ?? '',
      address: json['address'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      mobile: json['mobile'] ?? '',
      country: json['country'] ?? '',
      state: json['state'] ?? '',
      salesPersonName: json['salesperson_name'] ?? '',
      salesPersonId: json['salesperson_id'] ?? 0,
      gstNumber: json['gst_number'] ?? '',
      leadId: json['lead'] is int
          ? json['lead'] as int
          : int.tryParse('${json['lead'] ?? ''}'),
      createdDate: json['created_at'] ??
          json['created_date'] ??
          json['registration_date'] ??
          DateTime.now().toString().split(' ')[0],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': customerId,
      'module_type': moduleType,
      'first_name': firstName,
      'last_name': lastName,
      'company_name': companyName,
      'address': address,
      'email': email,
      'phone': phone,
      'mobile': mobile,
      'country': country,
      'state': state,
      'salesperson_name': salesPersonName,
      'salesperson_id': salesPersonId,
      'gst_number': gstNumber,
      'lead': leadId,
      'created_at': createdDate,
    };
  }
}
