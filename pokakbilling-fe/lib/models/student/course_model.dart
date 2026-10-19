class InternshipCourseModel {
  final int id;
  final String title;
  final String description;
  final bool isActive;
  final String departmentName;
  final String totalFee;
  final int sgst;
  final int cgst;
  final int totalTaxPercentage;
  final int studentsCount;

  InternshipCourseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.isActive,
    required this.departmentName,
    required this.totalFee,
    required this.sgst,
    required this.cgst,
    required this.totalTaxPercentage,
    required this.studentsCount,
  });

  factory InternshipCourseModel.fromJson(Map<String, dynamic> json) {
    return InternshipCourseModel(
      id: (json['id'] is int)
          ? json['id'] as int
          : int.tryParse('${json['id']}') ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      isActive: json['is_active'] as bool? ?? true,
      departmentName: json['department_name']?.toString() ?? '',
      totalFee: json['total_fee']?.toString() ?? '0',
      sgst: (json['sgst'] is int)
          ? json['sgst'] as int
          : int.tryParse('${json['sgst'] ?? 0}') ?? 0,
      cgst: (json['cgst'] is int)
          ? json['cgst'] as int
          : int.tryParse('${json['cgst'] ?? 0}') ?? 0,
      totalTaxPercentage: (json['total_tax_percentage'] is int)
          ? json['total_tax_percentage'] as int
          : int.tryParse('${json['total_tax_percentage'] ?? 0}') ?? 0,
      studentsCount: (json['students_count'] is int)
          ? json['students_count'] as int
          : int.tryParse('${json['students_count'] ?? 0}') ?? 0,
    );
  }
}
