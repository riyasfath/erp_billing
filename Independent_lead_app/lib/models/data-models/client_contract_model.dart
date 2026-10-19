class ContractModel {
  final int? id;
  final String name;
  final bool isActive;
  final List<ContractSection> sections;

  ContractModel({
    this.id,
    required this.name,
    required this.isActive,
    required this.sections,
  });

  factory ContractModel.fromJson(Map<String, dynamic> json) {
    return ContractModel(
      id: json['id'],
      name: json['name'],
      isActive: json['is_active'],
      sections: (json['sections'] as List? ?? [])
          .map((e) => ContractSection.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "is_active": isActive,
      "sections": sections.map((e) => e.toJson()).toList(),
    };
  }
}

class ContractSection {
  final String title;
  final int order;
  final List<ContractPoint> points;

  ContractSection({
    required this.title,
    required this.order,
    required this.points,
  });

  factory ContractSection.fromJson(Map<String, dynamic> json) {
    return ContractSection(
      title: json['title'],
      order: json['order'],
      points: (json['points'] as List? ?? [])
          .map((e) => ContractPoint.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "order": order,
      "points": points.map((e) => e.toJson()).toList(),
    };
  }
}

class ContractPoint {
  final String content;
  final int order;

  ContractPoint({
    required this.content,
    required this.order,
  });

  factory ContractPoint.fromJson(Map<String, dynamic> json) {
    return ContractPoint(
      content: json['content'],
      order: json['order'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "content": content,
      "order": order,
    };
  }
}
