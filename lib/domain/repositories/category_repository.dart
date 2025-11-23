import '../entities/category_entity.dart';

abstract class CategoryRepository {
  Future<void> create(String userId, String type, CategoryEntity entity);
  Future<List<CategoryEntity>> read(String userId, String type);
  Future<void> update(String userId, String type, CategoryEntity entity);
  Future<void> delete(String userId, String type, String id);

  /// 🔥 Realtime stream
  Stream<List<CategoryEntity>> listen(String userId, String type);
}
