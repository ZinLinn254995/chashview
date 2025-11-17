

import '../../domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  CategoryModel({
    required super.id,
    required super.name,
    super.createdAt,
    super.updatedAt,
  });

  /// Create CategoryModel from Firebase JSON
  factory CategoryModel.fromJson(Map<String, dynamic> json, String id) {
    return CategoryModel(
      id: id,
      name: json['name'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  /// Convert CategoryModel to JSON for Firebase
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }
}
