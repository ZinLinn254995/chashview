import '../../entities/category_entity.dart';
import '../../repositories/category_repository.dart';

class UpdateCategoryUseCase {
  final CategoryRepository repository;

  UpdateCategoryUseCase(this.repository);

  Future<void> call(String userId, String type, CategoryEntity category) async {
    await repository.update(userId, type, category);
  }
}
