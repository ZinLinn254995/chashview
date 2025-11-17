import '../../domain/entities/expense_entity.dart';

class ExpenseModel extends ExpenseEntity {
  ExpenseModel({
    required super.id,
    required super.titleId,
    required super.amount,
    required super.categoryId,
    required super.date,
    required super.createdAt,
    required super.isBookmarked,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json, String id) {
    return ExpenseModel(
      id: id,
      titleId: json['titleId'] as String,
      amount: (json['amount'] as num).toDouble(),
      categoryId: json['categoryId'] as String,
      date: DateTime.parse(json['date'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isBookmarked: json['isBookmarked'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titleId': titleId,
      'amount': amount,
      'categoryId': categoryId,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'isBookmarked': isBookmarked,
    };
  }
}
