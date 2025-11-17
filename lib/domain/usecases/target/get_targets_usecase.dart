import '../../entities/target_entity.dart';
import '../../repositories/target_repository.dart';

class GetTargetsUseCase {
  final TargetRepository repository;

  GetTargetsUseCase(this.repository);

  Future<List<TargetEntity>> call(String userId) async {
    return repository.getTargets(userId);
  }
}
