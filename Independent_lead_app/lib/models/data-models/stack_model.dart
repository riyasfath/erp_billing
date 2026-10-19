import 'dart:convert';

class StackModel {
  int stackId;
  String stackName;

  StackModel({required this.stackName, required this.stackId});

  factory StackModel.fromRawJson(String str) =>
      StackModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory StackModel.fromJson(Map<String, dynamic> json) => StackModel(
        stackId: json["id"],
        stackName: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": stackId,
        "name": stackName,
      };
}
