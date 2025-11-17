import '../../domain/entities/budget_entity.dart';

class BudgetModel extends BudgetEntity {
  BudgetModel({
    required super.id,
    required super.limitAmount,
    required super.categoryId,
    required super.month,
    required super.createdAt,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json, String id) {
    return BudgetModel(
      id: id,
      limitAmount: (json['limitAmount'] as num).toDouble(),
      categoryId: json['categoryId'] as String,
      month: json['month'] as String,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'limitAmount': limitAmount,
      'categoryId': categoryId,
      'month': month,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
