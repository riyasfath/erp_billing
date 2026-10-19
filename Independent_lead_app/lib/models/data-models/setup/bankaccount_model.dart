class BankaccountModel {
  int bankAccountId;
  String bankName;
  String holderName;
  String accountNumber;
  String ifscCode;
  int customerId;

  BankaccountModel({
    required this.bankAccountId,
    required this.bankName,
    required this.holderName,
    required this.accountNumber,
    required this.ifscCode,
    required this.customerId,
  });

  factory BankaccountModel.fromJson(Map<String, dynamic> json) {
    return BankaccountModel(
      bankAccountId: json['id'] ?? 0,
      bankName: json['bank_name'] ?? '',
      holderName: json['account_holder_name'] ?? '',
      accountNumber: json['account_number'] ?? '',
      ifscCode: json['ifsc_code'] ?? '',
      customerId: json['customer'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': bankAccountId,
      'bank_name': bankName,
      'account_holder_name': holderName,
      'account_number': accountNumber,
      'ifsc_code': ifscCode,
      'customer': customerId
    };
  }
}
