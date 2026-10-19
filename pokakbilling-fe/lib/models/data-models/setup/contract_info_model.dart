import 'package:flutter/material.dart';

class ContractInfoModel {
  int id;
  String title;
  String createdAt;
  List<SectionModel> sections;

  ContractInfoModel({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.sections,
  });

  factory ContractInfoModel.fromJson(Map<String, dynamic> json) {
    return ContractInfoModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      createdAt: json['created_at'] ?? '',
      sections: (json['sections'] as List<dynamic>? ?? [])
          .map((e) => SectionModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'created_at': createdAt,
        'sections': sections.map((e) => e.toJson()).toList(),
      };
}

class SectionModel {
  int id;
  String title;
  int contract;
  List<PointModel> points;

  SectionModel({
    required this.id,
    required this.title,
    required this.contract,
    required this.points,
  });

  factory SectionModel.fromJson(Map<String, dynamic> json) {
    return SectionModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      contract: json['contract'] ?? 0,
      points: (json['points'] as List<dynamic>? ?? [])
          .map((e) => PointModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'contract': contract,
        'points': points.map((e) => e.toJson()).toList(),
      };
}

class PointModel {
  int id;
  String points;
  int section;

  PointModel({
    required this.id,
    required this.points,
    required this.section,
  });

  factory PointModel.fromJson(Map<String, dynamic> json) {
    return PointModel(
      id: json['id'] ?? 0,
      points: json['points'] ?? '',
      section: json['section'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'points': points,
        'section': section,
      };
}

class EditablePointModel {
  final int id;
  final int section;
  final String initialText;
  final TextEditingController controller;

  EditablePointModel({
    required this.id,
    required this.section,
    required this.initialText,
  }) : controller = TextEditingController(text: initialText);
}

class EditableSectionModel {
  final int id;
  final TextEditingController titleController;
  final List<EditablePointModel> points;

  EditableSectionModel({
    required this.id,
    required String title,
    required this.points,
  }) : titleController = TextEditingController(text: title);
}
