import '../../domain/entities/income_entity.dart';

class IncomeModel extends IncomeEntity {
  IncomeModel({
    required super.id,
    required super.titleId,
    required super.amount,
    required super.categoryId,
    required super.date,
    required super.createdAt,
    required super.isBookmarked,
  });

  factory IncomeModel.fromJson(Map<String, dynamic> json, String id) {
    return IncomeModel(
      id: id,
      titleId: json['titleId'] as String,
      amount: (json['amount'] as num).toDouble(),
      categoryId: json['categoryId'] as String,
      date: DateTime.parse(json['date'] as String),        // <-- convert to DateTime
      createdAt: DateTime.parse(json['createdAt'] as String), // <-- convert to DateTime
      isBookmarked: json['isBookmarked'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titleId': titleId,
      'amount': amount,
      'categoryId': categoryId,
      'date': date.toIso8601String(),         // <-- convert DateTime to String
      'createdAt': createdAt.toIso8601String(), // <-- convert DateTime to String
      'isBookmarked': isBookmarked,
    };
  }
}
