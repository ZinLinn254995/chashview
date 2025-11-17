import '../../core/constants/firebase_paths.dart';
import '../../core/services/firebase_service.dart';
import '../models/budget_model.dart';

class BudgetRemoteDataSource {
  final FirebaseService service;

  BudgetRemoteDataSource(this.service);

  Future<void> createBudget(String userId, BudgetModel model) async {
    final path = FirebasePaths.budget(userId);
    await service.ref(path).child(model.id).set(model.toJson());
  }

  Future<List<BudgetModel>> getBudgets(String userId) async {
    final snap = await service.getData(FirebasePaths.budget(userId));

    if (!snap.exists) return [];

    return snap.children.map((e) {
      return BudgetModel.fromJson(
        Map<String, dynamic>.from(e.value as Map),
        e.key!,
      );
    }).toList();
  }

  Future<void> updateBudget(String userId, BudgetModel model) async {
    await service.ref(FirebasePaths.budget(userId))
        .child(model.id)
        .update(model.toJson());
  }

  Future<void> deleteBudget(String userId, String id) async {
    await service.ref(FirebasePaths.budget(userId)).child(id).remove();
  }
}
