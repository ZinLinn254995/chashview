import '../../repositories/budget_repository.dart';

class DeleteBudgetUseCase {
  final BudgetRepository repository;

  DeleteBudgetUseCase(this.repository);

  Future<void> call(String userId, String budgetId) async {
    return repository.deleteBudget(userId, budgetId);
  }
}
