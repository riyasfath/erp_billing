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
