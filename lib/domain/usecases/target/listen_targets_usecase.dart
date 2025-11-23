import '../../entities/target_entity.dart';
import '../../repositories/target_repository.dart';

class ListenTargetsUseCase {
  final TargetRepository repository;

  ListenTargetsUseCase(this.repository);

  Stream<List<TargetEntity>> call(String userId) {
    return repository.listenTargets(userId);
  }
}
