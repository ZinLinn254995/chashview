import '../../repositories/target_repository.dart';

class DeleteTargetUseCase {
  final TargetRepository repository;

  DeleteTargetUseCase(this.repository);

  Future<void> call(String userId, String targetId) async {
    return repository.deleteTarget(userId, targetId);
  }
}
