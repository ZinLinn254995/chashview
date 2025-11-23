// data/models/title_model.dart

import '../../domain/entities/title_entity.dart';

class TitleModel extends TitleEntity {
  TitleModel({
    required super.id,
    required super.name,
    required super.categoryId,
    required super.bookmark,
  });

  factory TitleModel.fromJson(Map<String, dynamic> json, String id) {
    return TitleModel(
      id: id,
      name: json['name'] ?? '',
      categoryId: json['categoryId'] ?? '', // 🔥 Read categoryId
      bookmark: json['bookmark'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'categoryId': categoryId, // 🔥 Write categoryId
      'bookmark': bookmark,
    };
  }
}