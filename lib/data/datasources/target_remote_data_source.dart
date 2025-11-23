import 'dart:async';
import '../../core/constants/firebase_paths.dart';
import '../../core/services/firebase_service.dart';
import '../models/target_model.dart';
import 'package:firebase_database/firebase_database.dart';

class TargetRemoteDataSource {
  final FirebaseService service;

  TargetRemoteDataSource(this.service);

  Future<void> createTarget(String userId, TargetModel model) async {
    final path = FirebasePaths.target(userId);
    await service.ref(path).child(model.id).set(model.toJson());
  }

  Future<List<TargetModel>> getTargets(String userId) async {
    final snap = await service.getData(FirebasePaths.target(userId));

    if (!snap.exists || snap.value == null) return [];

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

  /// 🔥 REALTIME LISTEN
  Stream<List<TargetModel>> listenTargets(String userId) {
    final path = FirebasePaths.target(userId);

    return service.listenToPath(path).map((DatabaseEvent event) {
      final snap = event.snapshot;

      if (!snap.exists) return <TargetModel>[];

      final list = <TargetModel>[];

      for (final child in snap.children) {
        if (child.value == null) continue;

        try {
          final json = Map<String, dynamic>.from(child.value as Map);
          list.add(TargetModel.fromJson(json, child.key!));
        } catch (_) {}
      }

      return list;
    });
  }
}
