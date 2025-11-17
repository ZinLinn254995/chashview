import '../../repositories/title_repository.dart';

class DeleteTitleUseCase {
  final TitleRepository repository;

  DeleteTitleUseCase(this.repository);

  Future<void> call({
    required String userId,
    required String type,      // ← change from categoryId
    required String titleId,
  }) async {
    return repository.deleteTitle(userId, type, titleId);
  }
}

