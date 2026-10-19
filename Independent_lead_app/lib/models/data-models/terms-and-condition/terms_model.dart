class TermsModel {
  final int? id;
  final String? name;
  final String? content;
  final bool? isActive;
  final String? createdAt;
  final List<TermPoint>? points;

  TermsModel({
    this.id,
    this.name,
    this.content,
    this.isActive,
    this.createdAt,
    this.points,
  });

  factory TermsModel.fromJson(Map<String, dynamic> json) {
    return TermsModel(
      id: json["id"],
      name: json["name"],
      content: json["content"],
      isActive: json["is_active"],
      createdAt: json["created_at"],
      points: json["points"] != null
          ? List<TermPoint>.from(
              json["points"].map((x) => TermPoint.fromJson(x)))
          : [],
    );
  }
}

class TermPoint {
  final int? id;
  final String? content;
  final int? order;

  TermPoint({
    this.id,
    this.content,
    this.order,
  });

  factory TermPoint.fromJson(Map<String, dynamic> json) {
    return TermPoint(
      id: json["id"],
      content: json["content"],
      order: json["order"],
    );
  }
}
