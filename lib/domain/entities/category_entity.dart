class CategoryEntity {
  final String id;        // Firebase key (or generated UUID)
  final String name;      // Category name
  final DateTime? createdAt;  // Optional creation timestamp
  final DateTime? updatedAt;  // Optional update timestamp

  CategoryEntity({
    required this.id,
    required this.name,
    this.createdAt,
    this.updatedAt,
  });

  // CopyWith method for immutability convenience
  CategoryEntity copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
