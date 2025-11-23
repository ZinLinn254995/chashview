import '../entities/budget_entity.dart';

abstract class BudgetRepository {
  Future<void> createBudget(String userId, BudgetEntity budget);
  Future<List<BudgetEntity>> getBudgets(String userId);
  Future<void> updateBudget(String userId, BudgetEntity budget);
  Future<void> deleteBudget(String userId, String budgetId);

  /// 🔥 Realtime stream
  Stream<List<BudgetEntity>> listenBudgets(String userId);
}
