import '../../repositories/expense_repository.dart';

class DeleteExpenseUseCase {
  final ExpenseRepository repository;
  DeleteExpenseUseCase(this.repository);

  Future<void> call(String userId, String id) {
    return repository.deleteExpense(userId, id);
  }
}
