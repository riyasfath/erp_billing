import 'dart:convert';

class TermsTitleModel {
  final int titleId;
  final String title;
  final String createdAt;

  TermsTitleModel({
    required this.titleId,
    required this.title,
    required this.createdAt,
  });

  factory TermsTitleModel.fromRawJson(String str) =>
      TermsTitleModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory TermsTitleModel.fromJson(Map<String, dynamic> json) =>
      TermsTitleModel(
        titleId: json["id"],
        title: json["title"],
        createdAt: json["created_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": titleId,
        "title": title,
        "created_at": createdAt,
      };
}

class TermsPointsModel {
  final int pointId;
  final int titleId;
  final String title;
  final String point;
  final String createdAt;

  TermsPointsModel({
    required this.pointId,
    required this.titleId,
    required this.title,
    required this.point,
    required this.createdAt,
  });

  factory TermsPointsModel.fromRawJson(String str) =>
      TermsPointsModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory TermsPointsModel.fromJson(Map<String, dynamic> json) =>
      TermsPointsModel(
        pointId: json["id"] ?? 0,
        titleId: json["terms_and_conditions"] ?? 0,
        title: json["terms_and_conditions_title"] ?? "",
        point: json["point"] ?? "",
        createdAt: json["created_at"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": pointId,
        "terms_and_conditions": titleId,
        "terms_and_conditions_title": title,
        "point": point,
        "created_at": createdAt,
      };
}
