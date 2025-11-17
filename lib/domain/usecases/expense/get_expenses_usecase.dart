import '../../entities/expense_entity.dart';
import '../../repositories/expense_repository.dart';

class GetExpensesUseCase {
  final ExpenseRepository repository;
  GetExpensesUseCase(this.repository);

  Future<List<ExpenseEntity>> call(String userId) {
    return repository.getExpenses(userId);
  }
}
