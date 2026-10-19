// ─────────────────────────────────────────────────────────────────────────────
// UserModuleModel
// Maps one entry of the /accounts/user/modules/all/ response:
// { "name": "sales", "submodules": ["quotation", "invoice", ...] }
// ─────────────────────────────────────────────────────────────────────────────
class UserModuleModel {
  final String name;
  final List<String> submodules;

  UserModuleModel({
    required this.name,
    required this.submodules,
  });

  factory UserModuleModel.fromJson(Map<String, dynamic> json) {
    return UserModuleModel(
      name: json['name']?.toString() ?? '',
      submodules: (json['submodules'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'submodules': submodules,
      };
}
