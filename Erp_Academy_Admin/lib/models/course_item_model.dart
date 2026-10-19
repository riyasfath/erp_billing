import '../core/utils/json_parse.dart';
import 'installment_plan_model.dart';

class FacultyDetail {
  final int id;
  final String name;
  const FacultyDetail({required this.id, required this.name});

  factory FacultyDetail.fromJson(Map<String, dynamic> json) => FacultyDetail(
        id: JsonParse.toInt(json['id']),
        name: JsonParse.toStr(json['name']),
      );
}

/// Course from GET /internship/course/
class CourseItem {
  final int id;
  final String title;
  final String description;
  final bool isActive;
  final int department;
  final String departmentName;
  final List<FacultyDetail> faculties;
  final int studentsCount;
  final double totalFee;
  final List<InstallmentPlan> installmentPlans;
  final DateTime? createdAt;
  final int? taxSettings;
  final double sgst;
  final double cgst;
  final double totalTaxPercentage;

  const CourseItem({
    required this.id,
    required this.title,
    this.description = '',
    this.isActive = true,
    this.department = 0,
    this.departmentName = '',
    this.faculties = const [],
    this.studentsCount = 0,
    this.totalFee = 0,
    this.installmentPlans = const [],
    this.createdAt,
    this.taxSettings,
    this.sgst = 0,
    this.cgst = 0,
    this.totalTaxPercentage = 0,
  });

  // ---- Getters kept so existing UI code keeps working ----
  String get name => title;
  int get students => studentsCount;

  /// Syllabus completed %. Not provided by the API yet → 0.
  int get progress => 0;

  double get totalFeeWithTax => totalFee + totalFee * totalTaxPercentage / 100;

  factory CourseItem.fromJson(Map<String, dynamic> json) => CourseItem(
        id: JsonParse.toInt(json['id']),
        title: JsonParse.toStr(json['title']).trim(),
        description: JsonParse.toStr(json['description']),
        isActive: JsonParse.toBool(json['is_active'], true),
        department: JsonParse.toInt(json['department']),
        departmentName: JsonParse.toStr(json['department_name']),
        faculties: JsonParse.toMapList(json['faculty_details'])
            .map(FacultyDetail.fromJson)
            .toList(),
        studentsCount: JsonParse.toInt(json['students_count']),
        totalFee: JsonParse.toDouble(json['total_fee']),
        installmentPlans: JsonParse.toMapList(json['installment_plans'])
            .map(InstallmentPlan.fromJson)
            .toList(),
        createdAt: JsonParse.toDate(json['created_at']),
        taxSettings: json['tax_settings'] == null
            ? null
            : JsonParse.toInt(json['tax_settings']),
        sgst: JsonParse.toDouble(json['sgst']),
        cgst: JsonParse.toDouble(json['cgst']),
        totalTaxPercentage: JsonParse.toDouble(json['total_tax_percentage']),
      );
}