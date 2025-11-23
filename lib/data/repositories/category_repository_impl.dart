import '../../../domain/entities/category_entity.dart';
import '../../../domain/repositories/category_repository.dart';
import '../datasources/category_remote_datasource.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource remoteDataSource;

  CategoryRepositoryImpl(this.remoteDataSource);

  CategoryModel _toModel(CategoryEntity e) {
    return CategoryModel(
      id: e.id,
      name: e.name,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
    );
  }

  @override
  Future<void> create(String userId, String type, CategoryEntity entity) async {
    await remoteDataSource.createCategory(userId, type, _toModel(entity));
  }

  @override
  Future<List<CategoryEntity>> read(String userId, String type) async {
    final models = await remoteDataSource.getCategories(userId, type);
    return models.map((e) => CategoryEntity(
      id: e.id,
      name: e.name,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
    )).toList();
  }

  @override
  Future<void> update(String userId, String type, CategoryEntity entity) async {
    await remoteDataSource.updateCategory(userId, type, _toModel(entity));
  }

  @override
  Future<void> delete(String userId, String type, String id) async {
    await remoteDataSource.deleteCategory(userId, type, id);
  }

  /// 🔥 Realtime
  @override
  Stream<List<CategoryEntity>> listen(String userId, String type) {
    return remoteDataSource.listenToCategories(userId, type).map((models) {
      return models.map((e) => CategoryEntity(
        id: e.id,
        name: e.name,
        createdAt: e.createdAt,
        updatedAt: e.updatedAt,
      )).toList();
    });
  }
}
