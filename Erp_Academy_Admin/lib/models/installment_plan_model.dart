import '../core/utils/json_parse.dart';

/// One installment inside a plan.
class InstallmentItem {
  final int? id;
  final int? planId;
  final int installmentNumber;
  final double amount;
  final int dueDays;

  const InstallmentItem({
    this.id,
    this.planId,
    required this.installmentNumber,
    required this.amount,
    required this.dueDays,
  });

  factory InstallmentItem.fromJson(Map<String, dynamic> json) =>
      InstallmentItem(
        id: json['id'] == null ? null : JsonParse.toInt(json['id']),
        planId: json['plan'] == null ? null : JsonParse.toInt(json['plan']),
        installmentNumber: JsonParse.toInt(json['installment_number']),
        amount: JsonParse.toDouble(json['amount']),
        dueDays: JsonParse.toInt(json['due_days']),
      );

  /// Body for POST (server generates id/plan).
  Map<String, dynamic> toJson() => {
        'installment_number': installmentNumber,
        'amount': amount % 1 == 0 ? amount.toInt() : amount,
        'due_days': dueDays,
      };
}

/// A payment plan, e.g. "3 installments".
class InstallmentPlan {
  final int? id;
  final int? courseId;
  final double courseTotalFee;
  final int totalInstallments;
  final bool isActive;
  final List<InstallmentItem> items;

  const InstallmentPlan({
    this.id,
    this.courseId,
    this.courseTotalFee = 0,
    required this.totalInstallments,
    this.isActive = true,
    required this.items,
  });

  double get itemsTotal => items.fold(0.0, (sum, i) => sum + i.amount);

  factory InstallmentPlan.fromJson(Map<String, dynamic> json) =>
      InstallmentPlan(
        id: json['id'] == null ? null : JsonParse.toInt(json['id']),
        courseId:
            json['course'] == null ? null : JsonParse.toInt(json['course']),
        courseTotalFee: JsonParse.toDouble(json['course_total_fee']),
        totalInstallments: JsonParse.toInt(json['total_installments']),
        isActive: JsonParse.toBool(json['is_active'], true),
        items: JsonParse.toMapList(json['items'])
            .map(InstallmentItem.fromJson)
            .toList()
          ..sort((a, b) => a.installmentNumber.compareTo(b.installmentNumber)),
      );

  /// Body for POST.
  Map<String, dynamic> toJson() => {
        'total_installments': totalInstallments,
        'is_active': isActive,
        'items': items.map((e) => e.toJson()).toList(),
      };
}