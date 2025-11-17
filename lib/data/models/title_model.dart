import '../../domain/entities/title_entity.dart';

class TitleModel extends TitleEntity {
  TitleModel({
    required super.id,
    required super.name,
  });

  factory TitleModel.fromJson(Map<String, dynamic> json, String id) {
    return TitleModel(
      id: id,
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}
