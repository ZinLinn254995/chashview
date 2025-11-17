import '../../repositories/title_repository.dart';
import '../../entities/title_entity.dart';

class CreateTitleUseCase {
  final TitleRepository repository;

  CreateTitleUseCase(this.repository);

  Future<void> call({
    required String userId,
    required String type, // 'incomeTitles' or 'expenseTitles'
    required TitleEntity title,
  }) async {
    return repository.createTitle(userId, type, title);
  }
}
