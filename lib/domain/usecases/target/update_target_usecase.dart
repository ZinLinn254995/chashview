import '../../entities/target_entity.dart';
import '../../repositories/target_repository.dart';

class UpdateTargetUseCase {
  final TargetRepository repository;

  UpdateTargetUseCase(this.repository);

  Future<void> call(String userId, TargetEntity target) async {
    return repository.updateTarget(userId, target);
  }
}
