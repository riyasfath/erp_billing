import 'dart:convert';

class StatesModel {
  final String name;

  StatesModel({
    required this.name,
  });

  factory StatesModel.fromRawJson(String str) =>
      StatesModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory StatesModel.fromJson(Map<String, dynamic> json) => StatesModel(
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
      };
}
