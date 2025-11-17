import '../../entities/expense_entity.dart';
import '../../repositories/expense_repository.dart';

class UpdateExpenseUseCase {
  final ExpenseRepository repository;
  UpdateExpenseUseCase(this.repository);

  Future<void> call(String userId, ExpenseEntity entity) {
    return repository.updateExpense(userId, entity);
  }
}
