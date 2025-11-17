class BudgetEntity {
  final String id;
  final double limitAmount;
  final String categoryId;
  final String month; // 2025-11
  final DateTime createdAt;

  BudgetEntity({
    required this.id,
    required this.limitAmount,
    required this.categoryId,
    required this.month,
    required this.createdAt,
  });

  BudgetEntity copyWith({
    String? id,
    double? limitAmount,
    String? categoryId,
    String? month,
    DateTime? createdAt,
  }) {
    return BudgetEntity(
      id: id ?? this.id,
      limitAmount: limitAmount ?? this.limitAmount,
      categoryId: categoryId ?? this.categoryId,
      month: month ?? this.month,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
