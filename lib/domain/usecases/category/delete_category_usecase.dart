import '../../repositories/category_repository.dart';

class DeleteCategoryUseCase {
  final CategoryRepository repository;

  DeleteCategoryUseCase(this.repository);

  Future<void> call(String userId, String type, String categoryId) async {
    await repository.delete(userId, type, categoryId);
  }
}
