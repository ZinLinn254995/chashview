import '../entities/target_entity.dart';

abstract class TargetRepository {
  Future<void> createTarget(String userId, TargetEntity target);
  Future<List<TargetEntity>> getTargets(String userId);
  Future<void> updateTarget(String userId, TargetEntity target);
  Future<void> deleteTarget(String userId, String targetId);

  /// 🔥 Realtime stream
  Stream<List<TargetEntity>> listenTargets(String userId);
}
