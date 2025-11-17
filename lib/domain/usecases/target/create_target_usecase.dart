import '../../entities/target_entity.dart';
import '../../repositories/target_repository.dart';

class CreateTargetUseCase {
  final TargetRepository repository;

  CreateTargetUseCase(this.repository);

  Future<void> call(String userId, TargetEntity target) async {
    return repository.createTarget(userId, target);
  }
}
