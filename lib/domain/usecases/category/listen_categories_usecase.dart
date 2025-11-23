import '../../entities/category_entity.dart';
import '../../repositories/category_repository.dart';

class ListenCategoriesUseCase {
  final CategoryRepository repository;

  ListenCategoriesUseCase(this.repository);

  Stream<List<CategoryEntity>> call(String userId, String type) {
    return repository.listen(userId, type);
  }
}
