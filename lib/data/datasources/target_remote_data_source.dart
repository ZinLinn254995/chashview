import '../../core/constants/firebase_paths.dart';
import '../../core/services/firebase_service.dart';
import '../models/target_model.dart';

class TargetRemoteDataSource {
  final FirebaseService service;

  TargetRemoteDataSource(this.service);

  Future<void> createTarget(String userId, TargetModel model) async {
    final path = FirebasePaths.target(userId);
    await service.ref(path).child(model.id).set(model.toJson());
  }

  Future<List<TargetModel>> getTargets(String userId) async {
    final snap = await service.getData(FirebasePaths.target(userId));

    if (!snap.exists) return [];

    return snap.children.map((e) {
      return TargetModel.fromJson(
        Map<String, dynamic>.from(e.value as Map),
        e.key!,
      );
    }).toList();
  }

  Future<void> updateTarget(String userId, TargetModel model) async {
    await service.ref(FirebasePaths.target(userId))
        .child(model.id)
        .update(model.toJson());
  }

  Future<void> deleteTarget(String userId, String id) async {
    await service.ref(FirebasePaths.target(userId)).child(id).remove();
  }
}
