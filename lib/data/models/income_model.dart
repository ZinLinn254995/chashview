import '../../domain/entities/income_entity.dart';

class IncomeModel extends IncomeEntity {
  IncomeModel({
    required super.id,
    required super.titleId,
    required super.amount,
    required super.date,
    required super.createdAt,
  });

  factory IncomeModel.fromJson(Map<String, dynamic> json, String id) {
    return IncomeModel(
      id: id,
      titleId: json['titleId'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),        // <-- convert to DateTime
      createdAt: DateTime.parse(json['createdAt'] as String), // <-- convert to DateTime
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titleId': titleId,
      'amount': amount,
      'date': date.toIso8601String(),         // <-- convert DateTime to String
      'createdAt': createdAt.toIso8601String(), // <-- convert DateTime to String
    };
  }
}
