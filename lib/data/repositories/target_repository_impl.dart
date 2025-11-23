import '../../domain/entities/target_entity.dart';
import '../../domain/repositories/target_repository.dart';
import '../datasources/target_remote_data_source.dart';
import '../models/target_model.dart';

class TargetRepositoryImpl implements TargetRepository {
  final TargetRemoteDataSource remote;

  TargetRepositoryImpl(this.remote);

  TargetModel _toModel(TargetEntity e) {
    return TargetModel(
      id: e.id,
      title: e.title,
      goalAmount: e.goalAmount,
      createdAt: e.createdAt,
    );
  }

  @override
  Future<void> createTarget(String userId, TargetEntity e) async {
    await remote.createTarget(userId, _toModel(e));
  }

  @override
  Future<List<TargetEntity>> getTargets(String userId) async {
    return remote.getTargets(userId);
  }

  @override
  Future<void> updateTarget(String userId, TargetEntity e) async {
    await remote.updateTarget(userId, _toModel(e));
  }

  @override
  Future<void> deleteTarget(String userId, String id) async {
    await remote.deleteTarget(userId, id);
  }

  /// 🔥 Realtime
  @override
  Stream<List<TargetEntity>> listenTargets(String userId) {
    return remote.listenTargets(userId).map<List<TargetEntity>>((list) => list);
  }
}
