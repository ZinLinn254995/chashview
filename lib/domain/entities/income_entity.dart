class IncomeEntity {
  final String id;
  final String titleId;
  final double amount;
  final DateTime date;
  final DateTime createdAt;

  IncomeEntity({
    required this.id,
    required this.titleId,
    required this.amount,
    required this.date,
    required this.createdAt,
  });

  IncomeEntity copyWith({
    String? id,
    String? titleId,
    double? amount,
    String? categoryId,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return IncomeEntity(
      id: id ?? this.id,
      titleId: titleId ?? this.titleId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
