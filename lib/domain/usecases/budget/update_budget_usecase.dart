import '../../entities/budget_entity.dart';
import '../../repositories/budget_repository.dart';

class UpdateBudgetUseCase {
  final BudgetRepository repository;

  UpdateBudgetUseCase(this.repository);

  Future<void> call(String userId, BudgetEntity budget) async {
    return repository.updateBudget(userId, budget);
  }
}
