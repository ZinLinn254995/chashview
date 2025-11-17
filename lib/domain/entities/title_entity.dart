class TitleEntity {
  final String id;
  final String name;

  const TitleEntity({
    required this.id,
    required this.name,
  });

  TitleEntity copyWith({
    String? id,
    String? name,
  }) {
    return TitleEntity(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
}
