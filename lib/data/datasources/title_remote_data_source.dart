import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import '../../../core/services/firebase_service.dart';
import '../models/title_model.dart';
import '../../../core/constants/firebase_paths.dart';

class TitleRemoteDataSource {
  final FirebaseService firebaseService;

  TitleRemoteDataSource(this.firebaseService);

  /// Create new title
  Future<void> createTitle(String userId, String type, TitleModel title) async {
    final ref = firebaseService.ref('${FirebasePaths.user(userId)}/${type}Titles').push();
    await ref.set(title.toJson());
  }

  /// Get all titles
  Future<List<TitleModel>> getTitles(String userId, String type) async {
    final ref = firebaseService.ref('${FirebasePaths.user(userId)}/${type}Titles');
    final snapshot = await ref.get();
    if (!snapshot.exists) return [];

    return snapshot.children.map((data) {
      final json = Map<String, dynamic>.from(data.value as Map);
      return TitleModel.fromJson(json, data.key!);
    }).toList();
  }

  /// Update title
  Future<void> updateTitle(String userId, String type, TitleModel title) async {
    final ref = firebaseService.ref('${FirebasePaths.user(userId)}/${type}Titles/${title.id}');
    await ref.update(title.toJson());
  }

  /// Delete title
  Future<void> deleteTitle(String userId, String type, String titleId) async {
    final ref = firebaseService.ref('${FirebasePaths.user(userId)}/${type}Titles/$titleId');
    await ref.remove();
  }

  /// 🔥 Realtime stream
  Stream<List<TitleModel>> listenTitles(String userId, String type) {
    final ref = firebaseService.ref('${FirebasePaths.user(userId)}/${type}Titles');
    return ref.onValue.map((DatabaseEvent event) {
      final snap = event.snapshot;
      if (!snap.exists || snap.value == null) return <TitleModel>[];

      final list = <TitleModel>[];
      for (final child in snap.children) {
        if (child.value == null) continue;
        try {
          final json = Map<String, dynamic>.from(child.value as Map);
          list.add(TitleModel.fromJson(json, child.key!));
        } catch (_) {}
      }
      return list;
    });
  }
}
