import '../../entities/budget_entity.dart';
import '../../repositories/budget_repository.dart';

class CreateBudgetUseCase {
  final BudgetRepository repository;

  CreateBudgetUseCase(this.repository);

  Future<void> call(String userId, BudgetEntity budget) async {
    return repository.createBudget(userId, budget);
  }
}
