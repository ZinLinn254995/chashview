// domain/entities/title_entity.dart

class TitleEntity {
  final String id;
  final String name;
  final String categoryId; // 🔥 NEW: Title ကို Category နဲ့ ချိတ်ဆက်ရန်
  final bool bookmark;

  const TitleEntity({
    required this.id,
    required this.name,
    required this.categoryId, // Required
    this.bookmark = false,
  });

  TitleEntity copyWith({
    String? id,
    String? name,
    String? categoryId, // New in copyWith
    bool? bookmark,
  }) {
    return TitleEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      bookmark: bookmark ?? this.bookmark,
    );
  }
}