import '../../entities/category_entity.dart';
import '../../repositories/category_repository.dart';

class CreateCategoryUseCase {
  final CategoryRepository repository;

  CreateCategoryUseCase(this.repository);

  Future<void> call(String userId, String type, CategoryEntity category) async {
    await repository.create(userId, type, category);
  }
}
