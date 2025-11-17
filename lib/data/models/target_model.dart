import '../../domain/entities/target_entity.dart';

class TargetModel extends TargetEntity {
  TargetModel({
    required super.id,
    required super.title,
    required super.goalAmount,
    required super.createdAt,
  });

  factory TargetModel.fromJson(Map<String, dynamic> json, String id) {
    return TargetModel(
      id: id,
      title: json['title'],
      goalAmount: (json['goalAmount'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'goalAmount': goalAmount,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
