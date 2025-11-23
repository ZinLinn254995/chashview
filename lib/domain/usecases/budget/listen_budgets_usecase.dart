import '../../entities/budget_entity.dart';
import '../../repositories/budget_repository.dart';

class ListenBudgetsUseCase {
  final BudgetRepository repository;

  ListenBudgetsUseCase(this.repository);

  Stream<List<BudgetEntity>> call(String userId) {
    return repository.listenBudgets(userId);
  }
}
