import '../../domain/entities/expense_entity.dart';

class ExpenseModel extends ExpenseEntity {
  ExpenseModel({
    required super.id,
    required super.titleId,
    required super.amount,
    required super.date,
    required super.createdAt,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json, String id) {
    return ExpenseModel(
      id: id,
      titleId: json['titleId'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titleId': titleId,
      'amount': amount,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
