class CustomerModel {
  int customerId;
  int? customerTypeId; // ✅ int ID — used when sending to API
  String customerType; // ✅ display name — from customer_type_name
  String firstName;
  String lastName;
  String companyName;
  String email;
  String phoneNumber;
  String mobileNumber;
  String address;
  String state;
  String country;
  int salesPersonId;
  String salesPersonName;
  int? contractId;
  String? contractName;
  DateTime? createdAt;
  DateTime? updatedAt;

  CustomerModel({
    required this.customerId,
    this.customerTypeId,
    this.customerType = '',
    required this.firstName,
    required this.lastName,
    required this.companyName,
    required this.email,
    required this.phoneNumber,
    required this.mobileNumber,
    required this.address,
    required this.state,
    required this.country,
    required this.salesPersonId,
    required this.salesPersonName,
    this.contractId,
    this.contractName,
    this.createdAt,
    this.updatedAt,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      customerId: json['id'] ?? 0,
      // ✅ customer_type is int ID from API
      customerTypeId:
          json['customer_type'] is int ? json['customer_type'] : null,
      // ✅ customer_type_name is the display String
      customerType: json['customer_type_name'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      companyName: json['company_name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      mobileNumber: json['mobile_number'] ?? '',
      address: json['address'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      salesPersonId: json['salesperson'] ?? 0,
      salesPersonName: json['salesperson_name'] ?? '',
      contractId: json['contract'],
      contractName: json['contract_name'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': customerId,
      // ✅ Always send int ID back
      'customer_type': customerTypeId,
      'first_name': firstName,
      'last_name': lastName,
      'company_name': companyName,
      'email': email,
      'phone_number': phoneNumber,
      'mobile_number': mobileNumber,
      'address': address,
      'state': state,
      'country': country,
      'salesperson': salesPersonId,
      'salesperson_name': salesPersonName,
      'contract': contractId,
    };
  }
}
