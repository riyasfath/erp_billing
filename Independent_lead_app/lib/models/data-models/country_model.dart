import 'dart:convert';

class CountriesModel {
  String name;

  CountriesModel({
    required this.name,
  });

  factory CountriesModel.fromRawJson(String str) =>
      CountriesModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CountriesModel.fromJson(Map<String, dynamic> json) => CountriesModel(
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
      };
}
