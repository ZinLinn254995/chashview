import '../../entities/expense_entity.dart';
import '../../repositories/expense_repository.dart';

class CreateExpenseUseCase {
  final ExpenseRepository repository;
  CreateExpenseUseCase(this.repository);

  Future<void> call(String userId, ExpenseEntity entity) {
    return repository.createExpense(userId, entity);
  }
}
