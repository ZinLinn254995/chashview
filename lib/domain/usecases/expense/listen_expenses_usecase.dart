import '../../entities/expense_entity.dart';
import '../../repositories/expense_repository.dart';

class ListenExpensesUseCase {
  final ExpenseRepository repository;

  ListenExpensesUseCase(this.repository);

  Stream<List<ExpenseEntity>> call(String userId) {
    return repository.listenExpenses(userId);
  }
}
