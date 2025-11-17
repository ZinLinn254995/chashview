class TargetEntity {
  final String id;
  final String title;
  final double goalAmount;
  final DateTime createdAt;

  TargetEntity({
    required this.id,
    required this.title,
    required this.goalAmount,
    required this.createdAt,
  });

  TargetEntity copyWith({
    String? id,
    String? title,
    double? goalAmount,
    DateTime? createdAt,
  }) {
    return TargetEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      goalAmount: goalAmount ?? this.goalAmount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
