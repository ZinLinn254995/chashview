import '../../domain/entities/budget_entity.dart';
import '../../domain/repositories/budget_repository.dart';
import '../datasources/budget_remote_data_source.dart';
import '../models/budget_model.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final BudgetRemoteDataSource remote;

  BudgetRepositoryImpl(this.remote);

  BudgetModel _toModel(BudgetEntity e) {
    return BudgetModel(
      id: e.id,
      categoryId: e.categoryId,
      limitAmount: e.limitAmount,
      month: e.month,
      createdAt: e.createdAt,
    );
  }

  @override
  Future<void> createBudget(String userId, BudgetEntity e) async {
    await remote.createBudget(userId, _toModel(e));
  }

  @override
  Future<List<BudgetEntity>> getBudgets(String userId) async {
    return remote.getBudgets(userId);
  }

  @override
  Future<void> updateBudget(String userId, BudgetEntity e) async {
    await remote.updateBudget(userId, _toModel(e));
  }

  @override
  Future<void> deleteBudget(String userId, String id) async {
    await remote.deleteBudget(userId, id);
  }

  /// 🔥 REALTIME
  @override
  Stream<List<BudgetEntity>> listenBudgets(String userId) {
    return remote.listenBudgets(userId).map<List<BudgetEntity>>((list) => list);
  }
}
