import '../../domain/entities/budget_entity.dart';
import '../../domain/repositories/budget_repository.dart';
import '../datasources/budget_remote_data_source.dart';
import '../models/budget_model.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final BudgetRemoteDataSource remote;

  BudgetRepositoryImpl(this.remote);

  @override
  Future<void> createBudget(String userId, BudgetEntity budget) async {
    final model = BudgetModel(
      id: budget.id,
      limitAmount: budget.limitAmount,
      categoryId: budget.categoryId,
      month: budget.month,
      createdAt: budget.createdAt,
    );
    return remote.createBudget(userId, model);
  }

  @override
  Future<List<BudgetEntity>> getBudgets(String userId) async {
    return remote.getBudgets(userId);
  }

  @override
  Future<void> updateBudget(String userId, BudgetEntity budget) async {
    final model = BudgetModel(
      id: budget.id,
      limitAmount: budget.limitAmount,
      categoryId: budget.categoryId,
      month: budget.month,
      createdAt: budget.createdAt,
    );
    return remote.updateBudget(userId, model);
  }

  @override
  Future<void> deleteBudget(String userId, String id) async {
    return remote.deleteBudget(userId, id);
  }
}
