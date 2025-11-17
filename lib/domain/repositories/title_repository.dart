import '../entities/title_entity.dart';

abstract class TitleRepository {
  /// Create new title (incomeTitles or expenseTitles)
  Future<void> createTitle(String userId, String type, TitleEntity title);

  /// Get all titles (incomeTitles or expenseTitles)
  Future<List<TitleEntity>> getTitles(String userId, String type);

  /// Update title
  Future<void> updateTitle(String userId, String type, TitleEntity title);

  /// Delete title
  Future<void> deleteTitle(String userId, String type, String titleId);
}
