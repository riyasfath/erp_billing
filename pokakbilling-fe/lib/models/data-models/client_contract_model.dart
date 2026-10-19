class ClientContractModel {
  final int contractId;
  final int client;
  final String contractName;
  final String description;
  final String contractDate;
  final String startDate;
  final String endDate;
  final int duration;

  ClientContractModel({
    required this.contractId,
    required this.client,
    required this.contractName,
    required this.description,
    required this.contractDate,
    required this.startDate,
    required this.endDate,
    required this.duration,
  });

  factory ClientContractModel.fromJson(Map<String, dynamic> json) {
    return ClientContractModel(
      contractId: json['id'],
      client: json['client'],
      contractName: json['contract_name'],
      description: json['description'],
      contractDate: json['contract_date'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      duration: json['duration'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'client': client,
      'contract_name': contractName,
      'description': description,
      'contract_date': contractDate,
      'start_date': startDate,
      'end_date': endDate,
      'duration': duration,
    };
  }
}
