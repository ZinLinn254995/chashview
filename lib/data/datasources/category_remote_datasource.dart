import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import '../../core/constants/firebase_paths.dart';
import '../../core/services/firebase_service.dart';
import '../models/category_model.dart';

class CategoryRemoteDataSource {
  final FirebaseService service;

  CategoryRemoteDataSource(this.service);

  Future<void> createCategory(String userId, String type, CategoryModel model) async {
    // await service.ref('users/$userId/categories/$type/${model.id}').set(model.toJson());
    await service.ref(FirebasePaths.category(userId, type, model.id)).set(model.toJson());
  }

  Future<List<CategoryModel>> getCategories(String userId, String type) async {
    // final snap = await service.getData('users/$userId/categories/$type');
    final snap = await service.getData(FirebasePaths.categoriesByType(userId, type));

    if (!snap.exists || snap.value == null) return [];

    final list = <CategoryModel>[];
    for (final child in snap.children) {
      if (child.value == null) continue;
      final json = Map<String, dynamic>.from(child.value as Map);
      list.add(CategoryModel.fromJson(json, child.key!));
    }
    return list;
  }

  Future<void> updateCategory(String userId, String type, CategoryModel model) async {
    // await service.ref('users/$userId/categories/$type/${model.id}').update(model.toJson());
    await service.ref(FirebasePaths.category(userId, type, model.id)).update(model.toJson());
  }

  Future<void> deleteCategory(String userId, String type, String id) async {
    // await service.ref('users/$userId/categories/$type/$id').remove();
    await service.ref(FirebasePaths.category(userId, type, id)).remove();
  }

  /// 🔥 Realtime stream
  Stream<List<CategoryModel>> listenToCategories(String userId, String type) {
    // final ref = service.ref('users/$userId/categories/$type');
    final ref = service.ref(FirebasePaths.categoriesByType(userId, type));

    return ref.onValue.map((DatabaseEvent event) {
      final snap = event.snapshot;
      if (!snap.exists || snap.value == null) return <CategoryModel>[];

      final list = <CategoryModel>[];
      for (final child in snap.children) {
        if (child.value == null) continue;
        try {
          final json = Map<String, dynamic>.from(child.value as Map);
          list.add(CategoryModel.fromJson(json, child.key!));
        } catch (_) {}
      }
      return list;
    });
  }
}
