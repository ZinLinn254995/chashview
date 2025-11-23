import '../../entities/title_entity.dart';
import '../../repositories/title_repository.dart';

class ListenTitlesUseCase {
  final TitleRepository repository;

  ListenTitlesUseCase(this.repository);

  Stream<List<TitleEntity>> call(String userId, String type) {
    return repository.listenTitles(userId, type);
  }
}
