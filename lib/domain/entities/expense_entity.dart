class ExpenseEntity {
  final String id;
  final String titleId;
  final double amount;
  final String categoryId;
  final DateTime date;
  final DateTime createdAt;
  final bool isBookmarked;

  ExpenseEntity({
    required this.id,
    required this.titleId,
    required this.amount,
    required this.categoryId,
    required this.date,
    required this.createdAt,
    this.isBookmarked = false,
  });

  ExpenseEntity copyWith({
    String? id,
    String? titleId,
    double? amount,
    String? categoryId,
    DateTime? date,
    DateTime? createdAt,
    bool? isBookmarked,
  }) {
    return ExpenseEntity(
      id: id ?? this.id,
      titleId: titleId ?? this.titleId,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }
}
