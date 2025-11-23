class ExpenseEntity {
  final String id;
  final String titleId;
  final double amount;
  final DateTime date;
  final DateTime createdAt;

  ExpenseEntity({
    required this.id,
    required this.titleId,
    required this.amount,
    required this.date,
    required this.createdAt,
  });

  ExpenseEntity copyWith({
    String? id,
    String? titleId,
    double? amount,
    String? categoryId,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return ExpenseEntity(
      id: id ?? this.id,
      titleId: titleId ?? this.titleId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
