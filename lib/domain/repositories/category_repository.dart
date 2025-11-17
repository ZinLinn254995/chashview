import '../entities/category_entity.dart';

abstract class CategoryRepository {
  /// Create a new category
  Future<void> create(String userId, String type, CategoryEntity entity);

  /// Read all categories of a type
  Future<List<CategoryEntity>> read(String userId, String type);

  /// Update an existing category
  Future<void> update(String userId, String type, CategoryEntity entity);

  /// Delete a category by id
  Future<void> delete(String userId, String type, String id);

  /// Optional: listen to realtime changes
  Stream<List<CategoryEntity>> listen(String userId, String type);
}
