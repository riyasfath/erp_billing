import 'installment_plan_model.dart';

class CreateCourseRequest {
  final String title;
  final String description;
  final int department;
  final double totalFee;
  final int taxSettings;
  final List<int> faculties;
  final List<InstallmentPlan> installmentPlans;

  const CreateCourseRequest({
    required this.title,
    required this.description,
    required this.department,
    required this.totalFee,
    required this.taxSettings,
    this.faculties = const [],
    this.installmentPlans = const [],
  });

  /// Returns an error message, or null if the request is valid.
  String? validate() {
    if (title.trim().isEmpty) return 'Course title is required';
    if (department <= 0) return 'Select a department';
    if (totalFee < 0) return 'Total fee cannot be negative';
    if (taxSettings <= 0) return 'Select tax settings';

    final seenCounts = <int>{};
    for (final plan in installmentPlans) {
      final n = plan.totalInstallments;
      if (n < 1) return 'Installment count must be at least 1';
      if (!seenCounts.add(n)) return 'Duplicate $n-installment plan';
      if (plan.items.length != n) {
        return '$n-installment plan must have exactly $n items';
      }
      for (var i = 0; i < plan.items.length; i++) {
        final item = plan.items[i];
        if (item.installmentNumber != i + 1) {
          return '$n-installment plan: numbers must be 1 to $n in order';
        }
        if (item.amount < 0) return '$n-installment plan: amount cannot be negative';
        if (item.dueDays < 0) return '$n-installment plan: due days cannot be negative';
      }
      if ((plan.itemsTotal - totalFee).abs() > 0.01) {
        return '$n-installment plan total (${plan.itemsTotal.toStringAsFixed(0)}) '
            'must equal course fee (${totalFee.toStringAsFixed(0)})';
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
        'title': title.trim(),
        'description': description.trim(),
        'department': department,
        'total_fee': totalFee % 1 == 0 ? totalFee.toInt() : totalFee,
        'tax_settings': taxSettings,
        if (faculties.isNotEmpty) 'faculties': faculties,
        'installment_plans': installmentPlans.map((p) => p.toJson()).toList(),
      };
}