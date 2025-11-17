import '../../domain/entities/target_entity.dart';
import '../../domain/repositories/target_repository.dart';
import '../datasources/target_remote_data_source.dart';
import '../models/target_model.dart';

class TargetRepositoryImpl implements TargetRepository {
  final TargetRemoteDataSource remote;

  TargetRepositoryImpl(this.remote);

  @override
  Future<void> createTarget(String userId, TargetEntity target) async {
    final model = TargetModel(
      id: target.id,
      title: target.title,
      goalAmount: target.goalAmount,
      createdAt: target.createdAt,
    );
    return remote.createTarget(userId, model);
  }

  @override
  Future<List<TargetEntity>> getTargets(String userId) async {
    return remote.getTargets(userId);
  }

  @override
  Future<void> updateTarget(String userId, TargetEntity target) async {
    final model = TargetModel(
      id: target.id,
      title: target.title,
      goalAmount: target.goalAmount,
      createdAt: target.createdAt,
    );
    return remote.updateTarget(userId, model);
  }

  @override
  Future<void> deleteTarget(String userId, String id) async {
    return remote.deleteTarget(userId, id);
  }
}
