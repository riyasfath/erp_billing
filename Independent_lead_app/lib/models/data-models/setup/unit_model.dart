class UnitModel {
  int unitId;
  String unitName;
  String unitDescription;

  UnitModel({
    required this.unitId,
    required this.unitName,
    required this.unitDescription,
  });

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(
      unitId: json['id'] ?? 0,
      unitName: json['name'] ?? '',
      unitDescription: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': unitId,
      'name': unitName,
      'description': unitDescription,
    };
  }
}
