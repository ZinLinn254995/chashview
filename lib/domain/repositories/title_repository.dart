import '../entities/title_entity.dart';

abstract class TitleRepository {
  Future<void> createTitle(String userId, String type, TitleEntity title);
  Future<List<TitleEntity>> getTitles(String userId, String type);
  Future<void> updateTitle(String userId, String type, TitleEntity title);
  Future<void> deleteTitle(String userId, String type, String titleId);

  /// 🔥 Realtime
  Stream<List<TitleEntity>> listenTitles(String userId, String type);
}
