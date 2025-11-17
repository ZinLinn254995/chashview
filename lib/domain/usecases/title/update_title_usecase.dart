import '../../entities/title_entity.dart';
import '../../repositories/title_repository.dart';

class UpdateTitleUseCase {
  final TitleRepository repository;

  UpdateTitleUseCase(this.repository);

  Future<void> call({
    required String userId,
    required String type, // 'incomeTitles' or 'expenseTitles'
    required TitleEntity title,
  }) async {
    return repository.updateTitle(userId, type, title);
  }
}
