
import '../../entities/title_entity.dart';
import '../../repositories/title_repository.dart';

class GetTitlesUseCase {
  final TitleRepository repository;

  GetTitlesUseCase(this.repository);

  Future<List<TitleEntity>> call({
    required String userId,
    required String type, // 'incomeTitles' or 'expenseTitles'
  }) async {
    return repository.getTitles(userId, type);
  }
}
